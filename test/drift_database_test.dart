import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pasar_desa_umkm/data/local/db/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift Local Database & Persistence Tests (Tugas #9)', () {
    test(
        '1. Dapat menyimpan produk secara atomik dan membaca via .watch() reactive stream',
        () async {
      final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch;

      final companions = [
        ProductsTableCompanion.insert(
          id: 'beras_test',
          name: 'Beras Rojolele Sukorejo',
          shortName: 'Beras Rojolele',
          seller: 'Kelompok Tani Barat',
          category: 'Hasil Tani',
          price: 65000,
          unit: '5 kg',
          image: 'assets/images/beras.png',
          rating: 4.9,
          stock: 25,
          lastFetched: nowMillis,
        ),
        ProductsTableCompanion.insert(
          id: 'jagung_test',
          name: 'Jagung Pipil Kering',
          shortName: 'Jagung Pipil',
          seller: 'Pak Slamet',
          category: 'Hasil Tani',
          price: 9000,
          unit: '1 kg',
          image: 'assets/images/jagung.png',
          rating: 4.7,
          stock: 50,
          lastFetched: nowMillis,
        ),
      ];

      await db.upsertProductsAtomic(companions);

      final streamResult = await db.watchAllProducts().first;

      expect(streamResult.length, 2);
      expect(streamResult[0].id, 'beras_test');
      expect(streamResult[0].lastFetched, nowMillis);
      expect(streamResult[1].id, 'jagung_test');

      final latestTs = await db.getLatestCacheTimestamp();
      expect(latestTs, nowMillis);
    });

    test('2. Dapat menyimpan pesanan baru secara atomik dengan relasi item',
        () async {
      final dbOrder = DbOrder(
        id: '#ORD-TEST-001',
        seller: 'Kelompok Tani Krajan',
        dateLabel: '19 Okt 2026 • 10:00 WIB',
        status: 'diproses',
        total: 68000,
        paymentLabel: 'QRIS BUMDes',
        receiverName: 'Elsa Maria',
        receiverPhone: '081234567890',
        deliveryAddress: 'Dusun Krajan RT 01',
        deliveryNote: 'Dekat gapura',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      final items = [
        OrderItemsTableCompanion.insert(
          orderId: '#ORD-TEST-001',
          name: 'Beras Pandan Wangi',
          variant: '5 kg',
          price: 68000,
          qty: 1,
          image: 'assets/images/beras.png',
        ),
      ];

      await db.insertOrderAtomic(order: dbOrder, items: items);

      final orders = await db.watchOrders().first;
      expect(orders.length, 1);
      expect(orders.first.id, '#ORD-TEST-001');

      final orderItems = await db.getItemsForOrder('#ORD-TEST-001');
      expect(orderItems.length, 1);
      expect(orderItems.first.name, 'Beras Pandan Wangi');
    });
  });
}
