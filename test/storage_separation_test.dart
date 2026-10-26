import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pasar_desa_umkm/data/local/storage/app_preferences.dart';
import 'package:pasar_desa_umkm/data/local/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Separation of Storage Concerns Tests (Requirement 2 & 3)', () {
    test(
        '1. SharedPreferences hanya menyimpan data preferensi kecil dan non-sensitif',
        () async {
      final prefs = await AppPreferences.getInstance();

      await prefs.setRememberEmail(true);
      await prefs.setSavedEmail('elsafe@gmail.com');
      await prefs.setNotificationsEnabled(true);
      await prefs.setDarkMode(false);
      await prefs.setLastSelectedCategory('Hasil Tani');

      expect(prefs.rememberEmail, true);
      expect(prefs.savedEmail, 'elsafe@gmail.com');
      expect(prefs.notificationsEnabled, true);
      expect(prefs.isDarkMode, false);
      expect(prefs.lastSelectedCategory, 'Hasil Tani');

      final rawPrefs = await SharedPreferences.getInstance();
      expect(rawPrefs.containsKey('sec_access_token'), false);
      expect(rawPrefs.containsKey('access_token'), false);
      expect(rawPrefs.containsKey('jwt_token'), false);
    });

    test(
        '2. FlutterSecureStorage menyimpan access token, refresh token, dan kredensial sensitif',
        () async {
      final secure = SecureStorageService.instance;

      await secure.saveAuthSession(
        accessToken: 'mock_jwt_access_token_12345',
        refreshToken: 'mock_jwt_refresh_token_67890',
        userId: 'usr_elsa_2026',
        userEmail: 'elsafe@gmail.com',
        userName: 'Elsa Maria',
        expiresInSeconds: 3600,
      );

      final token = await secure.getAccessToken();
      final refresh = await secure.getRefreshToken();
      final email = await secure.getUserEmail();
      final isValid = await secure.hasValidToken();

      expect(token, 'mock_jwt_access_token_12345');
      expect(refresh, 'mock_jwt_refresh_token_67890');
      expect(email, 'elsafe@gmail.com');
      expect(isValid, true);

      await secure.clearAuthSession();
      final afterLogoutToken = await secure.getAccessToken();
      final isStillValid = await secure.hasValidToken();

      expect(afterLogoutToken, null);
      expect(isStillValid, false);
    });
  });
}
