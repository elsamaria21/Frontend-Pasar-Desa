import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/order_repository.dart';
import '../screens/order_models.dart';

class OrderProvider extends ChangeNotifier {
  final OrderRepository _repository;
  StreamSubscription<List<OrderEntry>>? _subscription;
  Timer? _autoSync;
  bool _syncing = false;

  static const Duration _autoSyncInterval = Duration(seconds: 20);

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

  Future<void> terimaPesanan(String kode) => _repository.receiveOnServer(kode);

  Future<void> batalkanPesanan(String kode) async {
    await _repository.cancelByCode(kode);
  }

  Future<void> syncFromServer() async {
    if (_syncing) return;
    _syncing = true;
    try {
      await _repository.syncFromServer();
    } catch (e) {
      debugPrint('Gagal sinkron pesanan: $e');
    } finally {
      _syncing = false;
    }
  }

  /// Menyegarkan pesanan dari server secara berkala selama pembeli login, supaya perubahan dari
  /// dashboard penjual (dikemas, siap diambil, dll.) dan hasil pembayaran Midtrans tampil sendiri.
  /// Aman dipanggil berulang.
  void startAutoSync() {
    if (_autoSync != null) return;
    unawaited(syncFromServer());
    _autoSync = Timer.periodic(_autoSyncInterval, (_) => syncFromServer());
  }

  void stopAutoSync() {
    _autoSync?.cancel();
    _autoSync = null;
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
    stopAutoSync();
    _subscription?.cancel();
    super.dispose();
  }
}

final OrderProvider orderStore = OrderProvider();