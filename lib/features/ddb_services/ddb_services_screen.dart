import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../contests/contests_screen.dart';
import '../rehab_centers/rehab_centers_screen.dart';
import '../trainings/trainings_screen.dart';
import '../iec_materials/iec_materials_screen.dart';

class DdbServicesScreen extends StatelessWidget {
  const DdbServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ddbServicesTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Text(
              l10n.ddbServicesSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondary,
                  ),
            ),
            const SizedBox(height: 20),
            _ServiceTile(
              icon: Icons.school_outlined,
              title: l10n.trainingsTitle,
              subtitle: l10n.trainingsSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrainingsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ServiceTile(
              icon: Icons.animation_outlined,
              title: l10n.iecMaterialsTitle,
              subtitle: l10n.iecMaterialsSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const IecMaterialsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            _ServiceTile(
              icon: Icons.local_hospital_outlined,
              title: l10n.rehabCentersTitle,
              subtitle: l10n.rehabCentersSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RehabCentersScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _ServiceTile(
              icon: Icons.emoji_events_outlined,
              title: l10n.contestsTitle,
              subtitle: l10n.contestsSubtitle,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContestsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackground,
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: context.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
