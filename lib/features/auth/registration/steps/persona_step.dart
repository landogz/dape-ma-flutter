import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/options/app_option_catalog.dart';
import '../../../../core/options/app_option_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/registration_shell.dart';
import '../../../../core/theme/app_theme_colors.dart';

class PersonaStep extends StatelessWidget {
  const PersonaStep({
    super.key,
    required this.selected,
    required this.onToggle,
    this.options = const [],
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final List<AppOptionItem> options;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final personas = options.isNotEmpty ? options : AppOptionCatalog.personas();

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
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.regPersonaSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 20),
        ...personas.map((persona) {
          final isOn = selected.contains(persona.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: isOn ? context.softBrandSurface : context.optionFill,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onToggle(persona.key),
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
                      Icon(persona.icon, color: context.heading),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          persona.label(isTagalog: l10n.isTagalog),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        isOn
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
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
