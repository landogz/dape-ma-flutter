import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import 'care_colors.dart';
import 'checks/stress_check_screen.dart';
import 'mood_tracker_screen.dart';

class SelfCareToolkitScreen extends StatelessWidget {
  const SelfCareToolkitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: CareColors.mintSoft,
      appBar: AppBar(
        backgroundColor: CareColors.mintSoft,
        foregroundColor: CareColors.greenText,
        elevation: 0,
        title: Text(
          l10n.careToolkitTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: CareColors.mint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.careToolkitHero,
                    style: const TextStyle(
                      color: CareColors.greenText,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.volunteer_activism_rounded,
                  size: 48,
                  color: CareColors.teal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ToolkitTile(
            title: l10n.careStressCheck,
            subtitle: l10n.careStressCheckBody,
            icon: Icons.cloud_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const StressCheckScreen()),
            ),
          ),
          _ToolkitTile(
            title: l10n.careAnxietyCheck,
            subtitle: l10n.careAnxietyCheckBody,
            icon: Icons.sentiment_dissatisfied_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AnxietyCheckScreen()),
            ),
          ),
          _ToolkitTile(
            title: l10n.careSleepQuality,
            subtitle: l10n.careSleepQualityBody,
            icon: Icons.bedtime_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SleepQualityScreen()),
            ),
          ),
          _ToolkitTile(
            title: l10n.careMoodTracker,
            subtitle: l10n.careMoodTrackerBody,
            icon: Icons.mood_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MoodTrackerScreen()),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: CareColors.mint,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.eco_rounded, color: CareColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.careToolkitDisclaimer,
                    style: const TextStyle(
                      color: CareColors.greenText,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolkitTile extends StatelessWidget {
  const _ToolkitTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: CareColors.mint,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: CareColors.tealDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: CareColors.greenText,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
