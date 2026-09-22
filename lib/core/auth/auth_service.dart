import 'package:dio/dio.dart';

import '../accessibility/accessibility_controller.dart';
import '../network/api_client.dart';
import '../network/endpoints.dart';
import '../../features/settings/settings_preferences.dart';
import 'auth_storage.dart';

class AuthService {
  AuthService._();

  static String? _cachedToken;

  static Future<String?> getToken() async {
    if (_cachedToken != null) return _cachedToken;
    _cachedToken = await AuthStorage.getToken();
    return _cachedToken;
  }

  static Future<void> _setToken(String token) async {
    _cachedToken = token;
    await AuthStorage.saveToken(token);
  }

  static Future<void> logout() async {
    _cachedToken = null;
    await AuthStorage.clearToken();
    await AuthStorage.clearUserId();
    await SettingsPreferences.setUserScope(null);
    await AccessibilityController.instance.load();
  }

  /// Loads the signed-in user id and switches accessibility prefs to that user.
  static Future<void> bindCurrentUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await AuthStorage.clearUserId();
      await SettingsPreferences.setUserScope(null);
      await AccessibilityController.instance.load();
      return;
    }

    try {
      final res = await authedGet<Map<String, dynamic>>(Endpoints.me);
      final root = res.data ?? <String, dynamic>{};
      final user = root['data'] is Map<String, dynamic>
          ? root['data'] as Map<String, dynamic>
          : root;
      final id = user['id'];
      final userId = id == null ? null : '$id';
      if (userId != null && userId.isNotEmpty) {
        await AuthStorage.saveUserId(userId);
        await SettingsPreferences.setUserScope(userId);
      } else {
        final cached = await AuthStorage.getUserId();
        await SettingsPreferences.setUserScope(cached);
      }
    } catch (_) {
      final cached = await AuthStorage.getUserId();
      await SettingsPreferences.setUserScope(cached);
    }

    await AccessibilityController.instance.load();
  }

  static Future<void> restoreUserScope() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      await SettingsPreferences.setUserScope(null);
      return;
    }
    final cached = await AuthStorage.getUserId();
    await SettingsPreferences.setUserScope(cached);
  }

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final client = ApiClient();
    final res = await client.post<Map<String, dynamic>>(
      Endpoints.login,
      data: <String, dynamic>{
        'email': email,
        'password': password,
      },
    );

    final root = res.data ?? <String, dynamic>{};
    final payload = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final token = payload['token'] as String?;

    if (token == null || token.isEmpty) {
      throw StateError('No token returned from API.');
    }

    await _setToken(token);
    await bindCurrentUser();
  }

  static Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final client = ApiClient();
    final res = await client.post<Map<String, dynamic>>(
      Endpoints.register,
      data: <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    final root = res.data ?? <String, dynamic>{};
    final payload = root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    final token = payload['token'] as String?;

    if (token != null && token.isNotEmpty) {
      await _setToken(token);
      await bindCurrentUser();
    }
  }

  static Future<Map<String, dynamic>> updateOnboarding({
    String? nickname,
    String? pronouns,
    String? birthday,
    String? persona,
    List<String>? interests,
    bool complete = false,
  }) async {
    final res = await authedPut<Map<String, dynamic>>(
      Endpoints.onboardingUpdate,
      data: <String, dynamic>{
        'nickname': ?nickname,
        'pronouns': ?pronouns,
        'birthday': ?birthday,
        'persona': ?persona,
        'interests': ?interests,
        if (complete) 'complete': true,
      },
    );
    final root = res.data ?? <String, dynamic>{};
    return root['data'] is Map<String, dynamic>
        ? root['data'] as Map<String, dynamic>
        : <String, dynamic>{};
  }

  static Future<Response<T>> authedGet<T>(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final token = await getToken();
    final client = ApiClient(token: token);
    return client.get<T>(path, query: query);
  }

  static Future<Response<T>> authedPost<T>(
    String path, {
    Object? data,
  }) async {
    final token = await getToken();
    final client = ApiClient(token: token);
    return client.post<T>(path, data: data);
  }

  static Future<Response<T>> authedPut<T>(
    String path, {
    Object? data,
  }) async {
    final token = await getToken();
    final client = ApiClient(token: token);
    return client.put<T>(path, data: data);
  }

  static Future<Response<T>> authedDelete<T>(String path) async {
    final token = await getToken();
    final client = ApiClient(token: token);
    return client.delete<T>(path);
  }
}
