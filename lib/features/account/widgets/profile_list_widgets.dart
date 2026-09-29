import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/api_url.dart';

/// Shared empty state used by Bookmarks / Lessons / Articles list pages.
class ProfileListEmptyState extends StatelessWidget {
  const ProfileListEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor = AppColors.primaryBlue,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileListHeader extends StatelessWidget {
  const ProfileListHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            color: context.textPrimary,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: context.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Compact content row for Lessons / Articles / Bookmarks lists.
class ProfileContentTile extends StatelessWidget {
  const ProfileContentTile({
    super.key,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.meta,
    this.imageUrl,
    this.icon = Icons.article_outlined,
    this.iconColor = AppColors.primaryBlue,
    this.iconBackground = const Color(0xFFDBEAFE),
    this.trailing,
    this.chipSubtitle = true,
  });

  final String title;
  final String? subtitle;
  final String? meta;
  final String? imageUrl;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool chipSubtitle;

  @override
  Widget build(BuildContext context) {
    final resolvedImage = ApiUrl.resolve(imageUrl);

    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDarkMode ? 0.25 : 0.05,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              if (resolvedImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    resolvedImage,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _IconBox(
                      icon: icon,
                      color: iconColor,
                      background: iconBackground,
                    ),
                  ),
                )
              else
                _IconBox(
                  icon: icon,
                  color: iconColor,
                  background: iconBackground,
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        height: 1.25,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      if (chipSubtitle)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Text(
                          subtitle!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textSecondary,
                            fontSize: 12.5,
                            height: 1.3,
                          ),
                        ),
                    ],
                    if (meta != null && meta!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.textSecondary.withValues(alpha: 0.7),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 26),
    );
  }
}

({IconData icon, Color color, Color background}) profileCategoryStyle(
  String? slug,
) {
  switch ((slug ?? '').toLowerCase()) {
    case 'rehabilitation':
    case 'rehab':
      return (
        icon: Icons.favorite_outline_rounded,
        color: AppColors.accentRed,
        background: const Color(0xFFFEE2E2),
      );
    case 'prevention':
    case 'drug-effects':
      return (
        icon: Icons.menu_book_rounded,
        color: AppColors.primaryBlue,
        background: const Color(0xFFDBEAFE),
      );
    case 'iec':
    case 'lesson':
      return (
        icon: Icons.school_rounded,
        color: const Color(0xFF7C3AED),
        background: const Color(0xFFEDE9FE),
      );
    case 'legal':
      return (
        icon: Icons.gavel_rounded,
        color: const Color(0xFF0F766E),
        background: const Color(0xFFCCFBF1),
      );
    case 'news':
      return (
        icon: Icons.newspaper_rounded,
        color: AppColors.brightGold,
        background: const Color(0xFFFFEDD5),
      );
    default:
      return (
        icon: Icons.article_outlined,
        color: AppColors.primaryBlue,
        background: const Color(0xFFDBEAFE),
      );
  }
}
