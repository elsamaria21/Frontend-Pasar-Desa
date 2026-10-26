import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static AppPreferences? _instance;
  static SharedPreferences? _prefs;

  AppPreferences._();

  static Future<AppPreferences> getInstance() async {
    _instance ??= AppPreferences._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  static const String _keyRememberEmail = 'pref_remember_email';
  static const String _keySavedEmail = 'pref_saved_email';
  static const String _keyNotifications = 'pref_notifications_enabled';
  static const String _keyDarkMode = 'pref_dark_mode_enabled';
  static const String _keyLastCategory = 'pref_last_selected_category';
  static const String _keyOnboardingDone = 'pref_onboarding_completed';

  bool get rememberEmail => _prefs?.getBool(_keyRememberEmail) ?? false;
  Future<bool> setRememberEmail(bool value) async {
    return await _prefs?.setBool(_keyRememberEmail, value) ?? false;
  }

  String get savedEmail => _prefs?.getString(_keySavedEmail) ?? '';
  Future<bool> setSavedEmail(String email) async {
    return await _prefs?.setString(_keySavedEmail, email) ?? false;
  }

  Future<void> clearSavedEmail() async {
    await _prefs?.remove(_keySavedEmail);
    await _prefs?.setBool(_keyRememberEmail, false);
  }

  bool get notificationsEnabled => _prefs?.getBool(_keyNotifications) ?? true;
  Future<bool> setNotificationsEnabled(bool value) async {
    return await _prefs?.setBool(_keyNotifications, value) ?? false;
  }

  bool get isDarkMode => _prefs?.getBool(_keyDarkMode) ?? false;
  Future<bool> setDarkMode(bool value) async {
    return await _prefs?.setBool(_keyDarkMode, value) ?? false;
  }

  String get lastSelectedCategory =>
      _prefs?.getString(_keyLastCategory) ?? 'Semua';
  Future<bool> setLastSelectedCategory(String category) async {
    return await _prefs?.setString(_keyLastCategory, category) ?? false;
  }

  bool get hasCompletedOnboarding =>
      _prefs?.getBool(_keyOnboardingDone) ?? false;
  Future<bool> setHasCompletedOnboarding(bool value) async {
    return await _prefs?.setBool(_keyOnboardingDone, value) ?? false;
  }

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
