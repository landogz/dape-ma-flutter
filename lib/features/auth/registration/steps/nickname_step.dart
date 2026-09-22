import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_decor.dart';
import '../registration_constants.dart';
import '../widgets/registration_shell.dart';

class NicknameStep extends StatelessWidget {
  const NicknameStep({
    super.key,
    required this.nicknameController,
    required this.selectedPronouns,
    required this.onPronounsChanged,
  });

  final TextEditingController nicknameController;
  final String? selectedPronouns;
  final ValueChanged<String?> onPronounsChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Center(
          child: RegistrationIconBadge(
            child: Text('👋', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 18),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
              height: 1.25,
            ),
            children: [
              TextSpan(text: l10n.regNicknameTitlePrefix),
              TextSpan(
                text: l10n.regNicknameTitleHighlight,
                style: const TextStyle(color: AppColors.primaryBlue),
              ),
              TextSpan(text: l10n.regNicknameTitleSuffix),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.regNicknameSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 22),
        TextField(
          controller: nicknameController,
          textInputAction: TextInputAction.done,
          decoration: authFieldDecoration(
            context: context,
            hintText: l10n.regNicknameHint,
            prefixIcon: Icons.person_outline,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.regNicknameHelper,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                l10n.regOptionalLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Color(0xFFE5E7EB))),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          l10n.regPronounsTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.regPronounsSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: RegistrationConstants.pronouns.map((key) {
            final selected = selectedPronouns == key;
            return FilterChip(
              label: Text(l10n.regPronounLabel(key)),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) =>
                  onPronounsChanged(selected ? null : key),
              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.textSecondaryLight,
              ),
              side: BorderSide(
                color: selected
                    ? AppColors.primaryBlue
                    : const Color(0xFFE5E7EB),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
