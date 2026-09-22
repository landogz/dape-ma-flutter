import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/registration_shell.dart';

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

    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primaryBlue,
                    Color(0xFF7C3AED),
                    AppColors.accentRed,
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: _ConfettiLayer()),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        const RegistrationIconBadge(
                          backgroundColor: Color(0xFFFFF7D6),
                          child: Text('🥳', style: TextStyle(fontSize: 34)),
                        ),
                        const SizedBox(height: 16),
                        Text.rich(
                          TextSpan(
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                              height: 1.3,
                            ),
                            children: [
                              TextSpan(text: l10n.regSuccessTitlePrefix),
                              TextSpan(
                                text: l10n.regSuccessTitleHighlight,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryBlue,
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
                          color: AppColors.primaryBlue,
                          icon: Icons.menu_book_rounded,
                        ),
                        const SizedBox(height: 10),
                        _FeatureCard(
                          title: l10n.regFeatureHopeTitle,
                          subtitle: l10n.regFeatureHopeBody,
                          color: const Color(0xFFDB2777),
                          icon: Icons.groups_rounded,
                        ),
                        const SizedBox(height: 10),
                        _FeatureCard(
                          title: l10n.regFeatureCareTitle,
                          subtitle: l10n.regFeatureCareBody,
                          color: const Color(0xFF0D9488),
                          icon: Icons.favorite_rounded,
                        ),
                        const Spacer(),
                        Text(
                          l10n.regSuccessReady,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                            children: [
                              TextSpan(
                                text: l10n.regSuccessCtaLearn,
                                style: const TextStyle(color: AppColors.primaryBlue),
                              ),
                              TextSpan(text: l10n.regSuccessCtaMid),
                              TextSpan(
                                text: l10n.regSuccessCtaHope,
                                style: const TextStyle(color: Color(0xFFDB2777)),
                              ),
                              TextSpan(text: l10n.regSuccessCtaAnd),
                              TextSpan(
                                text: l10n.regSuccessCtaCare,
                                style: const TextStyle(color: Color(0xFF0D9488)),
                              ),
                              TextSpan(text: l10n.regSuccessCtaEnd),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 18),
                        Material(
                          color: AppColors.primaryBlue,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: loading ? null : onFinish,
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: loading
                                  ? const Padding(
                                      padding: EdgeInsets.all(18),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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

class _ConfettiLayer extends StatelessWidget {
  const _ConfettiLayer();

  @override
  Widget build(BuildContext context) {
    final random = math.Random(11);
    return IgnorePointer(
      child: Stack(
        children: List.generate(36, (index) {
          final left = random.nextDouble();
          final top = random.nextDouble();
          final size = 5.0 + random.nextDouble() * 8;
          final colors = [
            AppColors.accentYellow,
            Colors.white,
            const Color(0xFFF9A8D4),
            const Color(0xFF93C5FD),
          ];
          return Positioned(
            left: left * MediaQuery.sizeOf(context).width,
            top: top * MediaQuery.sizeOf(context).height * 0.55,
            child: Transform.rotate(
              angle: random.nextDouble() * math.pi,
              child: Container(
                width: size,
                height: size * 0.45,
                color: colors[index % colors.length],
              ),
            ),
          );
        }),
      ),
    );
  }
}
