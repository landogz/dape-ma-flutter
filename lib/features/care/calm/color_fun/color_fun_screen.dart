import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';

class ColorFunScreen extends StatefulWidget {
  const ColorFunScreen({super.key});

  @override
  State<ColorFunScreen> createState() => _ColorFunScreenState();
}

class _ColorFunScreenState extends State<ColorFunScreen> {
  int _filter = 0;

  static const _worksheets = [
    _Worksheet(
      id: 'love_birds',
      title: 'Love Birds',
      category: 1,
      icon: Icons.favorite_border_rounded,
    ),
    _Worksheet(
      id: 'garden',
      title: 'Garden',
      category: 1,
      icon: Icons.local_florist_outlined,
    ),
    _Worksheet(
      id: 'cute_ducks',
      title: 'Cute Ducks',
      category: 1,
      icon: Icons.water_rounded,
    ),
    _Worksheet(
      id: 'heart',
      title: 'Heart',
      category: 3,
      icon: Icons.favorite_rounded,
    ),
    _Worksheet(
      id: 'friends',
      title: 'Friends',
      category: 2,
      icon: Icons.groups_outlined,
    ),
    _Worksheet(
      id: 'kindness',
      title: 'Be Kind',
      category: 3,
      icon: Icons.volunteer_activism_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = [
      l10n.careColorFilterAll,
      l10n.careColorFilterNature,
      l10n.careColorFilterPeople,
      l10n.careColorFilterMessages,
    ];
    final items = _filter == 0
        ? _worksheets
        : _worksheets.where((w) => w.category == _filter).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CalmAppBar(
        title: '',
        onInfo: () => showCalmInfoDialog(
          context,
          title: l10n.careCalmInfoTitle,
          body: l10n.careCalmInfoBody,
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Column(
                  children: [
                    const Icon(
                      Icons.palette_rounded,
                      size: 72,
                      color: CareColors.calmForest,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.careColorFun,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: CareColors.calmForest,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.careColorFunIntro,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: CareColors.calmMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (var i = 0; i < filters.length; i++) ...[
                            if (i > 0) const SizedBox(width: 8),
                            ChoiceChip(
                              label: Text(filters[i]),
                              selected: _filter == i,
                              onSelected: (_) => setState(() => _filter = i),
                              selectedColor: CareColors.calmForest,
                              labelStyle: TextStyle(
                                color: _filter == i
                                    ? Colors.white
                                    : CareColors.calmMuted,
                                fontWeight: FontWeight.w700,
                              ),
                              side: BorderSide(
                                color: _filter == i
                                    ? CareColors.calmForest
                                    : CareColors.cardBorder,
                              ),
                              backgroundColor: Colors.white,
                              showCheckmark: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              sliver: items.isEmpty
                  ? const SliverToBoxAdapter(child: SizedBox.shrink())
                  : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = items[index];
                          return _WorksheetCard(
                            worksheet: item,
                            onDownload: () {
                              HapticFeedback.lightImpact();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.careWorksheetDownloaded),
                                ),
                              );
                            },
                          );
                        },
                        childCount: items.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Worksheet {
  const _Worksheet({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
  });

  final String id;
  final String title;
  final int category;
  final IconData icon;
}

class _WorksheetCard extends StatelessWidget {
  const _WorksheetCard({
    required this.worksheet,
    required this.onDownload,
  });

  final _Worksheet worksheet;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CareColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: CareColors.calmBg,
              alignment: Alignment.center,
              child: Icon(
                worksheet.icon,
                size: 56,
                color: CareColors.calmForest.withValues(alpha: 0.55),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    worksheet.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: CareColors.calmForest,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onDownload,
                  constraints:
                      const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: const Icon(
                    Icons.download_rounded,
                    color: CareColors.calmForest,
                    size: 22,
                  ),
                  tooltip: 'Download',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
