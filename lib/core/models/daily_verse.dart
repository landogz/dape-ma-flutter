class DailyVerse {
  final String brand;
  final String brandTagline;
  final String reference;
  final String verseText;
  final String kidListoMessage;
  final String translation;
  final String book;
  final int chapter;
  final int verseStart;
  final int? verseEnd;
  final int dayOfYear;
  final int totalDays;

  const DailyVerse({
    required this.brand,
    required this.brandTagline,
    required this.reference,
    required this.verseText,
    required this.kidListoMessage,
    required this.translation,
    required this.book,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
    required this.dayOfYear,
    required this.totalDays,
  });

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      brand: (json['brand'] ?? 'Kid Listo Says') as String,
      brandTagline: (json['brand_tagline'] ?? '') as String,
      reference: (json['reference'] ?? '') as String,
      verseText: (json['verse_text'] ?? '') as String,
      kidListoMessage: (json['kid_listo_message'] ?? json['verse_text'] ?? '') as String,
      translation: (json['translation'] ?? '') as String,
      book: (json['book'] ?? '') as String,
      chapter: (json['chapter'] as num?)?.toInt() ?? 1,
      verseStart: (json['verse_start'] as num?)?.toInt() ?? 1,
      verseEnd: (json['verse_end'] as num?)?.toInt(),
      dayOfYear: (json['day_of_year'] as num?)?.toInt() ?? 0,
      totalDays: (json['total_days'] as num?)?.toInt() ?? 365,
    );
  }
}
