import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/post_comment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/widgets/user_avatar.dart';

class CommentBubble extends StatelessWidget {
  const CommentBubble({
    super.key,
    required this.comment,
    required this.timeAgo,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
    this.onReply,
    this.depth = 0,
  });

  final PostComment comment;
  final String timeAgo;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReply;
  final int depth;

  static const _metaColor = Color(0xFF9CA3AF);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final metaLabel = timeAgo.isNotEmpty ? timeAgo : 'Just now';

    return Padding(
      padding: EdgeInsets.only(
        left: depth * 28.0,
        bottom: 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UserAvatar(
            name: comment.authorName,
            imageUrl: comment.authorAvatarUrl,
            radius: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        comment.authorName,
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                      ),
                    ),
                    if (canManage)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        icon: const Icon(
                          Icons.more_horiz,
                          size: 18,
                          color: _metaColor,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit?.call();
                          } else if (value == 'delete') {
                            onDelete?.call();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                const Icon(Icons.edit_outlined, size: 18),
                                const SizedBox(width: 8),
                                Text(l10n.edit),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.accentRed,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.deleteAction,
                                  style: const TextStyle(
                                    color: AppColors.accentRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: context.mutedSurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    comment.body,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: onReply,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    '$metaLabel · ${l10n.reply}',
                    style: const TextStyle(
                      color: _metaColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CommentThread extends StatelessWidget {
  const CommentThread({
    super.key,
    required this.comment,
    required this.timeAgoBuilder,
    required this.canManageBuilder,
    required this.onEdit,
    required this.onDelete,
    required this.onReply,
    this.depth = 0,
  });

  final PostComment comment;
  final String Function(DateTime?) timeAgoBuilder;
  final bool Function(PostComment comment) canManageBuilder;
  final void Function(PostComment comment) onEdit;
  final void Function(PostComment comment) onDelete;
  final void Function(PostComment comment) onReply;
  final int depth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommentBubble(
          comment: comment,
          timeAgo: timeAgoBuilder(comment.createdAt),
          canManage: canManageBuilder(comment),
          onEdit: () => onEdit(comment),
          onDelete: () => onDelete(comment),
          onReply: () => onReply(comment),
          depth: depth,
        ),
        ...comment.replies.map(
          (reply) => CommentThread(
            comment: reply,
            timeAgoBuilder: timeAgoBuilder,
            canManageBuilder: canManageBuilder,
            onEdit: onEdit,
            onDelete: onDelete,
            onReply: onReply,
            depth: depth + 1,
          ),
        ),
      ],
    );
  }
}
