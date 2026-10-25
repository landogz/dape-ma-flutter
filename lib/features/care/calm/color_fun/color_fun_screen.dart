import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_info_sheet.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'coloring_canvas_screen.dart';

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
      backgroundColor: context.pageBackground,
      appBar: CalmAppBar(
        title: '',
        onInfo: () => showCalmInfoSheet(
          context,
          CalmInfoCopy(
            whyTitle: l10n.careWhyMeditation,
            whyBody: l10n.careColorFunIntro,
            howTitle: l10n.careHowToUse,
            howBody: l10n.careColorOnScreen,
            tipTitle: l10n.careQuickTip,
            tipBody: l10n.careCalmStudentIntro,
          ),
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
                    Icon(
                      Icons.palette_rounded,
                      size: 72,
                      color: CareColors.headingOf(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.careColorFun,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: CareColors.headingOf(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.careColorFunIntro,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: CareColors.mutedOf(context),
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
                              selectedColor: AppColors.mediumElectricBlue,
                              labelStyle: TextStyle(
                                color: _filter == i
                                    ? Colors.white
                                    : CareColors.mutedOf(context),
                                fontWeight: FontWeight.w700,
                              ),
                              side: BorderSide(
                                color: _filter == i
                                    ? AppColors.mediumElectricBlue
                                    : CareColors.cardBorderOf(context),
                              ),
                              backgroundColor: context.pageBackground,
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
                            onOpen: () {
                              HapticFeedback.lightImpact();
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ColoringCanvasScreen(
                                    title: item.title,
                                    icon: item.icon,
                                  ),
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
    required this.onOpen,
  });

  final _Worksheet worksheet;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: CareColors.cardBorderOf(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  color: CareColors.pageBgOf(context),
                  alignment: Alignment.center,
                  child: Icon(
                    worksheet.icon,
                    size: 56,
                    color: AppColors.mediumElectricBlue.withValues(alpha: 0.55),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 10, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        worksheet.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: CareColors.headingOf(context),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.brush_rounded,
                      color: CareColors.headingOf(context),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
