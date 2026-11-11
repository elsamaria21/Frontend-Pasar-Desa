import 'dart:async';

import 'package:flutter/foundation.dart';
import '../data/remote/api_service.dart';
import '../data/repositories/auth_repository.dart';
import 'order_provider.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isAuthenticated = false;
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, String?> _currentUser = {};
  bool _rememberEmail = false;
  String _savedEmail = '';

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    // Token ditolak server (kedaluwarsa / dicabut) -> keluarkan pengguna.
    ApiService.instance.onUnauthorized = () {
      if (_isAuthenticated) unawaited(logout());
    };
    _init();
  }

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, String?> get currentUser => _currentUser;
  bool get rememberEmail => _rememberEmail;
  String get savedEmail => _savedEmail;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    try {
      _rememberEmail = await _repository.getRememberEmailPreference();
      _savedEmail = await _repository.getRememberedEmail();

      final valid = await _repository.isAuthenticated();
      if (valid) {
        _isAuthenticated = true;
        _currentUser = await _repository.getCurrentUserSession();
      } else {
        _isAuthenticated = false;
        _currentUser = {};
      }
    } catch (_) {
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    required bool rememberEmail,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.login(
        email: email,
        password: password,
        rememberEmail: rememberEmail,
      );

      if (success) {
        _isAuthenticated = true;
        _rememberEmail = rememberEmail;
        _savedEmail = rememberEmail ? email : '';
        _currentUser = await _repository.getCurrentUserSession();
        unawaited(orderStore.syncFromServer());
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengembalikan `null` bila berhasil, atau pesan galat untuk ditampilkan.
  Future<String?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (_) {
      return 'Pendaftaran gagal. Silakan coba lagi.';
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _repository.logout();
    await orderStore.clearLocal();
    _isAuthenticated = false;
    _currentUser = {};
    _isLoading = false;
    notifyListeners();
  }

  void setRememberEmail(bool value) {
    _rememberEmail = value;
    notifyListeners();
  }
}
