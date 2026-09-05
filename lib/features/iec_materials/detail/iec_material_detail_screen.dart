import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/iec_material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/theme/app_colors.dart';

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
            flags: const YoutubePlayerFlags(autoPlay: false),
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
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(l10n.iecMaterialDetailTitle),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : material == null
              ? Center(child: Text(l10n.noIecMaterialsFound))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    Text(
                      material.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                    ),
                    if (material.topic != null &&
                        material.topic!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          material.topic!,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _yt != null
                          ? YoutubePlayer(
                              controller: _yt!,
                              showVideoProgressIndicator: true,
                            )
                          : material.isImage
                              ? Image.network(
                                  material.mediaUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 220,
                                    color: Colors.grey.shade200,
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.broken_image_outlined),
                                  ),
                                )
                              : Container(
                                  height: 180,
                                  color: AppColors.primaryBlue
                                      .withValues(alpha: 0.08),
                                  alignment: Alignment.center,
                                  child: TextButton.icon(
                                    onPressed: _openExternal,
                                    icon: const Icon(Icons.open_in_new),
                                    label: Text(l10n.openMediaLink),
                                  ),
                                ),
                    ),
                    if (material.description != null &&
                        material.description!.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        l10n.aboutIecMaterial,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        material.description!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                              height: 1.45,
                            ),
                      ),
                    ],
                    if (_yt == null && material.isYoutube) ...[
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openExternal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.openOnYoutube),
                      ),
                    ],
                  ],
                ),
    );
  }
}
