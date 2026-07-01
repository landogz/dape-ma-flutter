import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/auth/auth_service.dart';
import '../../core/models/post.dart';
import '../../core/models/post_comment.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/json_parsers.dart';
import '../auth/login_screen.dart';
import '../post_engagement/post_engagement_service.dart';
import '../post_engagement/widgets/comment_bubble.dart';
import '../post_engagement/widgets/edit_comment_sheet.dart';

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

  static String _formatTime(DateTime? d) {
    if (d == null) return '';
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  static String _formatTimeAgo(DateTime? published) {
    if (published == null) return '';
    final now = DateTime.now();
    final diff = now.difference(published);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    if (diff.inDays < 7) return '${diff.inDays} d ago';
    return '${published.day}/${published.month}/${published.year}';
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
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
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
    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
      _loadCurrentUser();
    }
    try {
      final result = await PostEngagementService.toggleLike(_post.id);
      if (!mounted) return;
      setState(() {
        _post = _post.copyWith(
          isLiked: result.liked,
          likesCount: result.likesCount,
        );
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PostEngagementService.friendlyError(e, 'like this post')),
        ),
      );
    }
  }

  Future<void> _submitComment(String value) async {
    final body = value.trim();
    if (body.isEmpty || _submittingComment) return;

    if (!_isLoggedIn) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true || !mounted) return;
      setState(() => _isLoggedIn = true);
      _loadCurrentUser();
    }

    setState(() => _submittingComment = true);
    try {
      final comment =
          await PostEngagementService.postComment(_post.id, body);
      if (!mounted) return;
      setState(() {
        _comments = [comment, ..._comments];
        _post = _post.copyWith(commentsCount: _post.commentsCount + 1);
        _commentController.clear();
      });
      _commentFocus.unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PostEngagementService.friendlyError(e, 'post a comment')),
        ),
      );
    } finally {
      if (mounted) setState(() => _submittingComment = false);
    }
  }

  Future<void> _editComment(PostComment comment) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
            final index = _comments.indexWhere((c) => c.id == comment.id);
            if (index != -1) {
              _comments[index] = result;
            }
          });
        },
      ),
    );
    if (updated == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment updated')),
      );
    }
  }

  Future<void> _deleteComment(PostComment comment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This comment will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final commentsCount = await PostEngagementService.deleteComment(
        _post.id,
        comment.id,
      );
      if (!mounted) return;
      setState(() {
        _comments.removeWhere((c) => c.id == comment.id);
        _post = _post.copyWith(commentsCount: commentsCount);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PostEngagementService.friendlyError(e, 'delete this comment'),
          ),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBookmarked ? 'Saved to bookmarks' : 'Removed from bookmarks',
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

  @override
  void dispose() {
    _commentFocus.dispose();
    _commentController.dispose();
    _ytController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final hasImage = post.imageUrl != null && post.imageUrl!.isNotEmpty;
    final initial = post.authorName.isNotEmpty
        ? post.authorName.trim().substring(0, 1).toUpperCase()
        : '?';
    final timeStr = _formatTime(post.publishedAt);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_post),
        ),
        title: Text(
          "${post.authorName}'s Post",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.white,
            ),
            onPressed: _onBookmarkTap,
          ),
          if (timeStr.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  timeStr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Post header (avatar, name, time) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              AppColors.primaryBlue.withOpacity(0.2),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                              ),
                              Text(
                                _formatTimeAgo(post.publishedAt),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down),
                          color: AppColors.textSecondaryLight,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // ── Category ──
                  if (post.categoryName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          post.categoryName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  // ── Title ──
                  if (post.title.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Text(
                        post.title,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryLight,
                            ),
                      ),
                    ),
                  // ── Body (rich text as plain text) ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Text(
                      _stripHtml(
                        post.content.isNotEmpty
                            ? post.content
                            : post.excerpt,
                      ),
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            color: AppColors.textPrimaryLight,
                            height: 1.5,
                          ),
                    ),
                  ),
                  // ── Media ──
                  if (hasImage) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          post.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  if (_ytController != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 16),
                  // ── Reactions summary ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Text(
                          '${post.likesCount} ${post.likesCount == 1 ? 'like' : 'likes'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${post.commentsCount} ${post.commentsCount == 1 ? 'comment' : 'comments'}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _DetailActionButton(
                        icon: post.isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        label: 'Like',
                        isActive: post.isLiked,
                        onTap: _onLikeTap,
                      ),
                      _DetailActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Comment',
                        onTap: () {
                          FocusScope.of(context).requestFocus(_commentFocus);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  // ── Rate & Review (optional CTA) ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _onRateAndReview,
                        icon: const Icon(Icons.star_outline, size: 20),
                        label: const Text('Rate & Review'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  // ── Comments section ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Comments',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (post.commentsCount > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${post.commentsCount} ${post.commentsCount == 1 ? 'comment' : 'comments'}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (_hasMoreComments && _comments.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: _loadingMoreComments
                                    ? null
                                    : () => _loadComments(loadMore: true),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primaryBlue,
                                  padding: EdgeInsets.zero,
                                ),
                                child: _loadingMoreComments
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Load previous comments...'),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: const Text('Retry'),
                              ),
                            ],
                          )
                        else if (_comments.isEmpty)
                          Text(
                            'No comments yet. Be the first to comment.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppColors.textSecondaryLight,
                                  fontStyle: FontStyle.italic,
                                ),
                          )
                        else
                          ..._comments.map(_buildCommentTile),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Write comment bar (Facebook-style bottom input) ──
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.textSecondaryLight,
                  ),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocus,
                    enabled: !_submittingComment,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondaryLight,
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: AppColors.lightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: _submitComment,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_commentController.text.trim().isNotEmpty)
                  IconButton(
                    onPressed:
                        _submittingComment ? null : () => _submitComment(_commentController.text),
                    icon: Icon(
                      Icons.send_rounded,
                      color: AppColors.primaryBlue,
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.textSecondaryLight,
                    ),
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentTile(PostComment comment) {
    final canManage = _currentUserId != null &&
        comment.userId > 0 &&
        comment.userId == _currentUserId;
    return CommentBubble(
      comment: comment,
      timeAgo: _formatTimeAgo(comment.createdAt),
      canManage: canManage,
      onEdit: () => _editComment(comment),
      onDelete: () => _deleteComment(comment),
      onReply: () => FocusScope.of(context).requestFocus(_commentFocus),
    );
  }

  Future<void> _onRateAndReview() async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    if (token == null) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true) return;
    }
    if (!mounted) return;
    _showReviewSheet();
  }

  void _openReviewSheetWithComment(String comment) async {
    final token = await AuthService.getToken();
    if (!mounted) return;
    if (token == null) {
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      if (loggedIn != true) return;
    }
    if (!mounted) return;
    _showReviewSheet(initialComment: comment);
  }

  void _showReviewSheet({String? initialComment}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReviewSheet(
        postId: _post.id,
        initialComment: initialComment,
      ),
    );
  }
}

class _DetailActionButton extends StatelessWidget {
  const _DetailActionButton({
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({
    required this.postId,
    this.initialComment,
  });

  final int postId;
  final String? initialComment;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialComment != null) {
      _commentController.text = widget.initialComment!;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating <= 0) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await AuthService.authedPost<Map<String, dynamic>>(
        Endpoints.reviews,
        data: <String, dynamic>{
          'target_type': 'post',
          'target_id': widget.postId,
          'rating': _rating,
          'comment': _commentController.text.trim(),
        },
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _error = 'Failed to submit. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rate this content',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              return IconButton(
                icon: Icon(
                  starIndex <= _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _rating = starIndex;
                  });
                },
              );
            }),
          ),
          TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 12),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
