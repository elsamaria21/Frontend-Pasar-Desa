import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'address_screen.dart' show AddressBook;
import 'dashboard_screen.dart'
    show DashboardNav, NotificationCenter, showTopUpSheet;
import 'order_models.dart' show OrderEntry, OrderLine, OrderStatus;
import 'order_flow_screens.dart' show OrderOverrides, orderBuyAgain;
import 'order_tracking_screen.dart';
import 'order_ui.dart';

String _clock(OrderEntry o, int plusMinutes) {
  final m = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(o.dateLabel);
  var total = m == null
      ? 10 * 60
      : int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  total = (total + plusMinutes) % (24 * 60);
  final h = (total ~/ 60).toString().padLeft(2, '0');
  final mm = (total % 60).toString().padLeft(2, '0');
  return '$h:$mm WIB';
}

String _datePart(OrderEntry o) => o.dateLabel.split('•').first.trim();

int _subtotal(OrderEntry o) => o.lines.fold(0, (s, l) => s + l.price * l.qty);

int _otherFees(OrderEntry o) {
  final diff = o.total - _subtotal(o);
  return diff < 0 ? 0 : diff;
}

Widget _lineTile(OrderLine l) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: Image.asset(
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
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                ),
              ),
              if (l.variant.isNotEmpty)
                Text(
                  l.variant,
                  style: const TextStyle(fontSize: 9.5, color: AppColors.muted),
                ),
              const SizedBox(height: 2),
              Text(
                rp(l.price),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ),
        Text('${l.qty} Barang',
            style: const TextStyle(fontSize: 10, color: AppColors.muted)),
      ],
    ),
  );
}

Widget _sellerCard(OrderEntry o, {String? badge}) {
  return OCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.storefront_outlined,
                size: 18, color: AppColors.green),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                o.seller,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.verified, size: 14, color: AppColors.green),
            const Spacer(),
            if (badge != null) Pill(badge),
          ],
        ),
        const Divider(height: 18, color: Color(0xFFEEF2EF)),
        for (final l in o.lines) _lineTile(l),
      ],
    ),
  );
}

Widget _bar(List<Widget> children) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: kLine)),
    ),
    child: Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: children[i]),
        ],
      ],
    ),
  );
}

class OrderDetailScreen extends StatelessWidget {
  final OrderEntry order;

  const OrderDetailScreen({super.key, required this.order});

  static const _cancelReasons = [
    'Salah memilih produk',
    'Ingin mengubah pesanan',
    'Menemukan harga lebih baik',
    'Lainnya',
  ];

  static const _returnReasons = [
    'Kemasan sobek & barang tercecer',
    'Produk tidak segar / rusak',
    'Jumlah tidak sesuai pesanan',
    'Lainnya',
  ];

  Future<String?> _pickReason(
    BuildContext context,
    String title,
    String note,
    List<String> options,
    String confirmText,
  ) {
    String selected = options.first;

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
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
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      note,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final r in options)
                      InkWell(
                        onTap: () => setState(() => selected = r),
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 12),
                          decoration: BoxDecoration(
                            color: selected == r
                                ? const Color(0xFFEAF7EF)
                                : const Color(0xFFF7FAF8),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: selected == r
                                  ? AppColors.green
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  r,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (selected == r)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.green, size: 20),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    OButton(
                      confirmText,
                      onTap: () => Navigator.pop(sheetContext, selected),
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

  Future<void> _cancel(BuildContext context) async {
    final reason = await _pickReason(
      context,
      'Batalkan Pesanan?',
      'Pilih alasan pembatalan. Dana akan dikembalikan ke Saldo Kas '
          'PasarDesa Anda.',
      _cancelReasons,
      'Ya, Batalkan Pesanan',
    );
    if (reason == null || !context.mounted) return;

    OrderOverrides.cancelReasons[order.id] = reason;
    OrderOverrides.setStatus(order.id, OrderStatus.dibatalkan);
    NotificationCenter.add(
      'Pesanan dibatalkan',
      'Pesanan ${order.id} dibatalkan. Dana dikembalikan ke saldo.',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OrderCancelScreen(order: order)),
    );
  }

  Future<void> _return(BuildContext context) async {
    final reason = await _pickReason(
      context,
      'Ajukan Retur',
      'Pilih alasan pengembalian barang.',
      _returnReasons,
      'Ajukan Retur',
    );
    if (reason == null || !context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderReturnScreen(order: order, reason: reason),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, OrderStatus>>(
      valueListenable: OrderOverrides.status,
      builder: (context, _, __) {
        final status = OrderOverrides.of(order);
        final legacyAddress = AddressBook.selected;
        final receiverName = order.receiverName.trim().isNotEmpty
            ? order.receiverName.trim()
            : legacyAddress.name;
        final deliveryAddress = order.deliveryAddress.trim().isNotEmpty
            ? order.deliveryAddress.trim()
            : '${legacyAddress.dusun}\n${legacyAddress.area}';

        final Color fg;
        final Color bg;
        final IconData icon;
        switch (status) {
          case OrderStatus.diproses:
            fg = const Color(0xFF1D6FB8);
            bg = const Color(0xFFE8F2FB);
            icon = Icons.inventory_2_outlined;
            break;
          case OrderStatus.dikirim:
            fg = const Color(0xFFD97706);
            bg = const Color(0xFFFFF4E0);
            icon = Icons.two_wheeler_outlined;
            break;
          case OrderStatus.selesai:
            fg = AppColors.green;
            bg = AppColors.greenLight;
            icon = Icons.check_circle_outline_rounded;
            break;
          case OrderStatus.dibatalkan:
            fg = Colors.red.shade600;
            bg = Colors.red.shade50;
            icon = Icons.cancel_outlined;
            break;
        }

        final List<Widget> actions;
        switch (status) {
          case OrderStatus.diproses:
            actions = [
              OButton('Batalkan',
                  filled: false,
                  color: AppColors.red,
                  onTap: () => _cancel(context)),
              OButton('Lacak Pesanan',
                  icon: Icons.near_me_outlined,
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(order: order),
                        ),
                      )),
            ];
            break;
          case OrderStatus.dikirim:
            actions = [
              OButton('Lacak Pesanan',
                  icon: Icons.near_me_outlined,
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderTrackingScreen(order: order),
                        ),
                      )),
            ];
            break;
          case OrderStatus.selesai:
            actions = [
              OButton('Ajukan Retur',
                  filled: false, onTap: () => _return(context)),
              OButton('Beli Lagi',
                  icon: Icons.refresh,
                  onTap: () => orderBuyAgain(context, order)),
            ];
            break;
          case OrderStatus.dibatalkan:
            actions = [
              OButton('Lihat Pembatalan',
                  filled: false,
                  onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderCancelScreen(order: order),
                        ),
                      )),
              OButton('Beli Lagi',
                  icon: Icons.refresh,
                  onTap: () => orderBuyAgain(context, order)),
            ];
            break;
        }

        return OrderPageScaffold(
          title: 'Detail Pesanan',
          subtitle: order.id,
          bottomBar: _bar(actions),
          children: [
            OCard(
              color: bg,
              borderColor: fg.withAlpha(89),
              child: Row(
                children: [
                  Icon(icon, size: 30, color: fg),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel(status),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: fg,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.dateLabel,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _sellerCard(order, badge: 'Mitra BUMDes'),
            OCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('Informasi Pengiriman',
                      icon: Icons.location_on_outlined),
                  KV('Penerima', receiverName),
                  KV('Titik Pengantaran', deliveryAddress),
                  const KV('Kurir', 'Kurir Desa Sukorejo'),
                ],
              ),
            ),
            OCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('Rincian Pembayaran',
                      icon: Icons.receipt_long_outlined),
                  KV('Subtotal Produk', rp(_subtotal(order))),
                  KV('Ongkir & Biaya Layanan', rp(_otherFees(order))),
                  KV('Metode Pembayaran', order.paymentLabel),
                  const Divider(height: 14, color: Color(0xFFEEF2EF)),
                  KV('Total Pembayaran', rp(order.total), bold: true),
                ],
              ),
            ),
            const GuaranteeCard(
              title: 'Jaminan Transaksi Resmi BUMDes',
              body: 'Seluruh transaksi diawasi Kas BUMDes Sukorejo. Untuk '
                  'komplain & bantuan, hubungi Pos Pelayanan Balai Desa.',
            ),
          ],
        );
      },
    );
  }
}

class OrderCancelScreen extends StatelessWidget {
  final OrderEntry order;

  const OrderCancelScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final reason = OrderOverrides.cancelReasons[order.id] ??
        'Ingin mengubah pesanan / salah produk';
    final refundNo = '#RFN-${order.id.replaceAll('#PSD-', '')}';

    return OrderPageScaffold(
      title: 'Rincian Pembatalan',
      subtitle: order.id,
      children: [
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.red.shade50,
                    child: Icon(Icons.cancel_outlined,
                        size: 21, color: Colors.red.shade600),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Pesanan Dibatalkan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                  ),
                  const Pill('Selesai'),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Pengembalian dana sebesar ${rp(order.total)} telah berhasil '
                'dikembalikan ke Saldo Kas PasarDesa Anda.',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_datePart(order)}, ${_clock(order, 6)}',
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
              const Divider(height: 18, color: Color(0xFFEEF2EF)),
              KV('Nomor Pesanan', order.id),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                'Rincian Pengembalian Dana',
                icon: Icons.account_balance_wallet_outlined,
                trailing: Pill('Masuk Instan'),
              ),
              const KV('Metode Refund', 'Saldo Kas PasarDesa'),
              KV('No. Transaksi Refund', refundNo),
              KV('Waktu Pencairan', '${_datePart(order)}, ${_clock(order, 6)}'),
              const Divider(height: 14, color: Color(0xFFEEF2EF)),
              KV('Total Dana Dikembalikan', rp(order.total),
                  bold: true, valueColor: AppColors.green),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 16, color: AppColors.green),
                    SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'Dana telah masuk ke Saldo Anda. Silakan gunakan '
                        'untuk berbelanja kembali.',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.green,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading('Alasan Pembatalan',
                  icon: Icons.edit_note_rounded),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kLine),
                ),
                child: Text(
                  '"$reason"',
                  style: const TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const KV('Dibatalkan oleh', 'Pembeli (Disetujui Otomatis)'),
            ],
          ),
        ),
        _sellerCard(order),
        OCard(
          child: Column(
            children: [
              KV('Subtotal Produk', rp(_subtotal(order))),
              KV('Ongkir & Biaya Layanan', rp(_otherFees(order))),
              const Divider(height: 14, color: Color(0xFFEEF2EF)),
              KV('Total Pembayaran Semula', rp(order.total), bold: true),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading('Riwayat Pembatalan',
                  icon: Icons.history_rounded),
              TimelineList(
                entries: [
                  TimelineEntry(
                    title: 'Dana Dikembalikan ke Saldo',
                    detail: 'Refund diteruskan otomatis oleh Kas BUMDes.',
                    time: _clock(order, 6),
                    state: TlState.done,
                  ),
                  TimelineEntry(
                    title: 'Pembatalan Disetujui',
                    detail: 'Sistem menyetujui pembatalan secara otomatis.',
                    time: _clock(order, 4),
                    state: TlState.done,
                  ),
                  TimelineEntry(
                    title: 'Pengajuan Pembatalan Dibuat',
                    detail: 'Pembeli mengajukan pembatalan pesanan.',
                    time: _clock(order, 2),
                    state: TlState.done,
                  ),
                  TimelineEntry(
                    title: 'Pesanan Dibuat',
                    detail: 'Pesanan ${order.id} dibuat.',
                    time: _clock(order, 0),
                    state: TlState.done,
                  ),
                ],
              ),
            ],
          ),
        ),
        OButton(
          'Riwayat Pesanan',
          filled: false,
          onTap: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
            DashboardNav.tab.value = 3;
          },
        ),
        const SizedBox(height: 10),
        OButton(
          'Beli Lagi Produk',
          icon: Icons.refresh,
          onTap: () => orderBuyAgain(context, order),
        ),
      ],
    );
  }
}

class OrderReturnScreen extends StatelessWidget {
  final OrderEntry order;
  final String reason;

  const OrderReturnScreen({
    super.key,
    required this.order,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final line = order.lines.first;
    final refund = line.price * line.qty;
    final digits = order.id.replaceAll('#PSD-', '');

    return OrderPageScaffold(
      title: 'Detail Retur',
      subtitle: 'RET-$digits',
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kLine)),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Status Pengajuan',
                      style: TextStyle(fontSize: 9.5, color: AppColors.muted)),
                  SizedBox(height: 2),
                  Text(
                    'Dana Siap Dicairkan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: kInk,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 170,
              child: OButton(
                'Konfirmasi Terima',
                icon: Icons.check_circle_outline_rounded,
                onTap: () {
                  NotificationCenter.add(
                    'Retur selesai',
                    'Dana ${rp(refund)} dari retur ${order.id} diterima.',
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Dana retur dikonfirmasi diterima'),
                      ),
                    );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      children: [
        OCard(
          color: const Color(0xFFF2FBF5),
          borderColor: AppColors.green.withAlpha(128),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Pill('Pengembalian Disetujui',
                      icon: Icons.check_circle_outline,
                      fg: Colors.white,
                      bg: AppColors.green),
                  const Spacer(),
                  Text(
                    '${_datePart(order)}, ${_clock(order, 90)}',
                    style: const TextStyle(fontSize: 9, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Total Dana Dikembalikan',
                  style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: rp(refund),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                    const TextSpan(
                      text: '  (100% Utuh)',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Dana langsung dikembalikan ke Saldo Kas PasarDesa Anda, '
                'tanpa potongan administrasi.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const Divider(height: 20, color: Color(0xFFD7EBDD)),
              KV('No. Retur', '#RET-$digits'),
              KV('No. Pesanan Asal', order.id),
            ],
          ),
        ),
        _sellerCard(
          OrderEntry(
            id: order.id,
            seller: order.seller,
            dateLabel: order.dateLabel,
            status: order.status,
            lines: [line],
            total: order.total,
            paymentLabel: order.paymentLabel,
          ),
          badge: 'Mitra BUMDes',
        ),
        OCard(
          color: const Color(0xFFFFF8F4),
          borderColor: const Color(0xFFF3D9C8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ALASAN PENGAJUAN RETUR',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                reason,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '"Pesanan sampai dalam kondisi tidak sesuai. Mohon '
                'ditinjau dan dikembalikan dananya."',
                style: TextStyle(
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading('Foto Bukti Kerusakan Pembeli',
                  icon: Icons.photo_camera_outlined),
              Row(
                children: [
                  Expanded(child: _proof('Bukti Kemasan Sobek.jpg')),
                  const SizedBox(width: 10),
                  Expanded(child: _proof('Kondisi Barang.jpg')),
                ],
              ),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                'Riwayat Verifikasi Dana',
                icon: Icons.fact_check_outlined,
                trailing: Pill('3 Langkah Selesai'),
              ),
              TimelineList(
                entries: [
                  TimelineEntry(
                    title: 'Komplain Diajukan',
                    detail: 'Laporan kerusakan beserta foto bukti berhasil '
                        'dikirim.',
                    time: _clock(order, 60),
                    state: TlState.done,
                  ),
                  TimelineEntry(
                    title: 'Ditinjau Petugas BUMDes',
                    detail: 'Keputusan Amanah: disetujui, dana dikembalikan '
                        '100% tanpa wajib kirim balik barang.',
                    time: _clock(order, 75),
                    state: TlState.done,
                  ),
                  TimelineEntry(
                    title: 'Pengembalian Dana Berhasil',
                    detail: 'Kredit ${rp(refund)} masuk ke Saldo Kas Anda.',
                    time: _clock(order, 90),
                    state: TlState.done,
                  ),
                ],
              ),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading('Rincian Pengembalian Dana',
                  icon: Icons.receipt_long_outlined),
              const KV('Metode Pencairan', 'Saldo Kas BUMDes'),
              KV('Harga Barang (${line.qty} item)', rp(refund)),
              const KV('Ongkir Kurir Desa', 'GRATIS (GARANSI)',
                  valueColor: AppColors.green),
              const KV('Biaya Layanan Aplikasi', 'Rp 0'),
              const Divider(height: 14, color: Color(0xFFEEF2EF)),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Total Dana Dikembalikan',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    rp(refund),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Pill('LUNAS'),
                ],
              ),
              const SizedBox(height: 8),
              KV('No. Referensi Kas', 'SLD-SKR-$digits'),
            ],
          ),
        ),
        const GuaranteeCard(
          title: 'Jaminan Amanah BUMDes Sukorejo',
          body: 'Uang Anda aman. Setiap pengembalian dana diawasi langsung '
              'oleh Kas BUMDes Sukorejo sampai tuntas.',
        ),
        OButton(
          'Buka Saldo',
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => showTopUpSheet(context),
        ),
      ],
    );
  }

  Widget _proof(String caption) {
    return Column(
      children: [
        Container(
          height: 92,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2EF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.image_outlined,
              size: 30, color: AppColors.muted),
        ),
        const SizedBox(height: 4),
        Text(
          caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9, color: AppColors.muted),
        ),
      ],
    );
  }
}
