import 'dart:async';

import 'package:flutter/material.dart';

import '../events/hope_event.dart';
import '../hope_colors.dart';
import 'hope_event_cover.dart';

class HopeMovementCarousel extends StatefulWidget {
  const HopeMovementCarousel({
    super.key,
    required this.events,
    this.onTap,
  });

  final List<HopeEvent> events;
  final ValueChanged<HopeEvent>? onTap;

  @override
  State<HopeMovementCarousel> createState() => _HopeMovementCarouselState();
}

class _HopeMovementCarouselState extends State<HopeMovementCarousel> {
  final _controller = PageController();
  int _index = 0;
  Timer? _timer;

  int get _slideCount {
    if (widget.events.isNotEmpty) {
      return widget.events.length;
    }
    return 3;
  }

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HopeMovementCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.events.length != oldWidget.events.length) {
      if (_index >= _slideCount) {
        _index = _slideCount == 0 ? 0 : _slideCount - 1;
      }
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (_slideCount < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      final next = (_index + 1) % _slideCount;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.events;
    final count = _slideCount;

    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: count,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final event = i < events.length ? events[i] : null;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: event == null || widget.onTap == null
                      ? null
                      : () => widget.onTap!(event),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: HopeEventCover(
                      event: event,
                      fallbackIndex: i,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) {
              final active = i == _index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active
                      ? HopeColors.purple
                      : HopeColors.cardBorderOf(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
