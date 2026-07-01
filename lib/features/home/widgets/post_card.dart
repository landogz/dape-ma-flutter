import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;
  final VoidCallback onLikeTap;
  final VoidCallback onCommentTap;
  final bool isBookmarked;

  const PostCard({
    super.key,
    required this.post,
    required this.onTap,
    required this.onBookmarkTap,
    required this.onLikeTap,
    required this.onCommentTap,
    this.isBookmarked = false,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  YoutubePlayerController? _ytController;

  @override
  void initState() {
    super.initState();
    final hasImage =
        widget.post.imageUrl != null && widget.post.imageUrl!.isNotEmpty;
    final url = widget.post.youtubeUrl;
    if (!hasImage && url != null && url.isNotEmpty) {
      final videoId = YoutubePlayer.convertUrlToId(url);
      if (videoId != null && videoId.isNotEmpty) {
        _ytController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            controlsVisibleAtStart: true,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ytController?.dispose();
    super.dispose();
  }

  static String _formatTimeAgo(DateTime? published) {
    if (published == null) return '';
    final now = DateTime.now();
    final diff = now.difference(published);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = days[published.weekday - 1];
    return '$weekday at ${published.hour.toString().padLeft(2, '0')}:${published.minute.toString().padLeft(2, '0')}';
  }

  /// Strip HTML tags for plain-text display.
  static String _stripHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final onTap = widget.onTap;
    final onBookmarkTap = widget.onBookmarkTap;
    final isBookmarked = widget.isBookmarked;

    final timeAgo = _formatTimeAgo(post.publishedAt);
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final hasYoutube =
        !hasImage && post.youtubeUrl != null && post.youtubeUrl!.isNotEmpty;
    // Description: prefer content/body, then excerpt (API sends body from Laravel)
    final rawBody = post.content.isNotEmpty ? post.content : post.excerpt;
    final stripped = _stripHtml(rawBody);
    final displayText = stripped.trim().isEmpty ? rawBody.trim() : stripped;
    final initial = post.authorName.isNotEmpty
        ? post.authorName.trim().substring(0, 1).toUpperCase()
        : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Post header: avatar, author, time, options ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (timeAgo.isNotEmpty)
                          Text(
                            timeAgo,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    color: AppColors.primaryBlue,
                    onPressed: onBookmarkTap,
                  ),
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down),
                    color: AppColors.textSecondaryLight,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // ── Title ──
            if (post.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Text(
                  post.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // ── Description (body below title) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Text(
                displayText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimaryLight,
                    ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ── Category (chip) ──
            if (post.categoryName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    post.categoryName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            // ── Media (image or YouTube placeholder) ──
            if (hasImage) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: onTap,
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ] else if (hasYoutube) ...[
              const SizedBox(height: 8),
              if (_ytController != null)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: _ytController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppColors.primaryBlue,
                  ),
                )
              else
                InkWell(
                  onTap: onTap,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      color: AppColors.primaryBlue.withOpacity(0.15),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Icon(
                              Icons.play_circle_fill_rounded,
                              size: 64,
                              color: AppColors.primaryBlue.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
            // ── Reactions summary ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  Text(
                    '${post.likesCount} ${post.likesCount == 1 ? 'like' : 'likes'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${post.commentsCount} ${post.commentsCount == 1 ? 'comment' : 'comments'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                  ),
                  if (post.reviewsCount > 0) ...[
                    const Spacer(),
                    Icon(
                      Icons.star,
                      size: 14,
                      color: Colors.amber.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.averageRating.toStringAsFixed(1)} (${post.reviewsCount})',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            // ── Divider and action buttons (Like, Comment) ──
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionButton(
                    icon: post.isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    label: 'Like',
                    isActive: post.isLiked,
                    onTap: widget.onLikeTap,
                  ),
                  _ActionButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Comment',
                    onTap: widget.onCommentTap,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppColors.primaryBlue : AppColors.textSecondaryLight;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
