import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/locale_scope.dart';
import '../hope_colors.dart';
import 'hope_event.dart';
import 'hope_event_detail_screen.dart';
import 'hope_events_service.dart';

class HopeEventsScreen extends StatefulWidget {
  const HopeEventsScreen({super.key});

  @override
  State<HopeEventsScreen> createState() => _HopeEventsScreenState();
}

class _HopeEventsScreenState extends State<HopeEventsScreen> {
  final _searchController = TextEditingController();
  String _audience = '';
  String _search = '';
  bool _loading = true;
  List<HopeEvent> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await HopeEventsService.fetch(
        audience: _audience.isEmpty ? null : _audience,
        search: _search,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = const [];
        _loading = false;
      });
    }
  }

  String _formatDates(HopeEvent event) {
    final start = DateTime.tryParse(event.startDate ?? '');
    final end = DateTime.tryParse(event.endDate ?? '');
    if (start == null) return event.startDate ?? '';
    if (end == null || end.isAtSameMomentAs(start)) {
      return DateFormat('dd MMM yyyy').format(start);
    }
    if (start.month == end.month && start.year == end.year) {
      return '${DateFormat('dd').format(start)}-${DateFormat('dd MMM yyyy').format(end)}';
    }
    return '${DateFormat('dd MMM').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}';
  }

  Future<void> _register(HopeEvent event) async {
    final url = event.registrationUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = <(String, String)>[
      ('', l10n.hopeEventsAll),
      ('youth', l10n.hopeEventsYouth),
      ('parents', l10n.hopeEventsParents),
      ('community', l10n.hopeEventsCommunity),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: HopeColors.purple,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.hopeEventsTitle,
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
                final selected = _audience == chip.$1;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(chip.$2),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _audience = chip.$1);
                      _load();
                    },
                    selectedColor: HopeColors.purple,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : HopeColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected ? HopeColors.purple : HopeColors.cardBorder,
                    ),
                    showCheckmark: false,
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
                _load();
              },
              decoration: InputDecoration(
                hintText: l10n.hopeEventsSearchHint,
                prefixIcon: const Icon(Icons.search, color: HopeColors.purple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: HopeColors.cardBorder),
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: HopeColors.purple),
                  )
                : _items.isEmpty
                    ? Center(child: Text(l10n.hopeEventsEmpty))
                    : RefreshIndicator(
                        color: HopeColors.purple,
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final event = _items[index];
                            return _EventCard(
                              event: event,
                              dateLabel: _formatDates(event),
                              onOpen: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        HopeEventDetailScreen(eventId: event.id),
                                  ),
                                );
                              },
                              onRegister: () => _register(event),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.dateLabel,
    required this.onOpen,
    required this.onRegister,
  });

  final HopeEvent event;
  final String dateLabel;
  final VoidCallback onOpen;
  final VoidCallback onRegister;

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
        onTap: onOpen,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: HopeColors.purple.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: event.coverUrl != null
                      ? Image.network(event.coverUrl!, fit: BoxFit.cover)
                      : Image.asset(
                          'assets/hope/hope_banner_caravan.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HopeColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 13, color: HopeColors.purple),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            dateLabel,
                            style: const TextStyle(
                              color: HopeColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          event.isOnline
                              ? Icons.play_circle_outline
                              : Icons.place_outlined,
                          size: 14,
                          color: HopeColors.purple,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            place,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: HopeColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (event.slots != null)
                          Expanded(
                            child: Text(
                              l10n.hopeEventsSlotsLeft(event.slots!),
                              style: const TextStyle(
                                color: HopeColors.slotsGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        SizedBox(
                          height: 34,
                          child: FilledButton(
                            onPressed: onRegister,
                            style: FilledButton.styleFrom(
                              backgroundColor: HopeColors.purple,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              l10n.hopeEventsRegister,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
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
