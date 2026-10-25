import '../../../core/auth/auth_service.dart';
import '../../../core/models/care_check_result.dart';
import '../../../core/network/endpoints.dart';

class CareCheckService {
  CareCheckService._();

  static Future<CareCheckResult?> fetchLatest(String type) async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.careChecksLatest,
      query: {'type': type},
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is! Map<String, dynamic>) return null;
    return CareCheckResult.fromJson(data);
  }

  static Future<CareCheckResult> submit({
    required String checkType,
    required List<Map<String, dynamic>> answers,
  }) async {
    final res = await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.careChecks,
      data: {
        'check_type': checkType,
        'answers': answers,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return CareCheckResult.fromJson(data);
  }
}
