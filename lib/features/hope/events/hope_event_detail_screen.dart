import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/locale_scope.dart';
import '../hope_colors.dart';
import 'hope_event.dart';
import 'hope_events_service.dart';

class HopeEventDetailScreen extends StatefulWidget {
  const HopeEventDetailScreen({super.key, required this.eventId});

  final int eventId;

  @override
  State<HopeEventDetailScreen> createState() => _HopeEventDetailScreenState();
}

class _HopeEventDetailScreenState extends State<HopeEventDetailScreen> {
  HopeEvent? _event;
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final event = await HopeEventsService.fetchOne(widget.eventId);
      if (!mounted) return;
      setState(() {
        _event = event;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    final url = _event?.registrationUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final top = MediaQuery.viewPaddingOf(context).top;
    final event = _event;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: HopeColors.purple)),
      );
    }

    if (event == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.hopeEventsEmpty)),
      );
    }

    final tabs = [
      l10n.hopeEventAbout,
      l10n.hopeEventDetails,
      l10n.hopeEventSpeakers,
      l10n.hopeEventFaqs,
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 240 + top,
                        width: double.infinity,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: event.coverUrl != null
                                  ? NetworkImage(event.coverUrl!)
                                  : const AssetImage(
                                      'assets/hope/hope_banner_caravan.png',
                                    ) as ImageProvider,
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.35),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: top + 8,
                        left: 12,
                        child: Material(
                          color: Colors.black38,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white, size: 16),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: HopeColors.purple,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                event.status == 'upcoming'
                                    ? l10n.hopeEventUpcoming
                                    : event.status,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              event.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 24,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(tabs.length, (i) {
                                final selected = _tab == i;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(tabs[i]),
                                    selected: selected,
                                    onSelected: (_) => setState(() => _tab = i),
                                    selectedColor: HopeColors.purple,
                                    labelStyle: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : HopeColors.muted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    backgroundColor: Colors.white,
                                    side: BorderSide(
                                      color: selected
                                          ? HopeColors.purple
                                          : HopeColors.cardBorder,
                                    ),
                                    showCheckmark: false,
                                  ),
                                );
                              }),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ...switch (_tab) {
                            0 => _aboutTab(event, l10n),
                            1 => [
                                Text(
                                  event.detailsText?.isNotEmpty == true
                                      ? event.detailsText!
                                      : (event.aboutText ?? ''),
                                  style: const TextStyle(
                                    color: HopeColors.bodyText,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            2 => event.speakers.isEmpty
                                ? [Text(l10n.hopeEventsEmpty)]
                                : event.speakers
                                    .map(
                                      (s) => ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: const CircleAvatar(
                                          backgroundColor: HopeColors.purpleSoft,
                                          child: Icon(Icons.person,
                                              color: HopeColors.purple),
                                        ),
                                        title: Text(
                                          s.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: HopeColors.purple,
                                          ),
                                        ),
                                        subtitle: s.role != null
                                            ? Text(s.role!)
                                            : null,
                                      ),
                                    )
                                    .toList(),
                            _ => event.faqs.isEmpty
                                ? [Text(l10n.hopeEventsEmpty)]
                                : event.faqs
                                    .map(
                                      (f) => ExpansionTile(
                                        tilePadding: EdgeInsets.zero,
                                        title: Text(
                                          f.question,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: HopeColors.purple,
                                          ),
                                        ),
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 12),
                                              child: Text(f.answer),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(),
                          },
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _register,
                  style: FilledButton.styleFrom(
                    backgroundColor: HopeColors.purple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l10n.hopeEventsRegisterNow,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _aboutTab(HopeEvent event, dynamic l10n) {
    return [
      Text(
        l10n.hopeEventAboutHeading,
        style: const TextStyle(
          color: HopeColors.purple,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        event.aboutText ?? '',
        style: const TextStyle(color: HopeColors.bodyText, height: 1.5),
      ),
      if (event.forYouItems.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(
          l10n.hopeEventForYouHeading,
          style: const TextStyle(
            color: HopeColors.purple,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ...event.forYouItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: HopeColors.purple, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
      if (event.whoCanJoin != null && event.whoCanJoin!.isNotEmpty) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: HopeColors.purpleSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.hopeEventWhoCanJoin,
                style: const TextStyle(
                  color: HopeColors.purple,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(event.whoCanJoin!),
            ],
          ),
        ),
      ],
      if (event.highlights.isNotEmpty) ...[
        const SizedBox(height: 20),
        Text(
          l10n.hopeEventHighlights,
          style: const TextStyle(
            color: HopeColors.purple,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ...event.highlights.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: HopeColors.purpleSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: HopeColors.purple, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(h)),
              ],
            ),
          ),
        ),
      ],
    ];
  }
}
