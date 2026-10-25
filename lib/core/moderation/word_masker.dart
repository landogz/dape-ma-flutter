import 'blocked_word_catalog.dart';

class WordMasker {
  static const maskToken = '****';

  static String mask(String? text) {
    final source = text ?? '';
    if (source.isEmpty) {
      return '';
    }

    final words = BlockedWordCatalog.instance.words;
    if (words.isEmpty) {
      return source;
    }

    final escaped = words.map(RegExp.escape).join('|');
    final pattern = RegExp(
      '(?<![\\p{L}\\p{N}_])(?:$escaped)(?![\\p{L}\\p{N}_])',
      caseSensitive: false,
      unicode: true,
    );
    return source.replaceAll(pattern, maskToken);
  }
}
