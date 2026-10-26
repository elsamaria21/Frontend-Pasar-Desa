import '../local/db/app_database.dart';
import '../../screens/order_models.dart';

class OrderRepository {
  final AppDatabase _db;

  OrderRepository({AppDatabase? db}) : _db = db ?? appDatabase;

  Stream<List<OrderEntry>> watchOrders() {
    return _db.watchOrders().asyncMap((dbOrders) async {
      final List<OrderEntry> result = [];
      for (final o in dbOrders) {
        final items = await _db.getItemsForOrder(o.id);
        final lines = items
            .map((i) => OrderLine(
                  name: i.name,
                  variant: i.variant,
                  price: i.price,
                  qty: i.qty,
                  image: i.image,
                ))
            .toList();

        final status = OrderStatus.values.firstWhere(
          (s) => s.name.toLowerCase() == o.status.toLowerCase(),
          orElse: () => OrderStatus.diproses,
        );

        result.add(OrderEntry(
          id: o.id,
          seller: o.seller,
          dateLabel: o.dateLabel,
          status: status,
          lines: lines,
          total: o.total,
          paymentLabel: o.paymentLabel,
          courierTitle: o.courierTitle,
          courierInfo: o.courierInfo,
          receiverName: o.receiverName,
          receiverPhone: o.receiverPhone,
          deliveryAddress: o.deliveryAddress,
          deliveryNote: o.deliveryNote,
        ));
      }
      return result;
    });
  }

  Future<void> saveOrder(OrderEntry order) async {
    final dbOrder = DbOrder(
      id: order.id,
      seller: order.seller,
      dateLabel: order.dateLabel,
      status: order.status.name,
      total: order.total,
      paymentLabel: order.paymentLabel,
      courierTitle: order.courierTitle,
      courierInfo: order.courierInfo,
      receiverName: order.receiverName,
      receiverPhone: order.receiverPhone,
      deliveryAddress: order.deliveryAddress,
      deliveryNote: order.deliveryNote,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    final itemCompanions = order.lines.map((l) {
      return OrderItemsTableCompanion.insert(
        orderId: order.id,
        name: l.name,
        variant: l.variant,
        price: l.price,
        qty: l.qty,
        image: l.image,
      );
    }).toList();

    await _db.insertOrderAtomic(
      order: dbOrder,
      items: itemCompanions,
    );
  }
}
