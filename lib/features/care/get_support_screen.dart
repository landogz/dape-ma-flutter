import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import 'care_colors.dart';
import 'support/support_pages.dart';

class GetSupportScreen extends StatelessWidget {
  const GetSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: CareColors.mintSoft,
      appBar: AppBar(
        backgroundColor: CareColors.mintSoft,
        foregroundColor: CareColors.greenText,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.careGetSupportTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: CareColors.mint),
            ),
            child: Column(
              children: [
                const Icon(Icons.favorite_rounded,
                    size: 56, color: AppColors.fireEngineRed),
                const SizedBox(height: 12),
                Text(
                  l10n.careGetSupportHero1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: CareColors.greenText,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.careGetSupportHero2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: CareColors.mutedText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _SupportTile(
            title: l10n.careHotlines,
            subtitle: l10n.careHotlinesBody,
            color: AppColors.softPurple,
            iconColor: AppColors.accentPurple,
            icon: Icons.chat_bubble_outline,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HotlinesScreen()),
            ),
          ),
          _SupportTile(
            title: l10n.careCounseling,
            subtitle: l10n.careCounselingBody,
            color: AppColors.softBlue,
            iconColor: AppColors.mediumElectricBlue,
            icon: Icons.phone_in_talk_outlined,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CounselingScreen()),
            ),
          ),
          _SupportTile(
            title: l10n.careCrisis,
            subtitle: l10n.careCrisisBody,
            color: AppColors.softRed,
            iconColor: AppColors.fireEngineRed,
            icon: Icons.warning_amber_rounded,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CrisisSupportScreen()),
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
              children: [
                const Icon(Icons.eco_rounded, color: CareColors.teal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.careSupportFooter,
                    style: const TextStyle(
                      color: CareColors.greenText,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
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

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor),
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
                const Icon(Icons.chevron_right_rounded,
                    color: CareColors.greenText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
