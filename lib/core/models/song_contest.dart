class SongContest {
  final int id;
  final String title;
  final String? description;
  final String? rules;
  final String? theme;
  final String allowedEntryTypes;
  final int? contestYear;
  final String? submissionStartsAt;
  final String? submissionEndsAt;
  final String status;
  final String? coverImageUrl;
  final bool isOpenForSubmission;
  final int entriesCount;
  final int pendingCount;

  SongContest({
    required this.id,
    required this.title,
    this.description,
    this.rules,
    this.theme,
    required this.allowedEntryTypes,
    this.contestYear,
    this.submissionStartsAt,
    this.submissionEndsAt,
    required this.status,
    this.coverImageUrl,
    required this.isOpenForSubmission,
    required this.entriesCount,
    required this.pendingCount,
  });

  factory SongContest.fromJson(Map<String, dynamic> json) {
    return SongContest(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      rules: json['rules'] as String?,
      theme: json['theme'] as String?,
      allowedEntryTypes: json['allowed_entry_types'] as String? ?? 'both',
      contestYear: json['contest_year'] is int
          ? json['contest_year'] as int
          : int.tryParse('${json['contest_year'] ?? ''}'),
      submissionStartsAt: json['submission_starts_at']?.toString(),
      submissionEndsAt: json['submission_ends_at']?.toString(),
      status: json['status'] as String? ?? 'draft',
      coverImageUrl: json['cover_image_url'] as String?,
      isOpenForSubmission: json['is_open_for_submission'] == true,
      entriesCount: json['entries_count'] is int
          ? json['entries_count'] as int
          : int.tryParse('${json['entries_count'] ?? 0}') ?? 0,
      pendingCount: json['pending_count'] is int
          ? json['pending_count'] as int
          : int.tryParse('${json['pending_count'] ?? 0}') ?? 0,
    );
  }
}
