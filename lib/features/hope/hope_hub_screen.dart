import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_scope.dart';
import '../../core/share/app_share.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/utils/api_url.dart';
import '../contests/contests_screen.dart';
import '../iec_materials/iec_materials_screen.dart';
import '../rehab_centers/rehab_centers_screen.dart';
import 'directory/hope_directory_screen.dart';
import 'events/hope_event.dart';
import 'events/hope_event_detail_screen.dart';
import 'events/hope_events_screen.dart';
import 'events/hope_events_service.dart';
import 'hope_colors.dart';
import 'widgets/hope_event_cover.dart';
import 'widgets/hope_movement_carousel.dart';

class HopeHubAssets {
  HopeHubAssets._();

  static const headerBanner = 'assets/hope/hope_header_banner.png';
}

class HopeHubScreen extends StatefulWidget {
  const HopeHubScreen({super.key});

  @override
  State<HopeHubScreen> createState() => _HopeHubScreenState();
}

class _HopeHubScreenState extends State<HopeHubScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  List<HopeEvent> _events = [];
  HopeEvent? _featured;

  @override
  void initState() {
    super.initState();
    _loadHopeEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHopeEvents() async {
    try {
      final events = await HopeEventsService.fetch();
      if (!mounted) return;
      HopeEvent? featured;
      for (final event in events) {
        if (event.sortOrder == 1) {
          featured = event;
          break;
        }
      }
      setState(() {
        _events = events;
        _featured = featured ?? (events.isEmpty ? null : events.first);
      });
    } catch (_) {}
  }

  bool _matches(String haystack) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return haystack.toLowerCase().contains(q);
  }

  String _formatFeaturedDate(HopeEvent event) {
    final start = DateTime.tryParse(event.startDate ?? '');
    final end = DateTime.tryParse(event.endDate ?? '');
    if (start == null) return event.startDate ?? '';
    if (end == null || end.isAtSameMomentAs(start)) {
      return DateFormat('dd MMM yyyy').format(start);
    }
    return '${DateFormat('dd').format(start)}-${DateFormat('dd MMM yyyy').format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.viewPaddingOf(context).top;
    final canPop = Navigator.of(context).canPop();

    final tiles = <_HopeTileData>[
      _HopeTileData(
        title: l10n.hopeEventsTile,
        body: l10n.hopeEventsTileBody,
        icon: Icons.calendar_month_outlined,
        accent: AppColors.mediumElectricBlue,
        tint: AppColors.softBlue,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HopeEventsScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeDirectoryTile,
        body: l10n.hopeDirectoryTileBody,
        icon: Icons.account_balance_outlined,
        accent: AppColors.nileBlue,
        tint: const Color(0xFFE8EEF4),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HopeDirectoryScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeContestsTile,
        body: l10n.hopeContestsTileBody,
        icon: Icons.emoji_events_outlined,
        accent: const Color(0xFFB8860B),
        tint: AppColors.softGold,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContestsScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeIecTile,
        body: l10n.hopeIecTileBody,
        icon: Icons.menu_book_outlined,
        accent: AppColors.accentPurple,
        tint: AppColors.softPurple,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const IecMaterialsScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeRehabTile,
        body: l10n.hopeRehabTileBody,
        icon: Icons.local_hospital_outlined,
        accent: AppColors.fireEngineRed,
        tint: AppColors.softRed,
        featured: true,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RehabCentersScreen()),
        ),
      ),
    ].where((t) => _matches('${t.title} ${t.body}')).toList();

    final showFeatured = _featured != null &&
        _matches('${l10n.hopeFeaturedTitle} ${_featured!.title}');
    final carouselEvents = _events.take(3).toList();
    final showMovement = _matches(l10n.hopeMovementTitle);

    return Scaffold(
      backgroundColor: HopeColors.pageBgOf(context),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(32),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      HopeHubAssets.headerBanner,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (_, _, _) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              HopeColors.purpleMid,
                              HopeColors.purple,
                              HopeColors.purpleDark,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            HopeColors.purpleDark.withValues(alpha: 0.28),
                            HopeColors.purpleDark.withValues(alpha: 0.52),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, top + 12, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (canPop) ...[
                              Material(
                                color: Colors.white.withValues(alpha: 0.22),
                                shape: const CircleBorder(),
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: () => Navigator.of(context).maybePop(),
                                  child: const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            Image.asset(
                              'assets/bida/bida_hope_icon.png',
                              width: 36,
                              height: 36,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.groups_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l10n.hopeTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.hopeTagline,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v),
                          style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 13,
                            height: 1.2,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: l10n.hopeSearchHint,
                            hintStyle: TextStyle(
                              color: HopeColors.mutedOf(context),
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: HopeColors.mutedOf(context),
                              size: 18,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 32,
                            ),
                            filled: true,
                            fillColor: context.inputFill,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(999),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 132),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (showMovement) ...[
                  Text(
                    l10n.hopeMovementTitle,
                    style: TextStyle(
                      color: HopeColors.headingOf(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  HopeMovementCarousel(
                    events: carouselEvents,
                    onTap: (event) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HopeEventDetailScreen(eventId: event.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                if (showFeatured && _featured != null) ...[
                  Text(
                    l10n.hopeFeaturedTitle,
                    style: TextStyle(
                      color: HopeColors.headingOf(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _FeaturedCard(
                    event: _featured!,
                    dateLabel: _formatFeaturedDate(_featured!),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              HopeEventDetailScreen(eventId: _featured!.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                Text(
                  l10n.hopeSpeedDialTitle,
                  style: TextStyle(
                    color: context.heading,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                _HopeQuickAccessGrid(tiles: tiles),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _HopeTileData {
  const _HopeTileData({
    required this.title,
    required this.body,
    required this.icon,
    required this.accent,
    required this.tint,
    required this.onTap,
    this.featured = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color accent;
  final Color tint;
  final VoidCallback onTap;
  final bool featured;
}

class _HopeQuickAccessGrid extends StatelessWidget {
  const _HopeQuickAccessGrid({required this.tiles});

  final List<_HopeTileData> tiles;

  @override
  Widget build(BuildContext context) {
    const gap = 14.0;
    final regular = tiles.where((tile) => !tile.featured).toList();
    final featured = tiles.where((tile) => tile.featured).toList();
    final rows = <Widget>[];

    for (var i = 0; i < regular.length; i += 2) {
      if (i + 1 < regular.length) {
        rows.add(
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _HopeSpeedCard(data: regular[i], expand: true)),
                const SizedBox(width: gap),
                Expanded(child: _HopeSpeedCard(data: regular[i + 1], expand: true)),
              ],
            ),
          ),
        );
      } else {
        rows.add(_HopeSpeedCard(data: regular[i], wide: true));
      }
    }

    for (final tile in featured) {
      rows.add(_HopeSpeedCard(data: tile, wide: true));
    }

    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: gap),
          rows[i],
        ],
      ],
    );
  }
}

class _HopeSpeedCard extends StatefulWidget {
  const _HopeSpeedCard({
    required this.data,
    this.wide = false,
    this.expand = false,
  });

  final _HopeTileData data;
  final bool wide;
  final bool expand;

  @override
  State<_HopeSpeedCard> createState() => _HopeSpeedCardState();
}

class _HopeSpeedCardState extends State<_HopeSpeedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final wide = widget.wide;
    final iconTint = context.isDarkMode
        ? data.accent.withValues(alpha: 0.22)
        : data.tint;
    final border = context.isDarkMode
        ? context.borderSubtle
        : const Color(0xFFD6DEE8);
    final description = context.isDarkMode
        ? context.textSecondary
        : const Color(0xFF475569);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 90),
      child: Material(
        color: context.cardBackground,
        elevation: context.isDarkMode ? 0 : 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: data.onTap,
          onHighlightChanged: (value) => setState(() => _pressed = value),
            child: Container(
            constraints: BoxConstraints(minHeight: wide ? 88 : 148),
            height: widget.expand ? double.infinity : null,
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: wide
                ? Row(
                    children: [
                      _IconBadge(
                        icon: data.icon,
                        accent: data.accent,
                        tint: iconTint,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              data.title,
                              style: TextStyle(
                                color: context.heading,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data.body,
                              style: TextStyle(
                                color: description,
                                fontSize: 13,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: context.textSecondary,
                      ),
                    ],
                  )
                : Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _IconBadge(
                            icon: data.icon,
                            accent: data.accent,
                            tint: iconTint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            data.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.heading,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: description,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.accent,
    required this.tint,
  });

  final IconData icon;
  final Color accent;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: accent, size: 22),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.event,
    required this.dateLabel,
    required this.onTap,
  });

  final HopeEvent event;
  final String dateLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final place = event.isOnline
        ? (event.onlineLabel ?? 'Online')
        : (event.venue ?? '');

    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorderOf(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: TextStyle(
                        color: HopeColors.headingOf(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 13, color: HopeColors.headingOf(context)),
                        const SizedBox(width: 4),
                        Text(dateLabel,
                            style: TextStyle(
                                color: HopeColors.mutedOf(context), fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 14, color: HopeColors.headingOf(context)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: HopeColors.mutedOf(context), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    if (event.slots != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        l10n.hopeEventsSlotsLeft(event.slots!),
                        style: const TextStyle(
                          color: HopeColors.slotsGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: l10n.sharePost,
                        onPressed: () {
                          AppShare.item(
                            title: event.title,
                            url: ApiUrl.shareEvent(event.id, uuid: event.uuid),
                          );
                        },
                        icon: Icon(
                          Icons.ios_share_rounded,
                          color: HopeColors.headingOf(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: HopeEventCover(event: event),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
