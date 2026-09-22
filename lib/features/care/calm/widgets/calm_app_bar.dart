import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../care_colors.dart';

class CalmAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CalmAppBar({
    super.key,
    required this.title,
    this.onInfo,
  });

  final String title;
  final VoidCallback? onInfo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      foregroundColor: CareColors.calmForest,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: CareColors.calmForest,
          fontSize: 20,
        ),
      ),
      actions: [
        if (onInfo != null)
          IconButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              onInfo!();
            },
            icon: const Icon(Icons.info_outline_rounded),
            tooltip: 'Info',
          ),
      ],
    );
  }
}

Future<void> showCalmInfoDialog(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text(
        title,
        style: const TextStyle(
          color: CareColors.calmForest,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Text(
        body,
        style: const TextStyle(color: CareColors.calmMuted, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
