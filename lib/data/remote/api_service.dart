import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/api_config.dart';
import '../local/storage/secure_storage_service.dart';

/// Galat dari server maupun jaringan. [message] sudah berbahasa Indonesia dan
/// aman ditampilkan langsung ke pengguna.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Klien HTTP tunggal untuk backend. Semua respons backend berbentuk
/// `{ success, message?, data }`; kelas ini membuka `data` atau melempar
/// [ApiException] dengan pesan dari server.
class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  final http.Client _client = http.Client();

  /// Dipanggil saat server menolak token (401) pada permintaan yang memakai
  /// token. AuthProvider memakainya untuk mengeluarkan pengguna.
  void Function()? onUnauthorized;

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
    bool auth = true,
    String? token,
  }) async {
    final uri = Uri.parse('${ApiConfig.api}$path').replace(
      queryParameters: query,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
    };

    String? usedToken;
    if (auth) {
      usedToken = token ?? await SecureStorageService.instance.getAccessToken();
      if (usedToken != null && usedToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $usedToken';
      }
    }

    final http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);

      final streamed = await _client.send(request).timeout(ApiConfig.timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const ApiException(
        'Server terlalu lama merespons. Periksa sinyal Anda lalu coba lagi.',
      );
    } on SocketException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    }

    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {
      json = null;
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;

    if (ok && json != null && json['success'] != false) {
      return json['data'];
    }

    if (response.statusCode == 401 && usedToken != null && auth) {
      onUnauthorized?.call();
    }

    final message = json?['message'];
    throw ApiException(
      message is String && message.isNotEmpty
          ? message
          : 'Terjadi kesalahan pada server (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  // ---------------------------------------------------------------- Auth

  /// POST /auth/login -> { id, name, email, role, token }
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await _send(
      'POST',
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  /// POST /auth/register -> { id, name, email, role, token }
  /// Backend hanya menerima name, email, password (telepon lewat profil).
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final data = await _send(
      'POST',
      '/auth/register',
      body: {'name': name, 'email': email, 'password': password},
      auth: false,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  /// PUT /users/profile. [token] dipakai saat sesi belum disimpan
  /// (tepat setelah registrasi).
  Future<void> updateProfile({
    required String name,
    String? phone,
    String? token,
  }) async {
    await _send(
      'PUT',
      '/users/profile',
      body: {'name': name, 'phone': phone},
      token: token,
    );
  }

  // ------------------------------------------------------------ Katalog

  /// GET /products (publik; hanya produk yang tampil).
  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final data = await _send('GET', '/products', auth: false);
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ------------------------------------------------------------ Pesanan

  /// POST /orders -> { id, kode, total, status }
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) async {
    final data = await _send('POST', '/orders', body: payload);
    return Map<String, dynamic>.from(data as Map);
  }

  /// GET /orders -> pesanan milik akun yang login, lengkap dengan items.
  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    final data = await _send('GET', '/orders');
    return (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// PATCH /orders/:id/status -> membatalkan pesanan (stok dikembalikan).
  /// Server hanya mengizinkan saat status masih pending / perlu-dikemas.
  Future<void> cancelOrder(int id) async {
    await _send('PATCH', '/orders/$id/status', body: {'status': 'dibatalkan'});
  }
}
