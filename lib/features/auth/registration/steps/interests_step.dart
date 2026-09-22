import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../registration_constants.dart';
import '../widgets/registration_shell.dart';

class InterestsStep extends StatelessWidget {
  const InterestsStep({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width < 360 ? 1 : 2;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Center(
          child: RegistrationIconBadge(
            backgroundColor: Color(0xFFF3E8FF),
            child: Icon(
              Icons.favorite,
              size: 32,
              color: AppColors.accentPurple,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.regInterestsTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.regInterestsSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.35),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final gap = 10.0;
            final cardWidth = crossAxisCount == 1
                ? constraints.maxWidth
                : (constraints.maxWidth - gap) / 2;
            final interests = RegistrationConstants.interests;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: interests.map((interest) {
                final isOn = selected.contains(interest.key);
                return SizedBox(
                  width: cardWidth,
                  child: Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => onToggle(interest.key),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 96),
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOn
                                ? interest.accent
                                : const Color(0xFFE5E7EB),
                            width: isOn ? 1.6 : 1,
                          ),
                          color: isOn
                              ? interest.tint.withValues(alpha: 0.55)
                              : Colors.white,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: interest.tint,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                interest.icon,
                                size: 17,
                                color: interest.accent,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.regInterestLabel(interest.key),
                                    maxLines: 2,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimaryLight,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    l10n.regInterestBody(interest.key),
                                    maxLines: 3,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      height: 1.25,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
