import 'package:flutter/material.dart';

import '../../core/auth/auth_navigator.dart';
import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../account/edit_profile_screen.dart';
import '../account/widgets/logout_confirm_dialog.dart';
import '../account/widgets/settings_hero_header.dart';
import '../account/widgets/settings_menu_tile.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import 'about_screen.dart';
import 'accessibility_settings_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_use_screen.dart';

class SettingsHubScreen extends StatefulWidget {
  const SettingsHubScreen({super.key});

  @override
  State<SettingsHubScreen> createState() => _SettingsHubScreenState();
}

class _SettingsHubScreenState extends State<SettingsHubScreen> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    setState(() {
      _loggedIn = token != null && token.isNotEmpty;
      _checking = false;
    });
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) await _checkAuth();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showLogoutConfirmDialog(context);
    if (!confirmed || !mounted) return;

    try {
      await AuthService.authedPost<Map<String, dynamic>>(Endpoints.logout);
    } catch (_) {
      // ignore API errors on logout
    } finally {
      await AuthService.logout();
      if (mounted) {
        AuthNavigator.goToLogin(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: _checking
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                children: [
                  SettingsHeroHeader(
                    showBack: true,
                    icon: Icons.settings_rounded,
                    title: l10n.settingsTitle,
                    subtitle: l10n.settingsSubtitle,
                    iconBackground: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: 28),
                  if (!_loggedIn) ...[
                    _GuestAuthCard(
                      onLogin: () => _open(const LoginScreen()),
                      onRegister: () => _open(const RegisterScreen()),
                      onForgot: () => _open(const ForgotPasswordScreen()),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    SettingsMenuTile(
                      title: l10n.editProfile,
                      subtitle: l10n.editProfileSubtitle,
                      icon: Icons.person_rounded,
                      iconBackground: const Color(0xFFE8E0F5),
                      iconColor: const Color(0xFF6D28D9),
                      onTap: () => _open(const EditProfileScreen()),
                    ),
                    const SizedBox(height: 12),
                    SettingsMenuTile(
                      title: l10n.notificationsMenu,
                      subtitle: l10n.notificationsMenuSubtitle,
                      icon: Icons.notifications_rounded,
                      iconBackground: const Color(0xFFFFE8D6),
                      iconColor: AppColors.brightGold,
                      onTap: () => _open(const NotificationSettingsScreen()),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SettingsMenuTile(
                    title: l10n.privacyPolicy,
                    subtitle: l10n.privacyPolicySubtitle,
                    icon: Icons.shield_rounded,
                    iconBackground: context.isDarkMode
                        ? const Color(0xFF14532D)
                        : const Color(0xFFDCFCE7),
                    iconColor: context.isDarkMode
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFF16A34A),
                    onTap: () => _open(const PrivacyPolicyScreen()),
                  ),
                  const SizedBox(height: 12),
                  SettingsMenuTile(
                    title: l10n.termsOfUse,
                    subtitle: l10n.termsOfUseSubtitle,
                    icon: Icons.description_rounded,
                    iconBackground: context.isDarkMode
                        ? const Color(0xFF0C4A6E)
                        : const Color(0xFFE0F2FE),
                    iconColor: context.isDarkMode
                        ? const Color(0xFF7DD3FC)
                        : AppColors.primaryBlue,
                    onTap: () => _open(const TermsOfUseScreen()),
                  ),
                  const SizedBox(height: 12),
                  SettingsMenuTile(
                    title: l10n.accessibility,
                    subtitle: l10n.accessibilitySubtitle,
                    icon: Icons.accessibility_new_rounded,
                    iconBackground: const Color(0xFFFFE4E6),
                    iconColor: const Color(0xFFE11D48),
                    onTap: () => _open(const AccessibilitySettingsScreen()),
                  ),
                  const SizedBox(height: 12),
                  SettingsMenuTile(
                    title: l10n.aboutApp,
                    subtitle: l10n.aboutAppSubtitle,
                    icon: Icons.info_rounded,
                    iconBackground: const Color(0xFFEDE9FE),
                    iconColor: const Color(0xFF7C3AED),
                    onTap: () => _open(const AboutScreen()),
                  ),
                  if (_loggedIn) ...[
                    const SizedBox(height: 20),
                    SettingsMenuTile(
                      title: l10n.logOut,
                      subtitle: l10n.logOutSubtitle,
                      icon: Icons.logout_rounded,
                      iconBackground: context.cardBackground,
                      iconColor: AppColors.accentRed,
                      destructive: true,
                      onTap: _confirmLogout,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _GuestAuthCard extends StatelessWidget {
  const _GuestAuthCard({
    required this.onLogin,
    required this.onRegister,
    required this.onForgot,
  });

  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final VoidCallback onForgot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.softBrandSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.welcomeTitle,
            style: const TextStyle(
              color: AppColors.secondaryBlue,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.welcomeBody,
            style: TextStyle(
              color: AppColors.primaryBlue.withValues(alpha: 0.85),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.login),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onRegister,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                side: const BorderSide(color: AppColors.primaryBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.register),
            ),
          ),
          TextButton(
            onPressed: onForgot,
            child: Text(
              l10n.forgotPassword,
              style: const TextStyle(color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}
