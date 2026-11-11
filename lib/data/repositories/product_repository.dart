import '../../config/api_config.dart';
import '../../models/product.dart';
import '../local/db/app_database.dart';
import '../remote/api_service.dart';

class ProductRepository {
  final AppDatabase _db;
  final ApiService _api;

  static const Duration cacheValidityDuration = Duration(minutes: 5);

  ProductRepository({AppDatabase? db, ApiService? api})
      : _db = db ?? appDatabase,
        _api = api ?? ApiService.instance;

  Product _entryToModel(ProductEntry entry) {
    return Product(
      id: entry.id,
      name: entry.name,
      shortName: entry.shortName,
      seller: entry.seller,
      category: entry.category,
      price: entry.price,
      unit: entry.unit,
      image: entry.image,
      rating: entry.rating,
      stock: entry.stock,
    );
  }

  Stream<List<Product>> watchProducts() {
    return _db.watchAllProducts().map(
          (entries) => entries.map(_entryToModel).toList(),
        );
  }

  Stream<List<Product>> watchProductsByCategory(String category) {
    return _db.watchProductsByCategory(category).map(
          (entries) => entries.map(_entryToModel).toList(),
        );
  }

  Future<List<Product>> getCachedProducts() async {
    final entries = await _db.getAllProducts();
    return entries.map(_entryToModel).toList();
  }

  Future<DateTime?> getLastCacheTime() async {
    final millis = await _db.getLatestCacheTimestamp();
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
  }

  /// mysql2 mengirim kolom DECIMAL sebagai teks ("68000.00"), jadi nilai
  /// numerik dibaca lewat toString().
  static double _angka(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('${value ?? ''}') ?? 0;
  }

  static String _teks(dynamic value, String fallback) {
    final text = '${value ?? ''}'.trim();
    return text.isEmpty ? fallback : text;
  }

  ProductsTableCompanion _toCompanion(Map<String, dynamic> row, int fetchedAt) {
    final name = _teks(row['name'], 'Produk');
    final unit = _teks(row['unit'], 'kg');

    return ProductsTableCompanion.insert(
      id: '${row['id']}',
      name: name,
      shortName: name,
      seller: _teks(row['penjual'] ?? row['sumber'], 'BUMDes Sukorejo'),
      category: _teks(row['category_name'], 'Lainnya'),
      price: _angka(row['price']).round(),
      unit: _teks(row['ukuran'], unit),
      image: ApiConfig.resolveMediaUrl(row['image'] as String?),
      // Backend belum menyimpan rating produk.
      rating: 0,
      stock: _angka(row['stock']).floor(),
      lastFetched: fetchedAt,
    );
  }

  Future<bool> syncProducts({bool forceRefresh = false}) async {
    try {
      final latestMillis = await _db.getLatestCacheTimestamp();
      final nowUtcMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

      if (!forceRefresh && latestMillis != null) {
        final cacheAge = Duration(milliseconds: nowUtcMillis - latestMillis);
        if (cacheAge < cacheValidityDuration) {
          return true;
        }
      }

      final rows = await _api.fetchProducts();
      final companions = rows.map((r) => _toCompanion(r, nowUtcMillis)).toList();

      await _db.replaceProductsAtomic(companions);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    await _db.clearProductsCache();
  }
}
