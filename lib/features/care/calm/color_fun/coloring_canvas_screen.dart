import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/l10n/locale_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../care_colors.dart';
import '../widgets/calm_app_bar.dart';

class ColoringCanvasScreen extends StatefulWidget {
  const ColoringCanvasScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  State<ColoringCanvasScreen> createState() => _ColoringCanvasScreenState();
}

class _Stroke {
  _Stroke({required this.color, required this.width});

  final Color color;
  final double width;
  final Path path = Path();
}

class _ColoringCanvasScreenState extends State<ColoringCanvasScreen> {
  static const _palette = [
    Color(0xFF055498),
    Color(0xFF123A60),
    Color(0xFFFBD116),
    Color(0xFFCE2028),
    Color(0xFF22C55E),
    Color(0xFF7C3AED),
    Color(0xFFF97316),
    Color(0xFF111827),
  ];

  final List<_Stroke> _strokes = [];
  Color _color = const Color(0xFF055498);
  double _width = 10;

  void _start(Offset point) {
    final stroke = _Stroke(color: _color, width: _width);
    stroke.path.moveTo(point.dx, point.dy);
    setState(() => _strokes.add(stroke));
  }

  void _move(Offset point) {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.last.path.lineTo(point.dx, point.dy));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: CareColors.pageBgOf(context),
      appBar: CalmAppBar(title: widget.title),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: CareColors.cardBorderOf(context)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onPanStart: (d) => _start(d.localPosition),
                          onPanUpdate: (d) => _move(d.localPosition),
                          child: CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: _ColoringPainter(
                              strokes: List.of(_strokes),
                              outline: widget.icon,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  for (final color in _palette)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _color = color);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _color == color
                                    ? AppColors.nileBlue
                                    : Colors.white,
                                width: _color == color ? 3 : 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => setState(_strokes.clear),
                    child: Text(l10n.careColorClear),
                  ),
                  SizedBox(
                    width: 140,
                    child: Slider(
                      value: _width,
                      min: 4,
                      max: 22,
                      onChanged: (v) => setState(() => _width = v),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.mediumElectricBlue,
                      minimumSize: const Size(44, 44),
                    ),
                    child: Text(l10n.careDoneColoring),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColoringPainter extends CustomPainter {
  _ColoringPainter({required this.strokes, required this.outline});

  final List<_Stroke> strokes;
  final IconData outline;

  @override
  void paint(Canvas canvas, Size size) {
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(outline.codePoint),
        style: TextStyle(
          fontSize: size.shortestSide * 0.48,
          fontFamily: outline.fontFamily,
          package: outline.fontPackage,
          color: const Color(0x33055498),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        (size.width - iconPainter.width) / 2,
        (size.height - iconPainter.height) / 2,
      ),
    );

    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(stroke.path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ColoringPainter oldDelegate) => true;
}
