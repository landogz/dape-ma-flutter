import 'package:flutter/material.dart';

import '../../core/models/post.dart';
import '../account/account_screen.dart';
import '../care/care_hub_screen.dart';
import '../chat/botpress_chat_screen.dart';
import '../home/home_screen.dart';
import '../hope/hope_hub_screen.dart';
import 'widgets/main_bottom_nav.dart';

/// Root shell that keeps the floating bottom nav visible across the
/// Home / Hope / FAQ / Care / Profile tabs.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.initialPosts,
    this.initialTab = 0,
  });

  final List<Post> initialPosts;
  final int initialTab;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab.clamp(0, 4);
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
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
          const BotpressChatScreen(embeddedInShell: true),
          const CareHubScreen(),
          const AccountScreen(embeddedInShell: true),
        ],
      ),
      bottomNavigationBar: MainBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
