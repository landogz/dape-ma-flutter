import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme_colors.dart';
import '../../care_colors.dart';

class ToolkitDisclaimer extends StatelessWidget {
  const ToolkitDisclaimer({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.eco_rounded,
            size: 22,
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
