import 'package:flutter/material.dart';

import '../../../core/l10n/locale_scope.dart';
import '../../../core/models/iec_material.dart';
import '../../hope/hope_colors.dart';
import '../detail/iec_material_detail_screen.dart';

class IecMaterialCard extends StatelessWidget {
  final IecMaterial material;
  final int index;

  const IecMaterialCard({
    super.key,
    required this.material,
    required this.index,
  });

  IconData get _mediaIcon {
    if (material.isYoutube) return Icons.play_circle_outline;
    if (material.isGif) return Icons.gif_box_outlined;
    return Icons.image_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  IecMaterialDetailScreen(materialId: material.id),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: HopeColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: HopeColors.purple.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        material.previewUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: HopeColors.purpleSoft,
                          child: Icon(
                            _mediaIcon,
                            color: HopeColors.purple,
                            size: 32,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: HopeColors.purple.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            material.mediaType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: HopeColors.purple,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    if (material.topic != null &&
                        material.topic!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: HopeColors.purpleSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          material.topic!,
                          style: const TextStyle(
                            color: HopeColors.purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      l10n.tapToViewIec,
                      style: const TextStyle(
                        color: HopeColors.muted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
