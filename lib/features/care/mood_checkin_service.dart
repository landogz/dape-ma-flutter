import '../../core/auth/auth_service.dart';
import '../../core/models/mood_checkin.dart';
import '../../core/network/endpoints.dart';

class MoodCheckinService {
  MoodCheckinService._();

  static Future<List<MoodCheckin>> fetchList({int perPage = 30}) async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.moodCheckins,
      query: {'per_page': perPage},
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
        .map(MoodCheckin.fromJson)
        .toList();
  }

  static Future<MoodCheckin?> fetchToday() async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.moodCheckinsToday,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is! Map<String, dynamic>) return null;
    return MoodCheckin.fromJson(data);
  }

  static Future<MoodCheckin> create({
    required String mood,
    String source = 'care_hub',
    int? score,
    String? note,
  }) async {
    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.moodCheckins,
      data: <String, dynamic>{
        'mood': mood,
        'source': source,
        if (score != null) 'score': score,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return MoodCheckin.fromJson(data);
  }
}
