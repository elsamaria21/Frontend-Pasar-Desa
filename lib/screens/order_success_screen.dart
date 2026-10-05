import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';

String _rp(int value) {
  return 'Rp ${value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      )}';
}

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final String receiverName;
  final String receiverPhone;
  final String address;
  final String paymentLabel;
  final String deliveryTitle; // contoh: Kurir Desa Sukorejo
  final String deliveryInfo; // contoh: Estimasi diantar sore ini (...)
  final String note;
  final bool isPaid; // false untuk COD
  final List<dynamic> items; // item keranjang yang dipilih
  final int subtotal;
  final int deliveryFee;
  final int discount;
  final int total;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.receiverName,
    required this.receiverPhone,
    required this.address,
    required this.paymentLabel,
    required this.deliveryTitle,
    required this.deliveryInfo,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    this.note = '',
    this.isPaid = true,
  });

  void _openHistory(BuildContext context) {
    DashboardNav.goTo(context, 3);
  }

  void _goHome(BuildContext context) {
    DashboardNav.goTo(context, 0);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        body: SafeArea(
          child: Column(
            children: [
              const PasarDesaHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    children: [
                      _hero(),
                      const SizedBox(height: 16),
                      _orderIdCard(context),
                      const SizedBox(height: 12),
                      _addressCard(),
                      const SizedBox(height: 8),
                      _courierCard(),
                      if (note.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _noteCard(),
                      ],
                      const SizedBox(height: 12),
                      _productsCard(),
                      const SizedBox(height: 12),
                      _paymentDetail(),
                      const SizedBox(height: 12),
                      const AmanahKasCard(),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: GreenButton(
                          text: 'Lihat Status Pesanan',
                          onTap: () => _openHistory(context),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => _goHome(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Kembali ke Beranda',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hero() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: const BoxDecoration(
            color: AppColors.greenLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 34),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFBFE5CB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 13, color: AppColors.green),
              const SizedBox(width: 5),
              Text(
                isPaid ? 'LUNAS & TERVERIFIKASI' : 'TERVERIFIKASI',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Pesanan Berhasil Dibuat!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pesanan Anda sudah diteruskan ke penjual melalui BUMDes '
          'Sukorejo. Mohon tunggu konfirmasi dan pengantaran.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 11, height: 1.5, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _orderIdCard(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.green),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.green,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nomor Pesanan',
                          style: TextStyle(
                            fontSize: 9.5,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          orderId,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: orderId));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nomor pesanan disalin')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.copy_rounded,
                          size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Dibayar',
                            style: TextStyle(
                                fontSize: 9.5, color: AppColors.muted)),
                        const SizedBox(height: 2),
                        Text(
                          _rp(total),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Metode',
                          style:
                              TextStyle(fontSize: 9.5, color: AppColors.muted)),
                      const SizedBox(height: 2),
                      Text(
                        paymentLabel,
                        style: const TextStyle(
                            fontSize: 10.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressCard() {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_outlined,
                size: 18, color: AppColors.green),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Titik Pengantaran Desa',
                    style: TextStyle(fontSize: 9.5, color: AppColors.muted)),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '$receiverName ',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                      text: '($receiverPhone)',
                      style:
                          const TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ]),
                ),
                const SizedBox(height: 3),
                Text(
                  address,
                  style: const TextStyle(
                      fontSize: 10.5, height: 1.4, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _courierCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FBF4),
        border: Border.all(color: const Color(0xFFCDEBD6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.two_wheeler_outlined,
              size: 20, color: AppColors.green),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$deliveryTitle: ',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
                TextSpan(
                  text: deliveryInfo,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: AppColors.text,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteCard() {
    return _card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sticky_note_2_outlined,
              size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catatan Pengiriman',
                    style: TextStyle(fontSize: 9.5, color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(note, style: const TextStyle(fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _productsCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
            child: Row(
              children: [
                const Icon(Icons.agriculture_outlined,
                    size: 18, color: AppColors.green),
                const SizedBox(width: 6),
                const Text('Poktan Krajan Makmur',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 14, color: AppColors.green),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Petani Lokal',
                      style: TextStyle(
                          fontSize: 9,
                          color: AppColors.green,
                          fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E9E6)),
          ...items.map((line) {
            final p = line.product;
            return Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      p.image,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: AppColors.greenLight,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.shortName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(_rp(p.price),
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.green,
                                fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  Text('x${line.quantity}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.muted)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _paymentDetail() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Rincian Pembayaran',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              Text(_rp(total),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 10),
          _row('Subtotal Produk', _rp(subtotal)),
          const SizedBox(height: 6),
          _row('Ongkos Kirim', _rp(deliveryFee)),
          if (discount > 0) ...[
            const SizedBox(height: 6),
            _row('Subsidi Kupon Desa', '- ${_rp(discount)}', green: true),
          ],
          const SizedBox(height: 6),
          _row('Biaya Layanan', 'Gratis Warga', green: true),
          const SizedBox(height: 6),
          _row('Metode Pembayaran', paymentLabel),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Expanded(
                child: Text('Total Pembayaran',
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
              ),
              Text(_rp(total),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String t, String v, {bool green = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(t,
              style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
        ),
        Text(v,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: green ? AppColors.green : AppColors.text,
            )),
      ],
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(12),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
