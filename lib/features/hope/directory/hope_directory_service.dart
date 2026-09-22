import '../../../core/network/api_client.dart';
import '../../../core/network/endpoints.dart';
import '../../../core/utils/api_url.dart';
import 'hope_directory_org.dart';

class HopeDirectoryService {
  HopeDirectoryService._();

  static Future<List<HopeDirectoryOrg>> fetch({
    String? category,
    String? search,
  }) async {
    final client = ApiClient();
    final res = await client.get<Map<String, dynamic>>(
      Endpoints.hopeDirectory,
      query: {
        'per_page': 200,
        if (category != null && category.isNotEmpty) 'category': category,
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

    return list.whereType<Map<String, dynamic>>().map((json) {
      final org = HopeDirectoryOrg.fromJson(json);
      return HopeDirectoryOrg(
        id: org.id,
        name: org.name,
        description: org.description,
        category: org.category,
        address: org.address,
        phone: org.phone,
        email: org.email,
        logoUrl: ApiUrl.resolve(org.logoUrl),
      );
    }).toList();
  }
}
