import '../../core/auth/auth_service.dart';
import '../../core/models/diary_entry.dart';
import '../../core/network/endpoints.dart';

class DiaryService {
  DiaryService._();

  static Future<List<DiaryEntry>> fetchEntries() async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.diaryEntries,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    final list = data is Map<String, dynamic>
        ? data['data'] as List<dynamic>? ?? const []
        : data is List<dynamic>
            ? data
            : const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map(DiaryEntry.fromJson)
        .toList();
  }

  static Future<DiaryEntry?> fetchToday() async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.diaryToday,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is! Map<String, dynamic>) return null;
    return DiaryEntry.fromJson(data);
  }

  static Future<DiaryEntry> create({
    required String entryDate,
    String? title,
    required String bodyHtml,
  }) async {
    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.diaryEntries,
      data: <String, dynamic>{
        'entry_date': entryDate,
        if (title != null && title.isNotEmpty) 'title': title,
        'body_html': bodyHtml,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DiaryEntry.fromJson(data);
  }

  static Future<DiaryEntry> update({
    required int id,
    String? title,
    required String bodyHtml,
  }) async {
    final res = await AuthService.authedPut<Map<String, dynamic>>(
      Endpoints.diaryEntry(id),
      data: <String, dynamic>{
        if (title != null) 'title': title,
        'body_html': bodyHtml,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return DiaryEntry.fromJson(data);
  }

  static Future<void> delete(int id) async {
    await AuthService.authedDelete<Map<String, dynamic>>(
      Endpoints.diaryEntry(id),
    );
  }
}
