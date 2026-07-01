import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CategoryTabs extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const CategoryTabs({
    super.key,
    required this.current,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const categories = [
      {'slug': 'all', 'label': 'All'},
      {'slug': 'drug-effects', 'label': 'Drug Effects'},
      {'slug': 'rehabilitation', 'label': 'Rehabilitation'},
      {'slug': 'prevention', 'label': 'Prevention'},
      {'slug': 'news', 'label': 'News'},
      {'slug': 'legal', 'label': 'Laws & Policies'},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final c = categories[index];
          final isActive = c['slug'] == current;
          return ChoiceChip(
            label: Text(c['label']!),
            selected: isActive,
            onSelected: (_) => onChanged(c['slug']!),
            selectedColor: AppColors.primaryBlue,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color:
                  isActive ? Colors.white : AppColors.textSecondaryLight,
            ),
          );
        },
      ),
    );
  }
}

