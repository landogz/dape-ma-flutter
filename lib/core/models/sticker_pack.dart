import '../utils/api_url.dart';

class StickerItem {
  const StickerItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.sortOrder,
  });

  final int id;
  final String name;
  final String imageUrl;
  final int sortOrder;

  factory StickerItem.fromJson(Map<String, dynamic> json) {
    return StickerItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim() ?? '',
      imageUrl: ApiUrl.resolve((json['image_url'] as String?)?.trim()) ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}

class StickerPack {
  const StickerPack({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.coverUrl,
    required this.sortOrder,
    required this.stickers,
  });

  final int id;
  final String name;
  final String slug;
  final String description;
  final String? coverUrl;
  final int sortOrder;
  final List<StickerItem> stickers;

  factory StickerPack.fromJson(Map<String, dynamic> json) {
    final rawStickers = json['stickers'];
    final stickers = rawStickers is List
        ? rawStickers
            .whereType<Map>()
            .map((item) => StickerItem.fromJson(Map<String, dynamic>.from(item)))
            .where((item) => item.imageUrl.isNotEmpty)
            .toList()
        : <StickerItem>[];

    return StickerPack(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?)?.trim() ?? '',
      slug: (json['slug'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      coverUrl: ApiUrl.resolve((json['cover_url'] as String?)?.trim()),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      stickers: stickers,
    );
  }
}
