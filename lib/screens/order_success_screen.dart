import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import '../widgets/app_image.dart';

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
  final String deliveryTitle;
  final String deliveryInfo;
  final String note;
  final bool isPaid;
  final List<dynamic> items;
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
        backgroundColor: const Color(0xFFF4F8F5),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
                  child: Column(
                    children: [
                      _hero(),
                      const SizedBox(height: 22),
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
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => _openHistory(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text(
                              'Lihat Status Pesanan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => _goHome(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFDCE8DF)),
                            backgroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Kembali ke Beranda',
                            style: TextStyle(
                              fontSize: 13,
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
        const Text(
          'Pesanan Berhasil Dibuat!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21,
            letterSpacing: -.35,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: 86,
          height: 86,
          decoration: const BoxDecoration(
            color: Color(0xFFE3F5E9),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 62,
              height: 62,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 13),
        const Text(
          'Pesanan Anda sudah diteruskan ke penjual melalui BUMDes '
          'Sukorejo. Mohon tunggu konfirmasi dan pengantaran.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.55,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }

  Widget _orderIdCard(BuildContext context) {
    const double borderWidth = 1.2;
    const double outerRadius = 19;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFB8E1C5), width: borderWidth),
        borderRadius: BorderRadius.circular(outerRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D123D25),
            blurRadius: 20,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(outerRadius - borderWidth),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.green,
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nomor Pesanan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          orderId,
                          style: const TextStyle(
                            fontSize: 16,
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
                        borderRadius: BorderRadius.circular(11),
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
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
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
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.location_on_outlined,
                size: 21, color: AppColors.green),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Titik Pengantaran Desa',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: '$receiverName ',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w900),
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
                      fontSize: 11.5, height: 1.45, color: AppColors.muted),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FBF3), Color(0xFFE8F7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFCDEBD6)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .85),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.two_wheeler_outlined,
                size: 20, color: AppColors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '$deliveryTitle: ',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
                TextSpan(
                  text: deliveryInfo,
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.45,
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
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
            child: Row(
              children: [
                const Icon(Icons.agriculture_outlined,
                    size: 18, color: AppColors.green),
                const SizedBox(width: 6),
                const Text('Poktan Krajan Makmur',
                    style:
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
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
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: smartImage(
                      p.image,
                      width: 66,
                      height: 66,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 66,
                        height: 66,
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
                                fontSize: 13, fontWeight: FontWeight.w900)),
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
                        TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
              ),
              Text(_rp(total),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green)),
            ],
          ),
          const SizedBox(height: 14),
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
                      fontSize: 21,
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
              style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
        ),
        Text(v,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: green ? AppColors.green : AppColors.text,
            )),
      ],
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(15),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE3ECE5)),
        borderRadius: BorderRadius.circular(17),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080D2818),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
