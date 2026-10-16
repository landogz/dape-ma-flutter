import '../network/endpoints.dart';

class ApiUrl {
  ApiUrl._();

  static String get origin {
    final base = Endpoints.baseUrl;
    final apiIndex = base.indexOf('/api/');
    if (apiIndex == -1) return base;
    return base.substring(0, apiIndex);
  }

  static bool _isLoopback(String host) {
    final h = host.toLowerCase();
    return h == 'localhost' ||
        h == '127.0.0.1' ||
        h == '0.0.0.0' ||
        h == '::1';
  }

  /// Resolve storage/media paths to a URL the current device can load.
  /// Rewrites `127.0.0.1` / `localhost` from APP_URL to the app API host
  /// (e.g. Android emulator `10.0.2.2`).
  static String? resolve(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    final trimmed = path.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      final originUri = Uri.tryParse(origin);
      if (uri == null || originUri == null || !originUri.hasAuthority) {
        return trimmed;
      }

      if (_isLoopback(uri.host) && uri.host != originUri.host) {
        return uri
            .replace(
              scheme: originUri.scheme,
              host: originUri.host,
              port: originUri.hasPort ? originUri.port : null,
            )
            .toString();
      }
      return trimmed;
    }

    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }
    return '$origin/$trimmed';
  }

  static String sharePost(int id) => '$origin/posts/$id';

  static String shareEvent(int id) => '$origin/events/$id';

  static String shareContest(int id) => '$origin/contests/$id';
}
