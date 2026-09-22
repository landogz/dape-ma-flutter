import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/post.dart';
import '../../../core/theme/app_colors.dart';
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
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

/// Horizontal featured posts carousel used on the Posts screen.
class FeaturedPostCarousel extends StatefulWidget {
  const FeaturedPostCarousel({
    super.key,
    required this.posts,
    required this.onTap,
    this.isBookmarked,
    this.onBookmarkTap,
  });

  final List<Post> posts;
  final ValueChanged<Post> onTap;
  final bool Function(Post post)? isBookmarked;
  final ValueChanged<Post>? onBookmarkTap;

  @override
  State<FeaturedPostCarousel> createState() => _FeaturedPostCarouselState();
}

class _FeaturedPostCarouselState extends State<FeaturedPostCarousel> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: FeaturedPostCard(
                  post: post,
                  onTap: () => widget.onTap(post),
                ),
              );
            },
          ),
        ),
        if (widget.posts.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.posts.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index
                        ? AppColors.primaryBlue
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
