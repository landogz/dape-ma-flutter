import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/options/app_option_catalog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../journal_wizard/feeling_chip/feeling_chip.dart';
import 'journal_entry_filters.dart';

Future<JournalEntryFilters?> showJournalFilterSheet(
  BuildContext context, {
  required JournalEntryFilters current,
  List<String> customFeelings = const [],
}) {
  return showModalBottomSheet<JournalEntryFilters>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => JournalFilterSheet(
      current: current,
      customFeelings: customFeelings,
    ),
  );
}

class JournalFilterSheet extends StatefulWidget {
  const JournalFilterSheet({
    super.key,
    required this.current,
    this.customFeelings = const [],
  });

  final JournalEntryFilters current;
  final List<String> customFeelings;

  @override
  State<JournalFilterSheet> createState() => _JournalFilterSheetState();
}

class _JournalFilterSheetState extends State<JournalFilterSheet> {
  late String? _sky;
  late String? _feeling;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _sky = widget.current.sky;
    _feeling = widget.current.feeling;
    _searchController = TextEditingController(text: widget.current.search);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _apply() {
    Navigator.of(context).pop(
      widget.current.copyWith(
        sky: _sky,
        clearSky: _sky == null || _sky!.isEmpty,
        feeling: _feeling,
        clearFeeling: _feeling == null || _feeling!.isEmpty,
        search: _searchController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;
    final skies = AppOptionCatalog.skies();
    final feelings = AppOptionCatalog.feelings();
    final presetKeys = feelings.map((item) => item.key).toSet();
    final extras = widget.customFeelings
        .where((item) => item.trim().isNotEmpty && !presetKeys.contains(item))
        .toList();

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.borderSubtle,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.journalFilterTitle,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.heading,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: l10n.close,
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (_) => _apply(),
                      decoration: InputDecoration(
                        hintText: l10n.journalFilterSearchHint,
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: context.optionFill,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.borderSubtle),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: context.borderSubtle),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.journalSummarySky,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: skies.map((opt) {
                        final selected = _sky == opt.key;
                        final label = l10n.isTagalog ? opt.labelTl : opt.labelEn;
                        return FilterChip(
                          avatar: opt.hasLookupIcon
                              ? Icon(
                                  opt.icon,
                                  size: 16,
                                  color: selected
                                      ? AppColors.nileBlue
                                      : context.textPrimary,
                                )
                              : CircleAvatar(backgroundColor: opt.accent),
                          label: Text(label),
                          selected: selected,
                          showCheckmark: false,
                          onSelected: (_) {
                            setState(() => _sky = selected ? null : opt.key);
                          },
                          selectedColor: AppColors.accentYellow,
                          backgroundColor: context.chipBackground,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: selected
                                ? AppColors.nileBlue
                                : context.textPrimary,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.accentYellow
                                : context.borderSubtle,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.journalSummaryFeelings,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ...feelings.map((opt) {
                          return JournalFeelingChip(
                            label: l10n.isTagalog ? opt.labelTl : opt.labelEn,
                            selected: _feeling == opt.key,
                            accent: opt.accent ?? AppColors.primaryBlue,
                            icon: opt.icon,
                            onTap: () {
                              setState(() =>
                                  _feeling = _feeling == opt.key ? null : opt.key);
                            },
                          );
                        }),
                        ...extras.map(
                          (feeling) => JournalFeelingChip(
                            label: feeling,
                            selected: _feeling == feeling,
                            accent: AppColors.primaryBlue,
                            onTap: () {
                              setState(() =>
                                  _feeling = _feeling == feeling ? null : feeling);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _sky = null;
                          _feeling = null;
                          _searchController.clear();
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        minimumSize: const Size.fromHeight(48),
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(l10n.journalFilterReset),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _apply,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l10n.journalFilterApply,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
