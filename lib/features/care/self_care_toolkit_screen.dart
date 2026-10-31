import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/options/app_option_catalog.dart';
import '../../core/options/app_option_item.dart';
import 'care_colors.dart';
import 'checks/check_launch.dart';
import 'mood_tracker_screen.dart';
import 'self_care_toolkit/widgets/toolkit_check_tile.dart';
import 'self_care_toolkit/widgets/toolkit_disclaimer.dart';
import 'self_care_toolkit/widgets/toolkit_hero_card.dart';

class SelfCareToolkitScreen extends StatefulWidget {
  const SelfCareToolkitScreen({super.key});

  @override
  State<SelfCareToolkitScreen> createState() => _SelfCareToolkitScreenState();
}

class _SelfCareToolkitScreenState extends State<SelfCareToolkitScreen> {
  @override
  void initState() {
    super.initState();
    AppOptionCatalog.instance.addListener(_onCatalogChanged);
    // Always re-fetch so Lookups Active/Inactive changes show without relaunch.
    AppOptionCatalog.prefetch(force: true);
  }

  @override
  void dispose() {
    AppOptionCatalog.instance.removeListener(_onCatalogChanged);
    super.dispose();
  }

  void _onCatalogChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isTagalog = l10n.isTagalog;
    final toolkits = AppOptionCatalog.careToolkits();

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: CareColors.headingOf(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          l10n.careToolkitTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: CareColors.headingOf(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          ToolkitHeroCard(body: l10n.careToolkitHero),
          const SizedBox(height: 18),
          if (toolkits.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                l10n.careToolkitEmpty,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.35,
                  color: CareColors.headingOf(context).withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ...toolkits.map(
            (item) => ToolkitCheckTile(
              title: item.label(isTagalog: isTagalog),
              subtitle: _subtitleFor(item, isTagalog: isTagalog, l10n: l10n),
              emoji: _emojiFor(item.key),
              onTap: () => openCareCheck(context, item.key),
            ),
          ),
          ToolkitCheckTile(
            title: l10n.careMoodTracker,
            subtitle: l10n.careMoodTrackerBody,
            emoji: '😊',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MoodTrackerScreen()),
            ),
          ),
          const SizedBox(height: 8),
          ToolkitDisclaimer(text: l10n.careToolkitDisclaimer),
        ],
      ),
    );
  }

  String _subtitleFor(
    AppOptionItem item, {
    required bool isTagalog,
    required AppStrings l10n,
  }) {
    final fromCatalog = item.subtitle(isTagalog: isTagalog).trim();
    if (fromCatalog.isNotEmpty) {
      return fromCatalog;
    }
    return switch (item.key) {
      'stress' => l10n.careStressCheckBody,
      'anxiety' => l10n.careAnxietyCheckBody,
      'sleep' => l10n.careSleepQualityBody,
      _ => '',
    };
  }

  String _emojiFor(String key) {
    return switch (key) {
      'stress' => '😟',
      'anxiety' => '😐',
      'sleep' => '😴',
      _ => '🩵',
    };
  }
}
