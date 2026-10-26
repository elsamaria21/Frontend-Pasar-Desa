import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/common.dart';
import 'courier_contact_screen.dart' show ContactCourierScreen, CourierInfo;
import 'dashboard_screen.dart' show DashboardNav, NotificationCenter;
import 'order_flow_screens.dart'
    show orderMeta, orderBuyAgain, OrderReviewScreen, CancelledOrderScreen;
import 'order_models.dart' show OrderEntry, OrderLine, OrderStatus;
import 'topup_screen.dart' show WalletBalance;

const Color _ink = Color(0xFF10231B);
const Color _line = Color(0xFFE3E7E4);
const Color _soft = Color(0xFFF1FBF4);
const Color _softBorder = Color(0xFFCDEBD6);
const Color _orange = Color(0xFFE8742A);
const Color _red = Color(0xFFE5484D);
const Color _amber = Color(0xFFD97706);
const Color _amberBg = Color(0xFFFFF4E0);

String _two(int n) => n.toString().padLeft(2, '0');

String _rp(int value) {
  final s = value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
  return 'Rp $s';
}

String _clockAt(OrderEntry o, int plusMinutes) {
  final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(o.dateLabel);
  var t = m == null
      ? 10 * 60
      : int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  t = (t + plusMinutes) % (24 * 60);
  return '${_two(t ~/ 60)}:${_two(t % 60)} WIB';
}

bool _isCod(OrderEntry o) {
  final p = o.paymentLabel.toLowerCase();
  return p.contains('cod') || p.contains('tunai') || p.contains('di tempat');
}

int _subtotal(OrderEntry o) => o.lines.fold(0, (s, l) => s + l.price * l.qty);

class TrackDetailScreen extends StatefulWidget {
  final OrderEntry order;

  const TrackDetailScreen({super.key, required this.order});

  @override
  State<TrackDetailScreen> createState() => _TrackDetailScreenState();
}

class _TrackDetailScreenState extends State<TrackDetailScreen> {
  static const List<String> _cancelReasons = [
    'Ingin mengubah jumlah atau jenis pesanan',
    'Salah memilih produk',
    'Ingin mengganti alamat pengantaran',
    'Menemukan produk lain yang lebih cocok',
    'Alasan lainnya',
  ];

  OrderEntry get o => widget.order;

  @override
  void initState() {
    super.initState();
    orderMeta.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    orderMeta.removeListener(_refresh);
    super.dispose();
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactCourierScreen(order: o)),
    );
  }

  void _openReview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderReviewScreen(order: o)),
    );
  }

  Future<void> _confirmReceived() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Pesanan Sudah Diterima?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Pastikan semua hasil bumi sudah Anda terima dengan baik. '
            'Dana akan diteruskan ke petani setelah Anda konfirmasi.',
            style: TextStyle(fontSize: 12.5, height: 1.45, color: _ink),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Belum',
                  style: TextStyle(color: _ink, fontWeight: FontWeight.w800)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ya, Diterima',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    final m = orderMeta.metaOf(o.id);
    m.status = OrderStatus.selesai;
    m.receivedAt = DateTime.now();

    NotificationCenter.add(
      'Pesanan diterima',
      'Pesanan ${o.id} dari ${o.seller} sudah selesai. Beri ulasan Anda.',
    );

    orderMeta.changed();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderReviewScreen(order: o)),
    );
  }

  void _showCancelSheet() {
    String selected = _cancelReasons.first;
    final refundable = !_isCod(o);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheet) {
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
                      'Batalkan Pesanan?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      refundable
                          ? 'Dana ${_rp(o.total)} akan dikembalikan ke Saldo '
                              'Tabungan Koperasi Anda.'
                          : 'Pesanan dibayar di tempat, tidak ada dana yang '
                              'perlu dikembalikan.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final r in _cancelReasons)
                      InkWell(
                        onTap: () => setSheet(() => selected = r),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Row(
                            children: [
                              Icon(
                                selected == r
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 21,
                                color: selected == r
                                    ? AppColors.green
                                    : const Color(0xFFC3CBC6),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  r,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: selected == r
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              foregroundColor: _ink,
                              side: const BorderSide(color: Color(0xFFD9DEDB)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Kembali',
                                style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(sheetContext);
                              _cancel(selected);
                            },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                              backgroundColor: _red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Ya, Batalkan',
                                style: TextStyle(fontWeight: FontWeight.w900)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _cancel(String reason) {
    final refund = _isCod(o) ? 0 : o.total;

    final m = orderMeta.metaOf(o.id);
    m.status = OrderStatus.dibatalkan;
    m.cancelReason = reason;
    m.cancelledAt = DateTime.now();
    m.refundAmount = refund;

    if (refund > 0) {
      WalletBalance.add(refund);
    }

    NotificationCenter.add(
      'Pesanan dibatalkan',
      refund > 0
          ? 'Pesanan ${o.id} dibatalkan. ${_rp(refund)} kembali ke saldo.'
          : 'Pesanan ${o.id} dibatalkan.',
    );

    orderMeta.changed();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CancelledOrderScreen(order: o)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = orderMeta.statusOf(o);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Column(
          children: [
            const PasarDesaHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  _statusCard(st),
                  const SizedBox(height: 14),
                  _timelineCard(st),
                  const SizedBox(height: 14),
                  _addressCard(),
                  const SizedBox(height: 14),
                  _sellerCard(),
                  const SizedBox(height: 14),
                  _paymentCard(),
                  const SizedBox(height: 14),
                  _guaranteeCard(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _bottomBar(st),
          BottomNav(
            current: 3,
            onTap: (i) => DashboardNav.goTo(context, i),
          ),
        ],
      ),
    );
  }

  Widget _statusCard(OrderStatus st) {
    final String chip;
    final String title;
    final String subtitle;

    switch (st) {
      case OrderStatus.diproses:
        chip = 'Pesanan Diproses';
        title = 'Pesanan sedang disiapkan lapak';
        subtitle = 'Petani menyiapkan dan mengemas hasil bumi pesanan Anda.';
        break;
      case OrderStatus.dikirim:
        chip = 'Sedang Dikirim';
        title = 'Estimasi Tiba hari ini, ${_clockAt(o, 120)}';
        subtitle = 'Kurir BUMDes sedang mengantar pesanan Anda ke titik '
            'pengantaran. Mohon siap menerima.';
        break;
      default:
        chip = 'Pesanan Selesai';
        title = 'Pesanan telah diterima';
        subtitle = 'Terima kasih sudah berbelanja di PasarDesa.';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.green, Color(0xFF0B6E3A)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        chip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  o.id,
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.85),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.92),
                fontSize: 11.5,
                height: 1.4,
              ),
            ),
            if (st != OrderStatus.selesai) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.two_wheeler_rounded,
                          color: AppColors.green, size: 21),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kurir BUMDes Sukorejo',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.88),
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            '${CourierInfo.name} (RW 02)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _openChat,
                      borderRadius: BorderRadius.circular(11),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 14, color: AppColors.green),
                            SizedBox(width: 5),
                            Text(
                              'Hubungi',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _timelineCard(OrderStatus st) {
    final current = st == OrderStatus.selesai
        ? 4
        : st == OrderStatus.dikirim
            ? 2
            : 1;

    final titles = [
      'Pesanan Dikonfirmasi',
      'Sedang Disiapkan Petani Krajan',
      'Diantar Kurir Sukorejo',
      'Pesanan Diterima Warga',
    ];

    final descs = [
      'Pembayaran diterima & pesanan masuk ke lapak',
      'Petani memanen dan mengemas pesanan Anda',
      '${CourierInfo.name} membawa pesanan menuju alamat Anda',
      st == OrderStatus.selesai
          ? 'Pesanan telah diterima warga'
          : 'Menunggu konfirmasi penerimaan',
    ];

    final times = [
      _clockAt(o, 0),
      _clockAt(o, 60),
      _clockAt(o, 120),
      '',
    ];

    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.moving_rounded,
                  size: 19, color: AppColors.green),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Lacak Pengiriman Desa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
              ),
              if (st != OrderStatus.selesai)
                _pill('Live Update', AppColors.green, const Color(0xFFE1F5E9)),
            ],
          ),
          const SizedBox(height: 14),
          for (int i = 0; i < titles.length; i++)
            _timelineItem(
              index: i,
              current: current,
              last: i == titles.length - 1,
              title: titles[i],
              desc: descs[i],
              time: (i <= current && i < 3) ? times[i] : '',
            ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required int index,
    required int current,
    required bool last,
    required String title,
    required String desc,
    required String time,
  }) {
    final done = index < current;
    final active = index == current;
    final color = done
        ? AppColors.green
        : active
            ? _orange
            : const Color(0xFFCBD3CE);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (done || active) ? color : Colors.white,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: Colors.white)
                      : active
                          ? Center(
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null,
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: done ? AppColors.green : const Color(0xFFE3E8E5),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            color: active
                                ? _orange
                                : (done ? _ink : AppColors.muted),
                          ),
                        ),
                      ),
                      if (time.isNotEmpty)
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.35,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    final name =
        o.receiverName.trim().isNotEmpty ? o.receiverName.trim() : 'Penerima';

    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.home_outlined, size: 19, color: AppColors.green),
              SizedBox(width: 7),
              Text(
                'Alamat Penerima di Desa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _pill('Rumah', AppColors.green, const Color(0xFFE1F5E9)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            [
              if (o.receiverPhone.isNotEmpty) o.receiverPhone,
              if (o.deliveryAddress.isNotEmpty) o.deliveryAddress,
            ].join(' • '),
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.4,
              color: AppColors.muted,
            ),
          ),
          if (o.deliveryNote.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Catatan: ${o.deliveryNote}',
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.35,
                color: AppColors.muted,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _softBorder),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 16, color: AppColors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pengantaran Gratis oleh Kurir Desa BUMDes',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sellerCard() {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.greenLight,
                child:
                    Icon(Icons.eco_outlined, size: 19, color: AppColors.green),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            o.seller,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _ink,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified,
                            size: 14, color: AppColors.green),
                      ],
                    ),
                    const Text(
                      'Lapak Resmi Desa Sukorejo',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _openChat,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _softBorder),
                    color: _soft,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 13, color: AppColors.green),
                      SizedBox(width: 4),
                      Text(
                        'Chat',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEF2EF)),
          const SizedBox(height: 6),
          for (final l in o.lines) _productRow(l),
        ],
      ),
    );
  }

  Widget _productRow(OrderLine l) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              l.image,
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 58,
                height: 58,
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
                Text(
                  l.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                if (l.variant.isNotEmpty)
                  Text(
                    l.variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${l.qty}x ${_rp(l.price)}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _rp(l.price * l.qty),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentCard() {
    final subtotal = _subtotal(o);
    final isCourier =
        (o.courierTitle ?? 'Kurir').toLowerCase().contains('kurir');
    final shipping = isCourier ? 5000 : 0;
    final rawDiscount = subtotal + shipping - o.total;
    final discount = rawDiscount > 0 ? rawDiscount : 0;
    final digits = o.id.replaceAll(RegExp(r'[^0-9]'), '');
    final tail =
        digits.length >= 5 ? digits.substring(digits.length - 5) : digits;
    final cod = _isCod(o);

    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 19, color: AppColors.green),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Rincian Pembayaran',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
              ),
              if (cod)
                _pill('Bayar di Tempat', _amber, _amberBg)
              else
                _pill('Lunas', AppColors.green, const Color(0xFFE1F5E9)),
            ],
          ),
          const SizedBox(height: 12),
          _kv('Metode Pembayaran', o.paymentLabel),
          _kv('ID Referensi Kas', 'PS-SKR-$tail'),
          _kv('Subtotal Produk (${o.itemCount} item)', _rp(subtotal)),
          _kv('Ongkos Kirim Kurir Desa', _rp(shipping)),
          if (discount > 0)
            _kv('Subsidi Ongkir Warga', '- ${_rp(discount)}',
                valueColor: AppColors.green, labelColor: AppColors.green),
          _kv('Biaya Layanan Koperasi', 'Gratis Warga',
              valueColor: AppColors.green, labelColor: AppColors.green),
          const Divider(height: 22, color: Color(0xFFEEF2EF)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL TRANSAKSI',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 0.4,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _rp(o.total),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),
              if (!cod)
                _pill(
                    'Tuntas Dibayar', AppColors.green, const Color(0xFFE1F5E9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(
    String label,
    String value, {
    Color? valueColor,
    Color? labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                color: labelColor ?? AppColors.muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: valueColor ?? _ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _guaranteeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBorder),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.green,
            child: Icon(Icons.verified_user_rounded,
                size: 17, color: Colors.white),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amanah Transaksi Koperasi Desa',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Seluruh transaksi diawasi Kas BUMDes Sukorejo. Dana Anda '
                  'aman dan baru diteruskan ke petani setelah pesanan '
                  'diterima dengan baik.',
                  style: TextStyle(
                    fontSize: 10.5,
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

  Widget _bottomBar(OrderStatus st) {
    final Widget content;

    switch (st) {
      case OrderStatus.dikirim:
        content = _bigButton(
          'Pesanan Diterima',
          onTap: _confirmReceived,
          icon: Icons.check_circle_outline_rounded,
        );
        break;

      case OrderStatus.diproses:
        content = Row(
          children: [
            Expanded(
              child: _bigButton(
                'Batalkan Pesanan',
                onTap: _showCancelSheet,
                outlined: true,
                color: _red,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _bigButton(
                'Hubungi Kurir',
                onTap: _openChat,
                icon: Icons.chat_bubble_outline_rounded,
              ),
            ),
          ],
        );
        break;

      default:
        final reviewed = orderMeta.isReviewed(o);
        content = Row(
          children: [
            Expanded(
              child: _bigButton(
                reviewed ? 'Lihat Ulasan' : 'Beri Ulasan',
                onTap: _openReview,
                outlined: true,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _bigButton(
                'Beli Lagi',
                onTap: () => orderBuyAgain(context, o),
                icon: Icons.refresh_rounded,
              ),
            ),
          ],
        );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6EAE7))),
      ),
      child: content,
    );
  }

  Widget _bigButton(
    String text, {
    required VoidCallback onTap,
    IconData? icon,
    bool outlined = false,
    Color color = AppColors.green,
  }) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 6),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );

    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

    if (outlined) {
      return SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color, width: 1.3),
            shape: shape,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: shape,
        ),
        child: child,
      ),
    );
  }

  Widget _box({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: child,
    );
  }

  Widget _pill(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}
