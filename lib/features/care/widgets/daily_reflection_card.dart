import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_scope.dart';
import '../care_colors.dart';

/// Daily Reflection prompt — deep forest teal, gold CTA only.
class DailyReflectionCard extends StatelessWidget {
  const DailyReflectionCard({
    super.key,
    required this.onStartWriting,
    this.busy = false,
  });

  final VoidCallback onStartWriting;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CareColors.forestMid,
            CareColors.forest,
            CareColors.forestDeep,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CareColors.forest.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.careDailyReflection.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${l10n.careDailyReflectionPrompt}"',
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: Material(
              color: CareColors.accentGold,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: busy
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onStartWriting();
                      },
                borderRadius: BorderRadius.circular(999),
                child: Center(
                  child: busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: CareColors.accentGoldText,
                          ),
                        )
                      : Text(
                          l10n.careStartWriting,
                          style: const TextStyle(
                            color: CareColors.accentGoldText,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
