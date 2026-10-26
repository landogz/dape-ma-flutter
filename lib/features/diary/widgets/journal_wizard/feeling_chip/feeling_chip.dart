import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme_colors.dart';

class JournalFeelingChip extends StatelessWidget {
  const JournalFeelingChip({
    super.key,
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.onLongPress,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final onAccent = accent.computeLuminance() > 0.55
        ? AppColors.nileBlue
        : Colors.white;
    final fill = selected
        ? accent
        : accent.withValues(alpha: context.isDarkMode ? 0.28 : 0.14);
    final border = selected
        ? accent
        : accent.withValues(alpha: 0.55);
    final textColor = selected ? onAccent : _unselectedText(context, accent);

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          onLongPress: onLongPress == null
              ? null
              : () {
                  HapticFeedback.mediumImpact();
                  onLongPress!();
                },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: border,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _unselectedText(BuildContext context, Color accent) {
    if (accent.computeLuminance() < 0.18) {
      return context.textPrimary;
    }
    return Color.alphaBlend(accent.withValues(alpha: 0.85), AppColors.nileBlue);
  }
}
