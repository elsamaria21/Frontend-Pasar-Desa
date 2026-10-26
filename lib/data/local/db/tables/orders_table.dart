import 'package:drift/drift.dart';

@DataClassName('DbOrder')
class OrdersTable extends Table {
  TextColumn get id => text()();
  TextColumn get seller => text()();
  TextColumn get dateLabel => text()();
  TextColumn get status => text()();
  IntColumn get total => integer()();
  TextColumn get paymentLabel => text()();
  TextColumn get courierTitle => text().nullable()();
  TextColumn get courierInfo => text().nullable()();
  TextColumn get receiverName => text()();
  TextColumn get receiverPhone => text()();
  TextColumn get deliveryAddress => text()();
  TextColumn get deliveryNote => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DbOrderItem')
class OrderItemsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orderId => text().references(OrdersTable, #id)();
  TextColumn get name => text()();
  TextColumn get variant => text()();
  IntColumn get price => integer()();
  IntColumn get qty => integer()();
  TextColumn get image => text()();
}
