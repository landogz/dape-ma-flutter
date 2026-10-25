import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'journal_entry_filters.dart';

class JournalFilterBar extends StatelessWidget {
  const JournalFilterBar({
    super.key,
    required this.filters,
    required this.onPeriodChanged,
    required this.onOpenMore,
    required this.onClear,
  });

  final JournalEntryFilters filters;
  final ValueChanged<String> onPeriodChanged;
  final VoidCallback onOpenMore;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.journalYourEntries,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.heading,
                ),
              ),
            ),
            if (filters.isNarrowed)
              TextButton(
                onPressed: onClear,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  l10n.journalFilterClear,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            Tooltip(
              message: l10n.journalFilterTitle,
              child: Material(
              color: filters.hasExtras
                  ? AppColors.primaryBlue.withValues(alpha: 0.12)
                  : context.chipBackground,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onOpenMore,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: filters.hasExtras
                            ? AppColors.primaryBlue
                            : context.heading,
                      ),
                      if (filters.extraCount > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accentRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: JournalEntryFilters.periods.map((period) {
            final selected = filters.period == period;
            return FilterChip(
              label: Text(_periodLabel(l10n, period)),
              selected: selected,
              onSelected: (_) => onPeriodChanged(period),
              showCheckmark: false,
              selectedColor: AppColors.accentYellow,
              backgroundColor: context.chipBackground,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? AppColors.nileBlue : context.textPrimary,
              ),
              side: BorderSide(
                color: selected ? AppColors.accentYellow : context.borderSubtle,
              ),
              materialTapTargetSize: MaterialTapTargetSize.padded,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _periodLabel(AppStrings l10n, String period) {
    switch (period) {
      case 'today':
        return l10n.journalFilterToday;
      case 'week':
        return l10n.journalFilterThisWeek;
      case 'month':
        return l10n.journalFilterThisMonth;
      case 'all':
        return l10n.journalFilterAll;
      default:
        return l10n.journalFilterAll;
    }
  }
}
