import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/video_contest.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/video_contest_card.dart';

class VideoContestScreen extends StatefulWidget {
  const VideoContestScreen({super.key});

  @override
  State<VideoContestScreen> createState() => _VideoContestScreenState();
}

class _VideoContestScreenState extends State<VideoContestScreen> {
  List<VideoContest> _contests = [];
  bool _loading = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContests() async {
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.videoContest,
        query: <String, dynamic>{
          if (_searchController.text.trim().isNotEmpty)
            'search': _searchController.text.trim(),
        },
      );
      final root = res.data ?? <String, dynamic>{};
      List<dynamic> list = const [];
      final data = root['data'];
      if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
        list = data['data'] as List<dynamic>;
      } else if (data is List<dynamic>) {
        list = data;
      }
      if (mounted) {
        setState(() {
          _contests = list
              .map((e) => VideoContest.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _contests = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.videoContestTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchVideoContestHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _loadContests(),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _contests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam_off_outlined,
                                size: 64,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noVideoContestFound,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadContests,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _contests.length,
                            itemBuilder: (context, index) {
                              return VideoContestCard(
                                contest: _contests[index],
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
