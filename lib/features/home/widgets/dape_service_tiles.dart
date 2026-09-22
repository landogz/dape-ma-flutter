import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/theme/app_colors.dart';

class DapeServiceTiles extends StatelessWidget {
  const DapeServiceTiles({
    super.key,
    required this.onLearn,
    required this.onHope,
    required this.onCare,
    this.learnEnabled = true,
  });

  final VoidCallback onLearn;
  final VoidCallback onHope;
  final VoidCallback onCare;
  final bool learnEnabled;

  static const learnLogo = 'assets/bida/bida_learn_icon.png';
  static const hopeLogo = 'assets/bida/bida_hope_icon.png';
  static const careLogo = 'assets/bida/bida_care_icon.png';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _ServiceTile(
              label: l10n.bidaLearnTitle,
              logoAsset: learnLogo,
              fallbackIcon: Icons.menu_book_rounded,
              background: const Color(0xFFE8F1FA),
              border: const Color(0xFFB7D0EA),
              foreground: AppColors.primaryBlue,
              onTap: onLearn,
              enabled: learnEnabled,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ServiceTile(
              label: l10n.bidaHopeTitle,
              logoAsset: hopeLogo,
              fallbackIcon: Icons.groups_rounded,
              background: const Color(0xFFFCE7F3),
              border: const Color(0xFFF5C2D8),
              foreground: const Color(0xFFDB2777),
              onTap: onHope,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ServiceTile(
              label: l10n.bidaCareTitle,
              logoAsset: careLogo,
              fallbackIcon: Icons.favorite_rounded,
              background: const Color(0xFFE6F7F0),
              border: const Color(0xFFB8DFD0),
              foreground: const Color(0xFF0D9488),
              onTap: onCare,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatefulWidget {
  const _ServiceTile({
    required this.label,
    required this.logoAsset,
    required this.fallbackIcon,
    required this.background,
    required this.border,
    required this.foreground,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final String logoAsset;
  final IconData fallbackIcon;
  final Color background;
  final Color border;
  final Color foreground;
  final VoidCallback onTap;
  final bool enabled;

  @override
  State<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends State<_ServiceTile> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1 : 0.45,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _scale = 0.97) : null,
        onTapCancel: widget.enabled ? () => setState(() => _scale = 1) : null,
        onTapUp: widget.enabled ? (_) => setState(() => _scale = 1) : null,
        onTap: () {
          if (widget.enabled) {
            HapticFeedback.lightImpact();
          }
          widget.onTap();
        },
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 100),
          child: Container(
            constraints: const BoxConstraints(minHeight: 118),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            decoration: BoxDecoration(
              color: widget.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.border, width: 1.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 46,
                  width: 46,
                  child: Image.asset(
                    widget.logoAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      widget.fallbackIcon,
                      color: widget.foreground,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: widget.foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
