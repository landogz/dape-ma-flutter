import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/models/care_toolkit_question.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../care_colors.dart';
import 'check_brand_button.dart';
import 'check_option_tile.dart';

class CheckQuestionView extends StatelessWidget {
  const CheckQuestionView({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.selectedLikert,
    required this.selectedTime,
    required this.onLikert,
    required this.onPickTime,
    required this.onNext,
    required this.backLabel,
    required this.nextLabel,
    required this.saving,
    this.promptPrefix,
    this.onBack,
  });

  final CareToolkitQuestion question;
  final int index;
  final int total;
  final int? selectedLikert;
  final TimeOfDay? selectedTime;
  final ValueChanged<int> onLikert;
  final VoidCallback onPickTime;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String backLabel;
  final String nextLabel;
  final bool saving;
  final String? promptPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = (index + 1) / total;
    final options = question.options.isNotEmpty
        ? question.options
        : question.answerType == 'likert4'
            ? const [
                'Not at all',
                'Several days',
                'More than half the days',
                'Nearly every day',
              ]
            : [
                l10n.careScaleNever,
                l10n.careScaleAlmostNever,
                l10n.careScaleSometimes,
                l10n.careScaleFairlyOften,
                l10n.careScaleVeryOften,
              ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: CareColors.mintOf(context),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${index + 1} / $total',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: CareColors.headingOf(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.careQuestionProgress(index + 1, total),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: CareColors.mintOf(context),
                  color: CareColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: context.cardBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: CareColors.cardBorderOf(context)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.nileBlue.withValues(alpha: 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (promptPrefix != null && promptPrefix!.isNotEmpty) ...[
                      Text(
                        promptPrefix!,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: context.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    Text(
                      question.question,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: CareColors.headingOf(context),
                        fontSize: 20,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (question.answerType == 'time')
                _TimeAnswer(value: selectedTime, onPick: onPickTime)
              else
                ...List.generate(options.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: CheckOptionTile(
                      label: options[i],
                      selected: selectedLikert == i,
                      onTap: () => onLikert(i),
                    ),
                  );
                }),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                if (onBack != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: saving ? null : onBack,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        foregroundColor: CareColors.headingOf(context),
                        side: BorderSide(
                          color: CareColors.headingOf(context),
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        backLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                if (onBack != null) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: CheckBrandButton(
                    label: nextLabel,
                    onPressed: onNext,
                    busy: saving,
                    enabled: onNext != null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeAnswer extends StatelessWidget {
  const _TimeAnswer({required this.value, required this.onPick});

  final TimeOfDay? value;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final label = value?.format(context) ?? context.l10n.careInputTimeHint;
    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CareColors.cardBorderOf(context), width: 1.4),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: CareColors.mintOf(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: CareColors.headingOf(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: CareColors.textOf(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
