import 'package:flutter/material.dart';
import '../providers/order_provider.dart';
import 'order_models.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';
import 'order_flow_screens.dart';

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

  int _filter = 0;

  @override
  void initState() {
    super.initState();

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

  List<OrderEntry> get _allOrders => [...orderStore.orders];

  List<OrderEntry> get _orders {
    final all = _allOrders;

    switch (_filter) {
      case 1:
        return all.where((o) {
          final st = orderMeta.statusOf(o);

          return st == OrderStatus.diproses || st == OrderStatus.dikirim;
        }).toList();

      case 2:
        return all
            .where((o) => orderMeta.statusOf(o) == OrderStatus.selesai)
            .toList();

      case 3:
        return all
            .where((o) => orderMeta.statusOf(o) == OrderStatus.dibatalkan)
            .toList();

      default:
        return all;
    }
  }

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
                        setState(() => _filter = i);

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
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.green, size: 20),
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

  @override
  Widget build(BuildContext context) {
    final hasAny = _allOrders.isNotEmpty;

    final orders = _orders;

    final content = Column(
      children: [
        const PasarDesaHeader(),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Riwayat Pemesanan',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                        SizedBox(height: 2),
                        Text('Pantau transaksi hasil bumi & UMKM Sukorejo',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.muted)),
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
                            Icon(Icons.tune, size: 16, color: AppColors.green),
                            SizedBox(width: 4),
                            Text('Filter',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.green)),
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
                      child: Text('Belum ada pesanan di kategori ini.',
                          style:
                              TextStyle(fontSize: 11, color: AppColors.muted)),
                    ),
                  ),
                ...orders.map(_orderCard),
                const SizedBox(height: 4),
                _guaranteeCard(),
              ],
            ],
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

    final hasArrow = i != 0;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filter = i),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? AppColors.green : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? AppColors.green : AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _filters[i],
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.text,
                ),
              ),
              if (hasArrow) ...[
                const SizedBox(width: 3),
                Icon(Icons.keyboard_arrow_down,
                    size: 14, color: selected ? Colors.white : AppColors.muted),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _orderCard(OrderEntry o) {
    final st = orderMeta.statusOf(o);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // header penjual + status

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined,
                    size: 17, color: AppColors.green),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(o.seller,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 13, color: AppColors.green),
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
                  child: Text(o.dateLabel,
                      style:
                          const TextStyle(fontSize: 9, color: AppColors.muted)),
                ),
                Text(o.id,
                    style:
                        const TextStyle(fontSize: 9, color: AppColors.muted)),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E9E6)),

          ...o.lines.map(_lineRow),

          if (o.courierTitle != null &&
              (st == OrderStatus.dikirim || st == OrderStatus.diproses))
            Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: const Color(0xFFF1FBF4),
                border: Border.all(color: AppColors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.two_wheeler_outlined,
                      size: 18, color: AppColors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: '${o.courierTitle}: ',
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green),
                        ),
                        TextSpan(
                          text: o.courierInfo ?? '',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.text),
                        ),
                      ]),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TOTAL BELANJA (${o.itemCount} ITEM)',
                          style: const TextStyle(
                              fontSize: 8,
                              letterSpacing: 0.3,
                              color: AppColors.muted)),
                      const SizedBox(height: 2),
                      Text(_rp(o.total),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 1),
                      Text(o.paymentLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 8.5, color: AppColors.muted)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 6,
                    children: _actions(o),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _actions(OrderEntry o) {
    final st = orderMeta.statusOf(o);

    switch (st) {
      case OrderStatus.dikirim:
      case OrderStatus.diproses:
        return [
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
          const SizedBox(width: 6),
          _btn(
            'Beli Lagi',
            () => orderBuyAgain(context, o),
            green: true,
            icon: Icons.refresh,
          ),
        ];

        if (orderMeta.isReturnRequested(o)) {
          actions.add(const SizedBox(width: 6));

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
          _btn(
            'Pesan Ulang',
            () => orderBuyAgain(context, o),
            green: true,
            icon: Icons.refresh,
          ),
        ];
    }

    return const <Widget>[];
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
                      : (green ? AppColors.green : AppColors.border)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: plain ? AppColors.muted : fg)),
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
                child: const Icon(Icons.image_outlined, color: AppColors.green),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900)),
                if (l.variant.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(l.variant,
                      style:
                          const TextStyle(fontSize: 9, color: AppColors.muted)),
                ],
                const SizedBox(height: 4),
                Text(_rp(l.price),
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green)),
              ],
            ),
          ),
          Text('X ${l.qty}',
              style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
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
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
        ],
      ),
    );
  }

  Widget _guaranteeCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FBF4),
        border: Border.all(color: AppColors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.green,
            child: Icon(Icons.verified_user_rounded,
                size: 16, color: Colors.white),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jaminan Transaksi Resmi BUMDes',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green)),
                SizedBox(height: 3),
                Text(
                  'Seluruh transaksi diawasi oleh Kas BUMDes Sukorejo. '
                  'Komplain & bantuan pengantaran hubungi Pos Pelayanan '
                  'Balai Desa Sukorejo.',
                  style: TextStyle(
                      fontSize: 9.5, height: 1.4, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
