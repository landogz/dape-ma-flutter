import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/utils/api_url.dart';
import '../auth/forgot_password_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../bookmarks/bookmarks_screen.dart';
import '../diary/diary_list_screen.dart';
import '../post_detail/post_detail_screen.dart';
import '../post_engagement/post_engagement_service.dart';
import '../settings/settings_hub_screen.dart';
import 'edit_profile_screen.dart';
import 'profile/profile_lists_screen.dart';
import 'profile/profile_models.dart';
import 'profile/profile_stats_service.dart';
import 'widgets/profile_cards.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, this.embeddedInShell = false});

  final bool embeddedInShell;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _loading = true;
  bool _loggedIn = false;
  String _name = '';
  String? _photoUrl;
  String? _memberSince;
  bool _isChampion = false;
  int _lessons = 0;
  int _articles = 0;
  int _events = 0;
  int _streak = 0;
  List<ProfileBadge> _badges = const [];
  // Kept for when Certificates / Gains are re-enabled.
  // ignore: unused_field
  List<ProfileCertificate> _certificates = const [];
  // ignore: unused_field
  List<ProfileGain> _gains = const [];
  List<ProfileActivityItem> _lessonActivity = const [];
  List<ProfileActivityItem> _articleActivity = const [];
  List<ProfileActivityItem> _eventActivity = const [];
  File? _pickedFile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = await AuthService.getToken();
    final loggedIn = token != null && token.isNotEmpty;
    if (!loggedIn) {
      if (!mounted) return;
      setState(() {
        _loggedIn = false;
        _loading = false;
        _name = '';
        _photoUrl = null;
        _memberSince = null;
        _isChampion = false;
        _lessons = 0;
        _articles = 0;
        _events = 0;
        _streak = 0;
        _badges = const [];
        _certificates = const [];
        _gains = const [];
        _lessonActivity = const [];
        _articleActivity = const [];
        _eventActivity = const [];
      });
      return;
    }

    try {
      final summary = await ProfileStatsService.instance.fetchSummary();
      String? memberSince;
      if (summary.memberSinceRaw != null) {
        final parsed = DateTime.tryParse(summary.memberSinceRaw!);
        if (parsed != null) {
          memberSince = DateFormat.yMMMM().format(parsed);
        }
      }

      if (!mounted) return;
      setState(() {
        _loggedIn = true;
        _name = summary.name;
        _photoUrl = ApiUrl.resolve(summary.photoUrl);
        _pickedFile = null;
        _memberSince = memberSince;
        _isChampion = summary.isChampion;
        _lessons = summary.lessonsCompleted;
        _articles = summary.articlesRead;
        _events = summary.eventsJoined;
        _streak = summary.dayStreak;
        _badges = summary.badges;
        _certificates = summary.certificates;
        _gains = summary.gains;
        _lessonActivity = summary.lessonActivity;
        _articleActivity = summary.articleActivity;
        _eventActivity = summary.eventActivity;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loggedIn = true;
        _loading = false;
      });
    }
  }

  Future<void> _open(Widget screen) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
    if (mounted) await _load();
  }

  Future<void> _showFeatureUnavailable() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(l10n.featureUnavailableNow),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  Future<void> _showBadgesPhase2() async {
    final l10n = context.l10n;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.myBadges),
        content: Text(l10n.badgesPhase2Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }

  Future<void> _requireAuthThen(Widget screen) async {
    if (!_loggedIn) {
      await _open(const LoginScreen());
      if (!_loggedIn || !mounted) return;
    }
    await _open(screen);
  }

  Future<void> _openPostActivity(ProfileActivityItem item) async {
    try {
      final Post post = await PostEngagementService.fetchPost(item.id);
      if (!mounted) return;
      await _open(PostDetailScreen(post: post));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.updateFailed)),
      );
    }
  }

  Future<void> _pickPhoto() async {
    if (!_loggedIn) {
      await _open(const LoginScreen());
      return;
    }

    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (xFile == null || !mounted) return;

    final file = File(xFile.path);
    setState(() => _pickedFile = file);

    try {
      // POST multipart — PHP does not reliably parse files on PUT.
      final formData = FormData.fromMap({
        if (_name.trim().isNotEmpty) 'name': _name.trim(),
        'profile_photo': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split(RegExp(r'[/\\]')).last,
        ),
      });
      final res = await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.profileUpdate,
        data: formData,
      );
      final root = res.data ?? <String, dynamic>{};
      final data = root['data'] is Map<String, dynamic>
          ? root['data'] as Map<String, dynamic>
          : root;
      final uploadedUrl = ApiUrl.resolve(data['profile_image_url'] as String?);

      if (!mounted) return;
      setState(() {
        _pickedFile = null;
        if (uploadedUrl != null) _photoUrl = uploadedUrl;
      });
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _pickedFile = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.updateFailed),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  String get _firstName {
    final parts = _name.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return context.l10n.youAreSignedIn;
    return parts.first;
  }

  String get _handle {
    final base = _firstName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (base.isEmpty) return '@member';
    return '@$base';
  }

  /// Setup prompt for new accounts: photo, name, learning activity, badge/streak.
  double get _profileCompleteness {
    if (!_loggedIn) return 0;
    var score = 0.0;
    if (_name.trim().isNotEmpty) score += 0.25;
    if (_photoUrl != null || _pickedFile != null) score += 0.30;
    if (_lessons + _articles + _events > 0) score += 0.25;
    if (_streak > 0 || (!_badgesPhase2Locked && _badges.any((b) => b.earned))) {
      score += 0.20;
    }
    return score.clamp(0.0, 1.0);
  }

  /// Badges unlock in Phase 2 — keep UI visible but fully locked for now.
  static const bool _badgesPhase2Locked = true;

  static const List<ProfileBadge> _phase2BadgePlaceholders = [
    ProfileBadge(
      key: 'healthy_decision_maker',
      title: 'Healthy Decision Maker',
      description: '',
      icon: 'search',
      color: '#F59E0B',
      earned: false,
    ),
    ProfileBadge(
      key: 'stress_buster',
      title: 'Stress Buster',
      description: '',
      icon: 'bolt',
      color: '#22C55E',
      earned: false,
    ),
    ProfileBadge(
      key: 'empowered_peer',
      title: 'Empowered Peer',
      description: '',
      icon: 'handshake',
      color: '#EF4444',
      earned: false,
    ),
    ProfileBadge(
      key: 'dape_champion',
      title: 'DAPE Champion',
      description: '',
      icon: 'trophy',
      color: '#7C3AED',
      earned: false,
    ),
  ];

  List<ProfileBadge> get _displayBadges {
    if (_badgesPhase2Locked) {
      final source = _badges.isNotEmpty ? _badges : _phase2BadgePlaceholders;
      return source
          .map(
            (b) => ProfileBadge(
              key: b.key,
              title: b.title,
              description: b.description,
              icon: b.icon,
              color: b.color,
              earned: false,
            ),
          )
          .toList(growable: false);
    }

    if (_badges.isEmpty) return const [];
    // Prefer earned first, then locked — keeps progress visible and fills the row.
    final earned = _badges.where((b) => b.earned).toList();
    final locked = _badges.where((b) => !b.earned).toList();
    return [...earned, ...locked];
  }

  int get _earnedBadgeCount =>
      _badgesPhase2Locked ? 0 : _badges.where((b) => b.earned).length;

  IconData _badgeIcon(String key) {
    switch (key) {
      case 'healthy_decision_maker':
        return Icons.search_rounded;
      case 'empowered_peer':
        return Icons.handshake_rounded;
      case 'stress_buster':
        return Icons.bolt_rounded;
      case 'dape_champion':
        return Icons.emoji_events_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _badgeColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    if (cleaned.length != 6) return AppColors.primaryBlue;
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  Widget _avatarWidget(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 42,
      backgroundColor: context.pageBackground,
      backgroundImage: _pickedFile != null
          ? FileImage(_pickedFile!)
          : (_photoUrl != null ? NetworkImage(_photoUrl!) as ImageProvider : null),
      child: _pickedFile == null && _photoUrl == null
          ? Icon(Icons.person_rounded, size: 44, color: Colors.grey.shade400)
          : null,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (_loggedIn)
          ProfileCompletenessAvatar(
            progress: _profileCompleteness,
            child: avatar,
          )
        else
          avatar,
        Positioned(
          right: 0,
          bottom: 0,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: _pickPhoto,
              child: const Padding(
                padding: EdgeInsets.all(7),
                child: Icon(
                  Icons.photo_camera_rounded,
                  size: 16,
                  color: AppColors.secondaryBlue,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topPad = MediaQuery.of(context).padding.top;
    final completenessPct = (_profileCompleteness * 100).round();
    final bottomSafe = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.pageBackground,
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : RefreshIndicator(
              color: AppColors.primaryBlue,
              onRefresh: _load,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(8, topPad + 4, 8, 28),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.nileBlue,
                                AppColors.mediumElectricBlue,
                                AppColors.accentPurple,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  if (!widget.embeddedInShell)
                                    IconButton(
                                      onPressed: () =>
                                          Navigator.of(context).maybePop(),
                                      icon: const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    )
                                  else
                                    const SizedBox(width: 48),
                                  Expanded(
                                    child: Text(
                                      l10n.myProfileTitle,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 48),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    _avatarWidget(context),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _loggedIn
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () => _open(
                                                    const EditProfileScreen(),
                                                  ),
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      _name.trim().isNotEmpty
                                                          ? _name.trim()
                                                          : _firstName,
                                                      maxLines: 1,
                                                      softWrap: false,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 21,
                                                        fontWeight:
                                                            FontWeight.w900,
                                                        height: 1.15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$_handle · ${l10n.learnerStatus}',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.88),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (_memberSince != null) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '${l10n.memberSince} $_memberSince',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.85),
                                                      fontSize: 12.5,
                                                    ),
                                                  ),
                                                ],
                                                const SizedBox(height: 8),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: completenessPct >= 100
                                                        ? const Color(
                                                            0xFF059669)
                                                        : Colors.white
                                                            .withValues(
                                                                alpha: 0.92),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        completenessPct >= 100
                                                            ? Icons
                                                                .check_circle_rounded
                                                            : Icons
                                                                .radio_button_checked_rounded,
                                                        size: 14,
                                                        color: completenessPct >=
                                                                100
                                                            ? Colors.white
                                                            : const Color(
                                                                0xFF047857),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        completenessPct >= 100
                                                            ? l10n
                                                                .profileCompleteLabel
                                                            : l10n
                                                                .profilePercentComplete(
                                                                completenessPct,
                                                              ),
                                                        style: TextStyle(
                                                          color: completenessPct >=
                                                                  100
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xFF065F46),
                                                          fontSize: 11.5,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (_isChampion) ...[
                                                  const SizedBox(height: 10),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.22),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .emoji_events_rounded,
                                                          color: AppColors
                                                              .accentYellow,
                                                          size: 16,
                                                        ),
                                                        const SizedBox(
                                                            width: 6),
                                                        Text(
                                                          l10n.championBadge,
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 12,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  l10n.welcomeTitle,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  l10n.guestProfileHint,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.9),
                                                    fontSize: 13,
                                                    height: 1.3,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Wrap(
                                                  spacing: 8,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () => _open(
                                                        const LoginScreen(),
                                                      ),
                                                      style: TextButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor:
                                                            AppColors
                                                                .primaryBlue,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 14,
                                                          vertical: 8,
                                                        ),
                                                      ),
                                                      child: Text(l10n.login),
                                                    ),
                                                    TextButton(
                                                      onPressed: () => _open(
                                                        const RegisterScreen(),
                                                      ),
                                                      style: TextButton
                                                          .styleFrom(
                                                        foregroundColor:
                                                            Colors.white,
                                                        side:
                                                            const BorderSide(
                                                          color: Colors.white,
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 14,
                                                          vertical: 8,
                                                        ),
                                                      ),
                                                      child:
                                                          Text(l10n.register),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -22),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.fromLTRB(
                              16,
                              18,
                              16,
                              (widget.embeddedInShell ? 96 : 64) + bottomSafe,
                            ),
                            decoration: BoxDecoration(
                              color: context.pageBackground,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(28),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.myStats,
                                  style: TextStyle(
                                    color: context.isDarkMode
                                        ? context.textPrimary
                                        : AppColors.secondaryBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  height: (96 *
                                          MediaQuery.textScalerOf(context)
                                              .scale(1.0))
                                      .clamp(96.0, 128.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ProfileStatCard(
                                          icon: Icons.menu_book_rounded,
                                          iconColor: AppColors.primaryBlue,
                                          value: '$_lessons',
                                          label: l10n.lessonsCompleted,
                                          onTap: () => _requireAuthThen(
                                            ActivityListScreen(
                                              title: l10n.lessonsCompleted,
                                              items: _lessonActivity,
                                              emptyTitle: l10n.noActivityYet,
                                              emptyBody: l10n.noLessonsBody,
                                              onOpenPost: _openPostActivity,
                                              listIcon: Icons.menu_book_rounded,
                                              accentColor: AppColors.primaryBlue,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ProfileStatCard(
                                          icon: Icons.article_outlined,
                                          iconColor: AppColors.brightGold,
                                          value: '$_articles',
                                          label: l10n.articlesRead,
                                          onTap: () => _requireAuthThen(
                                            ActivityListScreen(
                                              title: l10n.articlesRead,
                                              items: _articleActivity,
                                              emptyTitle: l10n.noActivityYet,
                                              emptyBody: l10n.noArticlesBody,
                                              onOpenPost: _openPostActivity,
                                              listIcon: Icons.article_outlined,
                                              accentColor: AppColors.brightGold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ProfileStatCard(
                                          icon: Icons
                                              .play_circle_fill_rounded,
                                          iconColor: AppColors.fireEngineRed,
                                          value: '$_events',
                                          label: l10n.eventsJoined,
                                          onTap: () => _requireAuthThen(
                                            ActivityListScreen(
                                              title: l10n.eventsJoined,
                                              items: _eventActivity,
                                              emptyTitle: l10n.noActivityYet,
                                              emptyBody: l10n.noEventsBody,
                                              listIcon:
                                                  Icons.play_circle_fill_rounded,
                                              accentColor: AppColors.fireEngineRed,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ProfileStatCard(
                                          icon: Icons
                                              .local_fire_department_rounded,
                                          iconColor: AppColors.fireEngineRed,
                                          value: '$_streak',
                                          label: l10n.dayStreak,
                                          onTap: () => _requireAuthThen(
                                            const DiaryListScreen(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n.myBadges,
                                            style: TextStyle(
                                              color: context.isDarkMode
                                                  ? context.textPrimary
                                                  : AppColors.secondaryBlue,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            _badgesPhase2Locked
                                                ? l10n.badgesPhase2Subtitle
                                                : (_badges.isNotEmpty
                                                    ? l10n.badgesUnlockedProgress(
                                                        _earnedBadgeCount,
                                                        _badges.length,
                                                      )
                                                    : l10n.noActivityYet),
                                            style: TextStyle(
                                              color: context.textSecondary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _badgesPhase2Locked
                                          ? _showBadgesPhase2
                                          : _showFeatureUnavailable,
                                      child: Text(
                                        _badgesPhase2Locked
                                            ? l10n.comingSoon
                                            : l10n.seeAll,
                                        style: const TextStyle(
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                if (_displayBadges.isEmpty)
                                  Text(
                                    l10n.noActivityYet,
                                    style: TextStyle(
                                      color: context.textSecondary,
                                      fontSize: 13,
                                    ),
                                  )
                                else if (_displayBadges.length <= 4)
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      for (final badge in _displayBadges)
                                        Expanded(
                                          flex: 1,
                                          child: ProfileBadgeChip(
                                            label: badge.title,
                                            color: _badgeColor(badge.color),
                                            icon: _badgeIcon(badge.key),
                                            earned: badge.earned,
                                            compact: true,
                                            expand: true,
                                            onTap: _badgesPhase2Locked
                                                ? _showBadgesPhase2
                                                : _showFeatureUnavailable,
                                          ),
                                        ),
                                    ],
                                  )
                                else
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (var i = 0;
                                            i < _displayBadges.length;
                                            i++) ...[
                                          if (i > 0) const SizedBox(width: 14),
                                          ProfileBadgeChip(
                                            label: _displayBadges[i].title,
                                            color: _badgeColor(
                                              _displayBadges[i].color,
                                            ),
                                            icon: _badgeIcon(
                                              _displayBadges[i].key,
                                            ),
                                            earned: _displayBadges[i].earned,
                                            onTap: _badgesPhase2Locked
                                                ? _showBadgesPhase2
                                                : _showFeatureUnavailable,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 18),
                                Text(
                                  l10n.quickLinks,
                                  style: TextStyle(
                                    color: context.isDarkMode
                                        ? context.textPrimary
                                        : AppColors.secondaryBlue,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ProfileQuickLinkTile(
                                  icon: Icons.bookmark_rounded,
                                  label: l10n.savedArticles,
                                  onTap: () => _requireAuthThen(
                                    const BookmarksScreen(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ProfileQuickLinkTile(
                                  icon: Icons.workspace_premium_rounded,
                                  label: l10n.myCertificates,
                                  onTap: _showFeatureUnavailable,
                                ),
                                const SizedBox(height: 8),
                                ProfileQuickLinkTile(
                                  icon: Icons.emoji_events_rounded,
                                  label: l10n.myGains,
                                  onTap: _showFeatureUnavailable,
                                ),
                                const SizedBox(height: 8),
                                ProfileQuickLinkTile(
                                  icon: Icons.settings_rounded,
                                  label: l10n.dapeSettings,
                                  onTap: () =>
                                      _open(const SettingsHubScreen()),
                                ),
                                if (!_loggedIn) ...[
                                  const SizedBox(height: 20),
                                  TextButton(
                                    onPressed: () =>
                                        _open(const ForgotPasswordScreen()),
                                    child: Text(
                                      l10n.forgotPassword,
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
