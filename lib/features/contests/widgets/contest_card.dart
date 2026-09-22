import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/contest.dart';
import '../../hope/hope_colors.dart';
import '../detail/contest_detail_screen.dart';

class ContestCard extends StatelessWidget {
  final Contest contest;

  const ContestCard({super.key, required this.contest});

  IconData get _categoryIcon {
    switch (contest.category.toLowerCase()) {
      case 'poster':
        return Icons.image_outlined;
      case 'video':
        return Icons.videocam_outlined;
      default:
        return Icons.music_note_outlined;
    }
  }

  String _categoryLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (contest.category.toLowerCase()) {
      case 'poster':
        return l10n.contestCategoryPoster;
      case 'video':
        return l10n.contestCategoryVideo;
      default:
        return l10n.contestCategorySong;
    }
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContestDetailScreen(contestId: contest.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subtitle = contest.theme?.trim().isNotEmpty == true
        ? contest.theme!
        : (contest.description ?? '');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: HopeColors.purple.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: contest.coverImageUrl != null &&
                          contest.coverImageUrl!.isNotEmpty
                      ? Image.network(
                          contest.coverImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _IconThumb(
                            icon: _categoryIcon,
                          ),
                        )
                      : _IconThumb(icon: _categoryIcon),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contest.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HopeColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: HopeColors.muted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetaChip(label: _categoryLabel(context)),
                        _MetaChip(label: contest.status.toUpperCase()),
                        if (contest.contestYear != null)
                          _MetaChip(label: '${contest.contestYear}'),
                      ],
                    ),
                    if (contest.canSubmitEntry) ...[
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          height: 34,
                          child: FilledButton(
                            onPressed: () => _openDetail(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: HopeColors.purple,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              l10n.submitContestEntry,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconThumb extends StatelessWidget {
  const _IconThumb({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: HopeColors.purpleSoft,
      child: Icon(icon, color: HopeColors.purple, size: 32),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: HopeColors.purpleSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: HopeColors.purple,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
