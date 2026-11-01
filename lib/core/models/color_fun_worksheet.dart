class ColorFunWorksheet {
  const ColorFunWorksheet({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    this.sortOrder = 0,
  });

  final int id;
  final String title;
  final String category;
  final String imageUrl;
  final int sortOrder;

  factory ColorFunWorksheet.fromJson(Map<String, dynamic> json) {
    return ColorFunWorksheet(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Worksheet',
      category: ((json['category'] as String?) ?? 'nature').trim().toLowerCase(),
      imageUrl: (json['image_url'] as String?)?.trim() ?? '',
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  bool get hasImage => imageUrl.isNotEmpty;
}
