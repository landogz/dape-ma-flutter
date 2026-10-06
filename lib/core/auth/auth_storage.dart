import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static const _tokenKey = 'dape_ma_token';
  static const _userIdKey = 'dape_ma_user_id';

  /// Android Keystore / EncryptedSharedPreferences can hang or throw on some
  /// devices after reinstall; prefer encrypted prefs with reset-on-error.
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (error, stack) {
      debugPrint('[AuthStorage] saveToken failed: $error\n$stack');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (error, stack) {
      debugPrint('[AuthStorage] getToken failed: $error\n$stack');
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (error, stack) {
      debugPrint('[AuthStorage] clearToken failed: $error\n$stack');
    }
  }

  static Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (error, stack) {
      debugPrint('[AuthStorage] saveUserId failed: $error\n$stack');
    }
  }

  static Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (error, stack) {
      debugPrint('[AuthStorage] getUserId failed: $error\n$stack');
      return null;
    }
  }

  static Future<void> clearUserId() async {
    try {
      await _storage.delete(key: _userIdKey);
    } catch (error, stack) {
      debugPrint('[AuthStorage] clearUserId failed: $error\n$stack');
    }
  }
}
