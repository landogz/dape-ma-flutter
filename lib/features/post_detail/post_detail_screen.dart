import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/accessibility/accessibility_controller.dart';
import '../../core/accessibility/read_aloud_service.dart';
import '../../core/accessibility/youtube_a11y.dart';
import '../../core/analytics/analytics_client.dart';
import '../../core/auth/auth_service.dart';
import '../../core/l10n/locale_scope.dart';
import '../../core/models/post.dart';
import '../../core/models/post_comment.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/json_parsers.dart';
import '../auth/login_screen.dart';
import '../diary/image/diary_image_picker.dart';
import '../post_engagement/comment_tree_utils.dart';
import '../post_engagement/post_engagement_service.dart';
import '../post_engagement/post_reaction.dart';
import '../post_engagement/reaction_picker.dart';
import '../post_engagement/reactors_sheet.dart';
import '../post_engagement/widgets/comment_bubble.dart';
import '../post_engagement/widgets/comment_emoji_sheet.dart';
import '../post_engagement/widgets/edit_comment_sheet.dart';
import '../reviews/widgets/review_sheet.dart';
import 'widgets/post_article_layout.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final bool initialIsBookmarked;
  final bool focusCommentOnOpen;

  const PostDetailScreen({
    super.key,
    required this.post,
    this.initialIsBookmarked = false,
    this.focusCommentOnOpen = false,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  YoutubePlayerController? _ytController;
  final _commentFocus = FocusNode();
  final _commentController = TextEditingController();
  late Post _post;
  bool _isBookmarked = false;
  bool _isLoggedIn = false;
  int? _currentUserId;
  List<PostComment> _comments = [];
  bool _loadingComments = false;
  bool _loadingMoreComments = false;
  bool _hasMoreComments = false;
  int _commentsPage = 1;
  String? _commentsError;
  bool _submittingComment = false;
  PostComment? _replyingTo;
  File? _commentImage;

  static String _formatTimeAgo(DateTime? published) {
    if (published == null) return 'Just now';
    final now = DateTime.now();
    final diff = now.difference(published);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return formatPostDate(published);
  }


  void _showFloatingSnack(String message) {
    if (!mounted) return;
    final bottomClearance =
        96 + MediaQuery.viewPaddingOf(context).bottom;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: bottomClearance,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  static String _stripHtml(String html) {
    if (html.isEmpty) return '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _isBookmarked = widget.initialIsBookmarked;
    AuthService.getToken().then((t) {
      if (mounted) {
        setState(() => _isLoggedIn = t != null && t.isNotEmpty);
        if (_isLoggedIn) _loadCurrentUser();
      }
    });
    _loadComments();
    _refreshPostEngagement();
    AnalyticsClient.instance.trackPostView(widget.post.id);
    if (widget.focusCommentOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          FocusScope.of(context).requestFocus(_commentFocus);
        }
      });
    }
    final url = widget.post.youtubeUrl;
    if (url != null && url.isNotEmpty) {
      final id = YoutubePlayer.convertUrlToId(url);
      if (id != null) {
        _ytController = YoutubePlayerController(
          initialVideoId: id,
          flags: buildYoutubeFlags(
            enableCaptions: AccessibilityController.instance.captions,
          ),
        );
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final res = await AuthService.authedGet<Map<String, dynamic>>(
        Endpoints.me,
      );
      final root = res.data ?? <String, dynamic>{};
      final user = root['data'] is Map<String, dynamic>
          ? root['data'] as Map<String, dynamic>
          : root;
      final id = user['id'];
      final parsedId = parseJsonInt(id, 0);
      if (mounted && parsedId > 0) {
        setState(() => _currentUserId = parsedId);
      }
    } catch (_) {
      if (mounted) setState(() => _currentUserId = null);
    }
  }

  Future<void> _refreshPostEngagement() async {
    try {
      final fresh = await PostEngagementService.fetchPost(_post.id);
      if (!mounted) return;
      setState(() => _post = fresh);
    } catch (_) {
      // Keep the post passed from the feed when refresh fails.
    }
  }

  Future<void> _loadComments({bool loadMore = false}) async {
    if (loadMore) {
      if (_loadingMoreComments || !_hasMoreComments) return;
      setState(() => _loadingMoreComments = true);
    } else {
      setState(() {
        _loadingComments = true;
        _commentsError = null;
        _commentsPage = 1;
      });
    }

    final page = loadMore ? _commentsPage + 1 : 1;

    try {
      final result = await PostEngagementService.fetchComments(
        _post.id,
        page: page,
      );
      if (!mounted) return;
      setState(() {
        if (loadMore) {
          _comments = [..._comments, ...result.comments];
        } else {
          _comments = result.comments;
        }
        _commentsPage = page;
        _hasMoreComments = result.hasMore;
        _commentsError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (!loadMore) {
          _comments = [];
          _commentsError = PostEngagementService.friendlyError(
            e,
            'load comments',
            context.l10n,
          );
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingComments = false;
          _loadingMoreComments = false;
        });
      }
    }
  }

  Future<void> _onLikeTap() async {
    await _applyReaction(PostReactionType.like);
  }

  Future<void> _onLikeLongPress(Offset anchor) async {
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
      _loadCurrentUser();
    }

    final selected = await showReactionPicker(
      context,
      selected: _post.userReaction,
      anchor: anchor,
    );
    if (selected == null || !mounted) return;
    await _applyReaction(selected);
  }

  Future<void> _applyReaction(PostReactionType reaction) async {
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
      _loadCurrentUser();
    }
    try {
      final result = await PostEngagementService.setReaction(
        _post.id,
        reaction: reaction,
      );
      if (!mounted) return;
      setState(() {
        _post = _post.copyWith(
          isLiked: result.liked,
          likesCount: result.likesCount,
          userReaction: result.userReaction,
          clearUserReaction: result.userReaction == null,
          reactionCounts: result.reactionCounts,
        );
      });
      if (result.liked) {
        await AnalyticsClient.instance.trackLike(_post.id);
      }
    } catch (e) {
      if (!mounted) return;
      _showFloatingSnack(
        PostEngagementService.friendlyError(
          e,
          'react to this post',
          context.l10n,
        ),
      );
    }
  }

  Future<void> _onReactionsTap() async {
    if (_post.likesCount <= 0) return;
    await showReactorsSheet(
      context,
      postId: _post.id,
      reactionCounts: _post.reactionCounts,
    );
  }

  bool get _canSubmitComment =>
      _commentController.text.trim().isNotEmpty || _commentImage != null;

  Future<void> _pickCommentImage() async {
    if (!_post.commentsEnabled || _submittingComment) return;
    final l10n = context.l10n;
    final file = await DiaryImagePicker.pick(
      context: context,
      title: l10n.journalPhotoSourceTitle,
      cameraLabel: l10n.journalPhotoCamera,
      galleryLabel: l10n.journalPhotoGallery,
      cancelLabel: l10n.cancel,
    );
    if (!mounted || file == null) return;
    setState(() => _commentImage = file);
  }

  Future<void> _pickCommentEmoji() async {
    if (!_post.commentsEnabled || _submittingComment) return;
    final emoji = await showCommentEmojiSheet(context);
    if (!mounted || emoji == null || emoji.isEmpty) return;

    final text = _commentController.text;
    final selection = _commentController.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final next = text.replaceRange(start, end, emoji);
    _commentController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
    setState(() {});
    FocusScope.of(context).requestFocus(_commentFocus);
  }

  Future<void> _submitComment(String value) async {
    if (!_post.commentsEnabled) return;
    final body = value.trim();
    if ((!_canSubmitComment && body.isEmpty) || _submittingComment) return;
    if (body.isEmpty && _commentImage == null) return;

    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
      _loadCurrentUser();
    }

    final parentId = _replyingTo?.id;
    final image = _commentImage;
    setState(() => _submittingComment = true);
    try {
      final comment = await PostEngagementService.postComment(
        _post.id,
        body,
        parentId: parentId,
        image: image,
      );
      if (!mounted) return;
      setState(() {
        _comments = addCommentToTree(_comments, comment);
        _post = _post.copyWith(commentsCount: _post.commentsCount + 1);
        _commentController.clear();
        _commentImage = null;
        _replyingTo = null;
      });
      _commentFocus.unfocus();
      _showFloatingSnack(
            parentId == null
                ? context.l10n.commentPosted
                : context.l10n.replyPosted,
          );
    } catch (e) {
      if (!mounted) return;
      _showFloatingSnack(
        PostEngagementService.friendlyError(
              e,
              'post a comment',
              context.l10n,
            ),
      );
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  void _startReply(PostComment comment) {
    if (!_isLoggedIn) {
      Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      ).then((loggedIn) {
        if (loggedIn == true && mounted) {
          setState(() => _isLoggedIn = true);
          _loadCurrentUser();
          setState(() => _replyingTo = comment);
          FocusScope.of(context).requestFocus(_commentFocus);
        }
      });
      return;
    }

    setState(() => _replyingTo = comment);
    FocusScope.of(context).requestFocus(_commentFocus);
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
  }

  Future<void> _editComment(PostComment comment) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => EditCommentSheet(
        initialBody: comment.body,
        onSave: (body) async {
          final result = await PostEngagementService.updateComment(
            _post.id,
            comment.id,
            body,
          );
          if (!mounted) return;
          setState(() {
            _comments = updateCommentInTree(_comments, result);
          });
        },
      ),
    );
    if (updated == true && mounted) {
      _showFloatingSnack(context.l10n.commentUpdated);
    }
  }

  Future<void> _deleteComment(PostComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l10n = ctx.l10n;
        return AlertDialog(
          title: Text(l10n.deleteCommentTitle),
          content: Text(l10n.deleteCommentBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
              child: Text(l10n.deleteAction),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) return;

    try {
      final commentsCount = await PostEngagementService.deleteComment(
        _post.id,
        comment.id,
      );
      if (!mounted) return;
      setState(() {
        _comments = removeCommentFromTree(_comments, comment.id);
        _post = _post.copyWith(commentsCount: commentsCount);
      });
      _showFloatingSnack(context.l10n.commentDeleted);
    } catch (e) {
      if (!mounted) return;
      _showFloatingSnack(
        PostEngagementService.friendlyError(
              e,
              'delete this comment',
              context.l10n,
            ),
      );
    }
  }

  Future<void> _onBookmarkTap() async {
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
    }
    try {
      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.bookmarks,
        data: <String, dynamic>{'post_id': _post.id},
      );
      if (!mounted) return;
      setState(() => _isBookmarked = !_isBookmarked);
      if (_isBookmarked) {
        await AnalyticsClient.instance.trackBookmark(_post.id);
      }
      if (!mounted) return;
      _showFloatingSnack(
        _isBookmarked
            ? context.l10n.savedToBookmarks
            : context.l10n.removedFromBookmarks,
      );
    } catch (_) {
      if (!mounted) return;
      _showFloatingSnack(context.l10n.bookmarkUpdateFailed);
    }
  }

  @override
  void dispose() {
    _commentFocus.dispose();
    _commentController.dispose();
    _ytController?.dispose();
    ReadAloudService.instance.stop();
    super.dispose();
  }

  Future<void> _onShareTap() async {
    final l10n = context.l10n;
    final shareText = [
      _post.title,
      if (_post.excerpt.trim().isNotEmpty) _post.excerpt.trim(),
    ].join('\n\n');
    await Clipboard.setData(ClipboardData(text: shareText));
    if (!mounted) return;
    _showFloatingSnack(l10n.linkCopied);
  }

  Future<void> _toggleReadAloud() async {
    final service = ReadAloudService.instance;
    if (service.isSpeaking) {
      await service.stop();
      if (mounted) setState(() {});
      return;
    }
    final text = '${_post.title}. ${_stripHtml(_post.content)}';
    await service.speak(text);
    if (mounted) setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final post = _post;
    final l10n = context.l10n;
    final a11y = AccessibilityController.instance;
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final topInset = MediaQuery.viewPaddingOf(context).top;
    final statusTop = topInset > 0 ? topInset : 59.0;
    final pinnedTopHeight = kToolbarHeight + statusTop;
    // Keep last comment fully above the floating composer when comments are on.
    final listBottomPadding = post.commentsEnabled ? 110.0 : 24.0;
    final scrollBottomClearance = listBottomPadding + bottomInset;

    return Scaffold(
      backgroundColor: context.pageBackground,
      primary: true,
      extendBodyBehindAppBar: false,
      body: Column(
        children: [
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle.light,
            child: SizedBox(
              height: pinnedTopHeight,
              width: double.infinity,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF123A60),
                      Color(0xFF055498),
                    ],
                  ),
                ),
                child: SafeArea(
                  top: true,
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(_post),
                        ),
                        const Spacer(),
                        if (a11y.readAloud)
                          IconButton(
                            tooltip: ReadAloudService.instance.isSpeaking
                                ? l10n.stopListening
                                : l10n.listenToArticle,
                            onPressed: _toggleReadAloud,
                            icon: Icon(
                              ReadAloudService.instance.isSpeaking
                                  ? Icons.stop_circle_outlined
                                  : Icons.record_voice_over_rounded,
                              color: Colors.white,
                            ),
                          ),
                        IconButton(
                          tooltip: l10n.bookmarksTitle,
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _onBookmarkTap,
                        ),
                        IconButton(
                          tooltip: l10n.sharePost,
                          icon: const Icon(
                            Icons.ios_share_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _onShareTap,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                CustomScrollView(
                  primary: true,
                  clipBehavior: Clip.hardEdge,
                  slivers: [
                    SliverToBoxAdapter(child: PostHeroHeader(post: post)),
                    SliverToBoxAdapter(
                      child: Transform.translate(
                        offset: const Offset(0, -28),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: context.pageBackground,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 16,
                                offset: const Offset(0, -4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 10),
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: context.borderSubtle
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                              if (_ytController != null) ...[
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: YoutubePlayer(
                                        controller: _ytController!,
                                        showVideoProgressIndicator: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 20, 4),
                                child: PostArticleBody(
                                  htmlOrText: post.content.isNotEmpty
                                      ? post.content
                                      : post.excerpt,
                                ),
                              ),
                              PostEngagementBar(
                                likesCount: post.likesCount,
                                commentsCount: post.commentsCount,
                                isLiked: post.isLiked,
                                userReaction: post.userReaction,
                                reactionCounts: post.reactionCounts,
                                onLike: _onLikeTap,
                                onLikeLongPress: _onLikeLongPress,
                                onReactionsTap: _onReactionsTap,
                                onComment: post.commentsEnabled
                                    ? () {
                                        FocusScope.of(context)
                                            .requestFocus(_commentFocus);
                                      }
                                    : null,
                                onShare: _onShareTap,
                              ),
                              PostRatingCard(
                                averageRating: post.averageRating,
                                reviewsCount: post.reviewsCount,
                                userRating: post.userRating,
                                onStarTap: _onRateStarTap,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                child: Divider(
                                  height: 1,
                                  color: context.borderSubtle,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  16,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: AppColors.softBlue,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.forum_outlined,
                                            size: 18,
                                            color: AppColors.mediumElectricBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                l10n.commentsTitle,
                                                style: AppTypography.header(
                                                  color: AppColors.nileBlue,
                                                ).copyWith(fontSize: 18),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                post.commentsCount > 0
                                                    ? l10n.commentsCount(
                                                        post.commentsCount,
                                                      )
                                                    : l10n.noCommentsEmptyTitle,
                                                style: AppTypography.body(
                                                  color: context.textSecondary,
                                                  fontSize: 12.5,
                                                ).copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (_hasMoreComments &&
                                        _comments.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton(
                                            onPressed: _loadingMoreComments
                                                ? null
                                                : () => _loadComments(
                                                      loadMore: true,
                                                    ),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.primaryBlue,
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: _loadingMoreComments
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                    ),
                                                  )
                                                : Text(
                                                    l10n.loadPreviousComments,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    if (_loadingComments)
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (_commentsError != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _commentsError!,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: AppColors.accentRed,
                                                ),
                                          ),
                                          TextButton(
                                            onPressed: _loadComments,
                                            child: Text(l10n.retry),
                                          ),
                                        ],
                                      )
                                    else if (_comments.isEmpty)
                                      post.commentsEnabled
                                          ? const CommentsEmptyState()
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 12,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    l10n.commentsDisabledTitle,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    l10n.commentsDisabledBody,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: context
                                                              .textSecondary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            )
                                    else
                                      ..._comments.map(
                                        (comment) => CommentThread(
                                          comment: comment,
                                          timeAgoBuilder: _formatTimeAgo,
                                          canManageBuilder: _canManageComment,
                                          onEdit: _editComment,
                                          onDelete: _deleteComment,
                                          onReply: post.commentsEnabled
                                              ? _startReply
                                              : null,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(bottom: scrollBottomClearance),
                      sliver: const SliverToBoxAdapter(
                        child: SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
                if (post.commentsEnabled)
                  Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_replyingTo != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          color: context.mutedSurface,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${l10n.replyingTo} ${_replyingTo!.authorName}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.primaryBlue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: context.textSecondary,
                                onPressed: _cancelReply,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.only(
                          left: 12,
                          right: 12,
                          top: 8,
                          bottom: 12 + bottomInset,
                        ),
                        decoration: BoxDecoration(
                          color: context.cardBackground,
                          border: Border(
                            top: BorderSide(
                              color: context.borderSubtle,
                              width: 1,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_commentImage != null) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: Image.file(
                                        _commentImage!,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: -6,
                                      right: -6,
                                      child: Material(
                                        color: AppColors.nileBlue,
                                        shape: const CircleBorder(),
                                        child: InkWell(
                                          customBorder: const CircleBorder(),
                                          onTap: _submittingComment
                                              ? null
                                              : () => setState(
                                                    () => _commentImage = null,
                                                  ),
                                          child: const SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: Icon(
                                              Icons.close_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  tooltip: l10n.journalPhotoAdd,
                                  icon: Icon(
                                    Icons.camera_alt_outlined,
                                    color: context.textSecondary,
                                  ),
                                  onPressed: _submittingComment
                                      ? null
                                      : _pickCommentImage,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    focusNode: _commentFocus,
                                    enabled: !_submittingComment,
                                    minLines: 1,
                                    maxLines: 4,
                                    textInputAction: TextInputAction.send,
                                    decoration: InputDecoration(
                                      hintText: _replyingTo == null
                                          ? l10n.writeComment
                                          : l10n.writeReply,
                                      hintStyle: TextStyle(
                                        color: context.textSecondary,
                                        fontSize: 15,
                                      ),
                                      filled: true,
                                      fillColor: context.inputFill,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(24),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                    ),
                                    onSubmitted: _submitComment,
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                                if (_canSubmitComment)
                                  IconButton(
                                    tooltip: l10n.writeComment,
                                    onPressed: _submittingComment
                                        ? null
                                        : () => _submitComment(
                                              _commentController.text,
                                            ),
                                    icon: _submittingComment
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primaryBlue,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.send_rounded,
                                            color: AppColors.primaryBlue,
                                          ),
                                  )
                                else
                                  IconButton(
                                    tooltip: 'Emoji',
                                    icon: Icon(
                                      Icons.emoji_emotions_outlined,
                                      color: context.textSecondary,
                                    ),
                                    onPressed: _submittingComment
                                        ? null
                                        : _pickCommentEmoji,
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
        ],
      ),
    );
  }

  bool _canManageComment(PostComment comment) {
    return _currentUserId != null &&
        comment.userId > 0 &&
        comment.userId == _currentUserId;
  }

  Future<void> _onRateStarTap(int rating) async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    if (token == null) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
      _loadCurrentUser();
    }
    if (!mounted) return;
    await _showReviewSheet(initialRating: rating);
  }

  Future<void> _showReviewSheet({
    String? initialComment,
    int? initialRating,
  }) async {
    final result = await showModalBottomSheet<({
      int rating,
      int reviewsCount,
      double averageRating,
    })>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ReviewSheet(
        postId: _post.id,
        initialRating: initialRating ?? _post.userRating ?? 5,
        initialComment: initialComment,
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _post = _post.copyWith(
        userRating: result.rating,
        reviewsCount: result.reviewsCount,
        averageRating: result.averageRating,
      );
    });

    await AnalyticsClient.instance.trackReview(_post.id);

    if (!mounted) return;
    _showFloatingSnack(context.l10n.ratingSubmitted);
  }
}
