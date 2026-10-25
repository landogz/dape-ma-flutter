class TranslationVisual {
  const TranslationVisual({this.imageUrl, this.icon});

  final String? imageUrl;
  final String? icon;

  bool get hasImage => imageUrl != null && imageUrl!.trim().isNotEmpty;

  bool get hasIcon => icon != null && icon!.trim().isNotEmpty;

  factory TranslationVisual.fromJson(Map<String, dynamic> json) {
    final image = json['image_url']?.toString().trim();
    final icon = json['icon']?.toString().trim();
    return TranslationVisual(
      imageUrl: (image == null || image.isEmpty) ? null : image,
      icon: (icon == null || icon.isEmpty) ? null : icon,
    );
  }
}
