import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import 'settings_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _loading = true;
  bool _allow = true;
  bool _articles = true;
  bool _achievements = true;
  bool _events = true;
  bool _updates = true;
  bool _quietHours = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allow = await SettingsPreferences.getBool(
      SettingsPreferences.allowNotifications,
      fallback: true,
    );
    final articles = await SettingsPreferences.getBool(
      SettingsPreferences.notifyArticles,
      fallback: true,
    );
    final achievements = await SettingsPreferences.getBool(
      SettingsPreferences.notifyAchievements,
      fallback: true,
    );
    final events = await SettingsPreferences.getBool(
      SettingsPreferences.notifyEvents,
      fallback: true,
    );
    final updates = await SettingsPreferences.getBool(
      SettingsPreferences.notifyUpdates,
      fallback: true,
    );
    final quiet = await SettingsPreferences.getBool(
      SettingsPreferences.quietHours,
      fallback: false,
    );

    if (!mounted) return;
    setState(() {
      _allow = allow;
      _articles = articles;
      _achievements = achievements;
      _events = events;
      _updates = updates;
      _quietHours = quiet;
      _loading = false;
    });
  }

  Future<void> _set(String key, bool value, void Function(bool) assign) async {
    assign(value);
    setState(() {});
    await SettingsPreferences.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                        ),
                        color: context.textPrimary,
                        tooltip:
                            MaterialLocalizations.of(context).backButtonTooltip,
                      ),
                      Expanded(
                        child: Text(
                          l10n.notificationSettingsTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _SettingsCard(
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: AppColors.accentPurple,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.allowNotifications,
                                style: TextStyle(
                                  color: context.textPrimary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.allowNotificationsBody,
                                style: TextStyle(
                                  color: context.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _allow,
                          activeTrackColor: AppColors.primaryBlue,
                          onChanged: (value) => _set(
                            SettingsPreferences.allowNotifications,
                            value,
                            (v) => _allow = v,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l10n.notificationTypes,
                    style: TextStyle(
                      color: AppColors.primaryBlue.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: _allow ? 1 : 0.5,
                    child: _SettingsCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _PrefRow(
                            title: l10n.notifyArticles,
                            subtitle: l10n.notifyArticlesBody,
                            icon: Icons.menu_book_rounded,
                            iconBackground: const Color(0xFFDBEAFE),
                            iconColor: AppColors.primaryBlue,
                            value: _articles && _allow,
                            enabled: _allow,
                            onChanged: (value) => _set(
                              SettingsPreferences.notifyArticles,
                              value,
                              (v) => _articles = v,
                            ),
                          ),
                          Divider(height: 1, color: context.borderSubtle),
                          _PrefRow(
                            title: l10n.notifyAchievements,
                            subtitle: l10n.notifyAchievementsBody,
                            icon: Icons.workspace_premium_rounded,
                            iconBackground: const Color(0xFFEDE9FE),
                            iconColor: AppColors.accentPurple,
                            value: _achievements && _allow,
                            enabled: _allow,
                            onChanged: (value) => _set(
                              SettingsPreferences.notifyAchievements,
                              value,
                              (v) => _achievements = v,
                            ),
                          ),
                          Divider(height: 1, color: context.borderSubtle),
                          _PrefRow(
                            title: l10n.notifyEvents,
                            subtitle: l10n.notifyEventsBody,
                            icon: Icons.play_circle_filled_rounded,
                            iconBackground: const Color(0xFFFEE2E2),
                            iconColor: AppColors.accentRed,
                            value: _events && _allow,
                            enabled: _allow,
                            onChanged: (value) => _set(
                              SettingsPreferences.notifyEvents,
                              value,
                              (v) => _events = v,
                            ),
                          ),
                          Divider(height: 1, color: context.borderSubtle),
                          _PrefRow(
                            title: l10n.notifyUpdates,
                            subtitle: l10n.notifyUpdatesBody,
                            icon: Icons.system_update_rounded,
                            iconBackground: const Color(0xFFFFEDD5),
                            iconColor: AppColors.brightGold,
                            value: _updates && _allow,
                            enabled: _allow,
                            onChanged: (value) => _set(
                              SettingsPreferences.notifyUpdates,
                              value,
                              (v) => _updates = v,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    l10n.quietHours,
                    style: TextStyle(
                      color: AppColors.primaryBlue.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: _allow ? 1 : 0.5,
                    child: _SettingsCard(
                      child: _PrefRow(
                        dense: true,
                        title: l10n.quietHoursLabel,
                        subtitle: l10n.quietHoursRange,
                        icon: Icons.nightlight_round,
                        iconBackground: const Color(0xFFEDE9FE),
                        iconColor: AppColors.accentPurple,
                        value: _quietHours && _allow,
                        enabled: _allow,
                        onChanged: (value) => _set(
                          SettingsPreferences.quietHours,
                          value,
                          (v) => _quietHours = v,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sync_rounded,
                        size: 16,
                        color: AppColors.accentPurple.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.changeAnytime,
                        style: TextStyle(
                          color: context.textSecondary.withValues(alpha: 0.85),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(18),
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
      child: child,
    );
  }
}

class _PrefRow extends StatelessWidget {
  const _PrefRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.dense = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 0 : 14,
        vertical: dense ? 0 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.primaryBlue,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
