import '../../../core/auth/auth_service.dart';
import '../../../core/network/endpoints.dart';
import 'profile_models.dart';

class ProfileStatsService {
  ProfileStatsService._();

  static final ProfileStatsService instance = ProfileStatsService._();

  Future<ProfileSummary> fetchSummary() async {
    final res =
        await AuthService.authedGet<Map<String, dynamic>>(Endpoints.meProfile);
    final payload = res.data ?? <String, dynamic>{};
    final data = payload['data'] is Map<String, dynamic>
        ? payload['data'] as Map<String, dynamic>
        : payload;
    return ProfileSummary.fromJson(data);
  }
}
