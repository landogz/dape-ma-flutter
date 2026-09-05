import 'package:flutter/material.dart';

import '../../../core/models/song_contest.dart';
import '../../../core/theme/app_colors.dart';
import '../detail/song_contest_detail_screen.dart';

class SongContestCard extends StatelessWidget {
  final SongContest contest;

  const SongContestCard({super.key, required this.contest});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SongContestDetailScreen(contestId: contest.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.music_note_outlined,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contest.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimaryLight,
                                  ),
                        ),
                        if (contest.theme != null &&
                            contest.theme!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            contest.theme!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textSecondaryLight),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Chip(label: contest.status.toUpperCase()),
                  if (contest.contestYear != null)
                    _Chip(label: '${contest.contestYear}'),
                  if (contest.isOpenForSubmission)
                    const _Chip(label: 'Accepting entries'),
                ],
              ),
              if (contest.description != null &&
                  contest.description!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  contest.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
