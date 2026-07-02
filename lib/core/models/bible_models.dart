class BibleBook {
  final String id;
  final String name;
  final String testament;
  final int chapters;

  const BibleBook({
    required this.id,
    required this.name,
    required this.testament,
    required this.chapters,
  });

  factory BibleBook.fromJson(Map<String, dynamic> json) {
    return BibleBook(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      testament: (json['testament'] ?? '') as String,
      chapters: (json['chapters'] as num?)?.toInt() ?? 1,
    );
  }
}

class BibleVerseLine {
  final int verse;
  final String text;

  const BibleVerseLine({required this.verse, required this.text});

  factory BibleVerseLine.fromJson(Map<String, dynamic> json) {
    return BibleVerseLine(
      verse: (json['verse'] as num?)?.toInt() ?? 0,
      text: (json['text'] ?? '') as String,
    );
  }
}

class BiblePassage {
  final String reference;
  final String translation;
  final List<BibleVerseLine> verses;
  final String text;

  const BiblePassage({
    required this.reference,
    required this.translation,
    required this.verses,
    required this.text,
  });

  factory BiblePassage.fromJson(Map<String, dynamic> json) {
    final rawVerses = json['verses'];
    return BiblePassage(
      reference: (json['reference'] ?? '') as String,
      translation: (json['translation'] ?? '') as String,
      text: (json['text'] ?? '') as String,
      verses: rawVerses is List
          ? rawVerses
              .whereType<Map<String, dynamic>>()
              .map(BibleVerseLine.fromJson)
              .toList()
          : const [],
    );
  }
}
