class DiaryEntry {
  final int id;
  final String entryDate;
  final String? title;
  final String bodyHtml;
  final String? createdAt;
  final String? updatedAt;

  const DiaryEntry({
    required this.id,
    required this.entryDate,
    required this.bodyHtml,
    this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: (json['id'] as num?)?.toInt() ?? 0,
      entryDate: (json['entry_date'] ?? '') as String,
      title: json['title'] as String?,
      bodyHtml: (json['body_html'] ?? '') as String,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
