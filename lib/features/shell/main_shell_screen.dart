import 'package:flutter/material.dart';

import '../../core/analytics/analytics_client.dart';
import '../../core/auth/auth_navigator.dart';
import '../../core/auth/auth_service.dart';
import '../../core/l10n/translation_catalog.dart';
import '../../core/moderation/blocked_word_catalog.dart';
import '../../core/models/post.dart';
import '../account/account_screen.dart';
import '../care/care_hub_screen.dart';
import '../chat/tawk_chat_screen.dart';
import '../home/home_screen.dart';
import '../hope/hope_hub_screen.dart';
import '../kid_listo/kid_listo_welcome_screen.dart';
import 'widgets/main_bottom_nav.dart';

/// Root shell that keeps the floating bottom nav visible across the
/// Home / Hope / FAQ / Care / Profile tabs.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.initialPosts,
    this.initialTab = 0,
    this.completeProfileFirst = false,
  });

  final List<Post> initialPosts;
  final int initialTab;
  final bool completeProfileFirst;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;
  bool _authReady = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, 4);
    WidgetsBinding.instance.addPostFrameCallback((_) => _guardAuth());
  }

  Future<void> _guardAuth() async {
    final ok = await AuthService.ensureValidSession();
    if (!mounted) return;
    if (!ok) {
      AuthNavigator.goToLogin(context);
      return;
    }
    setState(() => _authReady = true);
  }

  static const _tabScreens = [
    'Home',
    'Hope',
    'FAQ',
    'Care',
    'Account',
  ];

  void _onTabSelected(int index) {
    TranslationCatalog.prefetch(force: true);
    BlockedWordCatalog.prefetch(force: true);
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    final screen = index >= 0 && index < _tabScreens.length
        ? _tabScreens[index]
        : 'Tab_$index';
    AnalyticsClient.instance.trackScreenView(screen);
  }

  void _openKidListoAfterProfile() {
    if (!AuthNavigator.pendingKidListoAfterProfile) return;
    final posts = AuthNavigator.pendingPosts;
    AuthNavigator.clearProfileSetup();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => KidListoWelcomeScreen(initialPosts: posts),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_authReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            initialPosts: widget.initialPosts,
            onSwitchTab: _onTabSelected,
          ),
          const HopeHubScreen(),
          const TawkChatScreen(embeddedInShell: true),
          const CareHubScreen(),
          AccountScreen(
            embeddedInShell: true,
            completeSetupOnOpen: widget.completeProfileFirst,
            onProfileSetupComplete: _openKidListoAfterProfile,
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
