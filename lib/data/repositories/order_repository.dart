import '../../screens/order_models.dart';
import '../local/db/app_database.dart';
import '../remote/api_service.dart';

/// Satu baris belanja yang dikirim ke server. Harga tidak dikirim: server
/// menghitungnya dari tabel produk.
class OrderItemInput {
  final String productId;
  final int quantity;

  const OrderItemInput({required this.productId, required this.quantity});
}

/// Hasil POST /orders.
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

  // ------------------------------------------------------------- Server

  /// Membuat pesanan di server. Stok dikurangi dan kode pesanan dibuat server.
  Future<ServerOrder> createOnServer({
    required List<OrderItemInput> items,
    required String receiverName,
    required String receiverPhone,
    required String address,
    required String delivery, // 'kurir-desa' | 'ambil-mandiri'
    required String paymentMethod,
    String landmark = '',
    String note = '',
  }) async {
    final data = await _api.createOrder({
      'pembeli': receiverName,
      'telepon': receiverPhone,
      'alamat': address,
      'opsiPengiriman': delivery,
      'metodeBayar': paymentMethod,
      if (landmark.isNotEmpty) 'patokan': landmark,
      if (note.isNotEmpty) 'catatan': note,
      'items': items
          .map((i) => {
                'productId': int.tryParse(i.productId) ?? i.productId,
                'jumlah': i.quantity,
              })
          .toList(),
    });

    return ServerOrder(
      id: _int(data['id']),
      kode: '${data['kode']}',
      total: _int(data['total']),
      status: '${data['status']}',
    );
  }

  Future<void> cancelOnServer(int serverId) => _api.cancelOrder(serverId);

  /// Membatalkan berdasarkan kode pesanan (yang dikenal layar riwayat).
  Future<void> cancelByCode(String kode) async {
    final rows = await _api.fetchMyOrders();
    final match = rows.where((r) => '${r['order_code']}' == kode);
    if (match.isEmpty) {
      throw const ApiException('Pesanan tidak ditemukan di server.');
    }
    await _api.cancelOrder(_int(match.first['id']));
    await syncFromServer();
  }

  /// Mengambil riwayat pesanan akun ini dari server dan menggantikan cache.
  Future<void> syncFromServer() async {
    final rows = await _api.fetchMyOrders();

    final catalog = {
      for (final p in await _db.getAllProducts()) p.id: p.image,
    };

    final orders = <DbOrder>[];
    final items = <OrderItemsTableCompanion>[];

    for (final row in rows) {
      final kode = '${row['order_code']}';
      final created = DateTime.tryParse('${row['created_at']}')?.toLocal() ??
          DateTime.now();

      orders.add(DbOrder(
        id: kode,
        seller: 'PasarDesa Sukorejo',
        dateLabel: _dateLabel(created),
        status: statusFromServer('${row['status']}').name,
        total: _int(row['total']),
        paymentLabel: '${row['payment_method'] ?? '-'}',
        courierTitle: null,
        courierInfo: null,
        receiverName: '${row['customer_name'] ?? ''}',
        receiverPhone: '${row['phone'] ?? ''}',
        deliveryAddress: '${row['address'] ?? ''}',
        deliveryNote: '${row['notes'] ?? ''}',
        createdAt: created.millisecondsSinceEpoch,
      ));

      for (final item in (row['items'] as List? ?? const [])) {
        final m = Map<String, dynamic>.from(item as Map);
        items.add(OrderItemsTableCompanion.insert(
          orderId: kode,
          name: '${m['product_name']}',
          variant: '',
          price: _int(m['price']),
          qty: _int(m['quantity']),
          image: catalog['${m['product_id']}'] ?? '',
        ));
      }
    }

    await _db.replaceOrdersAtomic(orders: orders, items: items);
  }

  Future<void> clearLocal() => _db.clearOrders();

  // ------------------------------------------------------------ Helper

  /// Status server (9 nilai) -> status yang dipahami layar mobile (4 nilai).
  static OrderStatus statusFromServer(String status) {
    switch (status) {
      case 'selesai':
        return OrderStatus.selesai;
      case 'dibatalkan':
        return OrderStatus.dibatalkan;
      case 'dikirim':
      case 'diantar':
      case 'tiba-di-pos':
      case 'komplain':
        return OrderStatus.dikirim;
      default: // pending, perlu-dikemas, diproses, sedang-dikemas, siap-jemput
        return OrderStatus.diproses;
    }
  }

  static int _int(dynamic v) {
    if (v is num) return v.round();
    return double.tryParse('${v ?? ''}')?.round() ?? 0;
  }

  static String _dateLabel(DateTime d) {
    const bulan = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.day} ${bulan[d.month - 1]} ${d.year} • ${two(d.hour)}:${two(d.minute)} WIB';
  }
}