import 'package:flutter/material.dart';

import '../../../core/l10n/translation_catalog.dart';
import '../../../core/options/app_option_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/api_url.dart';

class SettingsHeroHeader extends StatelessWidget {
  const SettingsHeroHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.translationKey,
    this.iconBackground,
    this.iconColor = Colors.white,
    this.showBack = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? translationKey;
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
        ListenableBuilder(
          listenable: TranslationCatalog.instance,
          builder: (context, _) => _HeroBadge(
            translationKey: translationKey,
            icon: icon,
            iconBackground: iconBackground,
            iconColor: iconColor,
          ),
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

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({
    required this.icon,
    required this.iconColor,
    this.translationKey,
    this.iconBackground,
  });

  final String? translationKey;
  final IconData icon;
  final Color? iconBackground;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final visual = translationKey == null
        ? null
        : TranslationCatalog.visual(translationKey!);
    final remoteUrl = ApiUrl.resolve(visual?.imageUrl);
    final resolvedIcon = appOptionIcon(visual?.icon, fallback: icon);

    Widget fallbackIcon() => Icon(resolvedIcon, size: 40, color: iconColor);

    Widget gradientShell({required Widget child}) {
      return Container(
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
        child: child,
      );
    }

    if (remoteUrl != null) {
      return Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Image.network(
          remoteUrl,
          width: 84,
          height: 84,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => gradientShell(
            child: fallbackIcon(),
          ),
        ),
      );
    }

    return gradientShell(child: fallbackIcon());
  }
}
