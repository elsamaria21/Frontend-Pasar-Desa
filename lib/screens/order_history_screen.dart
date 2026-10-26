import 'package:flutter/material.dart';
import '../providers/order_provider.dart';
import 'order_models.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';
import 'order_flow_screens.dart';

const bool kShowDemoOrders = true;

class OrderHistoryScreen extends StatefulWidget {
  final bool embedded;

  const OrderHistoryScreen({
    super.key,
    this.embedded = false,
  });

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  static const _filters = ['SEMUA', 'Berjalan', 'Selesai', 'Dibatalkan'];

  static const Map<int, List<String>> _subLabels = {
    1: ['Semua Berjalan', 'Diproses', 'Sedang Dikirim'],
    2: ['Semua Selesai', 'Belum Diulas', 'Sudah Diulas'],
  };

  int _filter = 0;
  int _sub = 0;

  static const String _demoReviewedId = 'PSD-2026-D003';
  static bool _seeded = false;

  static const String _rcvName = 'Pak RT Joko';
  static const String _rcvPhone = '0812-3456-7890';
  static const String _rcvAddr =
      'Dusun Krajan RT 02 / RW 01 (Pos Drop-point BUMDes Depan Balai Desa Sukorejo)';

  static final List<OrderEntry> _demoOrders = [
    const OrderEntry(
      id: 'PSD-2026-D001',
      seller: 'Poktan Krajan Makmur',
      dateLabel: '20 Okt 2026 • 09:12 WIB',
      status: OrderStatus.dikirim,
      lines: [
        OrderLine(
          name: 'Beras Pandan Wangi',
          variant: 'Grade A • Panen Baru (BUMDes)',
          price: 68000,
          qty: 1,
          image: 'assets/images/beras.png',
        ),
        OrderLine(
          name: 'Jagung Manis Organik',
          variant: 'Kemasan Kuat 1kg',
          price: 24000,
          qty: 1,
          image: 'assets/images/jagung.png',
        ),
      ],
      total: 92000,
      paymentLabel: 'QRIS Lunas',
      courierTitle: 'Kurir Desa Sukorejo',
      courierInfo: 'Estimasi diantar sore ini (15:00 - 17:00 WIB)',
      receiverName: _rcvName,
      receiverPhone: _rcvPhone,
      deliveryAddress: _rcvAddr,
    ),
    const OrderEntry(
      id: 'PSD-2026-D006',
      seller: 'UMKM Dapur Sari',
      dateLabel: '20 Okt 2026 • 11:05 WIB',
      status: OrderStatus.diproses,
      lines: [
        OrderLine(
          name: 'Keripik Singkong',
          variant: 'Renyah Gurih • 250g',
          price: 18000,
          qty: 2,
          image: 'assets/images/keripik.png',
        ),
      ],
      total: 36000,
      paymentLabel: 'QRIS Lunas',
      courierTitle: 'Kurir Desa Sukorejo',
      courierInfo: 'Penjual sedang menyiapkan pesanan Anda',
      receiverName: _rcvName,
      receiverPhone: _rcvPhone,
      deliveryAddress: _rcvAddr,
    ),
    const OrderEntry(
      id: 'PSD-2026-D002',
      seller: 'KWT Sari Tani Sukorejo',
      dateLabel: '19 Okt 2026 • 10:30 WIB',
      status: OrderStatus.selesai,
      lines: [
        OrderLine(
          name: 'Cabai Rawit Merah',
          variant: 'Petik Pagi Segar Desa',
          price: 36000,
          qty: 1,
          image: 'assets/images/cabai.png',
        ),
      ],
      total: 36000,
      paymentLabel: 'Saldo Lunas',
      receiverName: _rcvName,
      receiverPhone: _rcvPhone,
      deliveryAddress: _rcvAddr,
    ),
    const OrderEntry(
      id: _demoReviewedId,
      seller: 'Peternak Mandiri Sukorejo',
      dateLabel: '12 Okt 2026 • 08:00 WIB',
      status: OrderStatus.selesai,
      lines: [
        OrderLine(
          name: 'Telur Ayam Kampung',
          variant: 'Bebas Kimia • 10 butir',
          price: 52000,
          qty: 1,
          image: 'assets/images/telur.png',
        ),
      ],
      total: 52000,
      paymentLabel: 'COD BUMDes',
      receiverName: _rcvName,
      receiverPhone: _rcvPhone,
      deliveryAddress: _rcvAddr,
    ),
    const OrderEntry(
      id: 'PSD-2026-D005',
      seller: 'Kebun Sayur Bu Warsi',
      dateLabel: '05 Okt 2026 • 07:45 WIB',
      status: OrderStatus.selesai,
      lines: [
        OrderLine(
          name: 'Bayam Hijau & Kangkung',
          variant: 'Paket Hemat Sayur • 2 ikat',
          price: 12000,
          qty: 1,
          image: 'assets/images/bayam.png',
        ),
      ],
      total: 12000,
      paymentLabel: 'Saldo Lunas',
      receiverName: _rcvName,
      receiverPhone: _rcvPhone,
      deliveryAddress: _rcvAddr,
    ),
    const OrderEntry(
      id: 'PSD-2026-D004',
      seller: 'Peternak Mandiri Sukorejo',
      dateLabel: '10 Okt 2026 • 14:20 WIB',
      status: OrderStatus.dibatalkan,
      lines: [
        OrderLine(
          name: 'Telur Ayam Kampung',
          variant: 'Bebas Kimia • 10 butir',
          price: 52000,
          qty: 1,
          image: 'assets/images/telur.png',
        ),
      ],
      total: 52000,
      paymentLabel: 'Transfer BUMDes Lunas',
      receiverName: _rcvName,
      receiverPhone: _rcvPhone,
      deliveryAddress: _rcvAddr,
    ),
  ];

  static void _seedDemoMeta() {
    if (_seeded) return;
    _seeded = true;

    for (final o in _demoOrders) {
      final m = orderMeta.metaOf(o.id);

      if (o.status == OrderStatus.selesai) {
        m.receivedAt = DateTime(2026, 10, 12, 9, 30);
      }

      if (o.id == _demoReviewedId) {
        m.reviewed = true;
        m.rating = 5;
        m.tags = ['Segar Petik Pagi', 'Sesuai Deskripsi'];
        m.note = 'Telurnya segar dan dikemas rapi. Terima kasih!';
        m.courierLiked = true;
      }

      if (o.status == OrderStatus.dibatalkan) {
        m.status = OrderStatus.dibatalkan;
        m.cancelReason = 'Salah memilih produk';
        m.cancelledAt = DateTime(2026, 10, 10, 14, 35);
        m.refundAmount = o.total;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (kShowDemoOrders) _seedDemoMeta();
    orderStore.addListener(_refresh);
    orderMeta.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    orderStore.removeListener(_refresh);
    orderMeta.removeListener(_refresh);
    super.dispose();
  }

  String _rp(int value) {
    final s = value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
    return 'Rp $s';
  }

  List<OrderEntry> get _allOrders => [
        ...orderStore.orders,
        if (kShowDemoOrders) ..._demoOrders,
      ];

  bool _match(OrderEntry o) {
    final st = orderMeta.statusOf(o);

    switch (_filter) {
      case 1:
        if (st != OrderStatus.diproses && st != OrderStatus.dikirim) {
          return false;
        }
        if (_sub == 1) return st == OrderStatus.diproses;
        if (_sub == 2) return st == OrderStatus.dikirim;
        return true;
      case 2:
        if (st != OrderStatus.selesai) return false;
        if (_sub == 1) return !orderMeta.isReviewed(o);
        if (_sub == 2) return orderMeta.isReviewed(o);
        return true;
      case 3:
        return st == OrderStatus.dibatalkan;
      default:
        return true;
    }
  }

  List<OrderEntry> get _orders => _allOrders.where(_match).toList();

  void _openDetail(OrderEntry o) {
    final st = orderMeta.statusOf(o);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => st == OrderStatus.dibatalkan
            ? CancelledOrderScreen(order: o)
            : OrderDetailScreen(order: o),
      ),
    );
  }

  void _openReview(OrderEntry o) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderReviewScreen(order: o)),
    );
  }

  void _openChat(OrderEntry o) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CourierChatScreen(order: o)),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Filter Pesanan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                for (int i = 0; i < _filters.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _filter = i;
                          _sub = 0;
                        });
                        Navigator.pop(sheetContext);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 13,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _filter == i
                              ? const Color(0xFFEAF7EF)
                              : const Color(0xFFF7FAF8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _filter == i
                                ? AppColors.green
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                i == 0 ? 'Semua Pesanan' : _filters[i],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (_filter == i)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.green,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickFilter(int i, BuildContext chipContext) async {
    final subs = _subLabels[i];

    // SEMUA & Dibatalkan: langsung pilih tanpa dropdown.
    if (subs == null) {
      setState(() {
        _filter = i;
        _sub = 0;
      });
      return;
    }

    final box = chipContext.findRenderObject() as RenderBox;
    final overlay =
        Overlay.of(chipContext).context.findRenderObject() as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final picked = await showMenu<int>(
      context: chipContext,
      position: position,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        for (int s = 0; s < subs.length; s++)
          PopupMenuItem<int>(
            value: s,
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    subs[s],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: (_filter == i && _sub == s)
                          ? FontWeight.w900
                          : FontWeight.w600,
                      color: (_filter == i && _sub == s)
                          ? AppColors.green
                          : AppColors.text,
                    ),
                  ),
                ),
                if (_filter == i && _sub == s)
                  const Icon(Icons.check_rounded,
                      size: 16, color: AppColors.green),
              ],
            ),
          ),
      ],
    );

    if (picked != null && mounted) {
      setState(() {
        _filter = i;
        _sub = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasAny = _allOrders.isNotEmpty;
    final orders = _orders;

    final content = Column(
      children: [
        const PasarDesaHeader(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 34,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Riwayat Pemesanan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Pantau transaksi hasil bumi & UMKM Sukorejo',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasAny)
                              InkWell(
                                onTap: _showFilterSheet,
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.tune,
                                          size: 16, color: AppColors.green),
                                      SizedBox(width: 4),
                                      Text(
                                        'Filter',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (!hasAny) _emptyState(),
                        if (hasAny) ...[
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(_filters.length, _chip),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (orders.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 60),
                              child: Center(
                                child: Text(
                                  'Belum ada pesanan di kategori ini.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ),
                          ...orders.map(_orderCard),
                        ],
                        const Spacer(),
                        const SizedBox(height: 16),
                        _guaranteeCard(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (!widget.embedded)
          BottomNav(
            current: 3,
            onTap: (i) => DashboardNav.goTo(context, i),
          ),
      ],
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(child: content),
    );
  }

  Widget _emptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 34,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum Ada Riwayat Pemesanan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Riwayat akan muncul setelah Anda menyelesaikan '
            'checkout pesanan pertama.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () => DashboardNav.goTo(context, 0),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Mulai Belanja',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(int i) {
    final selected = _filter == i;
    final hasArrow = _subLabels.containsKey(i);
    final subs = _subLabels[i];

    final label =
        (selected && subs != null && _sub > 0) ? subs[_sub] : _filters[i];

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Builder(
        builder: (chipContext) {
          return GestureDetector(
            onTap: () => _pickFilter(i, chipContext),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: selected ? AppColors.green : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.green : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.text,
                    ),
                  ),
                  if (hasArrow) ...[
                    const SizedBox(width: 3),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: selected ? Colors.white : AppColors.muted,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _orderCard(OrderEntry o) {
    final st = orderMeta.statusOf(o);
    final refund = orderMeta.metaOf(o.id).refundAmount;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openDetail(o),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.storefront_outlined,
                        size: 17,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          o.seller,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        size: 13,
                        color: AppColors.green,
                      ),
                      const Spacer(),
                      _statusChip(st),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          o.dateLabel,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      Text(
                        '#${o.id}',
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE5E9E6)),
                ...o.lines.map(_lineRow),
                if (o.courierTitle != null &&
                    (st == OrderStatus.dikirim || st == OrderStatus.diproses))
                  InkWell(
                    onTap: () => _openDetail(o),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.two_wheeler_outlined,
                            size: 18,
                            color: AppColors.green,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${o.courierTitle}: ',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.green,
                                    ),
                                  ),
                                  TextSpan(
                                    text: o.courierInfo ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 16,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (st == OrderStatus.dibatalkan && refund > 0)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 16,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Dana ${_rp(refund)} dikembalikan ke Saldo '
                            'Tabungan Koperasi',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 1, color: Color(0xFFE5E9E6)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TOTAL BELANJA (${o.itemCount} ITEM)',
                              style: const TextStyle(
                                fontSize: 8,
                                letterSpacing: 0.3,
                                color: AppColors.muted,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _rp(o.total),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              o.paymentLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 8.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 5,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 6,
                            children: _actions(o),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(OrderEntry o) {
    final st = orderMeta.statusOf(o);

    switch (st) {
      case OrderStatus.diproses:
        return [
          _btn('Detail', () => _openDetail(o), plain: true),
        ];

      case OrderStatus.dikirim:
        return [
          _btn('Hubungi', () => _openChat(o), plain: true),
          _btn(
            'Lacak',
            () => _openDetail(o),
            filled: true,
            icon: Icons.near_me_outlined,
          ),
        ];

      case OrderStatus.selesai:
        final actions = <Widget>[
          _btn(
            orderMeta.isReviewed(o) ? 'Lihat Ulasan' : 'Ulasan',
            () => _openReview(o),
            plain: true,
          ),
          _btn(
            'Beli Lagi',
            () => orderBuyAgain(context, o),
            green: true,
            icon: Icons.refresh,
          ),
        ];

        if (orderMeta.isReturnRequested(o)) {
          actions.add(
            _btn(
              'Detail Retur',
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReturnDetailScreen(order: o),
                ),
              ),
            ),
          );
        }
        return actions;

      case OrderStatus.dibatalkan:
        return [
          _btn('Rincian Batal', () => _openDetail(o), plain: true),
          _btn(
            'Pesan Ulang',
            () => orderBuyAgain(context, o),
            green: true,
            icon: Icons.refresh,
          ),
        ];
    }
  }

  Widget _btn(
    String text,
    VoidCallback onTap, {
    bool filled = false,
    bool green = false,
    bool plain = false,
    IconData? icon,
  }) {
    final Color fg =
        filled ? Colors.white : (green ? AppColors.green : AppColors.text);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: filled ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: plain
              ? null
              : Border.all(
                  color: filled
                      ? AppColors.green
                      : (green ? AppColors.green : AppColors.border),
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: plain ? AppColors.muted : fg,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 13, color: fg),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lineRow(OrderLine l) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              l.image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.greenLight,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.green,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (l.variant.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    l.variant,
                    style: const TextStyle(
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _rp(l.price),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'X ${l.qty}',
            style: const TextStyle(
              fontSize: 9.5,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(OrderStatus s) {
    late final String label;
    late final Color fg;
    late final Color bg;
    IconData? icon;

    switch (s) {
      case OrderStatus.diproses:
        label = 'Diproses';
        fg = const Color(0xFF1D6FB8);
        bg = const Color(0xFFE8F2FB);
        break;
      case OrderStatus.dikirim:
        label = 'Sedang Dikirim';
        fg = const Color(0xFFD97706);
        bg = const Color(0xFFFFF4E0);
        break;
      case OrderStatus.selesai:
        label = 'Selesai';
        fg = AppColors.green;
        bg = AppColors.greenLight;
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.dibatalkan:
        label = 'Dibatalkan';
        fg = Colors.red.shade600;
        bg = Colors.red.shade50;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 11, color: fg)
          else
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _guaranteeCard() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.green,
            child: Icon(
              Icons.verified_user_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaminan Transaksi Resmi BUMDes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Seluruh transaksi diawasi oleh Kas BUMDes Sukorejo. '
                  'Komplain & bantuan pengantaran hubungi Pos Pelayanan '
                  'Balai Desa Sukorejo.',
                  style: TextStyle(
                    fontSize: 9.5,
                    height: 1.4,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
