import 'package:flutter/material.dart';

import '../../core/analytics/analytics_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../auth/login_screen.dart';
import '../home/widgets/category_tabs.dart';
import '../home/widgets/post_card.dart';
import '../post_detail/post_detail_screen.dart';
import '../post_engagement/post_engagement_service.dart';
import '../post_engagement/post_reaction.dart';
import '../post_engagement/reaction_picker.dart';
import '../post_engagement/reactors_sheet.dart';

/// Dedicated posts listing — formerly embedded on Home.
class PostsScreen extends StatefulWidget {
  const PostsScreen({
    super.key,
    this.initialPosts = const [],
    this.initialQuery,
  });

  final List<Post> initialPosts;
  final String? initialQuery;

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  final _searchController = TextEditingController();
  List<Post> _posts = [];
  Set<int> _bookmarkedIds = {};
  bool _loading = false;
  bool _isLoggedIn = false;
  String _currentCategory = 'all';

  @override
  void initState() {
    super.initState();
    _posts = List<Post>.from(widget.initialPosts);
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
      WidgetsBinding.instance.addPostFrameCallback((_) => _search(q));
    } else if (_posts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshAuth());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait([_loadPosts(), _refreshAuth()]);
  }

  Future<void> _refreshAuth() async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    setState(() => _isLoggedIn = token != null && token.isNotEmpty);
    if (_isLoggedIn) {
      await _loadBookmarkedIds();
    } else {
      setState(() => _bookmarkedIds = {});
    }
  }

  Future<void> _loadBookmarkedIds() async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.bookmarks,
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'];
      final list = data is List<dynamic> ? data : <dynamic>[];
      final ids = list
          .map((e) => e is Map<String, dynamic> ? e['id'] as int? : null)
          .whereType<int>()
          .toSet();
      if (mounted) setState(() => _bookmarkedIds = ids);
    } catch (_) {
      if (mounted) setState(() => _bookmarkedIds = {});
    }
  }

  Future<void> _loadPosts({String? category}) async {
    final selectedCategory = category ?? 'all';
    setState(() => _loading = true);
    try {
      final token = await AuthService.getToken();
      final api = ApiClient(token: token);
      final queryParams = (selectedCategory != 'all')
          ? <String, dynamic>{'category': selectedCategory}
          : null;
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.posts,
        query: queryParams,
      );
      final root = res.data ?? <String, dynamic>{};
      List<dynamic> rawList = const [];
      if (root['data'] is Map<String, dynamic>) {
        final paginated = root['data'] as Map<String, dynamic>;
        rawList = paginated['data'] as List<dynamic>? ?? const [];
      } else if (root['data'] is List<dynamic>) {
        rawList = root['data'] as List<dynamic>;
      }
      if (!mounted) return;
      setState(() {
        _currentCategory = selectedCategory;
        _posts = rawList
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      await _loadPosts(category: _currentCategory);
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.searchQuery(
          query.trim(),
          category: _currentCategory,
        ),
      );
      final root = res.data ?? <String, dynamic>{};
      final data = (root['data'] is Map<String, dynamic>)
          ? (root['data']['posts'] as List<dynamic>? ?? const [])
          : <dynamic>[];
      if (!mounted) return;
      setState(() {
        _posts = data
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      });
      await AnalyticsClient.instance.trackSearch();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onLikeTap(Post post) async {
    await _applyReaction(post, PostReactionType.like);
  }

  Future<void> _onLikeLongPress(Post post, Offset anchor) async {
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      await _refreshAuth();
    }
    if (!mounted) return;

    final selected = await showReactionPicker(
      context,
      selected: post.userReaction,
      anchor: anchor,
    );
    if (!mounted || selected == null) return;
    await _applyReaction(post, selected);
  }

  Future<void> _applyReaction(Post post, PostReactionType reaction) async {
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      await _refreshAuth();
    }
    try {
      final result = await PostEngagementService.setReaction(
        post.id,
        reaction: reaction,
      );
      if (!mounted) return;
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            isLiked: result.liked,
            likesCount: result.likesCount,
            userReaction: result.userReaction,
            clearUserReaction: result.userReaction == null,
            reactionCounts: result.reactionCounts,
          );
        }
      });
      if (result.liked) {
        await AnalyticsClient.instance.trackLike(post.id);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngagementService.friendlyError(
              e,
              'react to this post',
              context.l10n,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _onReactionsTap(Post post) async {
    if (post.likesCount <= 0) return;
    await showReactorsSheet(
      context,
      postId: post.id,
      reactionCounts: post.reactionCounts,
    );
  }

  Future<void> _onBookmarkTap(Post post) async {
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      await _refreshAuth();
    }
    try {
      await AuthService.authedPost(
        Endpoints.bookmarks,
        data: {'post_id': post.id},
      );
      if (!mounted) return;
      setState(() {
        if (_bookmarkedIds.contains(post.id)) {
          _bookmarkedIds = {..._bookmarkedIds}..remove(post.id);
        } else {
          _bookmarkedIds = {..._bookmarkedIds, post.id};
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngagementService.friendlyError(
              e,
              'bookmark this post',
              context.l10n,
            ),
          ),
        ),
      );
    }
  }

  Future<void> _openPostDetail(
    Post post, {
    bool focusComment = false,
  }) async {
    await AnalyticsClient.instance.trackPostView(post.id);
    if (!mounted) return;
    final updated = await Navigator.of(context).push<Post?>(
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(
          post: post,
          focusCommentOnOpen: focusComment,
        ),
      ),
    );
    if (!mounted) return;
    if (updated != null) {
      setState(() {
        final i = _posts.indexWhere((p) => p.id == updated.id);
        if (i != -1) _posts[i] = updated;
      });
    }
    await _loadBookmarkedIds();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final feed = _posts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: AppColors.secondaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        title: Text(
          l10n.postsPageTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: () => _loadPosts(category: _currentCategory),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) {
                    if (v.trim().isEmpty) {
                      _loadPosts(category: _currentCategory);
                    }
                  },
                  onSubmitted: _search,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: l10n.homeSearchTopicsHint,
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    l10n.homeMoreForYou,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      color: AppColors.secondaryBlue,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CategoryTabs(
                    current: _currentCategory,
                    onChanged: (c) => _loadPosts(category: c),
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (feed.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Text(
                    l10n.homeNoPostsFound,
                    style: const TextStyle(color: Color(0xFF64748B)),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = feed[index];
                      return PostCard(
                        post: post,
                        isBookmarked: _bookmarkedIds.contains(post.id),
                        onTap: () => _openPostDetail(post),
                        onLikeTap: () => _onLikeTap(post),
                        onLikeLongPress: (offset) =>
                            _onLikeLongPress(post, offset),
                        onReactionsTap: () => _onReactionsTap(post),
                        onCommentTap: () =>
                            _openPostDetail(post, focusComment: true),
                        onBookmarkTap: () => _onBookmarkTap(post),
                      );
                    },
                    childCount: feed.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
