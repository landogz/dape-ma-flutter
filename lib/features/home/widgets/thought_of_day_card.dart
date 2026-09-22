import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import 'home_header.dart';

/// Thought of the Day banner (carousel slide) — text from Kid Listo API.
class ThoughtOfDayBanner extends StatelessWidget {
  const ThoughtOfDayBanner({
    super.key,
    required this.message,
    this.onTap,
    this.loading = false,
  });

  final String message;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        borderRadius: BorderRadius.circular(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: 148,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 110, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeThoughtOfDay.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF8FA8C8),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: loading
                            ? const Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              )
                            : Text(
                                message,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                  color: AppColors.secondaryBlue,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -18,
                  top: -6,
                  bottom: -10,
                  child: SizedBox(
                    width: 140,
                    child: Image.asset(
                      HomeAssets.thoughtArt,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.favorite_rounded,
                        color: AppColors.primaryBlue,
                        size: 56,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
