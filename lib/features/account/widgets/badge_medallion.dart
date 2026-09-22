import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

IconData profileBadgeIcon(String key) {
  switch (key) {
    case 'healthy_decision_maker':
      return Icons.search_rounded;
    case 'empowered_peer':
      return Icons.handshake_rounded;
    case 'stress_buster':
      return Icons.bolt_rounded;
    case 'dape_champion':
      return Icons.emoji_events_rounded;
    default:
      return Icons.star_rounded;
  }
}

Color profileBadgeColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return AppColors.primaryBlue;
  return Color(int.parse('FF$cleaned', radix: 16));
}

/// Colorful starburst badge medallion used on Badges / Gains screens.
class BadgeMedallion extends StatelessWidget {
  const BadgeMedallion({
    super.key,
    required this.icon,
    required this.color,
    this.size = 72,
    this.earned = true,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool earned;

  @override
  Widget build(BuildContext context) {
    final fill = earned ? color : Colors.grey.shade400;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _StarburstPainter(
              color: fill.withValues(alpha: earned ? 0.35 : 0.22),
            ),
          ),
          Container(
            width: size * 0.72,
            height: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: earned
                    ? [Color.lerp(fill, Colors.white, 0.25)!, fill]
                    : [Colors.grey.shade300, Colors.grey.shade500],
              ),
              boxShadow: earned
                  ? [
                      BoxShadow(
                        color: fill.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Icon(
              earned ? icon : Icons.lock_outline_rounded,
              color: Colors.white,
              size: size * 0.32,
            ),
          ),
        ],
      ),
    );
  }
}

class _StarburstPainter extends CustomPainter {
  _StarburstPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width / 2;
    final inner = outer * 0.72;
    const spikes = 12;
    final path = Path();
    for (var i = 0; i < spikes * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = (i * math.pi / spikes) - math.pi / 2;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _StarburstPainter oldDelegate) =>
      oldDelegate.color != color;
}
