import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/rehab_center.dart';
import '../../hope/hope_colors.dart';
import '../detail/rehab_center_detail_screen.dart';
import '../../../core/theme/app_theme_colors.dart';

class RehabCenterCard extends StatelessWidget {
  final RehabCenter center;

  const RehabCenterCard({super.key, required this.center});

  Future<void> _launchPhone(String number) async {
    final digits = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RehabCenterDetailScreen(center: center),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initial = center.name.isNotEmpty ? center.name[0].toUpperCase() : '?';
    final regionLine = [
      if (center.region.isNotEmpty) center.region,
      if (center.province.isNotEmpty) center.province,
    ].join(' · ');
    final categoryLabel =
        center.categoryDisplay(isTagalog: context.l10n.isTagalog);
    final categoryColor = center.categoryColor ?? HopeColors.purple;
    final onCategory = categoryColor.computeLuminance() > 0.65
        ? const Color(0xFF123A60)
        : Colors.white;

    return Material(
      color: context.cardBackground,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorderOf(context)),
            boxShadow: [
              BoxShadow(
                color: HopeColors.purple.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: categoryColor.withValues(alpha: 0.14),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: categoryColor.computeLuminance() > 0.65
                        ? const Color(0xFF123A60)
                        : categoryColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      center.name,
                      style: TextStyle(
                        color: HopeColors.headingOf(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (categoryLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          categoryLabel,
                          style: TextStyle(
                            color: onCategory,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (regionLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        regionLine,
                        style: TextStyle(
                          color: HopeColors.mutedOf(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (center.address.isNotEmpty)
                      _InfoRow(Icons.place_outlined, center.address),
                    if (center.contact.isNotEmpty)
                      _InfoRow(Icons.phone_outlined, center.contact),
                    if (center.website != null &&
                        center.website!.trim().isNotEmpty)
                      _InfoRow(Icons.language, center.website!),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: HopeColors.chipInactiveOf(context),
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: center.contact.isEmpty
                      ? null
                      : () => _launchPhone(center.contact),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.phone,
                      color: HopeColors.headingOf(context),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: HopeColors.headingOf(context)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: HopeColors.headingOf(context)),
            ),
          ),
        ],
      ),
    );
  }
}
