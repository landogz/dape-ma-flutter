import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';

class ProfileCompletenessAvatar extends StatelessWidget {
  const ProfileCompletenessAvatar({
    super.key,
    required this.progress,
    required this.child,
    this.radius = 42,
  });

  /// 0.0 – 1.0
  final double progress;
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final ringSize = radius * 2 + 10;

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: CircularProgressIndicator(
              value: clamped <= 0 ? 0.02 : clamped,
              strokeWidth: 3.5,
              backgroundColor: Colors.white.withValues(alpha: 0.28),
              valueColor: AlwaysStoppedAnimation<Color>(
                clamped >= 1
                    ? const Color(0xFF4ADE80)
                    : Colors.white,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  const ProfileStatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: context.isDarkMode ? 0.25 : 0.06,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: context.isDarkMode
                    ? context.textPrimary
                    : AppColors.secondaryBlue,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: (context.isDarkMode
                      ? context.textSecondary
                      : AppColors.secondaryBlue)
                  .withValues(alpha: 0.85),
              fontSize: 11,
              height: 1.1,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      ),
    );
  }
}

class ProfileQuickLinkTile extends StatelessWidget {
  const ProfileQuickLinkTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDarkMode ? 0.25 : 0.05,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.isDarkMode
                            ? context.textPrimary
                            : AppColors.secondaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

class ProfileBadgeChip extends StatelessWidget {
  const ProfileBadgeChip({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.earned,
    this.onTap,
    this.compact = false,
    this.expand = false,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool earned;
  final VoidCallback? onTap;
  final bool compact;
  final bool expand;

  static const lockedLabelColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final circleSize = compact ? 52.0 : 78.0;
    final iconSize = compact ? (earned ? 22.0 : 18.0) : (earned ? 32.0 : 26.0);
    final labelSize = compact ? 10.0 : 11.0;
    final labelMinHeight = compact ? 28.0 : 32.0;
    final columnWidth = expand ? null : (compact ? circleSize + 12 : 108.0);

    final chip = SizedBox(
      width: columnWidth ?? double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: expand ? 4 : 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: earned
                      ? RadialGradient(
                          colors: [
                            color.withValues(alpha: 0.95),
                            color.withValues(alpha: 0.7),
                          ],
                        )
                      : null,
                  color: earned ? null : Colors.grey.shade300,
                  boxShadow: earned
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                  border: Border.all(
                    color: earned ? Colors.white : Colors.grey.shade400,
                    width: compact ? 2 : 3,
                  ),
                ),
                child: Icon(
                  earned ? icon : Icons.lock_outline_rounded,
                  color: earned ? Colors.white : Colors.grey.shade600,
                  size: iconSize,
                ),
              ),
            ),
            SizedBox(height: compact ? 6 : 8),
            SizedBox(
              height: labelMinHeight,
              width: double.infinity,
              child: ClipRect(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: earned
                        ? (context.isDarkMode
                            ? context.textPrimary
                            : AppColors.secondaryBlue)
                        : (context.isDarkMode
                            ? const Color(0xFF9CA3AF)
                            : lockedLabelColor),
                    fontSize: labelSize,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return chip;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: chip,
    );
  }
}
