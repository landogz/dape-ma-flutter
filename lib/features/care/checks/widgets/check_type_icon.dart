import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CheckTypeIcon extends StatelessWidget {
  const CheckTypeIcon({
    super.key,
    required this.checkType,
    this.size = 72,
  });

  final String checkType;
  final double size;

  IconData get _icon {
    return switch (checkType) {
      'stress' => Icons.monitor_heart_rounded,
      'anxiety' => Icons.self_improvement_rounded,
      _ => Icons.bedtime_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.42;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.mediumElectricBlue.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(_icon, color: Colors.white, size: iconSize),
    );
  }
}
