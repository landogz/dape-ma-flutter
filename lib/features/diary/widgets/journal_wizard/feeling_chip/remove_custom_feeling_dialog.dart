import 'package:flutter/material.dart';

import '../../../../../core/l10n/locale_scope.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_theme_colors.dart';

Future<bool> showRemoveCustomFeelingDialog(
  BuildContext context, {
  required String feeling,
}) async {
  final l10n = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: ctx.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.journalRemoveCustomFeelingTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: ctx.textPrimary,
          ),
        ),
        content: Text(
          l10n.journalRemoveCustomFeelingBody(feeling),
          style: TextStyle(
            height: 1.4,
            color: ctx.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: Text(l10n.journalRemoveFeeling),
          ),
        ],
      );
    },
  );
  return result == true;
}
