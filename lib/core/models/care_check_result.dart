class CareCheckResult {
  const CareCheckResult({
    required this.id,
    required this.checkType,
    required this.rawScore,
    required this.maxScore,
    required this.percent,
    required this.band,
    required this.displayTier,
    this.sleepHours,
    this.createdAt,
  });

  final int id;
  final String checkType;
  final int rawScore;
  final int maxScore;
  final int percent;
  final String band;
  final String displayTier;
  final double? sleepHours;
  final String? createdAt;

  bool get isHighTier => displayTier == 'high';

  factory CareCheckResult.fromJson(Map<String, dynamic> json) {
    return CareCheckResult(
      id: (json['id'] as num?)?.toInt() ?? 0,
      checkType: (json['check_type'] ?? '').toString(),
      rawScore: (json['raw_score'] as num?)?.toInt() ?? 0,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 0,
      percent: (json['percent'] as num?)?.toInt() ?? 0,
      band: (json['band'] ?? '').toString(),
      displayTier: (json['display_tier'] ?? 'low').toString(),
      sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
