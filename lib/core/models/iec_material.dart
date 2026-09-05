class IecMaterial {
  final int id;
  final String title;
  final String? description;
  final String? topic;
  final String mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final int sortOrder;

  IecMaterial({
    required this.id,
    required this.title,
    this.description,
    this.topic,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.sortOrder,
  });

  factory IecMaterial.fromJson(Map<String, dynamic> json) {
    return IecMaterial(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      topic: json['topic'] as String?,
      mediaType: json['media_type'] as String? ?? 'gif',
      mediaUrl: json['media_url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      sortOrder: json['sort_order'] is int
          ? json['sort_order'] as int
          : int.tryParse('${json['sort_order'] ?? 0}') ?? 0,
    );
  }

  bool get isGif => mediaType == 'gif';
  bool get isImage => mediaType == 'image' || mediaType == 'gif';
  bool get isYoutube => mediaType == 'youtube';
  bool get isLottie => mediaType == 'lottie';

  String get previewUrl =>
      (thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty)
          ? thumbnailUrl!
          : mediaUrl;
}
