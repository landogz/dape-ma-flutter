import 'package:flutter/material.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../account/widgets/profile_list_widgets.dart';
import '../post_detail/post_detail_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Post> _bookmarks = [];
  bool _loading = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadBookmarks();
  }

  List<Post> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _bookmarks;
    return _bookmarks.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.categoryName.toLowerCase().contains(q) ||
          p.excerpt.toLowerCase().contains(q);
    }).toList();
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
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.bookmarkRemoveFailed)),
      );
    }
  }

  String _metaFor(Post post) {
    final words = '${post.excerpt} ${post.content}'.trim().split(RegExp(r'\s+'));
    final mins = ((words.length / 180).ceil()).clamp(1, 30);
    return context.l10n.minReadLabel(mins);
  }

  String _excerptFor(Post post) {
    final text = post.excerpt.trim().isNotEmpty
        ? post.excerpt.trim()
        : post.content.trim();
    if (text.isEmpty) return post.categoryName;
    if (text.length <= 90) return text;
    return '${text.substring(0, 90).trim()}…';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final items = _filtered;
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileListHeader(
              title: l10n.savedArticles,
              subtitle: _loading
                  ? null
                  : l10n.bookmarksCountLabel(_bookmarks.length),
            ),
            if (_bookmarks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: l10n.searchBookmarksHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: context.inputFill,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.borderSubtle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: context.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primaryBlue,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryBlue,
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: _loadBookmarks,
                      child: _bookmarks.isEmpty
                          ? ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.55,
                                  child: ProfileListEmptyState(
                                    icon: Icons.bookmark_border_rounded,
                                    title: l10n.noBookmarksYet,
                                    body: l10n.noBookmarksBody,
                                  ),
                                ),
                              ],
                            )
                          : items.isEmpty
                              ? ListView(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  children: [
                                    SizedBox(
                                      height: MediaQuery.of(context).size.height *
                                          0.4,
                                      child: ProfileListEmptyState(
                                        icon: Icons.search_off_rounded,
                                        title: l10n.noSearchResults,
                                        body: l10n.noSearchResultsBody,
                                      ),
                                    ),
                                  ],
                                )
                              : ListView.separated(
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  padding: EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    28 + bottomSafe,
                                  ),
                                  itemCount: items.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final post = items[index];
                                    return ProfileContentTile(
                                      title: post.title,
                                      subtitle: _excerptFor(post),
                                      meta: _metaFor(post),
                                      chipSubtitle: false,
                                      imageUrl: post.imageUrl,
                                      icon: Icons.article_outlined,
                                      iconColor: AppColors.primaryBlue,
                                      iconBackground: const Color(0xFFDBEAFE),
                                      onTap: () => _openPostDetail(post),
                                      trailing: IconButton(
                                        tooltip: l10n.removedFromBookmarks,
                                        onPressed: () => _onBookmarkTap(post),
                                        icon: const Icon(
                                          Icons.bookmark_rounded,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
