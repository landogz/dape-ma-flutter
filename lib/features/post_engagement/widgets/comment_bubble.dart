import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/post_comment.dart';
import '../../../core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimaryLight,
                            height: 1.35,
                          ),
                      children: [
                        TextSpan(
                          text: '${comment.authorName} ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: comment.body),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      if (timeAgo.isNotEmpty)
                        Text(
                          timeAgo,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondaryLight,
                                fontSize: 12,
                              ),
                        ),
                      if (timeAgo.isNotEmpty) const SizedBox(width: 12),
                      TextButton(
                        onPressed: onReply,
                        style: TextButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          foregroundColor: AppColors.textSecondaryLight,
                        ),
                        child: Text(
                          l10n.reply,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (canManage) ...[
                        const SizedBox(width: 4),
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_horiz,
                            size: 18,
                            color: AppColors.textSecondaryLight,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 28,
                            minHeight: 28,
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
                                    style: const TextStyle(color: AppColors.accentRed),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
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
