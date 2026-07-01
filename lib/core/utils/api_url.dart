import '../network/endpoints.dart';

class ApiUrl {
  ApiUrl._();

  static String get _origin {
    final base = Endpoints.baseUrl;
    final apiIndex = base.indexOf('/api/');
    if (apiIndex == -1) return base;
    return base.substring(0, apiIndex);
  }

  static String? resolve(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('/')) {
      return '$_origin$trimmed';
    }
    return '$_origin/$trimmed';
  }
}
