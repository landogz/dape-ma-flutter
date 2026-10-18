import 'package:dio/dio.dart';

import 'endpoints.dart';

class ServerStatus {
  ServerStatus._();

  static const _downStatusCodes = {
    408,
    502,
    503,
    504,
    520,
    521,
    522,
    523,
    525,
    526,
  };

  static Future<bool> isReachable() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: Endpoints.baseUrl,
        connectTimeout: const Duration(seconds: 6),
        receiveTimeout: const Duration(seconds: 6),
        sendTimeout: const Duration(seconds: 6),
        headers: {'Accept': 'application/json'},
      ),
    );

    try {
      final res = await dio.get<dynamic>(Endpoints.health);
      final code = res.statusCode ?? 0;
      if (_downStatusCodes.contains(code)) {
        return false;
      }
      final data = res.data;
      if (data is Map && data['status'] == true) {
        return true;
      }
      return code >= 200 && code < 300;
    } on DioException catch (error) {
      final code = error.response?.statusCode;
      if (code != null && code >= 200 && code < 500 && !_downStatusCodes.contains(code)) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
