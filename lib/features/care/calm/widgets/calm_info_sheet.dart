import 'package:flutter/material.dart';

import '../../care_colors.dart';
import '../../../../core/theme/app_theme_colors.dart';

class CalmInfoCopy {
  const CalmInfoCopy({
    required this.whyTitle,
    required this.whyBody,
    required this.howTitle,
    required this.howBody,
    required this.tipTitle,
    required this.tipBody,
  });

  final String whyTitle;
  final String whyBody;
  final String howTitle;
  final String howBody;
  final String tipTitle;
  final String tipBody;
}

Future<void> showCalmInfoSheet(BuildContext context, CalmInfoCopy copy) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Material(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(28),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close_rounded, color: CareColors.headingOf(context)),
                      tooltip: MaterialLocalizations.of(ctx).closeButtonTooltip,
                    ),
                  ),
                  Container(
                    width: 88,
                    height: 88,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF055498), Color(0xFF123A60)],
                      ),
                    ),
                    child: const Icon(Icons.info_rounded, color: Colors.white, size: 42),
                  ),
                  const SizedBox(height: 22),
                  _InfoBlock(title: copy.whyTitle, body: copy.whyBody),
                  const SizedBox(height: 18),
                  _InfoBlock(title: copy.howTitle, body: copy.howBody),
                  const SizedBox(height: 18),
                  _InfoBlock(title: copy.tipTitle, body: copy.tipBody),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: CareColors.headingOf(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          body,
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 1.45,
            fontSize: 15,
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}
