import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../care_colors.dart';

class CheckDisclaimerRow extends StatelessWidget {
  const CheckDisclaimerRow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: CareColors.mintOf(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CareColors.cardBorderOf(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: CareColors.headingOf(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
