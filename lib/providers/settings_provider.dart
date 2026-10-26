import 'package:flutter/foundation.dart';
import '../data/local/storage/app_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  AppPreferences? _prefs;

  bool _notificationsEnabled = true;
  bool _isDarkMode = false;
  String _lastCategory = 'Semua';
  bool _isInitialized = false;

  SettingsProvider() {
    _init();
  }

  bool get notificationsEnabled => _notificationsEnabled;
  bool get isDarkMode => _isDarkMode;
  String get lastCategory => _lastCategory;
  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    _prefs = await AppPreferences.getInstance();
    _notificationsEnabled = _prefs!.notificationsEnabled;
    _isDarkMode = _prefs!.isDarkMode;
    _lastCategory = _prefs!.lastSelectedCategory;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();
    await _prefs?.setNotificationsEnabled(value);
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();
    await _prefs?.setDarkMode(value);
  }

  Future<void> setLastCategory(String category) async {
    _lastCategory = category;
    notifyListeners();
    await _prefs?.setLastSelectedCategory(category);
  }
}
