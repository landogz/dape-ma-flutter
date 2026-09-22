import '../../core/models/kid_listo_quote.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class KidListoQuoteService {
  KidListoQuoteService._();

  static Future<KidListoQuote?> fetchRandom({String? locale}) async {
    try {
      final client = ApiClient();
      final response = await client.get<Map<String, dynamic>>(
        Endpoints.kidListoRandom,
        query: {
          if (locale != null && locale.isNotEmpty) 'locale': locale,
        },
      );

      final data = response.data?['data'];
      if (data is Map<String, dynamic>) {
        return KidListoQuote.fromJson(data);
      }
    } catch (_) {
      // Fall through to null; UI shows fallback copy.
    }

    return null;
  }
}
