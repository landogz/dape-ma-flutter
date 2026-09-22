import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/models/contest.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';
import '../hope/hope_colors.dart';
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
  String _search = '';

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
    return switch (_categoryFilter) {
      ContestCategoryFilter.all => null,
      ContestCategoryFilter.song => 'song',
      ContestCategoryFilter.poster => 'poster',
      ContestCategoryFilter.video => 'video',
    };
  }

  Future<void> _loadContests() async {
    setState(() => _loading = true);
    try {
      final api = ApiClient();
      final res = await api.get<Map<String, dynamic>>(
        Endpoints.contests,
        query: <String, dynamic>{
          if (_search.trim().isNotEmpty) 'search': _search.trim(),
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
    final chips = <(ContestCategoryFilter, String)>[
      (ContestCategoryFilter.all, l10n.contestCategoryAll),
      (ContestCategoryFilter.song, l10n.contestCategorySong),
      (ContestCategoryFilter.poster, l10n.contestCategoryPoster),
      (ContestCategoryFilter.video, l10n.contestCategoryVideo),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: HopeColors.purple,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.contestsTitle,
          style: const TextStyle(
            color: HopeColors.purple,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: chips.map((chip) {
                final selected = _categoryFilter == chip.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(chip.$2),
                    selected: selected,
                    onSelected: (_) => _onCategorySelected(chip.$1),
                    selectedColor: HopeColors.purple,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : HopeColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color:
                          selected ? HopeColors.purple : HopeColors.cardBorder,
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onSubmitted: (v) {
                setState(() => _search = v);
                _loadContests();
              },
              onChanged: (v) {
                if (v.isEmpty && _search.isNotEmpty) {
                  setState(() => _search = '');
                  _loadContests();
                }
              },
              decoration: InputDecoration(
                hintText: l10n.searchContestsHint,
                hintStyle: const TextStyle(color: HopeColors.muted),
                prefixIcon:
                    const Icon(Icons.search, color: HopeColors.purple),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: HopeColors.purple, width: 1.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: HopeColors.purple),
                  )
                : _contests.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.emoji_events_outlined,
                                size: 56,
                                color: HopeColors.muted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.noContestsFound,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: HopeColors.purple,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _search.isNotEmpty ||
                                        _categoryFilter !=
                                            ContestCategoryFilter.all
                                    ? l10n.tryDifferentSearch
                                    : l10n.checkBackLater,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: HopeColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        color: HopeColors.purple,
                        onRefresh: _loadContests,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _contests.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return ContestCard(contest: _contests[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
