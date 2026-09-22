import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/rehab_center.dart';
import '../../hope/hope_colors.dart';
import '../detail/rehab_center_detail_screen.dart';

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

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openDetail(context),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorder),
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
                backgroundColor: HopeColors.purpleSoft,
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: HopeColors.purple,
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
                      style: const TextStyle(
                        color: HopeColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (regionLine.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        regionLine,
                        style: const TextStyle(
                          color: HopeColors.muted,
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
                color: HopeColors.chipInactive,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: center.contact.isEmpty
                      ? null
                      : () => _launchPhone(center.contact),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.phone,
                      color: HopeColors.purple,
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
          Icon(icon, size: 14, color: HopeColors.purple),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: HopeColors.purple),
            ),
          ),
        ],
      ),
    );
  }
}
