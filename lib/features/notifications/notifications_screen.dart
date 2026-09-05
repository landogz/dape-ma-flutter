import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/post.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../post_detail/post_detail_screen.dart';
import 'models/app_notification.dart';
import 'notifications_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _items = [];
  bool _loading = true;
  bool _markingAll = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await NotificationsService.fetchNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load notifications.';
      });
    }
  }

  Future<void> _markAllRead() async {
    if (_items.every((n) => !n.isUnread)) return;
    setState(() => _markingAll = true);
    try {
      await NotificationsService.markAllAsRead();
      if (!mounted) return;
      setState(() {
        _items = _items
            .map(
              (n) => AppNotification(
                id: n.id,
                type: n.type,
                title: n.title,
                body: n.body,
                data: n.data,
                readAt: n.readAt ?? DateTime.now(),
                createdAt: n.createdAt,
              ),
            )
            .toList();
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not mark all as read.')),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'comment_reply':
        return Icons.reply_rounded;
      case 'post_comment':
        return Icons.chat_bubble_outline_rounded;
      case 'post_liked':
        return Icons.favorite_outline_rounded;
      case 'new_post':
        return Icons.article_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'comment_reply':
        return AppColors.accentPurple;
      case 'post_comment':
        return AppColors.primaryBlue;
      case 'post_liked':
        return AppColors.accentRed;
      case 'new_post':
        return AppColors.secondaryBlue;
      default:
        return AppColors.primaryBlue;
    }
  }

  String _timeLabel(DateTime? createdAt) {
    if (createdAt == null) return '';
    final local = createdAt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(local);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(local);
  }

  Future<void> _openNotification(AppNotification item) async {
    if (item.isUnread) {
      try {
        await NotificationsService.markAsRead(item.id);
        if (mounted) {
          setState(() {
            final index = _items.indexWhere((n) => n.id == item.id);
            if (index >= 0) {
              _items[index] = AppNotification(
                id: item.id,
                type: item.type,
                title: item.title,
                body: item.body,
                data: item.data,
                readAt: DateTime.now(),
                createdAt: item.createdAt,
              );
            }
          });
        }
      } catch (_) {}
    }

    final postId = item.postId;
    if (postId == null) return;

    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.postDetail(postId),
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'] is Map<String, dynamic>
          ? root['data'] as Map<String, dynamic>
          : root;
      final post = Post.fromJson(data);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PostDetailScreen(
            post: post,
            focusCommentOnOpen: item.type == 'comment_reply' ||
                item.type == 'post_comment',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open this post.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _items.where((n) => n.isUnread).length;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markingAll ? null : _markAllRead,
              child: _markingAll
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Mark all read',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(onPressed: _load, child: const Text('Retry')),
                      ],
                    ),
                  )
                : _items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 64,
                              color: AppColors.textSecondaryLight.withOpacity(0.6),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Replies, likes, and new posts will appear here.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = _items[index];
                            final color = _colorForType(item.type);
                            return Material(
                              color: item.isUnread
                                  ? AppColors.primaryBlue.withOpacity(0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () => _openNotification(item),
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          _iconForType(item.type),
                                          color: color,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    item.title,
                                                    style: TextStyle(
                                                      fontWeight: item.isUnread
                                                          ? FontWeight.w700
                                                          : FontWeight.w600,
                                                      color: AppColors
                                                          .textPrimaryLight,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                if (item.isUnread)
                                                  Container(
                                                    width: 8,
                                                    height: 8,
                                                    decoration:
                                                        const BoxDecoration(
                                                      color:
                                                          AppColors.primaryBlue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            if (item.body != null &&
                                                item.body!.trim().isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                item.body!,
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: AppColors
                                                      .textSecondaryLight,
                                                  fontSize: 13,
                                                  height: 1.35,
                                                ),
                                              ),
                                            ],
                                            const SizedBox(height: 6),
                                            Text(
                                              _timeLabel(item.createdAt),
                                              style: TextStyle(
                                                color: AppColors
                                                    .textSecondaryLight
                                                    .withOpacity(0.8),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
