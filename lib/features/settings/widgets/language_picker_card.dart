import 'package:flutter/material.dart';

import '../../../core/l10n/app_locale.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';

class LanguagePickerCard extends StatelessWidget {
  const LanguagePickerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = LocaleScope.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.languageTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.languageSubtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...AppLocale.supported.map((locale) {
            final selected = controller.locale == locale;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: selected
                    ? AppColors.primaryBlue.withValues(alpha: 0.08)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: () => controller.setLocale(locale),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.primaryBlue.withValues(alpha: 0.35)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimaryLight,
                                    ),
                              ),
                              Text(
                                locale.nativeName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryBlue,
                            size: 22,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
