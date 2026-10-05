import 'package:flutter/foundation.dart';
import '../screens/order_models.dart';

class OrderProvider extends ChangeNotifier {
  final List<OrderEntry> _orders = [];

  List<OrderEntry> get orders => List<OrderEntry>.unmodifiable(_orders);

  void addOrder(OrderEntry order) {
    _orders.insert(0, order);
    notifyListeners();
  }

  void clear() {
    _orders.clear();
    notifyListeners();
  }
}

final OrderProvider orderStore = OrderProvider();
