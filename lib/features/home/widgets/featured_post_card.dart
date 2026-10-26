import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/share/app_share.dart';
import '../../../core/utils/api_url.dart';

class FeaturedPostCard extends StatelessWidget {
  const FeaturedPostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final imageUrl = ApiUrl.resolve(post.imageUrl);
    final excerpt = post.excerpt.trim().isNotEmpty
        ? post.excerpt.trim()
        : post.content.replaceAll(RegExp(r'<[^>]*>'), ' ').trim();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: SizedBox(
          height: 200,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _fallbackBg(),
                )
              else
                _fallbackBg(),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x22000000),
                      Color(0xE0123A60),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    Material(
                      color: Colors.black38,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: l10n.sharePost,
                        onPressed: () {
                          AppShare.item(
                            url: ApiUrl.sharePost(post.id, uuid: post.uuid),
                            postId: post.id,
                          );
                        },
                        icon: const Icon(
                          Icons.ios_share_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accentRed,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.featuredBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    if (excerpt.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        excerpt,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      l10n.minReadLabel(5),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _fallbackBg() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF055498), Color(0xFF123A60)],
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.fromLTRB(14, 48, 0, 0),
          child: Opacity(
            opacity: 0.2,
            child: Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}

/// One card when a single post is featured; a swipeable carousel when there are more.
class FeaturedPostsSection extends StatelessWidget {
  const FeaturedPostsSection({
    super.key,
    required this.posts,
    required this.onTap,
  });

  final List<Post> posts;
  final ValueChanged<Post> onTap;

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }

    if (posts.length == 1) {
      return FeaturedPostCard(
        post: posts.first,
        onTap: () => onTap(posts.first),
      );
    }

    return FeaturedPostCarousel(
      posts: posts,
      onTap: onTap,
    );
  }
}

/// Horizontal featured posts carousel used on Home and Posts.
class FeaturedPostCarousel extends StatefulWidget {
  const FeaturedPostCarousel({
    super.key,
    required this.posts,
    required this.onTap,
    this.autoPlay = true,
  });

  final List<Post> posts;
  final ValueChanged<Post> onTap;
  final bool autoPlay;

  @override
  State<FeaturedPostCarousel> createState() => _FeaturedPostCarouselState();
}

class _FeaturedPostCarouselState extends State<FeaturedPostCarousel> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant FeaturedPostCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.posts.length != widget.posts.length) {
      _index = _index.clamp(0, widget.posts.length - 1);
    }
    if (oldWidget.autoPlay != widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (!widget.autoPlay || widget.posts.length < 2) {
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients || widget.posts.length < 2) {
        return;
      }
      final next = (_index + 1) % widget.posts.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _goTo(int index) async {
    if (!_controller.hasClients) return;
    await _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.posts.isEmpty) {
      return Text(
        context.l10n.homeNoPostsFound,
        style: const TextStyle(color: Color(0xFF64748B)),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.posts.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final post = widget.posts[i];
              final isLast = i == widget.posts.length - 1;
              return Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 10),
                child: FeaturedPostCard(
                  post: post,
                  onTap: () => widget.onTap(post),
                ),
              );
            },
          ),
        ),
        if (widget.posts.length > 1) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.posts.length; i++)
                Semantics(
                  button: true,
                  selected: i == _index,
                  label: context.l10n.featuredPostSlide(
                    i + 1,
                    widget.posts.length,
                  ),
                  child: InkWell(
                    onTap: () => _goTo(i),
                    customBorder: const CircleBorder(),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: i == _index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? AppColors.primaryBlue
                                : const Color(0xFFCBD5E1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
