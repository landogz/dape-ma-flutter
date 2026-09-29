import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/auth_decor.dart';
import '../../widgets/auth_scaffold.dart';

/// Final onboarding step — same light + navy auth chrome as Login/Register.
class SuccessStep extends StatelessWidget {
  const SuccessStep({
    super.key,
    required this.onFinish,
    this.loading = false,
  });

  final VoidCallback onFinish;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const AuthBrandMark(sealSize: 80),
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: AppColors.softGold,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🥳', style: TextStyle(fontSize: 34)),
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: AuthTokens.headlineSize,
              fontWeight: AuthTokens.headlineWeight,
              color: AppColors.nileBlue,
              height: 1.3,
            ),
            children: [
              TextSpan(text: l10n.regSuccessTitlePrefix),
              TextSpan(
                text: l10n.regSuccessTitleHighlight,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.mediumElectricBlue,
                ),
              ),
              TextSpan(text: l10n.regSuccessTitleSuffix),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        _FeatureCard(
          title: l10n.regFeatureLearnTitle,
          subtitle: l10n.regFeatureLearnBody,
          color: AppColors.mediumElectricBlue,
          iconBackground: AppColors.softBlue,
          icon: Icons.menu_book_rounded,
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          title: l10n.regFeatureHopeTitle,
          subtitle: l10n.regFeatureHopeBody,
          color: AppColors.accentPurple,
          iconBackground: AppColors.softPurple,
          icon: Icons.groups_rounded,
        ),
        const SizedBox(height: 10),
        _FeatureCard(
          title: l10n.regFeatureCareTitle,
          subtitle: l10n.regFeatureCareBody,
          color: AppColors.nileBlue,
          iconBackground: AppColors.softBlue,
          icon: Icons.favorite_rounded,
        ),
        const SizedBox(height: 24),
        AuthSubtext(l10n.regSuccessReady),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AuthTokens.muted,
            ),
            children: [
              TextSpan(
                text: l10n.regSuccessCtaLearn,
                style: const TextStyle(color: AppColors.mediumElectricBlue),
              ),
              TextSpan(text: l10n.regSuccessCtaMid),
              TextSpan(
                text: l10n.regSuccessCtaHope,
                style: const TextStyle(color: AppColors.accentPurple),
              ),
              TextSpan(text: l10n.regSuccessCtaAnd),
              TextSpan(
                text: l10n.regSuccessCtaCare,
                style: const TextStyle(color: AppColors.nileBlue),
              ),
              TextSpan(text: l10n.regSuccessCtaEnd),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        AuthPrimaryButton(
          label: l10n.continueLabel,
          loading: loading,
          onPressed: onFinish,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconBackground,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final Color iconBackground;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AuthTokens.muted,
                    height: 1.35,
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
