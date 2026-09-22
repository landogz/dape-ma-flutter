import 'package:flutter/material.dart';

import '../../core/analytics/analytics_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../account/profile/profile_models.dart';
import '../account/profile/profile_stats_service.dart';
import '../auth/login_screen.dart';
import '../care/care_hub_screen.dart';
import '../hope/hope_hub_screen.dart';
import '../kid_listo/kid_listo_welcome_screen.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/notifications_service.dart';
import '../post_detail/post_detail_screen.dart';
import '../post_engagement/post_engagement_service.dart';
import '../posts/posts_screen.dart';
import 'widgets/dape_service_tiles.dart';
import 'widgets/featured_post_card.dart';
import 'widgets/home_banner_carousel.dart';
import 'widgets/home_header.dart';
import 'widgets/recent_activity_list.dart';

class HomeScreen extends StatefulWidget {
  final List<Post> initialPosts;
  final ValueChanged<int>? onSwitchTab;

  const HomeScreen({
    super.key,
    required this.initialPosts,
    this.onSwitchTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _lessonGoal = 6;

  List<Post> _posts = [];
  bool _isLoggedIn = false;
  Set<int> _bookmarkedIds = {};
  String? _userName;
  int _unreadNotifications = 0;
  int _lessonsCompleted = 0;
  int _bannerRefreshKey = 0;
  List<HomeActivityRow> _recentActivity = const [];

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _posts = widget.initialPosts;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _refreshAuthState();
      if (!_isLoggedIn) {
        setState(() => _recentActivity = _guestDiscoverActivity());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String get _firstName {
    final name = _userName?.trim() ?? '';
    if (name.isEmpty) return '';
    return name.split(RegExp(r'\s+')).first;
  }

  String _displayGreeting(AppStrings l10n) {
    final name = _firstName.isNotEmpty ? _firstName : l10n.guest;
    return l10n.homeHiName(name);
  }

  Post? get _featuredPost {
    if (_posts.isEmpty) return null;
    final withImage = _posts.where((p) {
      final url = p.imageUrl?.trim() ?? '';
      return url.isNotEmpty;
    });
    return withImage.isNotEmpty ? withImage.first : _posts.first;
  }

  Future<void> _refreshAuthState() async {
    final token = await AuthService.getToken();
    if (mounted) {
      setState(() => _isLoggedIn = token != null && token.isNotEmpty);
      if (_isLoggedIn) {
        await Future.wait([
          _loadBookmarkedIds(),
          _loadUserProfile(),
          _loadUnreadNotifications(),
          _loadProfileExtras(),
        ]);
      } else {
        setState(() {
          _userName = null;
          _unreadNotifications = 0;
          _lessonsCompleted = 0;
          _recentActivity = _guestDiscoverActivity();
        });
      }
    }
  }

  List<HomeActivityRow> _guestDiscoverActivity() {
    final l10n = context.l10n;
    return _posts.take(2).map((p) {
      return HomeActivityRow(
        id: p.id,
        title: p.title,
        subtitle: l10n.homeDiscover,
        isLesson: false,
      );
    }).toList();
  }

  Future<void> _loadProfileExtras() async {
    if (!_isLoggedIn) return;
    try {
      final summary = await ProfileStatsService.instance.fetchSummary();
      if (!mounted) return;
      final rows = <HomeActivityRow>[];
      for (final item in summary.lessonActivity.take(2)) {
        rows.add(_activityRow(item, isLesson: true));
      }
      if (rows.length < 2) {
        for (final item in summary.articleActivity) {
          if (rows.length >= 2) break;
          rows.add(_activityRow(item, isLesson: false));
        }
      }
      setState(() {
        _lessonsCompleted = summary.lessonsCompleted;
        _recentActivity = rows;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _lessonsCompleted = 0;
        _recentActivity = _guestDiscoverActivity();
      });
    }
  }

  HomeActivityRow _activityRow(
    ProfileActivityItem item, {
    required bool isLesson,
  }) {
    final l10n = context.l10n;
    final title = isLesson
        ? l10n.homeYouCompleted(item.title)
        : l10n.homeYouRead(item.title);
    return HomeActivityRow(
      id: item.id,
      title: title,
      subtitle: item.subtitle?.trim() ?? '',
      isLesson: isLesson,
    );
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
      if (mounted) {
        setState(() {
          _userName =
              name != null && name.trim().isNotEmpty ? name.trim() : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _userName = null;
        });
      }
    }
  }

  Future<void> _loadUnreadNotifications() async {
    if (!_isLoggedIn) return;
    try {
      final count = await NotificationsService.fetchUnreadCount();
      if (mounted) setState(() => _unreadNotifications = count);
    } catch (_) {
      if (mounted) setState(() => _unreadNotifications = 0);
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

  Future<void> _loadPosts() async {
    try {
      final token = await AuthService.getToken();
      final api = ApiClient(token: token);
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.posts,
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
        _posts = rawList
            .map((e) => Post.fromJson(e as Map<String, dynamic>))
            .toList();
        if (!_isLoggedIn) {
          _recentActivity = _guestDiscoverActivity();
        }
      });
    } catch (_) {
      // Keep existing posts on refresh failure.
    }
  }

  Future<void> _refreshHome() async {
    await Future.wait([
      _loadPosts(),
      _refreshAuthState(),
    ]);
    if (mounted) {
      setState(() => _bannerRefreshKey++);
    }
  }

  void _openKidListo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KidListoWelcomeScreen(
          initialPosts: _posts,
          replaceOnContinue: false,
        ),
      ),
    );
  }

  void _openPosts({String? query}) {
    final q = (query ?? '').trim();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostsScreen(
          initialPosts: _posts,
          initialQuery: q.isEmpty ? null : q,
        ),
      ),
    );
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

  Future<void> _openPostById(int id) async {
    final existing = _posts.where((p) => p.id == id).toList();
    if (existing.isNotEmpty) {
      await _openPostDetail(existing.first);
      return;
    }
    try {
      final post = await PostEngagementService.fetchPost(id);
      if (!mounted) return;
      await _openPostDetail(post);
    } catch (_) {
      // Ignore missing posts from activity feed.
    }
  }

  void _openCare() {
    if (widget.onSwitchTab != null) {
      widget.onSwitchTab!(3);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CareHubScreen()),
    );
  }

  void _openHope() {
    if (widget.onSwitchTab != null) {
      widget.onSwitchTab!(1);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HopeHubScreen()),
    );
  }

  void _onNotificationTap() {
    if (!_isLoggedIn) {
      Navigator.of(context)
          .push(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          )
          .then((_) => _refreshAuthState());
    } else {
      Navigator.of(context)
          .push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          )
          .then((_) => _loadUnreadNotifications());
    }
  }

  void _showLearnPhase2() {
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.hopeLearnPhase2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final greeting = _displayGreeting(l10n);
    final featured = _featuredPost;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: RefreshIndicator(
        color: AppColors.primaryBlue,
        onRefresh: _refreshHome,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  HomeHeaderBanner(
                    greetingName: greeting,
                    subtitle: l10n.homeExploreSubtitle,
                    unreadNotifications: _unreadNotifications,
                    onNotificationTap: _onNotificationTap,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                    child: HomeBannerCarousel(
                      key: ValueKey(_bannerRefreshKey),
                      lessonsCompleted: _lessonsCompleted,
                      lessonGoal: _lessonGoal,
                      onContinueTap: _openHope,
                      onWhatsNewTap: _openHope,
                      onThoughtTap: _openKidListo,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset + 88),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.homeFeaturedForYou,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _openPosts(),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          foregroundColor: AppColors.primaryBlue,
                        ),
                        child: Text(
                          l10n.seeAll,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (featured != null)
                    FeaturedPostCard(
                      post: featured,
                      onTap: () => _openPostDetail(featured),
                    )
                  else
                    Text(
                      l10n.homeNoPostsFound,
                      style: const TextStyle(color: Color(0xFF64748B)),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.homeTaraExplore,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.secondaryBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DapeServiceTiles(
                    onLearn: _showLearnPhase2,
                    onHope: _openHope,
                    onCare: _openCare,
                    learnEnabled: false,
                  ),
                  const SizedBox(height: 24),
                  RecentActivityList(
                    items: _recentActivity,
                    onTap: (row) => _openPostById(row.id),
                    onSeeAll: () => _openPosts(),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
