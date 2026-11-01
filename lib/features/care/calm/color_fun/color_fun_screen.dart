import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/models/color_fun_worksheet.dart';
import '../../../../core/options/app_option_catalog.dart';
import '../../../../core/options/app_option_item.dart';
import '../../../../core/theme/app_colors.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';
import '../widgets/calm_info_sheet.dart';
import '../../../../core/theme/app_theme_colors.dart';
import 'color_fun_library_repository.dart';
import 'coloring_canvas_screen.dart';

class ColorFunScreen extends StatefulWidget {
  const ColorFunScreen({super.key});

  @override
  State<ColorFunScreen> createState() => _ColorFunScreenState();
}

class _ColorFunScreenState extends State<ColorFunScreen> {
  String _filter = 'all';
  final _repo = ColorFunLibraryRepository.instance;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onLibraryChanged);
    AppOptionCatalog.instance.addListener(_onLibraryChanged);
    ColorFunLibraryRepository.prefetch();
    AppOptionCatalog.prefetch();
  }

  @override
  void dispose() {
    _repo.removeListener(_onLibraryChanged);
    AppOptionCatalog.instance.removeListener(_onLibraryChanged);
    super.dispose();
  }

  void _onLibraryChanged() {
    if (mounted) setState(() {});
  }

  List<AppOptionItem> get _filters {
    final items = AppOptionCatalog.colorFunCategories();
    if (items.any((item) => item.key == 'all')) {
      return items;
    }
    return [
      const AppOptionItem(
        key: 'all',
        labelEn: 'All',
        labelTl: 'Lahat',
        icon: Icons.palette_outlined,
      ),
      ...items,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filters = _filters;
    final selectedFilter = filters.any((item) => item.key == _filter)
        ? _filter
        : (filters.isNotEmpty ? filters.first.key : 'all');
    final items = selectedFilter == 'all'
        ? _repo.worksheets
        : _repo.worksheets
            .where((w) => w.category == selectedFilter)
            .toList(growable: false);

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
                              label: Text(
                                filters[i].label(isTagalog: l10n.isTagalog),
                              ),
                              selected: selectedFilter == filters[i].key,
                              onSelected: (_) =>
                                  setState(() => _filter = filters[i].key),
                              selectedColor: AppColors.mediumElectricBlue,
                              labelStyle: TextStyle(
                                color: selectedFilter == filters[i].key
                                    ? Colors.white
                                    : CareColors.mutedOf(context),
                                fontWeight: FontWeight.w700,
                              ),
                              side: BorderSide(
                                color: selectedFilter == filters[i].key
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
            if (_repo.isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        l10n.careColorFunLoading,
                        style: TextStyle(color: CareColors.mutedOf(context)),
                      ),
                    ],
                  ),
                ),
              )
            else if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: CareColors.mutedOf(context),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.careColorFunEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: CareColors.mutedOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                                imageUrl: item.imageUrl,
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

class _WorksheetCard extends StatelessWidget {
  const _WorksheetCard({
    required this.worksheet,
    required this.onOpen,
  });

  final ColorFunWorksheet worksheet;
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
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  child: ColoredBox(
                    color: CareColors.pageBgOf(context),
                    child: Image.network(
                      worksheet.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.palette_outlined,
                        size: 56,
                        color: AppColors.mediumElectricBlue.withValues(alpha: 0.55),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.mediumElectricBlue.withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      },
                    ),
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
