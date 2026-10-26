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
      if (!_speaking) return;
      _speaking = false;
      notifyListeners();
    });
  }

  static final NaturalTtsService instance = NaturalTtsService._();

  static const _englishVoice = 'en-US-JennyNeural';
  static const _filipinoVoice = 'fil-PH-BlessicaNeural';

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _deviceTts = FlutterTts();

  bool _deviceReady = false;
  bool _speaking = false;
  int _generation = 0;

  bool get isSpeaking => _speaking;

  String get _neuralVoice =>
      LocaleController.instance.locale == AppLocale.tl
          ? _filipinoVoice
          : _englishVoice;

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
    _generation++;
    await _halt(notify: true);
  }

  Future<void> _speakNeural(String text, int gen) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/dape-natural-tts-$gen.mp3');
    final timeout = Duration(
      seconds: (12 + text.length ~/ 80).clamp(20, 90),
    );

    await Communicate(
      text: text,
      voice: _neuralVoice,
      rate: '-8%',
    ).save(file.path).timeout(timeout);

    if (gen != _generation) {
      if (await file.exists()) await file.delete();
      return;
    }

    await _player.stop();
    await _player.play(
      DeviceFileSource(file.path, mimeType: 'audio/mpeg'),
    );
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
    await _deviceTts.setSpeechRate(0.45);
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
        var score = 0;
        if (locale == language) score += 4;
        if (quality.contains('premium') ||
            quality.contains('enhanced') ||
            quality.contains('neural')) {
          score += 6;
        }
        final lowerName = name.toLowerCase();
        if (lowerName.contains('premium') ||
            lowerName.contains('enhanced') ||
            lowerName.contains('neural') ||
            lowerName.contains('siri')) {
          score += 5;
        }
        if (lowerName.contains('compact')) score -= 3;
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
