import 'package:flutter/material.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import 'post_engagement_service.dart';
import 'post_reaction.dart';
import 'post_reactor.dart';

Future<void> showReactorsSheet(
  BuildContext context, {
  required int postId,
  required Map<PostReactionType, int> reactionCounts,
  PostReactionType? initialType,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _ReactorsSheet(
        postId: postId,
        reactionCounts: reactionCounts,
        initialType: initialType,
      );
    },
  );
}

class _ReactorsSheet extends StatefulWidget {
  const _ReactorsSheet({
    required this.postId,
    required this.reactionCounts,
    this.initialType,
  });

  final int postId;
  final Map<PostReactionType, int> reactionCounts;
  final PostReactionType? initialType;

  @override
  State<_ReactorsSheet> createState() => _ReactorsSheetState();
}

class _ReactorsSheetState extends State<_ReactorsSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<PostReactionType?> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = <PostReactionType?>[
      null,
      ...PostReactionType.values.where(
        (type) => (widget.reactionCounts[type] ?? 0) > 0,
      ),
    ];
    if (_tabs.length == 1) {
      _tabs.addAll(PostReactionType.values);
    }

    final initialIndex = widget.initialType == null
        ? 0
        : _tabs.indexOf(widget.initialType).clamp(0, _tabs.length - 1);
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = widget.reactionCounts.values.fold<int>(0, (a, b) => a + b);

    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.42,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Reactions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.nileBlue,
                          ),
                    ),
                    const Spacer(),
                    Text(
                      l10n.likesCount(total),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: AppColors.primaryBlue,
                unselectedLabelColor: context.textSecondary,
                indicatorColor: AppColors.primaryBlue,
                tabs: _tabs.map((type) {
                  if (type == null) {
                    return Tab(text: 'All ($total)');
                  }
                  final count = widget.reactionCounts[type] ?? 0;
                  return Tab(text: '${type.emoji} $count');
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: _tabs
                      .map(
                        (type) => _ReactorsList(
                          postId: widget.postId,
                          type: type,
                          outerController: scrollController,
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReactorsList extends StatefulWidget {
  const _ReactorsList({
    required this.postId,
    required this.type,
    required this.outerController,
  });

  final int postId;
  final PostReactionType? type;
  final ScrollController outerController;

  @override
  State<_ReactorsList> createState() => _ReactorsListState();
}

class _ReactorsListState extends State<_ReactorsList> {
  final List<PostReactor> _items = [];
  var _page = 1;
  var _loading = true;
  var _loadingMore = false;
  var _hasMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (more) {
      if (!_hasMore || _loadingMore) return;
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final result = await PostEngagementService.fetchReactors(
        widget.postId,
        type: widget.type,
        page: more ? _page + 1 : 1,
      );
      if (!mounted) return;
      setState(() {
        if (more) {
          _items.addAll(result.reactors);
          _page += 1;
        } else {
          _items
            ..clear()
            ..addAll(result.reactors);
          _page = 1;
        }
        _hasMore = result.hasMore;
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = PostEngagementService.friendlyError(
          error,
          'load reactions',
          context.l10n,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          'No reactions yet.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >
            notification.metrics.maxScrollExtent - 80) {
          _load(more: true);
        }
        return false;
      },
      child: ListView.separated(
        controller: widget.outerController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _items.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }

          final reactor = _items[index];
          final reaction = postReactionFromApi(reactor.reaction);

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
              backgroundImage: reactor.avatarUrl != null
                  ? NetworkImage(reactor.avatarUrl!)
                  : null,
              child: reactor.avatarUrl == null
                  ? Text(
                      reactor.name.isNotEmpty
                          ? reactor.name.characters.first.toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            title: Text(
              reactor.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              reaction?.emoji ?? '👍',
              style: const TextStyle(fontSize: 22),
            ),
          );
        },
      ),
    );
  }
}
