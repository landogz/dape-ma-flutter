class DiaryEntry {
  final int id;
  final String entryDate;
  final String? title;
  final String? sky;
  final List<String> feelings;
  final String? impact;
  final String? gratitude;
  final String bodyHtml;
  final String? imageUrl;
  final String? createdAt;
  final String? updatedAt;

  const DiaryEntry({
    required this.id,
    required this.entryDate,
    this.title,
    this.sky,
    this.feelings = const [],
    this.impact,
    this.gratitude,
    this.bodyHtml = '',
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    final rawFeelings = json['feelings'];
    final feelings = rawFeelings is List
        ? rawFeelings
            .map((e) => e?.toString().trim() ?? '')
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    return DiaryEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      entryDate: (json['entry_date'] ?? '') as String,
      title: json['title'] as String?,
      sky: json['sky'] as String?,
      feelings: feelings,
      impact: json['impact'] as String?,
      gratitude: json['gratitude'] as String?,
      bodyHtml: (json['body_html'] ?? '') as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  bool get hasNotes {
    final plain = bodyHtml
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return plain.isNotEmpty;
  }

  String get notesPreview {
    final plain = bodyHtml
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'&nbsp;', caseSensitive: false), ' ')
        .replaceAll(RegExp(r'&amp;', caseSensitive: false), '&')
        .replaceAll(RegExp(r'&lt;', caseSensitive: false), '<')
        .replaceAll(RegExp(r'&gt;', caseSensitive: false), '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return plain;
  }
}
