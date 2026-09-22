import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/rehab_center.dart';
import '../../hope/hope_colors.dart';

class RehabCenterDetailScreen extends StatelessWidget {
  const RehabCenterDetailScreen({super.key, required this.center});

  final RehabCenter center;

  String get _searchQuery {
    return [
      center.name,
      if (center.address.isNotEmpty) center.address,
      if (center.province.isNotEmpty) center.province,
      if (center.region.isNotEmpty) center.region,
    ].where((s) => s.trim().isNotEmpty).join(', ');
  }

  Uri get _mapEmbedUri {
    final lat = center.latitude!;
    final lng = center.longitude!;
    const delta = 0.02;
    return Uri.parse(
      'https://www.openstreetmap.org/export/embed.html'
      '?bbox=${lng - delta}%2C${lat - delta}%2C${lng + delta}%2C${lat + delta}'
      '&layer=mapnik'
      '&marker=$lat%2C$lng',
    );
  }

  Uri get _googleMapsDirectionsUri {
    if (center.hasCoordinates) {
      final dest = '${center.latitude},${center.longitude}';
      return Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(dest)}',
      );
    }
    return Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(_searchQuery)}',
    );
  }

  Uri get _googleMapsViewUri {
    if (center.hasCoordinates) {
      return Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${center.latitude},${center.longitude}',
      );
    }
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(_searchQuery)}',
    );
  }

  Future<void> _openDirections() async {
    final uri = _googleMapsDirectionsUri;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInGoogleMaps() async {
    final uri = _googleMapsViewUri;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String number) async {
    final digits = number.replaceAll(RegExp(r'[^\d+]'), '');
    if (digits.isEmpty) return;
    final uri = Uri.parse('tel:$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWebsite(String url) async {
    var value = url.trim();
    if (!value.startsWith('http')) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.viewPaddingOf(context).top;
    final regionLine = [
      if (center.region.isNotEmpty) center.region,
      if (center.province.isNotEmpty) center.province,
    ].join(' · ');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.34 + top,
                        width: double.infinity,
                        child: center.hasCoordinates
                            ? InAppWebView(
                                initialUrlRequest: URLRequest(
                                  url: WebUri(_mapEmbedUri.toString()),
                                ),
                                initialSettings: InAppWebViewSettings(
                                  javaScriptEnabled: true,
                                  domStorageEnabled: true,
                                  cacheEnabled: false,
                                ),
                              )
                            : Container(
                                color: HopeColors.purpleSoft,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.map_outlined,
                                      size: 48,
                                      color: HopeColors.purple,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Map location not available',
                                      style: TextStyle(
                                        color: HopeColors.muted,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: _openInGoogleMaps,
                                      icon: const Icon(
                                        Icons.open_in_new,
                                        size: 18,
                                      ),
                                      label: const Text('Search on Google Maps'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: HopeColors.purple,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      Positioned(
                        top: top + 8,
                        left: 12,
                        child: Material(
                          color: Colors.black38,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).maybePop(),
                            child: const SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Transform.translate(
                    offset: const Offset(0, -18),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            center.name,
                            style: const TextStyle(
                              color: HopeColors.purple,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                              height: 1.25,
                            ),
                          ),
                          if (regionLine.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              regionLine,
                              style: const TextStyle(
                                color: HopeColors.muted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 18),
                          if (center.address.isNotEmpty)
                            _DetailCard(
                              icon: Icons.location_on_outlined,
                              label: 'Address',
                              value: center.address,
                            ),
                          if (center.contact.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _DetailCard(
                              icon: Icons.phone_outlined,
                              label: 'Contact',
                              value: center.contact,
                              onTap: () => _launchPhone(center.contact),
                            ),
                          ],
                          if (center.website != null &&
                              center.website!.trim().isNotEmpty) ...[
                            const SizedBox(height: 10),
                            _DetailCard(
                              icon: Icons.language,
                              label: 'Website',
                              value: center.website!,
                              onTap: () => _launchWebsite(center.website!),
                            ),
                          ],
                          if (center.hasCoordinates) ...[
                            const SizedBox(height: 10),
                            _DetailCard(
                              icon: Icons.my_location_outlined,
                              label: 'Coordinates',
                              value:
                                  '${center.latitude!.toStringAsFixed(5)}, ${center.longitude!.toStringAsFixed(5)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _openDirections,
                      icon: const Icon(Icons.directions),
                      label: const Text('Get directions'),
                      style: FilledButton.styleFrom(
                        backgroundColor: HopeColors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _openInGoogleMaps,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Open in Google Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HopeColors.purple,
                        side: const BorderSide(
                          color: HopeColors.purple,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HopeColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: HopeColors.purple.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: HopeColors.purpleSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: HopeColors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: HopeColors.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: HopeColors.purple,
                    fontWeight:
                        onTap != null ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                    height: 1.35,
                    decoration:
                        onTap != null ? TextDecoration.underline : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}
