import '../../core/models/daily_verse.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class DailyVerseService {
  DailyVerseService._();

  static Future<DailyVerse?> fetchToday() async {
    final res = await ApiClient().get<Map<String, dynamic>>(
      Endpoints.dailyVerseToday,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is! Map<String, dynamic>) return null;
    return DailyVerse.fromJson(data);
  }
}
