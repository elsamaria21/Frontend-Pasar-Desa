import 'package:drift/drift.dart';

@DataClassName('ProductEntry')
class ProductsTable extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();
  TextColumn get seller => text()();
  TextColumn get category => text()();
  IntColumn get price => integer()();
  TextColumn get unit => text()();
  TextColumn get image => text()();
  RealColumn get rating => real()();
  IntColumn get stock => integer()();

  IntColumn get lastFetched => integer().named('last_fetched')();

  @override
  Set<Column> get primaryKey => {id};
}
