import '../local/storage/app_preferences.dart';
import '../local/storage/secure_storage_service.dart';
import '../remote/mock_api_service.dart';

class AuthRepository {
  final SecureStorageService _secureStorage;
  final MockApiService _api;

  AuthRepository({
    SecureStorageService? secureStorage,
    MockApiService? api,
  })  : _secureStorage = secureStorage ?? SecureStorageService.instance,
        _api = api ?? MockApiService.instance;

  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasValidToken();
  }

  Future<Map<String, String?>> getCurrentUserSession() async {
    final userId = await _secureStorage.getUserId();
    final userEmail = await _secureStorage.getUserEmail();
    final userName = await _secureStorage.getUserName();
    final accessToken = await _secureStorage.getAccessToken();

    return {
      'userId': userId,
      'email': userEmail,
      'name': userName,
      'accessToken': accessToken,
    };
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberEmail,
  }) async {
    final response = await _api.login(email: email, password: password);
    final accessToken = response['access_token'] as String;
    final refreshToken = response['refresh_token'] as String;
    final user = response['user'] as Map<String, dynamic>;
    final expiresIn = response['expires_in'] as int?;

    await _secureStorage.saveAuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user['id'] as String,
      userEmail: user['email'] as String,
      userName: user['name'] as String,
      expiresInSeconds: expiresIn,
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
