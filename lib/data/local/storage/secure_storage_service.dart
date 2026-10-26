import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static SecureStorageService? _instance;
  late final FlutterSecureStorage _storage;

  SecureStorageService._() {
    _storage = const FlutterSecureStorage();
  }

  static SecureStorageService get instance {
    _instance ??= SecureStorageService._();
    return _instance!;
  }

  static const String _keyAccessToken = 'sec_access_token';
  static const String _keyRefreshToken = 'sec_refresh_token';
  static const String _keyUserId = 'sec_user_id';
  static const String _keyUserEmail = 'sec_user_email';
  static const String _keyUserName = 'sec_user_name';
  static const String _keyExpiresAt = 'sec_expires_at_millis';

  Future<void> saveAuthSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String userEmail,
    required String userName,
    int? expiresInSeconds,
  }) async {
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresInSeconds ?? 86400 * 7))
        .millisecondsSinceEpoch;

    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
    await _storage.write(key: _keyUserId, value: userId);
    await _storage.write(key: _keyUserEmail, value: userEmail);
    await _storage.write(key: _keyUserName, value: userName);
    await _storage.write(key: _keyExpiresAt, value: expiresAt.toString());
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: _keyUserEmail);
  }

  Future<String?> getUserName() async {
    return await _storage.read(key: _keyUserName);
  }

  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;

    final expStr = await _storage.read(key: _keyExpiresAt);
    if (expStr == null) return false;

    final expMillis = int.tryParse(expStr) ?? 0;
    final nowMillis = DateTime.now().millisecondsSinceEpoch;

    return nowMillis < expMillis;
  }

  Future<void> clearAuthSession() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyUserName);
    await _storage.delete(key: _keyExpiresAt);
  }

  Future<void> wipeAllSecrets() async {
    await _storage.deleteAll();
  }
}
