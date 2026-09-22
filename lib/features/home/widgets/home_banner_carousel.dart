import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';
import '../../kid_listo/kid_listo_quote_service.dart';
import 'continue_learning_card.dart';
import 'home_header.dart';
import 'thought_of_day_card.dart';
import 'whats_new_card.dart';

/// Auto-playing homepage carousel for Thought / Continue / What's New.
class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({
    super.key,
    required this.lessonsCompleted,
    required this.lessonGoal,
    required this.onContinueTap,
    this.onThoughtTap,
    this.onWhatsNewTap,
    this.autoPlay = true,
  });

  final int lessonsCompleted;
  final int lessonGoal;
  final VoidCallback onContinueTap;
  final VoidCallback? onThoughtTap;
  final VoidCallback? onWhatsNewTap;
  final bool autoPlay;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;
  String? _thoughtMessage;
  bool _loadingThought = true;
  String? _loadedLocale;

  static const _pageCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.94);
    if (widget.autoPlay) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted || !_controller.hasClients) return;
        final next = (_index + 1) % _pageCount;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = LocaleScope.of(context).locale.code;
    if (_loadedLocale != locale) {
      _loadedLocale = locale;
      _loadKidListoThought();
    }
  }

  Future<void> _loadKidListoThought() async {
    setState(() => _loadingThought = true);
    final locale = LocaleScope.of(context).locale.code;
    final quote = await KidListoQuoteService.fetchRandom(locale: locale);
    if (!mounted) return;
    setState(() {
      _thoughtMessage = _cleanThoughtMessage(quote?.message);
      _loadingThought = false;
    });
  }

  /// Prefer the inspirational line without a repeated "Kid Listo says:" prefix.
  String? _cleanThoughtMessage(String? raw) {
    var text = (raw ?? '').trim();
    if (text.isEmpty) return null;
    final prefixes = [
      'Kid Listo says:',
      'Kid Listo says',
      'Sabi ni Kid Listo:',
      'Sabi ni Kid Listo',
    ];
    for (final p in prefixes) {
      if (text.toLowerCase().startsWith(p.toLowerCase())) {
        text = text.substring(p.length).trim();
        break;
      }
    }
    return text.isEmpty ? null : text;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final thought = (_thoughtMessage != null && _thoughtMessage!.isNotEmpty)
        ? _thoughtMessage!
        : l10n.homeThoughtFallback;

    return Column(
      children: [
        SizedBox(
          height: 156,
          child: PageView(
            controller: _controller,
            onPageChanged: (i) => setState(() => _index = i),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ThoughtOfDayBanner(
                  message: thought,
                  loading: _loadingThought && _thoughtMessage == null,
                  onTap: widget.onThoughtTap,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ContinueLearningCard(
                  lessonsCompleted: widget.lessonsCompleted,
                  lessonGoal: widget.lessonGoal,
                  onTap: widget.onContinueTap,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: WhatsNewCard(
                  items: [
                    WhatsNewItem(
                      iconAsset: HomeAssets.starIcon,
                      iconBg: const Color(0xFFFFF3CD),
                      prefix: l10n.homeNewCoursePrefix,
                      highlight: l10n.homeNewCourseTitle,
                      onTap: widget.onWhatsNewTap ?? widget.onContinueTap,
                    ),
                    WhatsNewItem(
                      iconAsset: HomeAssets.liveIcon,
                      iconBg: const Color(0xFFFFE4E6),
                      prefix: l10n.homeUpcomingWebinarPrefix,
                      highlight: l10n.homeUpcomingWebinarTitle,
                      onTap: widget.onWhatsNewTap ?? widget.onContinueTap,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _pageCount; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _index
                      ? AppColors.primaryBlue
                      : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
