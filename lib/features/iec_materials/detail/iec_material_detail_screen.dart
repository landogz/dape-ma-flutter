import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/accessibility/accessibility_controller.dart';
import '../../../core/analytics/analytics_client.dart';
import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/iec_material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../hope/hope_colors.dart';

class IecMaterialDetailScreen extends StatefulWidget {
  final int materialId;

  const IecMaterialDetailScreen({super.key, required this.materialId});

  @override
  State<IecMaterialDetailScreen> createState() =>
      _IecMaterialDetailScreenState();
}

class _IecMaterialDetailScreenState extends State<IecMaterialDetailScreen> {
  IecMaterial? _material;
  bool _loading = true;
  YoutubePlayerController? _yt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _yt?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiClient().get<Map<String, dynamic>>(
        Endpoints.iecMaterialDetail(widget.materialId),
      );
      final data = res.data?['data'];
      IecMaterial? material;
      if (data is Map<String, dynamic>) {
        material = IecMaterial.fromJson(data);
      }
      YoutubePlayerController? yt;
      if (material != null && material.isYoutube) {
        final id = YoutubePlayer.convertUrlToId(material.mediaUrl);
        if (id != null) {
          yt = YoutubePlayerController(
            initialVideoId: id,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              enableCaption: AccessibilityController.instance.captions,
              captionLanguage: 'en',
            ),
          );
        }
      }
      if (!mounted) {
        yt?.dispose();
        return;
      }
      setState(() {
        _material = material;
        _yt = yt;
      });
      if (material != null) {
        AnalyticsClient.instance.trackIecView(material.id);
      }
    } catch (_) {
      if (mounted) setState(() => _material = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openExternal() async {
    final url = _material?.mediaUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final material = _material;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: HopeColors.purple,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.iecMaterialDetailTitle,
          style: const TextStyle(
            color: HopeColors.purple,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: HopeColors.purple),
            )
          : material == null
              ? Center(
                  child: Text(
                    l10n.noIecMaterialsFound,
                    style: const TextStyle(color: HopeColors.muted),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    Text(
                      material.title,
                      style: const TextStyle(
                        color: HopeColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HopePill(label: material.mediaType.toUpperCase()),
                        if (material.topic != null &&
                            material.topic!.isNotEmpty)
                          _HopePill(label: material.topic!),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                      clipBehavior: Clip.antiAlias,
                      child: _yt != null
                          ? YoutubePlayer(
                              controller: _yt!,
                              showVideoProgressIndicator: true,
                            )
                          : material.isImage
                              ? Image.network(
                                  material.mediaUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    height: 220,
                                    color: HopeColors.purpleSoft,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      color: HopeColors.purple,
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 180,
                                  color: HopeColors.purpleSoft,
                                  alignment: Alignment.center,
                                  child: TextButton.icon(
                                    onPressed: _openExternal,
                                    icon: const Icon(Icons.open_in_new),
                                    label: Text(l10n.openMediaLink),
                                    style: TextButton.styleFrom(
                                      foregroundColor: HopeColors.purple,
                                    ),
                                  ),
                                ),
                    ),
                    if (material.description != null &&
                        material.description!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.aboutIecMaterial,
                        style: const TextStyle(
                          color: HopeColors.purple,
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        material.description!,
                        style: const TextStyle(
                          color: HopeColors.muted,
                          height: 1.5,
                          fontSize: 14,
                        ),
                      ),
                    ],
                    if (_yt == null && material.isYoutube) ...[
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _openExternal,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: Text(l10n.openOnYoutube),
                          style: FilledButton.styleFrom(
                            backgroundColor: HopeColors.purple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
    );
  }
}

class _HopePill extends StatelessWidget {
  const _HopePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: HopeColors.purpleSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: HopeColors.cardBorder),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: HopeColors.purple,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
