import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/order_repository.dart';
import '../screens/order_models.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;
  StreamSubscription<List<OrderEntry>>? _subscription;

  List<OrderEntry> _orders = [];

  OrderProvider({OrderRepository? repository})
      : _repository = repository ?? OrderRepository() {
    _init();
  }

  List<OrderEntry> get orders => List<OrderEntry>.unmodifiable(_orders);

  void _init() {
    _subscription = _repository.watchOrders().listen((dbOrders) {
      _orders = dbOrders;
      notifyListeners();
    });
  }

  Future<void> addOrder(OrderEntry order) async {
    if (!_orders.any((o) => o.id == order.id)) {
      _orders.insert(0, order);
      notifyListeners();
    }

    try {
      await _repository.saveOrder(order);
    } catch (e) {
      debugPrint('Gagal menyimpan pesanan ke database: $e');
    }
  }

  void clear() {
    _orders.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final OrderProvider orderStore = OrderProvider();
