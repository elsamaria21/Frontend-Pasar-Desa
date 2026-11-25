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
    _subscription = _repository.watchOrders().listen(
      (dbOrders) {
        _orders = dbOrders;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Gagal memuat riwayat pesanan lokal: $error');
      },
    );
  }

  Future<void> addOrder(OrderEntry order) async {
    if (!_orders.any((existing) => existing.id == order.id)) {
      _orders.insert(0, order);
      notifyListeners();
    }

    try {
      await _repository.saveOrder(order);
    } catch (error) {
      debugPrint('Gagal menyimpan pesanan ke database: $error');
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
    String voucherCode = '',
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
      voucherCode: voucherCode,
    );
  }

  Future<void> batalkanDiServer(int serverId) {
    return _repository.cancelOnServer(serverId);
  }

  Future<void> terimaPesanan(String kode) => _repository.receiveOnServer(kode);

  Future<void> batalkanPesanan(String kode) async {
    await _repository.cancelByCode(kode);
  }

  Future<void> syncFromServer() async {
    try {
      await _repository.syncFromServer();
    } catch (error) {
      debugPrint('Gagal sinkron pesanan: $error');
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
