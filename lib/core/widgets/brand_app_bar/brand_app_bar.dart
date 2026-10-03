import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Brand-colored AppBar with white title + icons.
///
/// Use this for every filled Medium Electric Blue / Nile Blue bar so the
/// global dark [AppBarTheme.titleTextStyle] cannot wash out contrast.
class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor = AppColors.mediumElectricBlue,
    this.elevation = 0,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final Color backgroundColor;
  final double elevation;

  static const _foreground = Colors.white;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      backgroundColor: backgroundColor,
      foregroundColor: _foreground,
      elevation: elevation,
      centerTitle: centerTitle,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      actions: actions,
      iconTheme: const IconThemeData(color: _foreground),
      actionsIconTheme: const IconThemeData(color: _foreground),
      titleTextStyle: AppTypography.header(color: _foreground).copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
