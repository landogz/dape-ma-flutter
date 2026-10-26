import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:edge_tts/edge_tts.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/app_locale.dart';
import '../../l10n/locale_controller.dart';

/// Neural read-aloud via Microsoft Edge voices, with on-device TTS fallback.
class NaturalTtsService extends ChangeNotifier {
  NaturalTtsService._() {
    _player.onPlayerComplete.listen((_) {
      _playNextQueuedClip();
    });
  }

  static final NaturalTtsService instance = NaturalTtsService._();

  static const _englishVoices = [
    'en-US-AriaNeural',
    'en-US-AvaMultilingualNeural',
  ];
  static const _filipinoVoices = [
    'fil-PH-BlessicaNeural',
    'fil-PH-AngeloNeural',
  ];
  static const _noveltyVoiceHints = [
    'zarvox',
    'trinoids',
    'bells',
    'cellos',
    'whisper',
    'boing',
    'bubbles',
    'bad news',
    'good news',
    'superstar',
    'organ',
    'ralph',
    'junior',
    'albert',
    'bahh',
    'wobble',
    'hysterical',
    'novelty',
  ];

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _deviceTts = FlutterTts();

  bool _deviceReady = false;
  bool _speaking = false;
  int _generation = 0;
  List<String> _parts = [];
  int _partIndex = 0;
  String _voice = _englishVoices.first;
  Future<File?>? _nextClip;

  bool get isSpeaking => _speaking;

  List<String> get _neuralVoices =>
      LocaleController.instance.locale == AppLocale.tl
          ? _filipinoVoices
          : _englishVoices;

  String get _deviceLanguage =>
      LocaleController.instance.locale == AppLocale.tl ? 'fil-PH' : 'en-US';

  Future<void> speak(String rawText) async {
    final text = _plainText(rawText);
    if (text.isEmpty) return;

    final gen = ++_generation;
    await _halt(notify: false);
    _speaking = true;
    notifyListeners();

    try {
      await _speakNeural(text, gen);
    } catch (_) {
      if (gen != _generation) return;
      try {
        await _speakDevice(text, gen);
      } catch (_) {
        if (gen != _generation) return;
        _speaking = false;
        notifyListeners();
      }
    }
  }

  Future<void> stop() async {
    _speaking = false;
    _generation++;
    await _halt(notify: true);
  }

  Future<void> _speakNeural(String text, int gen) async {
    _parts = _splitUtterances(text);
    _partIndex = 0;
    _voice = _neuralVoices.first;
    if (_parts.isEmpty) {
      throw StateError('No speech text');
    }

    final first = await _synthPart(_parts.first, gen, firstClip: true);
    if (gen != _generation) return;

    if (_parts.length > 1) {
      _nextClip = _synthPart(_parts[1], gen);
    }

    await _player.stop();
    await _player.play(
      DeviceFileSource(first.path, mimeType: 'audio/mpeg'),
    );
  }

  Future<void> _playNextQueuedClip() async {
    final gen = _generation;
    if (!_speaking || gen != _generation) return;

    _partIndex++;
    if (_partIndex >= _parts.length) {
      _speaking = false;
      notifyListeners();
      return;
    }

    try {
      var file = await _nextClip;
      if (gen != _generation) return;
      file ??= await _synthPart(_parts[_partIndex], gen);
      if (gen != _generation) return;

      _nextClip = _partIndex + 1 < _parts.length
          ? _synthPart(_parts[_partIndex + 1], gen)
          : null;

      await _player.play(
        DeviceFileSource(file.path, mimeType: 'audio/mpeg'),
      );
    } catch (_) {
      if (gen != _generation) return;
      final rest = _parts.sublist(_partIndex).join(' ');
      try {
        await _speakDevice(rest, gen);
      } catch (_) {
        _speaking = false;
        notifyListeners();
      }
    }
  }

  Future<File> _synthPart(
    String text,
    int gen, {
    bool firstClip = false,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dape-tts-$gen-${text.hashCode}.mp3');
    final timeout = Duration(seconds: firstClip ? 8 : 12);

    Object? lastError;
    final voices = firstClip ? <String>[_voice] : _neuralVoices;
    for (final voice in voices) {
      try {
        await Communicate(
          text: text,
          voice: voice,
          rate: '+0%',
          pitch: '+0Hz',
        ).save(file.path).timeout(timeout);
        if (firstClip) _voice = voice;
        return file;
      } catch (error) {
        lastError = error;
      }
    }
    throw lastError ?? Exception('Neural TTS failed');
  }

  List<String> _splitUtterances(String text) {
    final sentences = text
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();
    if (sentences.isEmpty) return [text];

    final parts = <String>[];
    var maxLen = 140;
    final buf = StringBuffer();

    void flush() {
      final chunk = buf.toString().trim();
      if (chunk.isNotEmpty) parts.add(chunk);
      buf.clear();
      maxLen = 240;
    }

    for (final sentence in sentences) {
      if (sentence.length > maxLen) {
        flush();
        parts.addAll(_splitLong(sentence, maxLen));
        maxLen = 240;
        continue;
      }
      if (buf.isEmpty) {
        buf.write(sentence);
        continue;
      }
      if (buf.length + sentence.length + 1 <= maxLen) {
        buf.write(' ');
        buf.write(sentence);
      } else {
        flush();
        buf.write(sentence);
      }
    }
    flush();
    return parts;
  }

  List<String> _splitLong(String text, int maxLen) {
    final words = text.split(RegExp(r'\s+'));
    final parts = <String>[];
    final buf = StringBuffer();
    for (final word in words) {
      if (word.isEmpty) continue;
      if (buf.isEmpty) {
        buf.write(word);
        continue;
      }
      if (buf.length + word.length + 1 <= maxLen) {
        buf.write(' ');
        buf.write(word);
      } else {
        parts.add(buf.toString());
        buf
          ..clear()
          ..write(word);
      }
    }
    if (buf.isNotEmpty) parts.add(buf.toString());
    return parts;
  }

  Future<void> _speakDevice(String text, int gen) async {
    await _ensureDeviceReady();
    if (gen != _generation) return;
    await _deviceTts.setLanguage(_deviceLanguage);
    await _preferNaturalDeviceVoice();
    if (gen != _generation) return;
    await _deviceTts.speak(text);
  }

  Future<void> _ensureDeviceReady() async {
    if (_deviceReady) return;

    await _deviceTts.setSharedInstance(true);
    await _deviceTts.setVolume(1.0);
    await _deviceTts.setPitch(1.0);
    await _deviceTts.setSpeechRate(0.5);
    await _deviceTts.setLanguage(_deviceLanguage);
    await _preferNaturalDeviceVoice();

    _deviceTts.setCompletionHandler(() {
      _speaking = false;
      notifyListeners();
    });
    _deviceTts.setCancelHandler(() {
      _speaking = false;
      notifyListeners();
    });
    _deviceTts.setErrorHandler((_) {
      _speaking = false;
      notifyListeners();
    });
    _deviceReady = true;
  }

  Future<void> _preferNaturalDeviceVoice() async {
    try {
      final raw = await _deviceTts.getVoices;
      if (raw is! List) return;

      final language = _deviceLanguage.toLowerCase();
      final languagePrefix = language.split('-').first;
      Map<String, dynamic>? best;
      var bestScore = -1;

      for (final item in raw) {
        if (item is! Map) continue;
        final voice = item.map((key, value) => MapEntry('$key', value));
        final locale = '${voice['locale'] ?? ''}'.toLowerCase();
        if (locale != language && !locale.startsWith(languagePrefix)) {
          continue;
        }

        final name = '${voice['name'] ?? ''} ${voice['identifier'] ?? ''}';
        final quality = '${voice['quality'] ?? ''}'.toLowerCase();
        final lowerName = name.toLowerCase();
        if (_noveltyVoiceHints.any(lowerName.contains) ||
            _noveltyVoiceHints.any(quality.contains)) {
          continue;
        }
        var score = 0;
        if (locale == language) score += 4;
        if (quality.contains('premium') ||
            quality.contains('enhanced') ||
            quality.contains('neural')) {
          score += 6;
        }
        if (lowerName.contains('premium') ||
            lowerName.contains('enhanced') ||
            lowerName.contains('neural') ||
            lowerName.contains('samantha') ||
            lowerName.contains('aria') ||
            lowerName.contains('ava')) {
          score += 5;
        }
        if (lowerName.contains('compact') || lowerName.contains('siri')) {
          score -= 3;
        }
        if (score > bestScore) {
          bestScore = score;
          best = voice.map((key, value) => MapEntry(key, value.toString()));
        }
      }

      if (best == null) return;
      await _deviceTts.setVoice({
        'name': best['name'] ?? '',
        'locale': best['locale'] ?? _deviceLanguage,
      });
    } catch (_) {}
  }

  Future<void> _halt({required bool notify}) async {
    _parts = [];
    _partIndex = 0;
    _nextClip = null;
    try {
      await _player.stop();
    } catch (_) {}
    try {
      await _deviceTts.stop();
    } catch (_) {}
    _speaking = false;
    if (notify) notifyListeners();
  }

  String _plainText(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
