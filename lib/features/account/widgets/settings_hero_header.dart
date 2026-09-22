import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

class SettingsHeroHeader extends StatelessWidget {
  const SettingsHeroHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBackground,
    this.iconColor = Colors.white,
    this.showBack = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconBackground;
  final Color iconColor;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showBack)
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: context.textPrimary,
              tooltip: 'Back',
            ),
          ),
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                iconBackground ?? AppColors.primaryBlue,
                AppColors.secondaryBlue,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(icon, size: 40, color: iconColor),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
