import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static const _tokenKey = 'dape_ma_token';
  static const _userIdKey = 'dape_ma_user_id';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }

  static Future<void> saveUserId(String userId) {
    return _storage.write(key: _userIdKey, value: userId);
  }

  static Future<String?> getUserId() {
    return _storage.read(key: _userIdKey);
  }

  static Future<void> clearUserId() {
    return _storage.delete(key: _userIdKey);
  }
}
