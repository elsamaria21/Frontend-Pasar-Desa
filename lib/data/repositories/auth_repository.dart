import 'package:flutter/foundation.dart';
import '../local/storage/app_preferences.dart';
import '../local/storage/secure_storage_service.dart';
import '../remote/api_service.dart';

class AuthRepository {
  final SecureStorageService _secureStorage;
  final ApiService _api;

  static const int _tokenLifetimeSeconds = 7 * 24 * 60 * 60;

  AuthRepository({
    SecureStorageService? secureStorage,
    ApiService? api,
  })  : _secureStorage = secureStorage ?? SecureStorageService.instance,
        _api = api ?? ApiService.instance;

  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasValidToken();
  }

  Future<Map<String, String?>> getCurrentUserSession() async {
    final userId = await _secureStorage.getUserId();
    final userEmail = await _secureStorage.getUserEmail();
    final userName = await _secureStorage.getUserName();
    final userPhone = await _secureStorage.getUserPhone();
    final accessToken = await _secureStorage.getAccessToken();

    return {
      'userId': userId,
      'email': userEmail,
      'name': userName,
      'phone': userPhone,
      'accessToken': accessToken,
    };
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberEmail,
  }) async {
    final data = await _api.login(email: email, password: password);

    if (kDebugMode) {
      debugPrint('LOGIN RESPONSE: $data');
    }

    final phone = data['phone'];

    await _secureStorage.saveAuthSession(
      accessToken: data['token'] as String,
      userId: '${data['id']}',
      userEmail: (data['email'] ?? email) as String,
      userName: (data['name'] ?? '') as String,
      userPhone: phone == null ? '' : '$phone',
      expiresInSeconds: _tokenLifetimeSeconds,
    );

    final prefs = await AppPreferences.getInstance();
    await prefs.setRememberEmail(rememberEmail);
    if (rememberEmail) {
      await prefs.setSavedEmail(email);
    } else {
      await prefs.clearSavedEmail();
    }

    return true;
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _api.register(
      name: name,
      email: email,
      password: password,
      phone: phone,
    );
  }

  Future<void> logout() async {
    await _secureStorage.clearAuthSession();
  }

  Future<String> getRememberedEmail() async {
    final prefs = await AppPreferences.getInstance();
    if (prefs.rememberEmail) {
      return prefs.savedEmail;
    }
    return '';
  }

  Future<bool> getRememberEmailPreference() async {
    final prefs = await AppPreferences.getInstance();
    return prefs.rememberEmail;
  }
}
