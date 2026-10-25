import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class CheckGauge extends StatelessWidget {
  const CheckGauge({
    super.key,
    required this.highTier,
  });

  final bool highTier;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      width: 240,
      child: CustomPaint(
        painter: _GaugePainter(highTier: highTier),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.highTier});

  final bool highTier;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.86);
    final radius = math.min(size.width / 2, size.height) - 8;
    const start = math.pi;
    const sweep = math.pi;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.butt;

    void arc(Color color, double from, double span) {
      track.color = color;
      canvas.drawArc(rect, start + from * sweep, span * sweep, false, track);
    }

    arc(const Color(0xFF22C55E), 0, 0.34);
    arc(AppColors.brightGold, 0.34, 0.32);
    arc(AppColors.fireEngineRed, 0.66, 0.34);

    final needleT = highTier ? 0.82 : 0.22;
    final angle = start + (needleT * sweep);
    final needle = Offset(
      center.dx + math.cos(angle) * (radius - 18),
      center.dy + math.sin(angle) * (radius - 18),
    );
    final needlePaint = Paint()
      ..color = AppColors.nileBlue
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needle, needlePaint);
    canvas.drawCircle(center, 8, Paint()..color = AppColors.nileBlue);
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.highTier != highTier;
}
