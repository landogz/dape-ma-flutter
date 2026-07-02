import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';

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

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: _slugs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final slug = _slugs[index];
          final isActive = slug == current;
          return ChoiceChip(
            label: Text(l10n.categoryLabel(slug)),
            selected: isActive,
            onSelected: (_) => onChanged(slug),
            selectedColor: AppColors.primaryBlue,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isActive ? Colors.white : AppColors.textSecondaryLight,
            ),
          );
        },
      ),
    );
  }
}
