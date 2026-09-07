import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/contest.dart';
import '../../../core/models/contest_entry.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/login_screen.dart';
import '../submit/contest_submit_screen.dart';

class ContestDetailScreen extends StatefulWidget {
  final int contestId;

  const ContestDetailScreen({super.key, required this.contestId});

  @override
  State<ContestDetailScreen> createState() => _ContestDetailScreenState();
}

class _ContestDetailScreenState extends State<ContestDetailScreen> {
  Contest? _contest;
  List<ContestEntry> _entries = [];
  ContestEntry? _myEntry;
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
          Endpoints.contestDetail(widget.contestId),
        );
        root = res.data ?? <String, dynamic>{};
      } else {
        final res = await ApiClient().get<Map<String, dynamic>>(
          Endpoints.contestDetail(widget.contestId),
        );
        root = res.data ?? <String, dynamic>{};
      }

      final data = root['data'];
      Contest? contest;
      List<ContestEntry> entries = [];
      ContestEntry? myEntry;

      if (data is Map<String, dynamic>) {
        if (data['contest'] is Map<String, dynamic>) {
          contest = Contest.fromJson(data['contest'] as Map<String, dynamic>);
        }
        if (data['entries'] is List) {
          entries = (data['entries'] as List)
              .whereType<Map<String, dynamic>>()
              .map(ContestEntry.fromJson)
              .toList();
        }
        if (data['my_entry'] is Map<String, dynamic>) {
          myEntry = ContestEntry.fromJson(
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
        builder: (_) => ContestSubmitScreen(contest: _contest!),
      ),
    );
    if (submitted == true) {
      await _load();
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool get _showSubmitCta =>
      _contest != null && _contest!.canSubmitEntry && _myEntry == null;

  String _categoryLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (_contest?.category.toLowerCase()) {
      case 'poster':
        return l10n.contestCategoryPoster;
      case 'video':
        return l10n.contestCategoryVideo;
      default:
        return l10n.contestCategorySong;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contestDetailTitle),
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
                          ? l10n.submitContestEntry
                          : l10n.loginToSubmitEntry,
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
              ? Center(child: Text(l10n.noContestsFound))
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
                          _Pill(label: _categoryLabel(context)),
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
                            label: Text(l10n.submitContestEntry),
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
                        l10n.publishedEntries,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      const SizedBox(height: 10),
                      if (_entries.isEmpty)
                        Text(
                          l10n.noPublishedEntriesYet,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                        )
                      else
                        ..._entries.map(
                          (entry) => _PublishedEntryTile(
                            entry: entry,
                            category: _contest!.category,
                            onOpenUrl: _openUrl,
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}

class _PublishedEntryTile extends StatefulWidget {
  final ContestEntry entry;
  final String category;
  final Future<void> Function(String url) onOpenUrl;

  const _PublishedEntryTile({
    required this.entry,
    required this.category,
    required this.onOpenUrl,
  });

  @override
  State<_PublishedEntryTile> createState() => _PublishedEntryTileState();
}

class _PublishedEntryTileState extends State<_PublishedEntryTile> {
  YoutubePlayerController? _yt;

  bool get _isPoster => widget.category.toLowerCase() == 'poster';
  bool get _isVideo => widget.category.toLowerCase() == 'video';

  @override
  void initState() {
    super.initState();
    if (!_isPoster) {
      final url = _isVideo
          ? widget.entry.effectiveVideoUrl
          : widget.entry.effectiveMediaUrl;
      if (url != null && widget.entry.isYoutube) {
        final id = YoutubePlayer.convertUrlToId(url);
        if (id != null) {
          _yt = YoutubePlayerController(
            initialVideoId: id,
            flags: const YoutubePlayerFlags(autoPlay: false),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _yt?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final posterUrl = entry.effectivePosterUrl;
    final mediaUrl = _isVideo
        ? entry.effectiveVideoUrl
        : entry.effectiveMediaUrl;

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
            if (_isPoster && posterUrl != null && posterUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  posterUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    alignment: Alignment.center,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
            ] else if (_yt != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: YoutubePlayer(
                  controller: _yt!,
                  showVideoProgressIndicator: true,
                ),
              ),
            ] else if (mediaUrl != null && mediaUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => widget.onOpenUrl(mediaUrl),
                icon: const Icon(Icons.open_in_new, size: 16),
                label: Text(
                  entry.isYoutube
                      ? context.l10n.openOnYoutube
                      : context.l10n.openMediaLink,
                ),
              ),
            ],
            if (entry.lyrics != null && entry.lyrics!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                entry.lyrics!,
                style: Theme.of(context).textTheme.bodySmall,
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
