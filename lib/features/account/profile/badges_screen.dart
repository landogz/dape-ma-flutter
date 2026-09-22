import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../widgets/badge_medallion.dart';
import '../widgets/profile_list_widgets.dart';
import 'profile_models.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key, required this.badges});

  final List<ProfileBadge> badges;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final earned = badges.where((b) => b.earned).toList();
    final display = earned.isNotEmpty ? earned : badges;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          children: [
            ProfileListHeader(title: l10n.myBadges),
            Expanded(
              child: display.isEmpty
                  ? ProfileListEmptyState(
                      icon: Icons.workspace_premium_outlined,
                      title: l10n.noActivityYet,
                      body: l10n.earnMoreBadgesFooter,
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        8,
                        20,
                        20 + bottomSafe,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: display.length,
                      itemBuilder: (context, index) {
                        final badge = display[index];
                        final color = profileBadgeColor(badge.color);
                        return Container(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
                          decoration: BoxDecoration(
                            color: context.cardBackground,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: context.borderSubtle),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: context.isDarkMode ? 0.25 : 0.05,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              BadgeMedallion(
                                icon: profileBadgeIcon(badge.key),
                                color: color,
                                earned: badge.earned,
                                size: 78,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                badge.title,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Text(
                                  badge.description,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 12 + bottomSafe * 0.3),
              child: Text(
                l10n.earnMoreBadgesFooter,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryBlue.withValues(alpha: 0.85),
                  fontSize: 12.5,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
