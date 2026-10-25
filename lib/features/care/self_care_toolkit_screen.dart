import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import 'care_colors.dart';
import 'checks/check_launch.dart';
import 'mood_tracker_screen.dart';
import 'self_care_toolkit/widgets/toolkit_check_tile.dart';
import 'self_care_toolkit/widgets/toolkit_disclaimer.dart';
import 'self_care_toolkit/widgets/toolkit_hero_card.dart';

class SelfCareToolkitScreen extends StatelessWidget {
  const SelfCareToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
          ToolkitCheckTile(
            title: l10n.careStressCheck,
            subtitle: l10n.careStressCheckBody,
            emoji: '😟',
            onTap: () => openCareCheck(context, 'stress'),
          ),
          ToolkitCheckTile(
            title: l10n.careAnxietyCheck,
            subtitle: l10n.careAnxietyCheckBody,
            emoji: '😐',
            onTap: () => openCareCheck(context, 'anxiety'),
          ),
          ToolkitCheckTile(
            title: l10n.careSleepQuality,
            subtitle: l10n.careSleepQualityBody,
            emoji: '😴',
            onTap: () => openCareCheck(context, 'sleep'),
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
}
