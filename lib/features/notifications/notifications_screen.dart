import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../post_detail/post_detail_screen.dart';
import '../settings/notification_settings_screen.dart';
import 'models/app_notification.dart';
import 'notifications_service.dart';
import 'widgets/notification_card.dart';

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
        _error = context.l10n.notificationsLoadFailed;
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
        SnackBar(content: Text(context.l10n.notificationsMarkAllFailed)),
      );
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final local = date.toLocal();
    final now = DateTime.now();
    return local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
  }

  ({IconData icon, Color color, Color background}) _styleForType(String type) {
    switch (type) {
      case 'new_post':
      case 'lesson':
      case 'article':
        return (
          icon: Icons.menu_book_rounded,
          color: AppColors.primaryBlue,
          background: const Color(0xFFDBEAFE),
        );
      case 'lesson_complete':
      case 'completed':
      case 'goal':
      case 'goals':
        return (
          icon: Icons.check_circle_rounded,
          color: const Color(0xFF16A34A),
          background: const Color(0xFFDCFCE7),
        );
      case 'event':
      case 'seminar':
      case 'training':
        return (
          icon: Icons.play_circle_filled_rounded,
          color: AppColors.accentRed,
          background: const Color(0xFFFEE2E2),
        );
      case 'badge':
      case 'achievement':
        return (
          icon: Icons.workspace_premium_rounded,
          color: AppColors.accentPurple,
          background: const Color(0xFFEDE9FE),
        );
      case 'comment_reply':
        return (
          icon: Icons.reply_rounded,
          color: AppColors.accentPurple,
          background: const Color(0xFFEDE9FE),
        );
      case 'post_comment':
        return (
          icon: Icons.chat_bubble_outline_rounded,
          color: AppColors.primaryBlue,
          background: const Color(0xFFDBEAFE),
        );
      case 'post_liked':
        return (
          icon: Icons.favorite_rounded,
          color: AppColors.accentRed,
          background: const Color(0xFFFEE2E2),
        );
      case 'admin_push':
        return (
          icon: Icons.campaign_rounded,
          color: AppColors.primaryBlue,
          background: const Color(0xFFDBEAFE),
        );
      default:
        return (
          icon: Icons.notifications_rounded,
          color: AppColors.primaryBlue,
          background: const Color(0xFFDBEAFE),
        );
    }
  }

  String _typeLabel(String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'new_post':
      case 'lesson':
      case 'article':
        return l10n.notifTypeNewLesson;
      case 'lesson_complete':
      case 'completed':
        return l10n.notifTypeCompletedLesson;
      case 'event':
      case 'seminar':
      case 'training':
        return l10n.notifTypeSeminar;
      case 'goal':
      case 'goals':
        return l10n.notifTypeGoals;
      case 'badge':
      case 'achievement':
        return l10n.notifTypeBadges;
      case 'comment_reply':
        return l10n.notifTypeReply;
      case 'post_comment':
        return l10n.notifTypeComment;
      case 'post_liked':
        return l10n.notifTypeLiked;
      case 'admin_push':
        return l10n.notifTypeAdminPush;
      default:
        return l10n.notifTypeGeneral;
    }
  }

  String _timeLabel(DateTime? createdAt) {
    if (createdAt == null) return '';
    final local = createdAt.toLocal();
    if (_isToday(local)) {
      return DateFormat.jm().format(local);
    }
    return '${DateFormat('dd MMMM yyyy').format(local)} | ${DateFormat.jm().format(local)}';
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
        SnackBar(content: Text(context.l10n.notificationsOpenFailed)),
      );
    }
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: context.textPrimary,
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final l10n = context.l10n;
    final today = _items.where((n) => _isToday(n.createdAt)).toList();
    final earlier = _items.where((n) => !_isToday(n.createdAt)).toList();

    final children = <Widget>[];
    if (today.isNotEmpty) {
      children.add(_sectionHeader(l10n.notificationsToday));
      for (final item in today) {
        final style = _styleForType(item.type);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NotificationCard(
              item: item,
              typeLabel: _typeLabel(item.type),
              timeLabel: _timeLabel(item.createdAt),
              icon: style.icon,
              iconColor: style.color,
              iconBackground: style.background,
              onTap: () => _openNotification(item),
            ),
          ),
        );
      }
    }
    if (earlier.isNotEmpty) {
      children.add(_sectionHeader(l10n.notificationsEarlier));
      for (final item in earlier) {
        final style = _styleForType(item.type);
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NotificationCard(
              item: item,
              typeLabel: _typeLabel(item.type),
              timeLabel: _timeLabel(item.createdAt),
              icon: style.icon,
              iconColor: style.color,
              iconBackground: style.background,
              onTap: () => _openNotification(item),
            ),
          ),
        );
      }
    }

    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unreadCount = _items.where((n) => n.isUnread).length;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    color: context.textPrimary,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  ),
                  Expanded(
                    child: Text(
                      l10n.notificationsTitle,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _openSettings,
                    icon: const Icon(Icons.settings_rounded),
                    color: AppColors.primaryBlue,
                    tooltip: l10n.notificationSettingsTitle,
                  ),
                ],
              ),
            ),
            if (unreadCount > 0)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _markingAll ? null : _markAllRead,
                  child: _markingAll
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryBlue,
                          ),
                        )
                      : Text(
                          l10n.markAllRead,
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: context.textSecondary),
                                ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: _load,
                                  child: Text(l10n.retry),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _items.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none_rounded,
                                      size: 64,
                                      color: context.textSecondary
                                          .withValues(alpha: 0.55),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      l10n.notificationsEmptyTitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: context.textSecondary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      l10n.notificationsEmptyBody,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: context.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildList(context),
            ),
          ],
        ),
      ),
    );
  }
}
