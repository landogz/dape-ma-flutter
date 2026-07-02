import '../../core/models/bible_models.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class BibleService {
  BibleService._();

  static Future<List<BibleBook>> fetchBooks({String locale = 'en'}) async {
    final res = await ApiClient().get<Map<String, dynamic>>(
      Endpoints.bibleBooks,
      query: <String, dynamic>{'locale': locale},
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is! List) return const [];

    return data
        .whereType<Map<String, dynamic>>()
        .map(BibleBook.fromJson)
        .toList();
  }

  static Future<BiblePassage> fetchPassage({
    required String book,
    required int chapter,
    required String locale,
    int? verseStart,
    int? verseEnd,
  }) async {
    final res = await ApiClient().get<Map<String, dynamic>>(
      Endpoints.biblePassage,
      query: <String, dynamic>{
        'book': book,
        'chapter': chapter,
        'locale': locale,
        if (verseStart != null) 'verse_start': verseStart,
        if (verseEnd != null) 'verse_end': verseEnd,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return BiblePassage.fromJson(data);
  }
}
