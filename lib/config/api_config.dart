/// Konfigurasi koneksi ke backend PasarDesa (Express + MySQL).
///
/// Alamat dasar diatur saat build/run, tanpa mengubah kode:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000
///
/// Bawaan `10.0.2.2` = localhost komputer dari dalam emulator Android.
/// Perangkat fisik harus memakai IP LAN komputer (satu Wi-Fi dengan server).
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static String get api => '$baseUrl/api';

  static const Duration timeout = Duration(seconds: 15);

  /// Backend menyimpan URL foto sebagai alamat absolut dengan host milik
  /// pengunggah (mis. `http://localhost:3000/uploads/products/x.jpg` dari
  /// dashboard web). Host itu tidak terjangkau dari ponsel, jadi bagian
  /// `/uploads/...` diambil lalu disambung ke [baseUrl].
  static String resolveMediaUrl(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return '';

    final idx = value.indexOf('/uploads/');
    if (idx >= 0) return '$baseUrl${value.substring(idx)}';

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('assets/')) return value;

    return '$baseUrl/${value.startsWith('/') ? value.substring(1) : value}';
  }
}
