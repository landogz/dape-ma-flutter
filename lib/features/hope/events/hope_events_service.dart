import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/utils/api_url.dart';
import 'hope_event.dart';

class HopeEventsService {
  HopeEventsService._();

  static Future<List<HopeEvent>> fetch({
    String? audience,
    String? search,
  }) async {
    final client = ApiClient();
    final res = await client.get<Map<String, dynamic>>(
      Endpoints.hopeEvents,
      query: {
        'per_page': 100,
        if (audience != null && audience.isNotEmpty) 'audience': audience,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    final list = data is Map<String, dynamic>
        ? data['data'] as List<dynamic>? ?? const []
        : data is List<dynamic>
            ? data
            : const [];

    return list
        .whereType<Map<String, dynamic>>()
        .map((json) => _withResolvedCover(HopeEvent.fromJson(json)))
        .toList();
  }

  static Future<HopeEvent> fetchOne(int id) async {
    final client = ApiClient();
    final res = await client.get<Map<String, dynamic>>(
      Endpoints.hopeEventDetail(id),
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return _withResolvedCover(HopeEvent.fromJson(data));
  }

  static HopeEvent _withResolvedCover(HopeEvent event) {
    return HopeEvent(
      id: event.id,
      title: event.title,
      audience: event.audience,
      coverUrl: ApiUrl.resolve(event.coverUrl),
      status: event.status,
      startDate: event.startDate,
      endDate: event.endDate,
      venue: event.venue,
      isOnline: event.isOnline,
      onlineLabel: event.onlineLabel,
      slots: event.slots,
      registrationUrl: event.registrationUrl,
      aboutText: event.aboutText,
      forYouItems: event.forYouItems,
      whoCanJoin: event.whoCanJoin,
      highlights: event.highlights,
      detailsText: event.detailsText,
      speakers: event.speakers
          .map(
            (speaker) => HopeSpeaker(
              name: speaker.name,
              role: speaker.role,
              photoUrl: ApiUrl.resolve(speaker.photoUrl),
            ),
          )
          .toList(),
      faqs: event.faqs,
    );
  }
}
