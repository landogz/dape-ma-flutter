class DailyVerse {
  final String reference;
  final String verseText;
  final String translation;
  final String book;
  final int chapter;
  final int verseStart;
  final int? verseEnd;

  const DailyVerse({
    required this.reference,
    required this.verseText,
    required this.translation,
    required this.book,
    required this.chapter,
    required this.verseStart,
    this.verseEnd,
  });

  factory DailyVerse.fromJson(Map<String, dynamic> json) {
    return DailyVerse(
      reference: (json['reference'] ?? '') as String,
      verseText: (json['verse_text'] ?? '') as String,
      translation: (json['translation'] ?? '') as String,
      book: (json['book'] ?? '') as String,
      chapter: (json['chapter'] as num?)?.toInt() ?? 1,
      verseStart: (json['verse_start'] as num?)?.toInt() ?? 1,
      verseEnd: (json['verse_end'] as num?)?.toInt(),
    );
  }
}
