import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';
import '../../care_colors.dart';

class ToolkitHeroCard extends StatelessWidget {
  const ToolkitHeroCard({super.key, required this.body});

  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.nileBlue.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              body,
              style: TextStyle(
                color: CareColors.headingOf(context),
                fontWeight: FontWeight.w600,
                height: 1.4,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/care/care_selfcare.png',
            width: 88,
            height: 72,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
