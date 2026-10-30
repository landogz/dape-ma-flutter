import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/contest.dart';
import '../../../core/share/app_share.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/api_url.dart';
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

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final value = raw.trim();
    return DateTime.tryParse(value) ??
        DateTime.tryParse(value.replaceFirst(' ', 'T'));
  }

  String? _dateLabel() {
    final start = _parseDate(contest.submissionStartsAt);
    final end = _parseDate(contest.submissionEndsAt);
    if (start == null && end == null) {
      return contest.contestYear?.toString();
    }
    if (start == null) return DateFormat('dd MMM yyyy').format(end!);
    if (end == null || _sameDay(start, end)) {
      return DateFormat('dd MMM yyyy').format(start);
    }
    if (start.month == end.month && start.year == end.year) {
      return '${DateFormat('dd').format(start)}-${DateFormat('dd MMM yyyy').format(end)}';
    }
    return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _detailLine(BuildContext context) {
    final category = _categoryLabel(context);
    final theme = contest.theme?.trim() ?? '';
    if (theme.isEmpty) return category;
    return '$category · $theme';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateLabel = _dateLabel();
    final isOpen = contest.canSubmitEntry;
    final statusLabel = isOpen
        ? l10n.acceptingEntries
        : l10n.submissionsClosedWindow(
            start: contest.submissionStartsAt,
            end: contest.submissionEndsAt,
          );

    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorderOf(context)),
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
                          errorBuilder: (_, _, _) =>
                              _IconThumb(icon: _categoryIcon),
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
                      style: TextStyle(
                        color: HopeColors.headingOf(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (dateLabel != null && dateLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: HopeColors.headingOf(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dateLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: HopeColors.mutedOf(context),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _categoryIcon,
                          size: 14,
                          color: HopeColors.headingOf(context),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _detailLine(context),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: HopeColors.mutedOf(context),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            statusLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isOpen
                                  ? HopeColors.slotsGreen
                                  : HopeColors.mutedOf(context),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: l10n.sharePost,
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            AppShare.item(
                              url: ApiUrl.shareContest(
                                contest.id,
                                uuid: contest.uuid,
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.ios_share_rounded,
                            color: HopeColors.headingOf(context),
                          ),
                        ),
                        if (isOpen)
                          Flexible(
                            child: SizedBox(
                              height: 34,
                              child: FilledButton(
                                onPressed: () => _openDetail(context),
                                style: FilledButton.styleFrom(
                                  backgroundColor: HopeColors.purple,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(0, 34),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: Text(
                                  l10n.submitContestEntry,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
      color: HopeColors.softOf(context),
      child: Icon(icon, color: HopeColors.headingOf(context), size: 32),
    );
  }
}
