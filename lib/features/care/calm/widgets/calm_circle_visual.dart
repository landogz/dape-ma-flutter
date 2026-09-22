import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../care_colors.dart';

/// Circular calm visual with optional progress ring + leaf accents.
class CalmCircleVisual extends StatelessWidget {
  const CalmCircleVisual({
    super.key,
    required this.child,
    this.progress = 0,
    this.size = 220,
    this.fillColor = CareColors.calmMint,
  });

  final Widget child;
  final double progress;
  final double size;
  final Color fillColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size + 48,
      height: size + 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 8,
            bottom: 28,
            child: Transform.rotate(
              angle: -0.4,
              child: Icon(
                Icons.eco_rounded,
                size: 48,
                color: CareColors.calmForest.withValues(alpha: 0.35),
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 28,
            child: Transform.rotate(
              angle: 0.4,
              child: Icon(
                Icons.eco_rounded,
                size: 48,
                color: CareColors.calmForest.withValues(alpha: 0.35),
              ),
            ),
          ),
          CustomPaint(
            size: Size(size + 16, size + 16),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0),
              trackColor: CareColors.calmRing,
              progressColor: CareColors.calmForest,
            ),
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fillColor,
              boxShadow: [
                BoxShadow(
                  color: CareColors.calmForest.withValues(alpha: 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, track);

    if (progress > 0) {
      final arc = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        arc,
      );
    }

    final angle = -math.pi / 2 + 2 * math.pi * progress;
    final dot = Offset(
      center.dx + radius * math.cos(angle),
      center.dy + radius * math.sin(angle),
    );
    canvas.drawCircle(dot, 5, Paint()..color = progressColor);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
