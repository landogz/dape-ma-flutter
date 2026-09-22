import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import 'home_header.dart';

/// Continue Learning banner (carousel slide).
class ContinueLearningCard extends StatelessWidget {
  const ContinueLearningCard({
    super.key,
    required this.lessonsCompleted,
    required this.lessonGoal,
    required this.onTap,
  });

  final int lessonsCompleted;
  final int lessonGoal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final goal = lessonGoal <= 0 ? 6 : lessonGoal;
    final done = lessonsCompleted.clamp(0, goal);
    final progress = done / goal;
    final percent = (progress * 100).round();
    final hasProgress = lessonsCompleted > 0;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(28),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: SizedBox(
            height: 148,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 118, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeContinueLearning.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: Color(0xFF8FA8C8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.homeContinueLearningTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.secondaryBlue,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasProgress
                            ? l10n.homeLessonProgress(done, goal)
                            : l10n.homeStartExploring,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8FA8C8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: const Color(0xFFE5E7EB),
                                color: AppColors.secondaryBlue,
                              ),
                            ),
                          ),
                          if (hasProgress) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondaryBlue,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: -12,
                  top: -4,
                  bottom: -8,
                  child: SizedBox(
                    width: 130,
                    child: Image.asset(
                      HomeAssets.continueArt,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerRight,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(
                        Icons.menu_book_rounded,
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
