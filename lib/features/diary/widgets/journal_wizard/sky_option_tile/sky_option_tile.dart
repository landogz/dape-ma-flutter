import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme_colors.dart';
import '../journal_constants.dart';

class JournalSkyOptionTile extends StatelessWidget {
  const JournalSkyOptionTile({
    super.key,
    required this.option,
    required this.selected,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final JournalSkyOption option;
  final bool selected;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final luminance = option.accent.computeLuminance();
    final needsRing = luminance > 0.82 || luminance < 0.08;
    final caption = subtitle.trim();

    return Material(
      color: selected ? context.softBrandSurface : context.optionFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? AppColors.secondaryBlue : context.borderSubtle,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: option.accent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: needsRing ? context.borderSubtle : option.accent,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                        color: context.textPrimary,
                      ),
                    ),
                    if (caption.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          height: 1.25,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.check_circle,
                  color: context.iconOnSurface,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
