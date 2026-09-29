import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Soft navy decorative motif for auth screens.
///
/// Matched pair of identical circles, mirrored diagonally (top-right /
/// bottom-left), so they read as one deliberate system — not two accidents.
class AuthDecorBackground extends StatelessWidget {
  const AuthDecorBackground({super.key, required this.child});

  final Widget child;

  /// Identical size for both blobs so the pair feels intentional.
  static const double _blobSize = 176;

  static const _blobGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.mediumElectricBlue,
      AppColors.nileBlue,
    ],
  );

  Widget _blob() {
    return IgnorePointer(
      child: Container(
        width: _blobSize,
        height: _blobSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _blobGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.nileBlue.withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 6),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    // Show only a soft crescent (~38% of the circle) so content never sits on navy.
    const peek = 0.38;
    final inset = _blobSize * (1 - peek);

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.white)),
        // Top-right — mirrored partner of bottom-left
        Positioned(
          top: topInset - inset * 0.15,
          right: -inset,
          child: _blob(),
        ),
        // Bottom-left — same size/curvature, pulled low so footer text stays on white
        Positioned(
          bottom: -inset - 8,
          left: -inset,
          child: _blob(),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

const Color _authFieldFill = Color(0xFFF8F9FC);
const Color _authMutedText = Color(0xFF6B7280);

InputDecoration authFieldDecoration({
  required BuildContext context,
  required String hintText,
  required IconData prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(
      color: _authMutedText,
      fontSize: 15,
      fontWeight: FontWeight.w400,
    ),
    filled: true,
    fillColor: _authFieldFill,
    prefixIcon: Icon(
      prefixIcon,
      color: AppColors.mediumElectricBlue,
      size: 22,
    ),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(
        color: AppColors.mediumElectricBlue,
        width: 1.6,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.fireEngineRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.fireEngineRed, width: 1.6),
    ),
  );
}

/// Soft elevation wrapper for auth text fields.
class AuthFieldShell extends StatelessWidget {
  const AuthFieldShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.nileBlue.withValues(alpha: 0.12),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nileBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.nileBlue.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

/// "──── or ────" divider with a small pill label.
class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(
        height: 1,
        color: AppColors.nileBlue.withValues(alpha: 0.12),
      ),
    );

    return Row(
      children: [
        line,
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F6),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: _authMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
