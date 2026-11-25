import '../../screens/order_models.dart';
import '../local/db/app_database.dart';
import '../remote/api_service.dart';

class OrderItemInput {
  final String productId;
  final int quantity;

  const OrderItemInput({required this.productId, required this.quantity});
}

class ServerOrder {
  final int id;
  final String kode;
  final int total;
  final String status;

  const ServerOrder({
    required this.id,
    required this.kode,
    required this.total,
    required this.status,
  });
}

class OrderRepository {
  final AppDatabase _db;
  final ApiService _api;

  OrderRepository({AppDatabase? db, ApiService? api})
      : _db = db ?? appDatabase,
        _api = api ?? ApiService.instance;

  Stream<List<OrderEntry>> watchOrders() {
    return _db.watchOrders().asyncMap((dbOrders) async {
      final List<OrderEntry> result = [];

      for (final order in dbOrders) {
        final items = await _db.getItemsForOrder(order.id);
        final lines = items
            .map(
              (item) => OrderLine(
                name: item.name,
                variant: item.variant,
                price: item.price,
                qty: item.qty,
                image: item.image,
              ),
            )
            .toList();

        final status = OrderStatus.values.firstWhere(
          (value) => value.name.toLowerCase() == order.status.toLowerCase(),
          orElse: () => OrderStatus.diproses,
        );

        result.add(
          OrderEntry(
            id: order.id,
            seller: order.seller,
            dateLabel: order.dateLabel,
            status: status,
            lines: lines,
            total: order.total,
            paymentLabel: order.paymentLabel,
            courierTitle: order.courierTitle,
            courierInfo: order.courierInfo,
            receiverName: order.receiverName,
            receiverPhone: order.receiverPhone,
            deliveryAddress: order.deliveryAddress,
            deliveryNote: order.deliveryNote,
          ),
        );
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

    final itemCompanions = order.lines.map((line) {
      return OrderItemsTableCompanion.insert(
        orderId: order.id,
        name: line.name,
        variant: line.variant,
        price: line.price,
        qty: line.qty,
        image: line.image,
      );
    }).toList();

    await _db.insertOrderAtomic(
      order: dbOrder,
      items: itemCompanions,
    );
  }

  Future<ServerOrder> createOnServer({
    required List<OrderItemInput> items,
    required String receiverName,
    required String receiverPhone,
    required String address,
    required String delivery,
    required String paymentMethod,
    String landmark = '',
    String note = '',
    String voucherCode = '',
  }) async {
    final data = await _api.createOrder({
      'items': items
          .map(
            (item) => {
              'product_id': int.tryParse(item.productId) ?? item.productId,
              'quantity': item.quantity,
            },
          )
          .toList(),
      'address': address,
      'payment_method': paymentMethod,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'delivery_option': delivery,
      if (landmark.trim().isNotEmpty) 'landmark': landmark.trim(),
      if (note.trim().isNotEmpty) 'note': note.trim(),
      if (voucherCode.trim().isNotEmpty)
        'voucher_code': voucherCode.trim().toUpperCase(),
    });

    final id = _int(data['id'] ?? data['order_id']);
    if (id <= 0) {
      throw const ApiException(
        'Pesanan belum mendapatkan nomor dari server. Silakan periksa riwayat pesanan sebelum mencoba lagi.',
      );
    }

    final kode = _text(
      data['kode'] ?? data['order_code'],
      _makeOrderCode(id),
    );

    return ServerOrder(
      id: id,
      kode: kode,
      total: _int(data['total']),
      status: _text(data['status'], 'pending'),
    );
  }

  Future<void> cancelOnServer(int serverId) => _api.cancelOrder(serverId);

  Future<void> receiveOnServer(String kode) async {
    await _api.receiveOrder(kode);
    await syncFromServer();
  }

  Future<void> cancelByCode(String kode) async {
    final rows = await _api.fetchMyOrders();
    final target = kode.trim();

    Map<String, dynamic>? matched;
    for (final row in rows) {
      final id = _int(row['id'] ?? row['order_id']);
      final rowCode = _text(
        row['order_code'] ?? row['kode'],
        id > 0 ? _makeOrderCode(id) : '',
      );

      if (rowCode == target) {
        matched = row;
        break;
      }
    }

    if (matched == null) {
      throw const ApiException('Pesanan tidak ditemukan di server.');
    }

    final id = _int(matched['id'] ?? matched['order_id']);
    if (id <= 0) {
      throw const ApiException('ID pesanan dari server tidak valid.');
    }

    await _api.cancelOrder(id);
    await syncFromServer();
  }

  Future<void> syncFromServer() async {
    final rows = await _api.fetchMyOrders();

    final catalog = {
      for (final product in await _db.getAllProducts())
        product.id.toString(): product.image,
    };

    final orders = <DbOrder>[];
    final items = <OrderItemsTableCompanion>[];

    for (final row in rows) {
      final serverId = _int(row['id'] ?? row['order_id']);
      final kode = _text(
        row['order_code'] ?? row['kode'],
        serverId > 0 ? _makeOrderCode(serverId) : '',
      );

      if (kode.isEmpty) continue;

      final createdRaw = _text(
        row['created_at'] ?? row['createdAt'],
        '',
      );
      final created =
          DateTime.tryParse(createdRaw)?.toLocal() ?? DateTime.now();

      final rawItems = row['items'] ?? row['details'];
      final serverItems = rawItems is List ? rawItems : const <dynamic>[];

      orders.add(
        DbOrder(
          id: kode,
          seller: 'PasarDesa Sukorejo',
          dateLabel: _dateLabel(created),
          status: statusFromServer(_text(row['status'], 'pending')).name,
          total: _int(row['total']),
          paymentLabel: _text(row['payment_method'], '-'),
          courierTitle: _courierTitle(
            _text(row['delivery_option'] ?? row['delivery'], ''),
          ),
          courierInfo: null,
          receiverName: _text(
            row['customer_name'] ?? row['receiver_name'] ?? row['pembeli'],
            '',
          ),
          receiverPhone: _text(
            row['phone'] ?? row['receiver_phone'] ?? row['telepon'],
            '',
          ),
          deliveryAddress: _text(row['address'] ?? row['alamat'], ''),
          deliveryNote: _text(
            row['notes'] ?? row['note'] ?? row['catatan'],
            '',
          ),
          createdAt: created.millisecondsSinceEpoch,
        ),
      );

      for (final rawItem in serverItems) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);
        final productId = _text(item['product_id'] ?? item['productId'], '');

        items.add(
          OrderItemsTableCompanion.insert(
            orderId: kode,
            name: _text(
              item['product_name'] ?? item['name'],
              'Produk',
            ),
            variant: _text(item['variant'], ''),
            price: _int(item['price']),
            qty: _int(item['quantity'] ?? item['jumlah']),
            image: _text(
              item['image'],
              catalog[productId] ?? '',
            ),
          ),
        );
      }
    }

    await _db.replaceOrdersAtomic(
      orders: orders,
      items: items,
    );
  }

  Future<void> clearLocal() => _db.clearOrders();

  static OrderStatus statusFromServer(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return OrderStatus.selesai;
      case 'dibatalkan':
        return OrderStatus.dibatalkan;
      case 'dikirim':
      case 'diantar':
      case 'tiba-di-pos':
      case 'komplain':
        return OrderStatus.dikirim;
      default:
        return OrderStatus.diproses;
    }
  }

  static int _int(dynamic value) {
    if (value is num) return value.round();
    return int.tryParse('${value ?? ''}') ??
        double.tryParse('${value ?? ''}')?.round() ??
        0;
  }

  static String _text(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static String _makeOrderCode(int id) => 'PD-${id.toString().padLeft(6, '0')}';

  static String? _courierTitle(String delivery) {
    switch (delivery) {
      case 'kurir-desa':
        return 'Kurir Desa Sukorejo';
      case 'ambil-mandiri':
        return 'Ambil Mandiri di Pos BUMDes';
      default:
        return null;
    }
  }

  static String _dateLabel(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    String two(int value) => value.toString().padLeft(2, '0');

    return '${date.day} ${months[date.month - 1]} ${date.year} • '
        '${two(date.hour)}:${two(date.minute)} WIB';
  }
}
