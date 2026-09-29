import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/locale_scope.dart';
import '../contests/contests_screen.dart';
import '../iec_materials/iec_materials_screen.dart';
import '../rehab_centers/rehab_centers_screen.dart';
import 'directory/hope_directory_screen.dart';
import 'events/hope_event.dart';
import 'events/hope_event_detail_screen.dart';
import 'events/hope_events_screen.dart';
import 'events/hope_events_service.dart';
import 'hope_colors.dart';
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
  HopeEvent? _featured;

  @override
  void initState() {
    super.initState();
    _loadFeatured();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFeatured() async {
    try {
      final events = await HopeEventsService.fetch();
      if (!mounted || events.isEmpty) return;
      setState(() => _featured = events.first);
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
        icon: Icons.event_available_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HopeEventsScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeDirectoryTile,
        body: l10n.hopeDirectoryTileBody,
        icon: Icons.contact_phone_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HopeDirectoryScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeContestsTile,
        body: l10n.hopeContestsTileBody,
        icon: Icons.emoji_events_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ContestsScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeIecTile,
        body: l10n.hopeIecTileBody,
        icon: Icons.menu_book_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const IecMaterialsScreen()),
        ),
      ),
      _HopeTileData(
        title: l10n.hopeRehabTile,
        body: l10n.hopeRehabTileBody,
        icon: Icons.local_hospital_rounded,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RehabCentersScreen()),
        ),
      ),
    ].where((t) => _matches('${t.title} ${t.body}')).toList();

    final showFeatured = _featured != null &&
        _matches('${l10n.hopeFeaturedTitle} ${_featured!.title}');
    final showMovement = _matches(l10n.hopeMovementTitle);

    return Scaffold(
      backgroundColor: HopeColors.pageBg,
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
                          style: const TextStyle(
                            color: HopeColors.purpleDark,
                            fontSize: 13,
                            height: 1.2,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: l10n.hopeSearchHint,
                            hintStyle: const TextStyle(
                              color: HopeColors.muted,
                              fontSize: 13,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: HopeColors.muted,
                              size: 18,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 32,
                            ),
                            filled: true,
                            fillColor: Colors.white,
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (showMovement) ...[
                  Text(
                    l10n.hopeMovementTitle,
                    style: const TextStyle(
                      color: HopeColors.purple,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const HopeMovementCarousel(),
                  const SizedBox(height: 24),
                ],
                if (showFeatured && _featured != null) ...[
                  Text(
                    l10n.hopeFeaturedTitle,
                    style: const TextStyle(
                      color: HopeColors.purple,
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
                  style: const TextStyle(
                    color: HopeColors.purple,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final crossAxisCount = width >= 520 ? 3 : 2;
                    final gap = 10.0;
                    final tileWidth =
                        (width - gap * (crossAxisCount - 1)) / crossAxisCount;

                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: tiles
                          .map(
                            (tile) => SizedBox(
                              width: tileWidth,
                              child: _HopeSpeedCard(data: tile),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
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
    required this.onTap,
  });

  final String title;
  final String body;
  final IconData icon;
  final VoidCallback onTap;
}

class _HopeSpeedCard extends StatelessWidget {
  const _HopeSpeedCard({required this.data});

  final _HopeTileData data;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: data.onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 148),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorder, width: 1.2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(data.icon, color: HopeColors.purple, size: 36),
              const SizedBox(height: 12),
              Text(
                data.title,
                style: const TextStyle(
                  color: HopeColors.purple,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                data.body,
                style: const TextStyle(
                  color: HopeColors.muted,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
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
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        color: HopeColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: HopeColors.purple),
                        const SizedBox(width: 4),
                        Text(dateLabel,
                            style: const TextStyle(
                                color: HopeColors.muted, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined,
                            size: 14, color: HopeColors.purple),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: HopeColors.muted, fontSize: 12),
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
                  ],
                ),
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 84,
                  height: 84,
                  child: event.coverUrl != null
                      ? Image.network(event.coverUrl!, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/hope/hope_banner_celebration.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
