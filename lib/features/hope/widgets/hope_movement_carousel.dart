import 'package:flutter/material.dart';

import '../hope_colors.dart';

class HopeMovementCarousel extends StatefulWidget {
  const HopeMovementCarousel({super.key});

  @override
  State<HopeMovementCarousel> createState() => _HopeMovementCarouselState();
}

class _HopeMovementCarouselState extends State<HopeMovementCarousel> {
  static const _banners = [
    'assets/hope/hope_banner_caravan.png',
    'assets/hope/hope_banner_celebration.png',
    'assets/hope/hope_banner_scout_run.png',
    'assets/hope/hope_banner_workshop.png',
  ];

  final _controller = PageController(viewportFraction: 1);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _controller,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  _banners[i],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, _, _) => Container(
                    color: HopeColors.purpleSoft,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_outlined,
                        color: HopeColors.purple, size: 40),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? HopeColors.purple : HopeColors.cardBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
