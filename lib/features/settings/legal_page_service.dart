import '../../core/models/legal_page.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class LegalPageService {
  LegalPageService._();

  static Future<LegalPage?> fetchBySlug({
    required String slug,
    required String locale,
  }) async {
    try {
      final client = ApiClient();
      final response = await client.get<Map<String, dynamic>>(
        Endpoints.legalPage(slug),
        query: {'locale': locale},
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return LegalPage.fromJson(data);
      }
    } catch (_) {
      // Fall back to local strings.
    }

    return null;
  }
}
