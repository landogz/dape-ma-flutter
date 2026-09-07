import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/contest.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/contest_card.dart';

enum ContestCategoryFilter { all, song, poster, video }

class ContestsScreen extends StatefulWidget {
  const ContestsScreen({super.key});

  @override
  State<ContestsScreen> createState() => _ContestsScreenState();
}

class _ContestsScreenState extends State<ContestsScreen> {
  List<Contest> _contests = [];
  bool _loading = false;
  ContestCategoryFilter _categoryFilter = ContestCategoryFilter.all;
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

  String? get _categoryQuery {
    switch (_categoryFilter) {
      case ContestCategoryFilter.all:
        return null;
      case ContestCategoryFilter.song:
        return 'song';
      case ContestCategoryFilter.poster:
        return 'poster';
      case ContestCategoryFilter.video:
        return 'video';
    }
  }

  Future<void> _loadContests() async {
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.contests,
        query: <String, dynamic>{
          if (_searchController.text.trim().isNotEmpty)
            'search': _searchController.text.trim(),
          if (_categoryQuery != null) 'category': _categoryQuery,
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
              .map((e) => Contest.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (_) {
      if (mounted) setState(() => _contests = []);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onCategorySelected(ContestCategoryFilter filter) {
    if (_categoryFilter == filter) return;
    setState(() => _categoryFilter = filter);
    _loadContests();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contestsTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchContestsHint,
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
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: l10n.contestCategoryAll,
                    selected: _categoryFilter == ContestCategoryFilter.all,
                    onSelected: () =>
                        _onCategorySelected(ContestCategoryFilter.all),
                  ),
                  _FilterChip(
                    label: l10n.contestCategorySong,
                    selected: _categoryFilter == ContestCategoryFilter.song,
                    onSelected: () =>
                        _onCategorySelected(ContestCategoryFilter.song),
                  ),
                  _FilterChip(
                    label: l10n.contestCategoryPoster,
                    selected: _categoryFilter == ContestCategoryFilter.poster,
                    onSelected: () =>
                        _onCategorySelected(ContestCategoryFilter.poster),
                  ),
                  _FilterChip(
                    label: l10n.contestCategoryVideo,
                    selected: _categoryFilter == ContestCategoryFilter.video,
                    onSelected: () =>
                        _onCategorySelected(ContestCategoryFilter.video),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _contests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.emoji_events_outlined,
                                size: 64,
                                color: AppColors.textSecondaryLight,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noContestsFound,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondaryLight,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _searchController.text.isNotEmpty ||
                                        _categoryFilter !=
                                            ContestCategoryFilter.all
                                    ? l10n.tryDifferentSearch
                                    : l10n.checkBackLater,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
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
                              return ContestCard(contest: _contests[index]);
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.primaryBlue.withOpacity(0.2),
        labelStyle: TextStyle(
          color: selected
              ? AppColors.primaryBlue
              : AppColors.textSecondaryLight,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}
