class CareMoodOption {
  const CareMoodOption({
    required this.key,
    required this.emoji,
    required this.labelEn,
    required this.labelTl,
  });

  final String key;
  final String emoji;
  final String labelEn;
  final String labelTl;
}

class CareConstants {
  CareConstants._();

  static const moods = <CareMoodOption>[
    CareMoodOption(
      key: 'struggling',
      emoji: '😭',
      labelEn: 'Struggling',
      labelTl: 'Nahihirapan',
    ),
    CareMoodOption(
      key: 'difficult',
      emoji: '😢',
      labelEn: 'Difficult',
      labelTl: 'Mahirap',
    ),
    CareMoodOption(
      key: 'meh',
      emoji: '😐',
      labelEn: 'Meh',
      labelTl: 'Okay lang',
    ),
    CareMoodOption(
      key: 'good',
      emoji: '🙂',
      labelEn: 'Good',
      labelTl: 'Mabuti',
    ),
    CareMoodOption(
      key: 'great',
      emoji: '🤩',
      labelEn: 'Great!',
      labelTl: 'Ayos!',
    ),
  ];

  /// Maps Care hub mood keys to journal "sky" reflection keys.
  static String? skyForCareMood(String? mood) {
    return switch (mood) {
      'struggling' => 'stormy',
      'difficult' => 'overcast',
      'meh' => 'passing_mist',
      'good' => 'clear_skies',
      'great' => 'clear_skies',
      _ => null,
    };
  }

  /// Suggested journal feelings for a Care hub mood.
  static List<String> feelingsForCareMood(String? mood) {
    return switch (mood) {
      'struggling' => const ['Overwhelmed', 'Lonely'],
      'difficult' => const ['Anxious', 'Triggered'],
      'meh' => const ['Restless'],
      'good' => const ['Grounded', 'Peaceful'],
      'great' => const ['Grateful', 'Hopeful', 'Motivated'],
      _ => const [],
    };
  }
}
