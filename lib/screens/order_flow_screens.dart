import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../data/remote/api_service.dart' show ApiException;
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart' show PasarDesaHeader;
import '../widgets/common.dart';
import 'dashboard_screen.dart' show DashboardNav, NotificationCenter;
import 'order_models.dart';
import 'topup_screen.dart' show WalletBalance, formatRupiahId;
import '../widgets/app_image.dart';

class OrderMeta {
  OrderStatus? status;
  DateTime? receivedAt;

  bool reviewed = false;
  int rating = 0;
  List<String> tags = [];
  String note = '';
  bool courierLiked = true;

  String? cancelReason;
  DateTime? cancelledAt;
  int refundAmount = 0;

  bool returnRequested = false;
  String? returnReason;
  DateTime? returnRequestedAt;
}

class OrderMetaStore extends ChangeNotifier {
  final Map<String, OrderMeta> _map = {};
  OrderMeta metaOf(String id) => _map.putIfAbsent(id, () => OrderMeta());
  OrderStatus statusOf(OrderEntry o) => _map[o.id]?.status ?? o.status;
  bool isReviewed(OrderEntry o) => _map[o.id]?.reviewed ?? false;
  bool isReturnRequested(OrderEntry o) => _map[o.id]?.returnRequested ?? false;
  void changed() => notifyListeners();
}

final OrderMetaStore orderMeta = OrderMetaStore();

const String _kCourierName = 'Pak Wardi';
const String _kCourierArea = 'RW 02';
const Color _kRed = Color(0xFFE5484D);

String _two(int n) => n.toString().padLeft(2, '0');

String _dateLabel(DateTime d) {
  const bulan = [
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
  return '${d.day} ${bulan[d.month - 1]} ${d.year} • '
      '${_two(d.hour)}:${_two(d.minute)} WIB';
}

bool _isCod(OrderEntry o) {
  final p = o.paymentLabel.toLowerCase();
  return p.contains('cod') || p.contains('tunai') || p.contains('di tempat');
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

void orderBuyAgain(BuildContext context, OrderEntry o) {
  final cart = context.read<CartProvider>();
  final messenger = ScaffoldMessenger.of(context);

  int added = 0;

  for (final line in o.lines) {
    Product? found;
    for (final p in products) {
      if (p.name == line.name || p.shortName == line.name) {
        found = p;
        break;
      }
    }

    if (found != null && found.stock > 0) {
      cart.add(found);
      added++;
    }
  }

  if (added == 0) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Produk pesanan ini sedang tidak tersedia'),
        ),
      );
    return;
  }

  NotificationCenter.add(
    'Keranjang diperbarui',
    '$added produk dari pesanan ${o.id} ditambahkan ke keranjang',
  );

  DashboardNav.goTo(context, 2);
}

const String _kCourierPhone = '0813-8821-4902';

String _waNumber(String raw) {
  var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (d.startsWith('0')) {
    d = '62${d.substring(1)}';
  } else if (d.startsWith('8')) {
    d = '62$d';
  }
  return d;
}

Future<void> openCourierWhatsApp(
  BuildContext context,
  OrderEntry o, {
  String phone = _kCourierPhone,
  String courierName = _kCourierName,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final who =
      o.receiverName.trim().isNotEmpty ? o.receiverName.trim() : 'pembeli';
  final text = 'Halo $courierName, saya $who. Saya ingin menanyakan '
      'pesanan ${o.id} di PasarDesa Sukorejo.';
  final uri = Uri.parse(
    'https://wa.me/${_waNumber(phone)}?text=${Uri.encodeComponent(text)}',
  );

  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    ok = false;
  }

  if (!ok) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'WhatsApp tidak dapat dibuka. Pastikan WhatsApp sudah terpasang.',
          ),
        ),
      );
  }
}

class _FlowHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showLogo;
  final double titleSize;

  const _FlowHeader({
    required this.title,
    this.subtitle,
    this.showLogo = true,
    this.titleSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 20, color: AppColors.text),
            ),
          ),
          if (showLogo) ...[
            const BrandMark(size: 28),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowTitleBar extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _FlowTitleBar({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 2, 16, 6),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E9E6))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: AppColors.text),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? bottom;
  final bool brandHeader;
  final bool showLogo;
  final double titleSize;

  const _FlowPage({
    required this.title,
    required this.children,
    this.subtitle,
    this.bottom,
    this.showLogo = true,
    this.titleSize = 16,
  }) : brandHeader = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Column(
          children: [
            if (brandHeader) ...[
              const PasarDesaHeader(),
              _FlowTitleBar(title: title, subtitle: subtitle),
            ] else
              _FlowHeader(
                title: title,
                subtitle: subtitle,
                showLogo: showLogo,
                titleSize: titleSize,
              ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: children,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (bottom != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE6EAE7))),
              ),
              child: bottom,
            ),
          BottomNav(
            current: 3,
            onTap: (i) => DashboardNav.goTo(context, i),
          ),
        ],
      ),
    );
  }
}

Widget _box({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(14),
  Color color = Colors.white,
  Color? border,
}) {
  return Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border ?? AppColors.border),
    ),
    child: child,
  );
}

Widget _sectionTitle(String text, {Widget? trailing, IconData? icon}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: AppColors.green),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

Widget _pill(String text, Color fg, Color bg, {IconData? icon}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          text,
          style:
              TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: fg),
        ),
      ],
    ),
  );
}

Widget _kv(String label, String value,
    {Color? valueColor, bool bold = false, double size = 12}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(
            label,
            style: TextStyle(fontSize: size - 0.5, color: AppColors.muted),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: size,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              color: valueColor ?? AppColors.text,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _lineTile(OrderLine l) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: smartImage(
            l.image,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 54,
              height: 54,
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
                    fontSize: 12.5, fontWeight: FontWeight.w900),
              ),
              if (l.variant.isNotEmpty)
                Text(
                  l.variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              const SizedBox(height: 3),
              Text(
                formatRupiahId(l.price),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ),
        Text('x ${l.qty}',
            style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
      ],
    ),
  );
}

class OrderDetailScreen extends StatefulWidget {
  final OrderEntry order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const List<String> _reasons = [
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
    openCourierWhatsApp(context, o);
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
            style:
                TextStyle(fontSize: 12.5, height: 1.45, color: AppColors.muted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Belum',
                  style: TextStyle(
                      color: AppColors.muted, fontWeight: FontWeight.w800)),
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

    try {
      await orderStore.terimaPesanan(o.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Gagal mengonfirmasi penerimaan. Periksa koneksi lalu coba lagi.'),
      ));
      return;
    }
    if (!mounted) return;

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
    String selected = _reasons.first;
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
                          ? 'Dana ${formatRupiahId(o.total)} akan dikembalikan '
                              'ke Saldo Tabungan Koperasi Anda.'
                          : 'Pesanan dibayar di tempat, tidak ada dana yang perlu dikembalikan.',
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.4,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final r in _reasons)
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
                              foregroundColor: AppColors.text,
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
                              backgroundColor: _kRed,
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

  Future<void> _cancel(String reason) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await orderStore.batalkanPesanan(o.id);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
      return;
    }
    if (!mounted) return;

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
          ? 'Pesanan ${o.id} dibatalkan. ${formatRupiahId(refund)} kembali ke saldo.'
          : 'Pesanan ${o.id} dibatalkan.',
    );

    orderMeta.changed();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => CancelledOrderScreen(order: o)),
    );
  }

  void _openReview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OrderReviewScreen(order: o)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = orderMeta.statusOf(o);

    return _FlowPage(
      title: 'Detail Pemesanan',
      titleSize: 22,
      showLogo: false,
      bottom: _buildBottom(st),
      children: [
        _buildStatusCard(st),
        const SizedBox(height: 14),
        _buildAddress(),
        const SizedBox(height: 14),
        _buildProducts(),
        const SizedBox(height: 14),
        _buildPayment(),
      ],
    );
  }

  Widget _buildStatusCard(OrderStatus st) {
    late final String chip;
    late final String title;

    switch (st) {
      case OrderStatus.diproses:
        chip = 'Dikemas';
        title = 'Pesanan sedang dikemas';
        break;
      case OrderStatus.dikirim:
        chip = 'Dikirim';
        title = 'Pesanan dalam perjalanan';
        break;
      default:
        chip = 'Selesai';
        title = 'Pesanan telah diterima';
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
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
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
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
                      const SizedBox(width: 5),
                      Text(
                        chip,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 19,
                height: 1.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              o.id,
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 0.9),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (st != OrderStatus.selesai) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.two_wheeler_rounded,
                          color: AppColors.green, size: 20),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kurir Desa Sukorejo',
                            style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 0.85),
                              fontSize: 9.5,
                            ),
                          ),
                          Text(
                            '$_kCourierName ($_kCourierArea)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildAddress() {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Alamat Penerima'),
          Row(
            children: [
              Expanded(
                child: Text(
                  o.receiverName.isNotEmpty ? o.receiverName : 'Penerima',
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
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
            const SizedBox(height: 7),
            Text(
              'Catatan: ${o.deliveryNote}',
              style: const TextStyle(
                fontSize: 10.5,
                height: 1.35,
                color: AppColors.muted,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FBF4),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 16, color: AppColors.green),
                SizedBox(width: 7),
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

  Widget _buildProducts() {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storefront_outlined,
                  size: 18, color: AppColors.green),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  o.seller,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.verified, size: 14, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 2),
          const Padding(
            padding: EdgeInsets.only(left: 24),
            child: Text(
              'Lapak Hasil Desa Sukorejo',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 6),
          for (final l in o.lines) _lineTile(l),
        ],
      ),
    );
  }

  Widget _buildPayment() {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Rincian Pembayaran',
            trailing: _pill(
              _isCod(o) ? 'Bayar di Tempat' : 'Lunas',
              AppColors.green,
              const Color(0xFFE1F5E9),
            ),
          ),
          _kv('Metode Pembayaran', o.paymentLabel),
          _kv('Subtotal Produk (${o.itemCount} item)', formatRupiahId(o.total)),
          _kv('Ongkos Kirim Desa', 'Gratis (Rp 0)',
              valueColor: AppColors.green),
          _kv('Biaya Layanan Koperasi', 'Gratis (Rp 0)',
              valueColor: AppColors.green),
          const Divider(height: 10, color: Color(0xFFEEF2EF)),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TOTAL PEMBAYARAN',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Text(
                formatRupiahId(o.total),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottom(OrderStatus st) {
    switch (st) {
      case OrderStatus.dikirim:
        return _bigButton(
          'Pesanan Diterima',
          onTap: _confirmReceived,
          icon: Icons.check_circle_outline_rounded,
        );

      case OrderStatus.diproses:
        return Row(
          children: [
            Expanded(
              child: _bigButton(
                'Batalkan Pesanan',
                onTap: _showCancelSheet,
                outlined: true,
                color: _kRed,
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

      default:
        final reviewed = orderMeta.isReviewed(o);
        return Row(
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
  }
}

Widget _bigButton(
  String text, {
  required VoidCallback? onTap,
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
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    ],
  );

  final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

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
        disabledBackgroundColor: const Color(0xFFE2E6E3),
        disabledForegroundColor: const Color(0xFF98A19C),
        elevation: 0,
        shape: shape,
      ),
      child: child,
    ),
  );
}

class OrderReviewScreen extends StatefulWidget {
  final OrderEntry order;

  const OrderReviewScreen({super.key, required this.order});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  static const List<String> _allTags = [
    'Segar Petik Pagi',
    'Kemasan Rapi & Bersih',
    'Timbangan Pas Penuh',
    'Rasa Alami & Enak',
    'Sesuai Deskripsi',
    'Harga Terjangkau',
  ];

  static const Map<int, String> _ratingLabel = {
    1: 'Kurang Baik',
    2: 'Cukup',
    3: 'Baik',
    4: 'Segar & Bagus',
    5: 'Sangat Segar & Bagus',
  };

  final TextEditingController _note = TextEditingController();

  late final bool _readOnly;
  bool _checked = false;
  int _rating = 0;
  bool _courierLiked = true;
  final Set<String> _tags = {};

  OrderEntry get o => widget.order;

  @override
  void initState() {
    super.initState();

    final m = orderMeta.metaOf(o.id);
    _readOnly = m.reviewed;

    if (_readOnly) {
      _checked = true;
      _rating = m.rating;
      _courierLiked = m.courierLiked;
      _tags.addAll(m.tags);
      _note.text = m.note;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  bool get _canSubmit => _checked && _rating > 0;

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _submit() {
    if (!_canSubmit) return;

    final m = orderMeta.metaOf(o.id);
    m.reviewed = true;
    m.rating = _rating;
    m.tags = _tags.toList();
    m.note = _note.text.trim();
    m.courierLiked = _courierLiked;

    NotificationCenter.add(
      'Ulasan terkirim',
      'Terima kasih! Ulasan Anda untuk ${o.seller} membantu warga lain.',
    );

    orderMeta.changed();

    _snack('Terima kasih, ulasan Anda sudah terkirim');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return _FlowPage(
      showLogo: false,
      title: _readOnly ? 'Ulasan Anda' : 'Beri Ulasan',
      subtitle: o.id,
      bottom: _readOnly
          ? _bigButton('Beli Lagi',
              onTap: () => orderBuyAgain(context, o),
              icon: Icons.refresh_rounded)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _bigButton(
                  'Selesai & Beri Ulasan',
                  onTap: _canSubmit ? _submit : null,
                  icon: Icons.check_circle_outline_rounded,
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReturnDetailScreen(order: o),
                      ),
                    );
                  },
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.warning_amber_rounded, size: 15, color: _kRed),
                      SizedBox(width: 5),
                      Text(
                        'Ada Masalah dengan Barang? Ajukan Komplain',
                        style: TextStyle(
                          color: _kRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      children: [
        _buildArrivedCard(),
        const SizedBox(height: 14),
        _buildReceivedProducts(),
        if (!_readOnly) ...[
          const SizedBox(height: 12),
          _buildCheckBox(),
          const SizedBox(height: 14),
          _buildEvidence(),
        ],
        const SizedBox(height: 14),
        _buildQuality(),
        const SizedBox(height: 14),
        _buildCourierRating(),
      ],
    );
  }

  Widget _buildArrivedCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
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
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.green, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Barang Telah Tiba!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.verified, size: 16, color: Colors.white),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Periksa kondisi hasil bumi, lalu beri ulasan Anda.',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 0.9),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _arrivedRow('Nomor Pesanan', o.id),
                  const SizedBox(height: 6),
                  _arrivedRow(
                    'Penerima',
                    o.receiverName.trim().isNotEmpty
                        ? o.receiverName.trim()
                        : 'Budi Santoso • RT 02 / RW 01',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _arrivedRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceivedProducts() {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Produk Pesanan Diterima',
            icon: Icons.shopping_basket_outlined,
            trailing: _pill(
              '${o.lines.length} Komoditas',
              AppColors.green,
              const Color(0xFFE1F5E9),
            ),
          ),
          for (int i = 0; i < o.lines.length; i++) ...[
            if (i > 0) const Divider(height: 16, color: Color(0xFFEEF2EF)),
            _receivedLine(o.lines[i]),
          ],
        ],
      ),
    );
  }

  Widget _receivedLine(OrderLine l) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: smartImage(
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (l.variant.isNotEmpty)
                Text(
                  l.variant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              const SizedBox(height: 6),
              _pill(
                'Kondisi Segar & Bersih',
                AppColors.green,
                const Color(0xFFE1F5E9),
                icon: Icons.verified_outlined,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatRupiahId(l.price),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'x ${l.qty}',
              style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
            ),
          ],
        ),
      ],
    );
  }

  Widget _photoThumb() {
    final img = o.lines.isNotEmpty ? o.lines.first.image : '';

    return InkWell(
      onTap: () => _snack('Foto serah terima dari kurir desa'),
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 110,
          height: 80,
          child: Stack(
            fit: StackFit.expand,
            children: [
              smartImage(
                img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.greenLight,
                  child: const Icon(Icons.image_outlined,
                      color: AppColors.green, size: 28),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: const Color.fromRGBO(0, 0, 0, 0.55),
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: const Text(
                    'Foto Serah Terima',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckBox() {
    return InkWell(
      onTap: () => setState(() => _checked = !_checked),
      borderRadius: BorderRadius.circular(14),
      child: _box(
        color: _checked ? const Color(0xFFF1FBF4) : Colors.white,
        border: _checked ? AppColors.green : AppColors.border,
        child: Row(
          children: [
            Icon(
              _checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color: _checked ? AppColors.green : const Color(0xFFC3CBC6),
              size: 24,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Saya telah memeriksa bahwa pesanan diterima dalam kondisi '
                'utuh, segar, dan sesuai timbangan.',
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvidence() {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'Bukti Serah Terima',
            icon: Icons.photo_camera_outlined,
            trailing:
                _pill('Opsional', AppColors.muted, const Color(0xFFEDEFEE)),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _photoThumb(),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => _snack(
                    'Unggah foto akan aktif setelah terhubung ke server'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 110,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD5DBD7)),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: AppColors.green, size: 24),
                      SizedBox(height: 4),
                      Text(
                        'Tambah Foto',
                        style: TextStyle(
                          fontSize: 10.5,
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
          const SizedBox(height: 8),
          const Text(
            'Foto kondisi barang membantu jika ada komplain di kemudian hari.',
            style: TextStyle(fontSize: 10.5, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildQuality() {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.greenLight,
              child: Icon(Icons.eco_outlined, size: 20, color: AppColors.green),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Kualitas Panen ${o.seller}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Bagaimana kondisi dan kesegaran hasil bumi yang Anda terima? '
              'Penilaian Anda membantu petani menjaga mutu hasil panen desa.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 1; i <= 5; i++)
                GestureDetector(
                  onTap: _readOnly ? null : () => setState(() => _rating = i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i <= _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 40,
                      color: i <= _rating
                          ? const Color(0xFFFFB800)
                          : const Color(0xFFD5DBD7),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              _rating == 0
                  ? 'Ketuk bintang untuk menilai'
                  : '${_ratingLabel[_rating]} (${_rating.toStringAsFixed(1)})',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _rating == 0 ? AppColors.muted : AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pilih Tag Produk',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              for (final t in _allTags)
                InkWell(
                  onTap: _readOnly
                      ? null
                      : () => setState(() {
                            if (!_tags.add(t)) _tags.remove(t);
                          }),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                    decoration: BoxDecoration(
                      color: _tags.contains(t)
                          ? AppColors.green
                          : const Color(0xFFF4F9F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _tags.contains(t)
                            ? AppColors.green
                            : const Color(0xFFD3EFDD),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_tags.contains(t)) ...[
                          const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          t,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: _tags.contains(t)
                                ? Colors.white
                                : AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Catatan Masukan Lapak Petani',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _note,
            enabled: !_readOnly,
            maxLines: 4,
            maxLength: 300,
            style: const TextStyle(fontSize: 12.5),
            decoration: InputDecoration(
              hintText: 'Ceritakan kualitas hasil panen yang Anda terima...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
              filled: true,
              fillColor: const Color(0xFFF7FAF8),
              counterStyle: const TextStyle(fontSize: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.green),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourierRating() {
    return _box(
      child: Row(
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.green,
            child: Text(
              _initials(_kCourierName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _kCourierName,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Kurir $_kCourierArea • Bagaimana pengantarannya?',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ],
            ),
          ),
          _thumb(Icons.thumb_up_alt_rounded, true),
          const SizedBox(width: 6),
          _thumb(Icons.thumb_down_alt_rounded, false),
        ],
      ),
    );
  }

  Widget _thumb(IconData icon, bool value) {
    final selected = _courierLiked == value;
    final color = value ? AppColors.green : _kRed;

    return InkWell(
      onTap: _readOnly ? null : () => setState(() => _courierLiked = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : AppColors.border),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : AppColors.muted,
        ),
      ),
    );
  }
}

class ReturnDetailScreen extends StatefulWidget {
  final OrderEntry order;

  const ReturnDetailScreen({super.key, required this.order});

  @override
  State<ReturnDetailScreen> createState() => _ReturnDetailScreenState();
}

class _ReturnDetailScreenState extends State<ReturnDetailScreen> {
  final TextEditingController _reason = TextEditingController();
  bool _submitted = false;

  OrderEntry get o => widget.order;

  @override
  void initState() {
    super.initState();
    final m = orderMeta.metaOf(o.id);
    _submitted = m.returnRequested;
    _reason.text = m.returnReason ?? '';
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _submit() {
    if (_reason.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis alasan retur terlebih dahulu')),
      );
      return;
    }

    final m = orderMeta.metaOf(o.id);
    m.returnRequested = true;
    m.returnReason = _reason.text.trim();
    m.returnRequestedAt = DateTime.now();
    orderMeta.changed();

    NotificationCenter.add(
      'Pengajuan retur dikirim',
      'Retur pesanan ${o.id} sedang diperiksa oleh BUMDes Sukorejo.',
    );

    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final m = orderMeta.metaOf(o.id);
    final when = m.returnRequestedAt;

    return _FlowPage(
      title: 'Detail Retur',
      subtitle: o.id,
      showLogo: false,
      bottom: _submitted
          ? _bigButton(
              'Kembali ke Pesanan',
              onTap: () => Navigator.pop(context),
              icon: Icons.arrow_back_rounded,
            )
          : _bigButton(
              'Ajukan Retur',
              onTap: _submit,
              icon: Icons.assignment_return_outlined,
            ),
      children: [
        _box(
          color: const Color(0xFFF1FBF4),
          border: AppColors.green,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor:
                    _submitted ? AppColors.green : const Color(0xFFE8742A),
                child: Icon(
                  _submitted
                      ? Icons.check_rounded
                      : Icons.assignment_return_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _submitted ? 'Retur Sedang Diproses' : 'Pengajuan Retur',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _submitted
                          ? 'Pengajuan Anda sudah diterima dan sedang diperiksa oleh BUMDes Sukorejo.'
                          : 'Sampaikan masalah pada barang yang Anda terima. Tim akan memeriksa pengajuan retur Anda.',
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.45,
                        color: AppColors.muted,
                      ),
                    ),
                    if (when != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        'Diajukan ${_dateLabel(when)}',
                        style: const TextStyle(
                          fontSize: 9.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Produk yang Diretur',
                icon: Icons.shopping_basket_outlined,
                trailing: _pill(
                  '${o.itemCount} Item',
                  AppColors.green,
                  const Color(0xFFE1F5E9),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.storefront_outlined,
                      size: 17, color: AppColors.green),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      o.seller,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              for (final l in o.lines) _lineTile(l),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Alasan Retur', icon: Icons.info_outline_rounded),
              if (_submitted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    m.returnReason ?? '-',
                    style: const TextStyle(
                        fontSize: 11.5, height: 1.45, color: AppColors.text),
                  ),
                )
              else
                TextField(
                  controller: _reason,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 11.5),
                  decoration: InputDecoration(
                    hintText: 'Contoh: sayuran rusak dan tidak sesuai pesanan',
                    hintStyle:
                        const TextStyle(fontSize: 10.5, color: AppColors.muted),
                    filled: true,
                    fillColor: const Color(0xFFF7FAF8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Bukti Retur',
                icon: Icons.photo_library_outlined,
                trailing: _pill(
                  'Opsional',
                  AppColors.muted,
                  const Color(0xFFF0F3F1),
                ),
              ),
              Container(
                height: 110,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.green, size: 28),
                    SizedBox(height: 5),
                    Text('Tambahkan foto kondisi barang',
                        style: TextStyle(
                            fontSize: 10.5, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('Foto membantu proses verifikasi retur',
                        style: TextStyle(fontSize: 9, color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Riwayat Verifikasi Dana',
                  icon: Icons.verified_user_outlined),
              _returnStep(
                title:
                    _submitted ? 'Pengajuan Retur Dikirim' : 'Pengajuan Retur',
                desc: _submitted
                    ? 'Pengajuan diterima oleh BUMDes Sukorejo'
                    : 'Menunggu pengajuan dari pembeli',
                active: _submitted,
                done: _submitted,
                last: false,
              ),
              _returnStep(
                title: 'Pemeriksaan BUMDes',
                desc: 'Tim memeriksa kondisi barang dan bukti retur',
                active: false,
                done: false,
                last: false,
              ),
              _returnStep(
                title: 'Pengembalian Dana',
                desc: 'Dana dikembalikan sesuai hasil verifikasi',
                active: false,
                done: false,
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _returnStep({
    required String title,
    required String desc,
    required bool active,
    required bool done,
    required bool last,
  }) {
    final c = done ? AppColors.green : const Color(0xFFD1D8D3);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? c : Colors.white,
                    border: Border.all(color: c, width: 2),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: Colors.white)
                      : null,
                ),
                if (!last) Expanded(child: Container(width: 2, color: c)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: active ? AppColors.green : AppColors.text)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 9.5, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CancelledOrderScreen extends StatelessWidget {
  final OrderEntry order;

  const CancelledOrderScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final o = order;
    final m = orderMeta.metaOf(o.id);
    final refund = m.refundAmount;
    final when = m.cancelledAt ?? DateTime.now();
    final reason = m.cancelReason ?? 'Pesanan dibatalkan oleh pembeli';
    final refId = o.id.replaceFirst('#PSD', '#REF');

    return _FlowPage(
      title: 'Rincian Pembatalan',
      subtitle: o.id,
      showLogo: false,
      bottom: _bigButton(
        'Pesan Ulang',
        onTap: () => orderBuyAgain(context, o),
        icon: Icons.refresh_rounded,
      ),
      children: [
        _box(
          color: const Color(0xFFFFF4F5),
          border: const Color(0xFFFFD3D8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _kRed,
                    child: Icon(Icons.close_rounded,
                        color: Colors.white, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pesanan Dibatalkan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _kRed,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Nomor Pesanan  ',
                      style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
                  Text(o.id,
                      style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _dateLabel(when),
                style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle(
                'Rincian Pengembalian Dana',
                icon: Icons.account_balance_wallet_outlined,
                trailing: refund > 0
                    ? _pill('Masuk Instan', AppColors.green,
                        const Color(0xFFE1F5E9))
                    : null,
              ),
              if (refund > 0) ...[
                _kv('Metode Refund', 'Saldo Tabungan Koperasi'),
                _kv('No. Transaksi Refund', refId),
                _kv('Waktu Refund', _dateLabel(when)),
              ] else
                _kv('Metode Pembayaran', o.paymentLabel),
              const Divider(height: 18, color: Color(0xFFEEF2EF)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      refund > 0
                          ? 'Total Dana Kembali ke Saldo'
                          : 'Tidak ada dana yang dikembalikan',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    formatRupiahId(refund),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Alasan Pembatalan',
                  icon: Icons.info_outline_rounded),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.storefront_outlined,
                      size: 18, color: AppColors.green),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      o.seller,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, size: 14, color: AppColors.green),
                ],
              ),
              const SizedBox(height: 6),
              for (final l in o.lines) _lineTile(l),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Rincian Pembayaran',
                  icon: Icons.receipt_long_outlined),
              _kv('Subtotal Produk (${o.itemCount} item)',
                  formatRupiahId(o.total)),
              _kv('Ongkos Kirim Desa', 'Gratis (Rp 0)',
                  valueColor: AppColors.green),
              const Divider(height: 18, color: Color(0xFFEEF2EF)),
              _kv('Total Pembayaran Semula', formatRupiahId(o.total),
                  bold: true, size: 13),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _box(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Riwayat Pembatalan', icon: Icons.history_rounded),
              _cancelStep(
                title: refund > 0
                    ? 'Dana Dikembalikan ke Saldo'
                    : 'Pembatalan Selesai',
                desc: refund > 0
                    ? '${formatRupiahId(refund)} masuk ke Tabungan Koperasi'
                    : 'Pesanan dibayar di tempat, tanpa refund',
                time: _dateLabel(when),
                done: true,
                last: false,
              ),
              _cancelStep(
                title: 'Pembatalan Disetujui',
                desc: 'Lapak membatalkan penyiapan pesanan',
                time: _dateLabel(when),
                done: true,
                last: false,
              ),
              _cancelStep(
                title: 'Pengajuan Pembatalan',
                desc: 'Diajukan oleh pembeli',
                time: _dateLabel(when),
                done: true,
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cancelStep({
    required String title,
    required String desc,
    required String time,
    required bool done,
    required bool last,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white),
                ),
                if (!last)
                  Expanded(
                    child: Container(width: 2, color: AppColors.green),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 2),
                  Text(desc,
                      style: const TextStyle(
                          fontSize: 10.5, color: AppColors.muted)),
                  const SizedBox(height: 2),
                  Text(time,
                      style: const TextStyle(
                          fontSize: 9.5, color: AppColors.muted)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourierChatScreen extends StatefulWidget {
  final OrderEntry order;

  const CourierChatScreen({super.key, required this.order});

  @override
  State<CourierChatScreen> createState() => _CourierChatScreenState();
}

class _CourierChatScreenState extends State<CourierChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await openCourierWhatsApp(context, widget.order);
      if (mounted) Navigator.maybePop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.green),
      ),
    );
  }
}
