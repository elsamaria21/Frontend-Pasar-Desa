import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/products_table.dart';
import 'tables/orders_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ProductsTable, OrdersTable, OrderItemsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'pasar_desa_database');
  }

  Stream<List<ProductEntry>> watchAllProducts() {
    return select(productsTable).watch();
  }

  Stream<List<ProductEntry>> watchProductsByCategory(String category) {
    if (category.isEmpty || category.toLowerCase() == 'semua') {
      return watchAllProducts();
    }
    return (select(productsTable)
          ..where((tbl) => tbl.category.equals(category)))
        .watch();
  }

  Future<List<ProductEntry>> getAllProducts() {
    return select(productsTable).get();
  }

  Future<int?> getLatestCacheTimestamp() async {
    final query = selectOnly(productsTable)
      ..addColumns([productsTable.lastFetched.max()]);
    final result = await query.getSingleOrNull();
    return result?.read(productsTable.lastFetched.max());
  }

  Future<void> upsertProductsAtomic(
    List<ProductsTableCompanion> entries,
  ) async {
    await transaction(() async {
      await batch((b) {
        b.insertAllOnConflictUpdate(productsTable, entries);
      });
    });
  }

  Future<void> clearProductsCache() async {
    await delete(productsTable).go();
  }

  Stream<List<DbOrder>> watchOrders() {
    return (select(ordersTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<DbOrderItem>> getItemsForOrder(String orderId) {
    return (select(orderItemsTable)..where((t) => t.orderId.equals(orderId)))
        .get();
  }

  Future<void> insertOrderAtomic({
    required DbOrder order,
    required List<OrderItemsTableCompanion> items,
  }) async {
    await transaction(() async {
      await into(ordersTable).insertOnConflictUpdate(order);
      if (items.isNotEmpty) {
        await batch((b) {
          b.insertAll(orderItemsTable, items);
        });
      }
    });
  }
}

final AppDatabase appDatabase = AppDatabase();
