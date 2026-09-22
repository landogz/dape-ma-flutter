import '../../core/models/care_support_item.dart';
import '../../core/network/api_client.dart';
import '../../core/network/endpoints.dart';

class CareSupportService {
  CareSupportService._();

  static Future<List<CareSupportItem>> fetch({
    required String category,
    String? locale,
  }) async {
    final client = ApiClient();
    final res = await client.get<Map<String, dynamic>>(
      Endpoints.careSupportResources,
      query: {
        'category': category,
        if (locale != null && locale.isNotEmpty) 'locale': locale,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    final data = root['data'];
    final list = data is Map<String, dynamic>
        ? data['resources'] as List<dynamic>? ?? const []
        : const [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(CareSupportItem.fromJson)
        .toList();
  }
}
