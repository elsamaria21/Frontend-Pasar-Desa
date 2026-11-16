class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static String get api => '$baseUrl/api';
  static const Duration timeout = Duration(seconds: 15);

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
