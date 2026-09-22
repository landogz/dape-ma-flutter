import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import 'home_header.dart';

class DapeProgressCard extends StatelessWidget {
  const DapeProgressCard({
    super.key,
    required this.courses,
    required this.lessons,
    required this.streak,
    this.onTap,
  });

  final int courses;
  final int lessons;
  final int streak;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: Colors.white,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 12, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeDapeProgress,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _Stat(
                          label: l10n.homeProgressCourses,
                          value: '$courses',
                        ),
                        _Stat(
                          label: l10n.homeProgressLessons,
                          value: '$lessons',
                        ),
                        _Stat(
                          label: l10n.homeProgressStreak,
                          value: '$streak',
                          trailing: const Text('🔥', style: TextStyle(fontSize: 14)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                height: 72,
                child: Image.asset(
                  HomeAssets.progressArt,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.primaryBlue,
                    size: 48,
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

class _Stat extends StatelessWidget {
  const _Stat({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.secondaryBlue,
                  height: 1,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 2),
                trailing!,
              ],
            ],
          ),
        ],
      ),
    );
  }
}
