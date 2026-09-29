import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_colors.dart';
import '../../../core/utils/api_url.dart';
import '../../post_engagement/post_reaction.dart';
import '../../post_engagement/reaction_picker.dart';

/// Shared publication date format across post surfaces: `17 Mar 2026`.
String formatPostDate(DateTime? date) {
  if (date == null) return '';
  return DateFormat('d MMM yyyy').format(date.toLocal());
}

int estimateReadMinutes(String text) {
  final plain = text
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (plain.isEmpty) return 1;
  final words = plain.split(' ').where((w) => w.isNotEmpty).length;
  return (words / 180).ceil().clamp(1, 45);
}

/// Keep brand-style hyphenated words on one line (e.g. DAPE-MA).
String displayTitle(String title) => title.replaceAll('-', '\u2011');

String normalizeArticleHtml(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '<p></p>';
  if (trimmed.contains(RegExp(r'<[a-zA-Z]'))) return trimmed;

  final blocks = trimmed
      .split(RegExp(r'\n\s*\n'))
      .map((b) => b.trim())
      .where((b) => b.isNotEmpty)
      .toList();

  final buffer = StringBuffer();
  for (final block in blocks) {
    final heading =
        RegExp(r'^(\d+)\.\s+(.+)$', multiLine: true).firstMatch(block);
    if (heading != null && !block.contains('\n')) {
      buffer.writeln('<h2>${heading.group(1)}. ${heading.group(2)}</h2>');
      continue;
    }
    if (block.startsWith('> ') || block.startsWith('"')) {
      final quote =
          block.replaceFirst(RegExp(r'^>\s*'), '').replaceAll('"', '');
      buffer.writeln('<blockquote><p>$quote</p></blockquote>');
      continue;
    }
    final withBreaks = block.replaceAll('\n', '<br/>');
    buffer.writeln('<p>$withBreaks</p>');
  }
  return buffer.toString();
}

class PostHeroHeader extends StatelessWidget {
  const PostHeroHeader({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final imageUrl = ApiUrl.resolve(post.imageUrl);
    final minutes = estimateReadMinutes(
      post.content.isNotEmpty ? post.content : post.excerpt,
    );
    final dateLabel = formatPostDate(post.publishedAt);
    final meta = [
      l10n.minReadLabel(minutes),
      if (dateLabel.isNotEmpty) dateLabel,
    ].join(' · ');
    final badge = post.categoryName.trim().isNotEmpty
        ? post.categoryName
        : l10n.featuredBadge;
    final initial = post.authorName.isNotEmpty
        ? post.authorName.trim().substring(0, 1).toUpperCase()
        : '?';

    // Toolbar is rendered separately above this hero, so do not add
    // status/toolbar insets here (that was doubling the banner height).
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const _HeroFallback(),
            )
          else
            const _HeroFallback(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x33000000),
                  Color(0xCC123A60),
                ],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  displayTitle(post.title),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                ),
                if (post.excerpt.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.excerpt.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.white.withValues(alpha: 0.22),
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        [
                          post.authorName,
                          if (meta.isNotEmpty) meta,
                        ].where((s) => s.trim().isNotEmpty).join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.88),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF123A60),
            Color(0xFF055498),
            Color(0xFF7C3AED),
          ],
        ),
      ),
    );
  }
}

class PostArticleBody extends StatelessWidget {
  const PostArticleBody({super.key, required this.htmlOrText});

  final String htmlOrText;

  @override
  Widget build(BuildContext context) {
    final html = normalizeArticleHtml(htmlOrText);
    var calloutIndex = 0;

    return HtmlWidget(
      html,
      textStyle: TextStyle(
        color: context.textPrimary,
        fontSize: 15.5,
        height: 1.55,
      ),
      customStylesBuilder: (element) {
        final tag = element.localName?.toLowerCase();
        if (tag == 'h1' || tag == 'h2' || tag == 'h3') {
          return {
            'color': '#7C3AED',
            'font-weight': '800',
            'font-size': tag == 'h1' ? '20px' : '17px',
            'margin-top': '18px',
            'margin-bottom': '8px',
            'line-height': '1.3',
          };
        }
        if (tag == 'p') {
          return {
            'margin-top': '0',
            'margin-bottom': '12px',
            'color': context.isDarkMode ? '#E5E7EB' : '#374151',
          };
        }
        if (tag == 'blockquote') {
          return {
            'margin': '12px 0',
            'padding': '0',
            'border': 'none',
          };
        }
        return null;
      },
      customWidgetBuilder: (element) {
        if (element.localName?.toLowerCase() != 'blockquote') return null;
        final text = element.text.trim();
        if (text.isEmpty) return null;
        final styleIndex = calloutIndex % 2;
        calloutIndex++;
        return _CalloutBox(
          text: text,
          variant: styleIndex == 0
              ? _CalloutVariant.purple
              : _CalloutVariant.green,
        );
      },
    );
  }
}

enum _CalloutVariant { purple, green }

class _CalloutBox extends StatelessWidget {
  const _CalloutBox({required this.text, required this.variant});

  final String text;
  final _CalloutVariant variant;

  @override
  Widget build(BuildContext context) {
    final isPurple = variant == _CalloutVariant.purple;
    final bg = isPurple ? const Color(0xFFF3E8FF) : const Color(0xFFECFDF5);
    final border =
        isPurple ? const Color(0xFFC4B5FD) : const Color(0xFFA7F3D0);
    final iconColor =
        isPurple ? AppColors.accentPurple : const Color(0xFF059669);
    final textColor =
        isPurple ? const Color(0xFF5B21B6) : const Color(0xFF065F46);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDarkMode ? iconColor.withValues(alpha: 0.18) : bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.isDarkMode
              ? iconColor.withValues(alpha: 0.45)
              : border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isPurple ? Icons.favorite_rounded : Icons.eco_rounded,
            color: iconColor,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: context.isDarkMode ? context.textPrimary : textColor,
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PostEngagementBar extends StatelessWidget {
  const PostEngagementBar({
    super.key,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    this.userReaction,
    this.reactionCounts = const {},
    required this.onLike,
    this.onLikeLongPress,
    this.onReactionsTap,
    required this.onComment,
    required this.onShare,
  });

  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final PostReactionType? userReaction;
  final Map<PostReactionType, int> reactionCounts;
  final VoidCallback onLike;
  final ValueChanged<Offset>? onLikeLongPress;
  final VoidCallback? onReactionsTap;
  final VoidCallback? onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (likesCount > 0) ...[
            ReactionSummaryRow(
              reactionCounts: reactionCounts.isEmpty
                  ? {for (final type in PostReactionType.values) type: 0}
                  : reactionCounts,
              totalCount: likesCount,
              onTap: onReactionsTap ?? onLike,
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              _EngagementChip(
                icon: isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                emoji: userReaction?.emoji,
                count: likesCount,
                active: isLiked,
                onTap: onLike,
                onLongPress: onLikeLongPress == null
                    ? null
                    : () {
                        final box = context.findRenderObject() as RenderBox?;
                        final offset = box?.localToGlobal(
                              box.size.centerLeft(Offset.zero),
                            ) ??
                            Offset.zero;
                        onLikeLongPress!(offset);
                      },
                tooltip: userReaction?.label ?? context.l10n.like,
              ),
              const SizedBox(width: 4),
              _EngagementChip(
                icon: Icons.chat_bubble_outline_rounded,
                count: commentsCount,
                onTap: onComment,
                tooltip: context.l10n.comment,
              ),
              const Spacer(),
              IconButton(
                onPressed: onShare,
                tooltip: context.l10n.sharePost,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.ios_share_rounded,
                  size: 20,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EngagementChip extends StatelessWidget {
  const _EngagementChip({
    required this.icon,
    required this.count,
    required this.onTap,
    required this.tooltip,
    this.onLongPress,
    this.emoji,
    this.active = false,
  });

  final IconData icon;
  final int count;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String tooltip;
  final String? emoji;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryBlue : context.textSecondary;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (emoji != null)
                Text(emoji!, style: const TextStyle(fontSize: 18))
              else
                Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PostRatingCard extends StatelessWidget {
  const PostRatingCard({
    super.key,
    required this.averageRating,
    required this.reviewsCount,
    required this.userRating,
    required this.onStarTap,
  });

  final double averageRating;
  final int reviewsCount;
  final int? userRating;
  final ValueChanged<int> onStarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final displayStars = userRating ?? averageRating.round().clamp(0, 5);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: context.mutedSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderSubtle),
      ),
      child: Column(
        children: [
          Text(
            l10n.rateThisContent,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              final filled = star <= displayStars;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () => onStarTap(star),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 34,
                      color: Colors.amber.shade700,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            reviewsCount > 0
                ? l10n.ratingAverageSummary(averageRating, reviewsCount)
                : l10n.tapStarsToRate,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.textSecondary,
                ),
          ),
          if (userRating != null) ...[
            const SizedBox(height: 4),
            Text(
              l10n.youRatedStars(userRating!),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class CommentsEmptyState extends StatelessWidget {
  const CommentsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 26,
                color: AppColors.primaryBlue.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noCommentsEmptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.noCommentsEmptyBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
