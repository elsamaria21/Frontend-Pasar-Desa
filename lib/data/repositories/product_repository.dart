import '../local/db/app_database.dart';
import '../remote/mock_api_service.dart';
import '../../models/product.dart';

class ProductRepository {
  final AppDatabase _db;
  final MockApiService _api;

  static const Duration cacheValidityDuration = Duration(minutes: 5);

  ProductRepository({AppDatabase? db, MockApiService? api})
      : _db = db ?? appDatabase,
        _api = api ?? MockApiService.instance;

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

      final rawList = await _api.fetchProducts();

      final companions = rawList.map((map) {
        return ProductsTableCompanion.insert(
          id: map['id'] as String,
          name: map['name'] as String,
          shortName: map['shortName'] as String,
          seller: map['seller'] as String,
          category: map['category'] as String,
          price: map['price'] as int,
          unit: map['unit'] as String,
          image: map['image'] as String,
          rating: (map['rating'] as num).toDouble(),
          stock: map['stock'] as int,
          lastFetched: nowUtcMillis,
        );
      }).toList();

      await _db.upsertProductsAtomic(companions);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearCache() async {
    await _db.clearProductsCache();
  }
}
