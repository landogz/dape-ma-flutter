class HopeEvent {
  final int id;
  final String title;
  final String? audience;
  final String? coverUrl;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? venue;
  final bool isOnline;
  final String? onlineLabel;
  final int? slots;
  final String? registrationUrl;
  final String? aboutText;
  final List<String> forYouItems;
  final String? whoCanJoin;
  final List<String> highlights;
  final String? detailsText;
  final List<HopeSpeaker> speakers;
  final List<HopeFaq> faqs;

  const HopeEvent({
    required this.id,
    required this.title,
    this.audience,
    this.coverUrl,
    this.status = 'upcoming',
    this.startDate,
    this.endDate,
    this.venue,
    this.isOnline = false,
    this.onlineLabel,
    this.slots,
    this.registrationUrl,
    this.aboutText,
    this.forYouItems = const [],
    this.whoCanJoin,
    this.highlights = const [],
    this.detailsText,
    this.speakers = const [],
    this.faqs = const [],
  });

  factory HopeEvent.fromJson(Map<String, dynamic> json) {
    final forYou = json['for_you_items'];
    final highlightsRaw = json['highlights'];
    final speakersRaw = json['speakers'];
    final faqsRaw = json['faqs'];

    return HopeEvent(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '') as String,
      audience: json['audience'] as String?,
      coverUrl: json['cover_url'] as String?,
      status: (json['status'] ?? 'upcoming') as String,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      venue: json['venue'] as String?,
      isOnline: json['is_online'] == true,
      onlineLabel: json['online_label'] as String?,
      slots: (json['slots'] as num?)?.toInt(),
      registrationUrl: json['registration_url'] as String?,
      aboutText: json['about_text'] as String?,
      forYouItems: forYou is List
          ? forYou.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
          : const [],
      whoCanJoin: json['who_can_join'] as String?,
      highlights: highlightsRaw is List
          ? highlightsRaw
              .map((e) {
                if (e is Map) return (e['label'] ?? '').toString();
                return e.toString();
              })
              .where((e) => e.isNotEmpty)
              .toList()
          : const [],
      detailsText: json['details_text'] as String?,
      speakers: speakersRaw is List
          ? speakersRaw
              .whereType<Map>()
              .map((e) => HopeSpeaker.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
      faqs: faqsRaw is List
          ? faqsRaw
              .whereType<Map>()
              .map((e) => HopeFaq.fromJson(Map<String, dynamic>.from(e)))
              .toList()
          : const [],
    );
  }
}

class HopeSpeaker {
  final String name;
  final String? role;

  const HopeSpeaker({required this.name, this.role});

  factory HopeSpeaker.fromJson(Map<String, dynamic> json) {
    return HopeSpeaker(
      name: (json['name'] ?? '') as String,
      role: json['role'] as String?,
    );
  }
}

class HopeFaq {
  final String question;
  final String answer;

  const HopeFaq({required this.question, required this.answer});

  factory HopeFaq.fromJson(Map<String, dynamic> json) {
    return HopeFaq(
      question: (json['question'] ?? '') as String,
      answer: (json['answer'] ?? '') as String,
    );
  }
}
