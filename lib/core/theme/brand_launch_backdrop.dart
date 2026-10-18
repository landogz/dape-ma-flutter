import 'package:flutter/material.dart';

import 'app_colors.dart';

class BrandLaunchBackdrop extends StatelessWidget {
  const BrandLaunchBackdrop({super.key, this.child});

  final Widget? child;

  static const gradient = LinearGradient(
    colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const IgnorePointer(child: _SoftRadialLight()),
          if (child != null) child!,
        ],
      ),
    );
  }
}

class _SoftRadialLight extends StatelessWidget {
  const _SoftRadialLight();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.08),
          radius: 0.82,
          colors: [
            Colors.white.withValues(alpha: 0.14),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class BrandSeal extends StatelessWidget {
  const BrandSeal({
    super.key,
    this.size = 128,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.35),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.16),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Image.asset(
          'assets/ddb.png',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
