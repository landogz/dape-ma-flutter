import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../registration_constants.dart';
import '../widgets/registration_shell.dart';

class PersonaStep extends StatelessWidget {
  const PersonaStep({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Center(
          child: RegistrationIconBadge(
            child: Icon(
              Icons.person_outline_rounded,
              size: 34,
              color: AppColors.accentRed,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.regPersonaTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.regPersonaSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ...RegistrationConstants.personas.map((persona) {
          final isOn = selected == persona.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(persona.key),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isOn
                          ? AppColors.primaryBlue
                          : const Color(0xFFE5E7EB),
                      width: isOn ? 1.6 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(persona.icon, color: AppColors.secondaryBlue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.regPersonaLabel(persona.key),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      Icon(
                        isOn
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isOn
                            ? AppColors.primaryBlue
                            : const Color(0xFFD1D5DB),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),
      ],
    );
  }
}
