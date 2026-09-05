import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/rehab_center.dart';
import '../../../core/theme/app_colors.dart';

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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          center.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.38,
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
                    color: const Color(0xFFE5E7EB),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppColors.textSecondaryLight,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Map location not available',
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _openInGoogleMaps,
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Search on Google Maps'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    center.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                  ),
                  if (center.region.isNotEmpty ||
                      center.province.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      [
                        if (center.region.isNotEmpty) center.region,
                        if (center.province.isNotEmpty) center.province,
                      ].join(' • '),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (center.address.isNotEmpty)
                    _DetailRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: center.address,
                    ),
                  if (center.contact.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact',
                      value: center.contact,
                      valueColor: AppColors.primaryBlue,
                      onTap: () => _launchPhone(center.contact),
                    ),
                  ],
                  if (center.website != null &&
                      center.website!.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.language,
                      label: 'Website',
                      value: center.website!,
                      valueColor: AppColors.primaryBlue,
                      onTap: () => _launchWebsite(center.website!),
                    ),
                  ],
                  if (center.hasCoordinates) ...[
                    const SizedBox(height: 14),
                    _DetailRow(
                      icon: Icons.my_location_outlined,
                      label: 'Coordinates',
                      value:
                          '${center.latitude!.toStringAsFixed(5)}, ${center.longitude!.toStringAsFixed(5)}',
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openDirections,
                      icon: const Icon(Icons.directions),
                      label: const Text('Get directions'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _openInGoogleMaps,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Open in Google Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.textSecondaryLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: valueColor ?? AppColors.textPrimaryLight,
                      decoration:
                          onTap != null ? TextDecoration.underline : null,
                    ),
              ),
            ],
          ),
        ),
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}
