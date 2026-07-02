import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/network/endpoints.dart';
import '../post_engagement/post_engagement_service.dart';
import '../post_detail/post_detail_screen.dart';
import '../home/widgets/post_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Post> _bookmarks = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    setState(() => _loading = true);
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.bookmarks,
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'];
      final list = data is List<dynamic> ? data : <dynamic>[];
      setState(() {
        _bookmarks = list
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } catch (_) {
      if (mounted) setState(() => _bookmarks = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onLikeTap(Post post) async {
    try {
      final result = await PostEngagementService.toggleLike(post.id);
      if (!mounted) return;
      setState(() {
        final index = _bookmarks.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _bookmarks[index] = _bookmarks[index].copyWith(
            isLiked: result.liked,
            likesCount: result.likesCount,
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngagementService.friendlyError(
              e,
              'like this post',
              context.l10n,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openPostDetail(Post post, {bool focusComment = false}) async {
    final updated = await Navigator.of(context).push<Post?>(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          initialIsBookmarked: true,
          focusCommentOnOpen: focusComment,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        final index = _bookmarks.indexWhere((p) => p.id == updated.id);
        if (index != -1) {
          _bookmarks[index] = updated;
        }
      });
    } else {
      await _loadBookmarks();
    }
  }

  Future<void> _onBookmarkTap(Post post) async {
    try {
      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.bookmarks,
        data: <String, dynamic>{'post_id': post.id},
      );
      await _loadBookmarks();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.removedFromBookmarks),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.bookmarkRemoveFailed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookmarksTitle)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadBookmarks,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final post = _bookmarks[index];
                    return PostCard(
                      post: post,
                      isBookmarked: true,
                      onTap: () => _openPostDetail(post),
                      onLikeTap: () => _onLikeTap(post),
                      onCommentTap: () =>
                          _openPostDetail(post, focusComment: true),
                      onBookmarkTap: () => _onBookmarkTap(post),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

