import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';

class HomeAssets {
  static const headerGradient = 'assets/home/home_header_gradient.png';
  static const progressArt = 'assets/home/home_progress_art.png';
  static const thoughtArt = 'assets/home/banner_thought_art.png';
  static const continueArt = 'assets/home/banner_continue_art.png';
  static const whatsNewArt = 'assets/home/banner_whatsnew_art.png';
  static const starIcon = 'assets/home/banner_star_icon.png';
  static const liveIcon = 'assets/home/banner_live_icon.png';
}

/// Mock-aligned home header: grainy blue→purple→magenta banner.
class HomeHeaderBanner extends StatelessWidget {
  const HomeHeaderBanner({
    super.key,
    required this.greetingName,
    required this.subtitle,
    required this.unreadNotifications,
    required this.onNotificationTap,
    this.bottomOverlap = 0,
  });

  final String greetingName;
  final String subtitle;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;
  final double bottomOverlap;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.viewPaddingOf(context).top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, topPad + 10, 12, 28 + bottomOverlap),
      decoration: const BoxDecoration(
        color: Color(0xFF4B3CF0),
        image: DecorationImage(
          image: AssetImage(HomeAssets.headerGradient),
          fit: BoxFit.cover,
          alignment: Alignment.center,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onNotificationTap,
            tooltip: context.l10n.notificationsTitle,
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            icon: Badge(
              isLabelVisible: unreadNotifications > 0,
              label: Text(
                unreadNotifications > 99 ? '99+' : '$unreadNotifications',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
              backgroundColor: AppColors.accentRed,
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Legacy non-sliver header kept for smoke tests.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.greetingName,
    required this.subtitle,
    required this.unreadNotifications,
    required this.onNotificationTap,
  });

  final String greetingName;
  final String subtitle;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return HomeHeaderBanner(
      greetingName: greetingName,
      subtitle: subtitle,
      unreadNotifications: unreadNotifications,
      onNotificationTap: onNotificationTap,
    );
  }
}

class HomeCollapsedActions extends StatelessWidget {
  const HomeCollapsedActions({
    super.key,
    required this.unreadNotifications,
    required this.onNotificationTap,
  });

  final int unreadNotifications;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onNotificationTap,
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      icon: Badge(
        isLabelVisible: unreadNotifications > 0,
        label: Text(
          unreadNotifications > 99 ? '99+' : '$unreadNotifications',
          style: const TextStyle(fontSize: 10),
        ),
        backgroundColor: AppColors.accentRed,
        child: const Icon(Icons.notifications_none, color: Colors.white),
      ),
    );
  }
}

class HomeHeaderFlexibleSpace extends StatelessWidget {
  const HomeHeaderFlexibleSpace({
    super.key,
    required this.greetingName,
    required this.subtitle,
    required this.initials,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    this.onSearchSubmitted,
  });

  final String greetingName;
  final String subtitle;
  final String initials;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final ValueChanged<String>? onSearchSubmitted;

  @override
  Widget build(BuildContext context) {
    return HomeHeaderBanner(
      greetingName: greetingName,
      subtitle: subtitle,
      unreadNotifications: 0,
      onNotificationTap: () {},
    );
  }
}
