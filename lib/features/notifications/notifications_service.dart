import '../../core/auth/auth_service.dart';
import '../../core/network/endpoints.dart';
import 'models/app_notification.dart';

class NotificationsService {
  NotificationsService._();

  static Future<List<AppNotification>> fetchNotifications({
    bool unreadOnly = false,
    int page = 1,
    int perPage = 20,
  }) async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.notifications,
      query: <String, dynamic>{
        'per_page': perPage,
        'page': page,
        if (unreadOnly) 'unread_only': 1,
      },
    );

    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    List<dynamic> list = const [];

    if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
      list = data['data'] as List<dynamic>;
    } else if (data is List<dynamic>) {
      list = data;
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map(AppNotification.fromJson)
        .toList();
  }

  static Future<int> fetchUnreadCount() async {
    final res = await AuthService.authedGet<Map<String, dynamic>>(
      Endpoints.notificationsSummary,
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    if (data is Map<String, dynamic>) {
      final count = data['unread_count'];
      if (count is int) return count;
      return int.tryParse(count?.toString() ?? '') ?? 0;
    }
    return 0;
  }

  static Future<void> markAsRead(int id) async {
    await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.notificationRead(id),
    );
  }

  static Future<void> markAllAsRead() async {
    await AuthService.authedPost<Map<String, dynamic>>(
      Endpoints.notificationsReadAll,
    );
  }
}
