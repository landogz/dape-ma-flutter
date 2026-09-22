import 'package:flutter_tts/flutter_tts.dart';

class ReadAloudService {
  ReadAloudService._();

  static final ReadAloudService instance = ReadAloudService._();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;
  bool _speaking = false;

  bool get isSpeaking => _speaking;

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => _speaking = false);
    _tts.setCancelHandler(() => _speaking = false);
    _ready = true;
  }

  Future<void> speak(String rawText) async {
    final text = _plainText(rawText);
    if (text.isEmpty) return;
    await _ensureReady();
    await stop();
    _speaking = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    if (!_speaking && !_ready) return;
    await _tts.stop();
    _speaking = false;
  }

  String _plainText(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
