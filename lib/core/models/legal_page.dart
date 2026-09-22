class LegalPage {
  const LegalPage({
    required this.slug,
    required this.locale,
    required this.title,
    required this.subtitle,
    required this.intro,
    required this.body,
    this.updatedAt,
  });

  final String slug;
  final String locale;
  final String title;
  final String subtitle;
  final String intro;
  final String body;
  final String? updatedAt;

  factory LegalPage.fromJson(Map<String, dynamic> json) {
    return LegalPage(
      slug: (json['slug'] ?? '') as String,
      locale: (json['locale'] ?? 'en') as String,
      title: (json['title'] ?? '') as String,
      subtitle: (json['subtitle'] ?? '') as String,
      intro: (json['intro'] ?? '') as String,
      body: (json['body'] ?? '') as String,
      updatedAt: json['updated_at'] as String?,
    );
  }
}
