import '../local/storage/app_preferences.dart';
import '../local/storage/secure_storage_service.dart';
import '../remote/api_service.dart';

class AuthRepository {
  final SecureStorageService _secureStorage;
  final ApiService _api;

  /// Masa berlaku token dari backend (JWT 7 hari).
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
    final data = await _api.login(email: email, password: password);

    await _secureStorage.saveAuthSession(
      accessToken: data['token'] as String,
      userId: '${data['id']}',
      userEmail: (data['email'] ?? email) as String,
      userName: (data['name'] ?? '') as String,
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

  /// Mendaftarkan akun baru. Sesi tidak disimpan: setelah berhasil pengguna
  /// diarahkan ke layar login (alur yang sudah ada di aplikasi).
  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = await _api.register(
      name: name,
      email: email,
      password: password,
    );

    // Endpoint register belum menyimpan nomor telepon; simpan lewat profil.
    // Gagal di langkah ini tidak membatalkan akun yang sudah terbentuk.
    try {
      await _api.updateProfile(
        name: name,
        phone: phone,
        token: data['token'] as String?,
      );
    } catch (_) {}
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
