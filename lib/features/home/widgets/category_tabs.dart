import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

class CategoryTabs extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const CategoryTabs({
    super.key,
    required this.current,
    required this.onChanged,
  });

  static const List<String> _slugs = [
    'all',
    'drug-effects',
    'rehabilitation',
    'prevention',
    'iec',
    'news',
    'legal',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scale = MediaQuery.textScalerOf(context).scale(1.0);
    final height = (48.0 * scale).clamp(48.0, 72.0);

    return SizedBox(
      height: height,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        scrollDirection: Axis.horizontal,
        itemCount: _slugs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final slug = _slugs[index];
          final isActive = slug == current;
          return Center(
            child: ChoiceChip(
              label: Text(
                l10n.categoryLabel(slug),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              selected: isActive,
              onSelected: (_) => onChanged(slug),
              selectedColor: AppColors.primaryBlue,
              backgroundColor: context.chipBackground,
              checkmarkColor: Colors.white,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: BorderSide(color: context.borderSubtle),
              labelStyle: TextStyle(
                color: isActive ? Colors.white : context.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
