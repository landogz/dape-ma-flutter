import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';

class CheckBrandButton extends StatelessWidget {
  const CheckBrandButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !busy && onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: active ? AppColors.primaryGradient : null,
        color: active ? null : context.mutedSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: active ? onPressed : null,
          borderRadius: BorderRadius.circular(999),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active ? Colors.white : context.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
