import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/auth_decor.dart';

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen({super.key});

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
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF7C3AED),
                    Color(0xFF055498),
                    Color(0xFF123A60),
                  ],
                ),
              ),
            ),
          ),
          const Positioned.fill(child: _ConfettiLayer()),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        l10n.verificationSuccessful,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.secondaryBlue,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.verificationSuccessfulBody,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primaryBlue.withValues(alpha: 0.8),
                          fontSize: 14,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 28),
                      AuthPrimaryButton(
                        label: l10n.continueToApp,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ),
              ),
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
    final random = math.Random(7);
    return IgnorePointer(
      child: Stack(
        children: List.generate(28, (index) {
          final left = random.nextDouble();
          final top = random.nextDouble();
          final size = 6.0 + random.nextDouble() * 8;
          final colors = [
            AppColors.accentYellow,
            Colors.white,
            const Color(0xFFF472B6),
            const Color(0xFF67E8F9),
          ];
          return Positioned(
            left: MediaQuery.sizeOf(context).width * left,
            top: MediaQuery.sizeOf(context).height * top,
            child: Transform.rotate(
              angle: random.nextDouble() * math.pi,
              child: Container(
                width: size,
                height: size * 0.45,
                decoration: BoxDecoration(
                  color: colors[index % colors.length],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
