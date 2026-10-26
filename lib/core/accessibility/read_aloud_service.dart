import 'natural_tts/natural_tts_service.dart';

/// Post listen button and other read-aloud callers use the shared neural TTS.
class ReadAloudService {
  ReadAloudService._();

  static NaturalTtsService get instance => NaturalTtsService.instance;
}
