import 'package:flutter/material.dart';

import '../../core/models/post.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/auth/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/analytics/analytics_client.dart';
import '../account/account_screen.dart';
import '../auth/login_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../chat/botpress_chat_screen.dart';
import '../post_engagement/post_engagement_service.dart';
import '../post_detail/post_detail_screen.dart';
import '../rehab_centers/rehab_centers_screen.dart';
import 'widgets/category_tabs.dart';
import 'widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  final List<Post> initialPosts;

  const HomeScreen({super.key, required this.initialPosts});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> _posts = [];
  bool _loading = false;
  String _currentCategory = 'all';
  int _currentTabIndex = 0;
  bool _isLoggedIn = false;
  Set<int> _bookmarkedIds = {};
  String? _userName;
  String? _userProfileImageUrl;

  final _searchController = TextEditingController();

  Future<void> _refreshAuthState() async {
    final token = await AuthService.getToken();
    if (mounted) {
      setState(() => _isLoggedIn = token != null && token.isNotEmpty);
      if (_isLoggedIn) {
        _loadBookmarkedIds();
        _loadUserProfile();
      } else {
        setState(() {
          _userName = null;
          _userProfileImageUrl = null;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    if (!_isLoggedIn) return;
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.me,
      );
      final data = res.data ?? <String, dynamic>{};
      final user = data['data'] is Map<String, dynamic>
          ? data['data'] as Map<String, dynamic>
          : data;
      final name = user['name'] as String?;
      final profileImageUrl = user['profile_image_url'] as String?;
      if (mounted) {
        setState(() {
          _userName = name != null && name.trim().isNotEmpty ? name.trim() : null;
          _userProfileImageUrl = profileImageUrl != null && profileImageUrl.isNotEmpty ? profileImageUrl : null;
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _userName = null;
        _userProfileImageUrl = null;
      });
    }
  }

  Future<void> _loadBookmarkedIds() async {
    if (!_isLoggedIn) return;
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

  @override
  void initState() {
    super.initState();
    _posts = widget.initialPosts;
    _refreshAuthState();
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
    if (query.isEmpty) {
      await _loadPosts(category: _currentCategory);
      return;
    }
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.searchQuery(
          query,
          category: _currentCategory,
        ),
      );
      final root = res.data ?? <String, dynamic>{};
      final data = (root['data'] is Map<String, dynamic>)
          ? (root['data']['posts'] as List<dynamic>? ?? const [])
          : <dynamic>[];
      setState(() {
        _posts = data
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
      });

      // Fire analytics for mobile searches
      await AnalyticsClient.instance.trackSearch(query);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onLikeTap(Post post) async {
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      await _refreshAuthState();
    }
    try {
      final result = await PostEngagementService.toggleLike(post.id);
      if (!mounted) return;
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            isLiked: result.liked,
            likesCount: result.likesCount,
          );
        }
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update like. Try again.')),
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
          initialIsBookmarked: _bookmarkedIds.contains(post.id),
          focusCommentOnOpen: focusComment,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() {
        final index = _posts.indexWhere((p) => p.id == updated.id);
        if (index != -1) {
          _posts[index] = updated;
        }
      });
    }
    await _loadBookmarkedIds();
  }

  Future<void> _onBookmarkTap(Post post) async {
    if (!_isLoggedIn) {
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      _refreshAuthState();
      return;
    }
    try {
      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.bookmarks,
        data: <String, dynamic>{'post_id': post.id},
      );
      await _loadBookmarkedIds();
      if (!mounted) return;
      final added = _bookmarkedIds.contains(post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            added ? 'Saved to bookmarks' : 'Removed from bookmarks',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not update bookmark. Try again.'),
        ),
      );
    }
  }

  void _onBottomTabTap(int index) async {
    setState(() => _currentTabIndex = index);
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RehabCentersScreen()),
      );
    } else if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BookmarksScreen()),
      );
    } else if (index == 3) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(builder: (_) => const AccountScreen()),
          )
          .then((_) => _refreshAuthState());
    }
  }

  void _onNotificationTap() {
    if (!_isLoggedIn) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((_) => _refreshAuthState());
    } else {
      // TODO: Navigate to notifications screen when implemented
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primaryBlue.withOpacity(0.15),
                        backgroundImage: _userProfileImageUrl != null
                            ? NetworkImage(_userProfileImageUrl!)
                            : null,
                        child: _userProfileImageUrl == null
                            ? Text(
                                _userName != null && _userName!.isNotEmpty
                                    ? _userName!.trim().substring(0, 1).toUpperCase()
                                    : 'G',
                                style: const TextStyle(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_userName ?? 'Guest'} 👋',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimaryLight,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _onNotificationTap,
                        icon: Icon(
                          Icons.notifications_none,
                          color: AppColors.textPrimaryLight,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  CategoryTabs(
                    current: _currentCategory,
                    onChanged: (c) => _loadPosts(category: c),
                  ),
                  const SizedBox(height: 8),
                  Material(
                    elevation: 1,
                    shadowColor: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(999),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search information, rehab, news...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(
                          color: AppColors.textSecondaryLight.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: BorderSide(
                          color: AppColors.textSecondaryLight.withOpacity(0.25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(
                          color: AppColors.primaryBlue,
                          width: 1.5,
                        ),
                      ),
                    ),
                      onChanged: _search,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () => _loadPosts(category: _currentCategory),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) {
                          final post = _posts[index];
                          return PostCard(
                            post: post,
                            isBookmarked: _bookmarkedIds.contains(post.id),
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
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22C55E),
        elevation: 4,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BotpressChatScreen()),
          );
        },
        child: const Icon(
          Icons.chat_bubble_outline,
          color: Colors.white,
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.secondaryBlue,
        shape: const CircularNotchedRectangle(),
        elevation: 8,
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: _currentTabIndex == 0,
                onTap: () => _onBottomTabTap(0),
              ),
              _NavItem(
                icon: Icons.local_hospital_outlined,
                label: 'Rehab',
                selected: _currentTabIndex == 1,
                onTap: () => _onBottomTabTap(1),
              ),
              const SizedBox(width: 40), // space for FAB notch
              _NavItem(
                icon: Icons.bookmark_outline,
                label: 'Saved',
                selected: _currentTabIndex == 2,
                onTap: () => _onBottomTabTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: 'Account',
                selected: _currentTabIndex == 3,
                onTap: () => _onBottomTabTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white70;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

