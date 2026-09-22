import '../../core/models/care_toolkit_question.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class CareToolkitService {
  CareToolkitService._();

  static Future<List<CareToolkitQuestion>> fetchQuestions({
    required String type,
    String? locale,
  }) async {
    final client = ApiClient();
    final res = await client.get<Map<String, dynamic>>(
      Endpoints.careToolkitQuestions,
      query: {
        'type': type,
        if (locale != null && locale.isNotEmpty) 'locale': locale,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    final list = data is Map<String, dynamic>
        ? data['questions'] as List<dynamic>? ?? const []
        : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CareToolkitQuestion.fromJson)
        .toList();
  }
}
