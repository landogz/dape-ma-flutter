class Training {
  final int id;
  final String title;
  final String? description;
  final String category;
  final String? region;
  final String? venue;
  final String? startDate;
  final String? endDate;
  final String? scheduleNotes;
  final String? organizer;
  final String? contact;
  final String? registrationUrl;
  final int? slots;

  Training({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    this.region,
    this.venue,
    this.startDate,
    this.endDate,
    this.scheduleNotes,
    this.organizer,
    this.contact,
    this.registrationUrl,
    this.slots,
  });

  String get scheduleLabel {
    final start = _dateOnly(startDate);
    final end = _dateOnly(endDate);

    if (start != null && end != null && start != end) {
      return '$start → $end';
    }
    if (start != null) {
      return start;
    }
    if (scheduleNotes != null && scheduleNotes!.trim().isNotEmpty) {
      return scheduleNotes!.trim();
    }
    return 'Schedule TBA';
  }

  factory Training.fromJson(Map<String, dynamic> json) {
    return Training(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      category: json['category'] as String? ?? 'Training',
      region: json['region'] as String?,
      venue: json['venue'] as String?,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      scheduleNotes: json['schedule_notes'] as String?,
      organizer: json['organizer'] as String?,
      contact: json['contact'] as String?,
      registrationUrl: json['registration_url'] as String?,
      slots: json['slots'] is int
          ? json['slots'] as int
          : int.tryParse('${json['slots'] ?? ''}'),
    );
  }

  static String? _dateOnly(String? value) {
    if (value == null || value.isEmpty) return null;
    return value.length >= 10 ? value.substring(0, 10) : value;
  }
}
