import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Right-edge blue→red curve used by registration onboarding steps.
class RegistrationCurveBackground extends StatelessWidget {
  const RegistrationCurveBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.white)),
        Positioned(
          top: 0,
          right: 0,
          bottom: 0,
          width: MediaQuery.sizeOf(context).width * 0.42,
          child: const CustomPaint(
            painter: _RegistrationCurvePainter(),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _RegistrationCurvePainter extends CustomPainter {
  const _RegistrationCurvePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.55, 0)
      ..quadraticBezierTo(
        size.width * 0.05,
        size.height * 0.28,
        size.width * 0.35,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.78,
        size.width * 0.2,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primaryBlue,
          AppColors.secondaryBlue,
          AppColors.accentRed,
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RegistrationShell extends StatelessWidget {
  const RegistrationShell({
    super.key,
    required this.child,
    this.onBack,
    this.onNext,
    this.nextLoading = false,
    this.showNextFab = true,
    this.showBack = true,
  });

  final Widget child;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final bool nextLoading;
  final bool showNextFab;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: RegistrationCurveBackground(
        child: SafeArea(
          child: Stack(
            children: [
              if (showBack)
                Positioned(
                  top: 4,
                  left: 8,
                  child: IconButton(
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    showBack ? 48 : 16,
                    24,
                    showNextFab ? 88 + safeBottom : 24 + safeBottom,
                  ),
                  child: child,
                ),
              ),
              if (showNextFab)
                Positioned(
                  right: 0,
                  left: 0,
                  bottom: 16 + safeBottom + (bottomInset > 0 ? 0 : 0),
                  child: Center(
                    child: Material(
                      color: AppColors.primaryBlue,
                      shape: const CircleBorder(),
                      elevation: 4,
                      shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: nextLoading ? null : onNext,
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: nextLoading
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegistrationIconBadge extends StatelessWidget {
  const RegistrationIconBadge({
    super.key,
    required this.child,
    this.backgroundColor = const Color(0xFFE8F1FA),
  });

  final Widget child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}
