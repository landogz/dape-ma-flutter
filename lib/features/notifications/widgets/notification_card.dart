import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../models/app_notification.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.item,
    required this.typeLabel,
    required this.timeLabel,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.onTap,
  });

  final AppNotification item;
  final String typeLabel;
  final String timeLabel;
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = (item.body != null && item.body!.trim().isNotEmpty)
        ? item.body!.trim()
        : item.title;

    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: context.isDarkMode ? 0.28 : 0.05,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    if (timeLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        timeLabel,
                        style: TextStyle(
                          color: context.textSecondary.withValues(alpha: 0.9),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.isUnread)
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 2),
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppColors.accentPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
