import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/post_comment.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/theme/app_typography.dart';
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
    final metaLabel = timeAgo.isNotEmpty ? timeAgo : 'Just now';
    final isReply = depth > 0;
    final hasBody = comment.body.trim().isNotEmpty;
    final hasImage =
        comment.imageUrl != null && comment.imageUrl!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: isReply ? 12.0 + (depth - 1).clamp(0, 2) * 10.0 : 0,
        bottom: 12,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: AppColors.nileBlue.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isReply)
                Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.mediumElectricBlue.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 8, 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UserAvatar(
                        name: comment.authorName,
                        imageUrl: comment.authorAvatarUrl,
                        radius: isReply ? 16 : 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comment.authorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.body(
                                          color: AppColors.nileBlue,
                                          fontSize: 14,
                                        ).copyWith(
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        metaLabel,
                                        style: AppTypography.body(
                                          color: context.textSecondary
                                              .withValues(alpha: 0.85),
                                          fontSize: 12,
                                        ).copyWith(
                                          fontWeight: FontWeight.w500,
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (canManage)
                                  PopupMenuButton<String>(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                    tooltip: l10n.edit,
                                    icon: Icon(
                                      Icons.more_horiz_rounded,
                                      size: 20,
                                      color: context.textSecondary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                                            const Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                            ),
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
                                              color: AppColors.fireEngineRed,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              l10n.deleteAction,
                                              style: const TextStyle(
                                                color: AppColors.fireEngineRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            if (hasBody) ...[
                              const SizedBox(height: 8),
                              Text(
                                comment.body,
                                style: AppTypography.body(
                                  color: context.textPrimary,
                                  fontSize: 14,
                                ).copyWith(
                                  height: 1.45,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                            if (hasImage) ...[
                              SizedBox(height: hasBody ? 10 : 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 220,
                                    minWidth: double.infinity,
                                  ),
                                  child: Image.network(
                                    comment.imageUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 120,
                                      color: AppColors.softBlue,
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (onReply != null) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: onReply,
                                  style: TextButton.styleFrom(
                                    foregroundColor:
                                        AppColors.mediumElectricBlue,
                                    backgroundColor: AppColors.softBlue,
                                    minimumSize: const Size(44, 36),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(
                                    Icons.reply_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    l10n.reply,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
    this.onReply,
    this.depth = 0,
  });

  final PostComment comment;
  final String Function(DateTime?) timeAgoBuilder;
  final bool Function(PostComment comment) canManageBuilder;
  final void Function(PostComment comment) onEdit;
  final void Function(PostComment comment) onDelete;
  final void Function(PostComment comment)? onReply;
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
          onReply: onReply == null ? null : () => onReply!(comment),
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
