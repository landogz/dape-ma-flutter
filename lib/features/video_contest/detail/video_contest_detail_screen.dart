import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/video_contest.dart';
import '../../../core/models/video_contest_entry.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/login_screen.dart';
import '../submit/video_contest_submit_screen.dart';

class VideoContestDetailScreen extends StatefulWidget {
  final int contestId;

  const VideoContestDetailScreen({super.key, required this.contestId});

  @override
  State<VideoContestDetailScreen> createState() =>
      _VideoContestDetailScreenState();
}

class _VideoContestDetailScreenState extends State<VideoContestDetailScreen> {
  VideoContest? _contest;
  List<VideoContestEntry> _entries = [];
  VideoContestEntry? _myEntry;
  bool _loading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = await AuthService.getToken();
      final loggedIn = token != null && token.isNotEmpty;
      final Map<String, dynamic> root;
      if (loggedIn) {
        final res = await AuthService.authedGet<Map<String, dynamic>>(
          Endpoints.videoContestDetail(widget.contestId),
        );
        root = res.data ?? <String, dynamic>{};
      } else {
        final res = await ApiClient().get<Map<String, dynamic>>(
          Endpoints.videoContestDetail(widget.contestId),
        );
        root = res.data ?? <String, dynamic>{};
      }

      final data = root['data'];
      VideoContest? contest;
      List<VideoContestEntry> entries = [];
      VideoContestEntry? myEntry;

      if (data is Map<String, dynamic>) {
        if (data['contest'] is Map<String, dynamic>) {
          contest =
              VideoContest.fromJson(data['contest'] as Map<String, dynamic>);
        }
        if (data['entries'] is List) {
          entries = (data['entries'] as List)
              .whereType<Map<String, dynamic>>()
              .map(VideoContestEntry.fromJson)
              .toList();
        }
        if (data['my_entry'] is Map<String, dynamic>) {
          myEntry = VideoContestEntry.fromJson(
            data['my_entry'] as Map<String, dynamic>,
          );
        }
      }

      if (mounted) {
        setState(() {
          _contest = contest;
          _entries = entries;
          _myEntry = myEntry;
          _isLoggedIn = loggedIn;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _contest = null;
          _entries = [];
          _myEntry = null;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _onSubmitTap() async {
    final token = await AuthService.getToken();
    if (token == null || token.isEmpty) {
      if (!mounted) return;
      final loggedIn = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      await _load();
      if (loggedIn != true || !mounted || _contest == null || _myEntry != null) {
        return;
      }
    }

    if (!mounted || _contest == null) return;
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => VideoContestSubmitScreen(contest: _contest!),
      ),
    );
    if (submitted == true) {
      await _load();
    }
  }

  bool get _showSubmitCta =>
      _contest != null && _contest!.canSubmitEntry && _myEntry == null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.videoContestDetailTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: _loading || _contest == null || !_showSubmitCta
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onSubmitTap,
                    icon: Icon(
                      _isLoggedIn ? Icons.upload_outlined : Icons.login,
                    ),
                    label: Text(
                      _isLoggedIn
                          ? l10n.submitVideoEntry
                          : l10n.loginToSubmitVideo,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _contest == null
              ? Center(child: Text(l10n.noVideoContestFound))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      _showSubmitCta ? 24 : 32,
                    ),
                    children: [
                      Text(
                        _contest!.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryLight,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _Pill(label: _contest!.status.toUpperCase()),
                          if (_contest!.contestYear != null)
                            _Pill(label: '${_contest!.contestYear}'),
                          if (_contest!.canSubmitEntry)
                            _Pill(label: l10n.acceptingEntries),
                        ],
                      ),
                      if (_contest!.description != null &&
                          _contest!.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _contest!.description!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimaryLight,
                                    height: 1.45,
                                  ),
                        ),
                      ],
                      if (_contest!.rules != null &&
                          _contest!.rules!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.contestRules,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _contest!.rules!,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textPrimaryLight,
                                    height: 1.45,
                                  ),
                        ),
                      ],
                      if (_myEntry != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${l10n.yourEntryStatus}: ${_myEntry!.status.toUpperCase()} — ${_myEntry!.title}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ] else if (!_contest!.canSubmitEntry) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.submissionsClosed,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.orange.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _onSubmitTap,
                            icon: const Icon(Icons.upload_outlined),
                            label: Text(l10n.submitVideoEntry),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primaryBlue,
                              side: const BorderSide(
                                color: AppColors.primaryBlue,
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text(
                        l10n.publishedVideos,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 10),
                      if (_entries.isEmpty)
                        Text(
                          l10n.noPublishedVideosYet,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                        )
                      else
                        ..._entries.map(
                          (entry) => _PublishedVideoTile(entry: entry),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _PublishedVideoTile extends StatefulWidget {
  final VideoContestEntry entry;

  const _PublishedVideoTile({required this.entry});

  @override
  State<_PublishedVideoTile> createState() => _PublishedVideoTileState();
}

class _PublishedVideoTileState extends State<_PublishedVideoTile> {
  YoutubePlayerController? _yt;

  @override
  void initState() {
    super.initState();
    if (widget.entry.isYoutube && widget.entry.hasVideo) {
      final id = YoutubePlayer.convertUrlToId(widget.entry.videoUrl);
      if (id != null) {
        _yt = YoutubePlayerController(
          initialVideoId: id,
          flags: const YoutubePlayerFlags(autoPlay: false),
        );
      }
    }
  }

  @override
  void dispose() {
    _yt?.dispose();
    super.dispose();
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.entry.videoUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                Text(
                  entry.status.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              entry.creatorName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
            ),
            if (_yt != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: YoutubePlayer(
                  controller: _yt!,
                  showVideoProgressIndicator: true,
                ),
              ),
            ] else if (entry.hasVideo) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _openExternal,
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(
                  entry.isYoutube
                      ? context.l10n.openOnYoutube
                      : context.l10n.openMediaLink,
                ),
              ),
            ],
            if (entry.description != null &&
                entry.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.description!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
