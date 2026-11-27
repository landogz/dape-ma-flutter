import 'package:flutter/material.dart';

import '../../l10n/locale_scope.dart';
import '../../theme/app_colors.dart';
import 'password_policy.dart';

/// Live bullet checklist for password complexity (matches admin web rules).
class PasswordPolicyChecklist extends StatelessWidget {
  const PasswordPolicyChecklist({
    super.key,
    required this.password,
    this.compact = false,
  });

  final String password;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final checks = PasswordPolicy.checks(password);
    final rules = <({bool met, String label})>[
      (met: checks.length, label: l10n.passwordRuleLength),
      (met: checks.mixed, label: l10n.passwordRuleMixed),
      (met: checks.number, label: l10n.passwordRuleNumber),
      (met: checks.symbol, label: l10n.passwordRuleSymbol),
    ];

    return Semantics(
      label: l10n.passwordPolicyHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rule in rules)
            Padding(
              padding: EdgeInsets.only(bottom: compact ? 4 : 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: rule.met
                          ? const Color(0xFF15803D)
                          : AppColors.nileBlue.withValues(alpha: 0.55),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      rule.label,
                      style: TextStyle(
                        fontSize: compact ? 12 : 13,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: rule.met
                            ? const Color(0xFF15803D)
                            : AppColors.nileBlue.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
