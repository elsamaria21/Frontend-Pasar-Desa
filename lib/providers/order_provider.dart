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

  Future<ServerOrder> kirimPesanan({
    required List<OrderItemInput> items,
    required String receiverName,
    required String receiverPhone,
    required String address,
    required String delivery,
    required String paymentMethod,
    String landmark = '',
    String note = '',
  }) {
    return _repository.createOnServer(
      items: items,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      address: address,
      delivery: delivery,
      paymentMethod: paymentMethod,
      landmark: landmark,
      note: note,
    );
  }

  Future<void> batalkanDiServer(int serverId) async {
    try {
      await _repository.cancelOnServer(serverId);
    } catch (e) {
      debugPrint('Gagal membatalkan pesanan di server: $e');
    }
  }

  Future<void> batalkanPesanan(String kode) async {
    await _repository.cancelByCode(kode);
  }

  Future<void> syncFromServer() async {
    try {
      await _repository.syncFromServer();
    } catch (e) {
      debugPrint('Gagal sinkron pesanan: $e');
    }
  }

  Future<void> clearLocal() async {
    _orders = [];
    notifyListeners();
    await _repository.clearLocal();
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
