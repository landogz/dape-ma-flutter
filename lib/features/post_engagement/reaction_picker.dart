import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import 'post_reaction.dart';

Future<PostReactionType?> showReactionPicker(
  BuildContext context, {
  PostReactionType? selected,
  required Offset anchor,
}) {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox?;
  final size = overlay?.size ?? MediaQuery.sizeOf(context);

  return showMenu<PostReactionType>(
    context: context,
    position: RelativeRect.fromLTRB(
      (anchor.dx - 120).clamp(12, size.width - 280),
      (anchor.dy - 72).clamp(48, size.height - 100),
      size.width - anchor.dx,
      size.height - anchor.dy,
    ),
    color: Colors.white,
    elevation: 10,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    items: [
      PopupMenuItem<PostReactionType>(
        enabled: false,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: PostReactionType.values.map((type) {
              final isSelected = type == selected;
              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pop(type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlue.withValues(alpha: 0.12)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(type.emoji, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    ],
  );
}

class ReactionSummaryRow extends StatelessWidget {
  const ReactionSummaryRow({
    super.key,
    required this.reactionCounts,
    required this.totalCount,
    required this.onTap,
  });

  final Map<PostReactionType, int> reactionCounts;
  final int totalCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (totalCount <= 0) {
      return const SizedBox.shrink();
    }

    final top = topReactionTypes(reactionCounts);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...top.map(
              (type) => Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Text(type.emoji, style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$totalCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.nileBlue.withValues(alpha: 0.75),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
