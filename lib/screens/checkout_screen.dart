import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';
import 'order_models.dart';
import 'order_success_screen.dart';
import 'topup_screen.dart';

enum DeliveryOption { kurir, ambil }

enum PayMethod { qris, cod, saldo }

enum QrisPaymentType { qris, transfer }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  static const int _kurirFee = 5000;

  int get _saldo => WalletBalance.balance.value;

  DeliveryOption _delivery = DeliveryOption.kurir;
  PayMethod? _pay = PayMethod.qris;
  bool _noteSaved = false;
  bool _loading = false;

  final _noteC = TextEditingController();

  String _name = 'Pak RT Joko';
  String _phone = '0812-3456-7890';
  String _address =
      'Dusun Krajan RT 02 / RW 01 (Pos Drop-point BUMDes Depan Balai Desa Sukorejo)';

  @override
  void dispose() {
    _noteC.dispose();
    super.dispose();
  }

  String formatRupiah(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]}.',
        );
  }

  String get _payLabel {
    switch (_pay) {
      case PayMethod.qris:
        return 'QRIS Desa / Transfer BUMDes';
      case PayMethod.cod:
        return 'Bayar di Tempat (COD)';
      case PayMethod.saldo:
        return 'Saldo PasarDesa';
      case null:
        return '-';
    }
  }

  Future<void> _editAddress() async {
    final result = await showModalBottomSheet<AddressData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddressSheet(
        data: AddressData(_name, _phone, _address),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _name = result.name;
        _phone = result.phone;
        _address = result.address;
      });
    }
  }

  Future<String?> _openQrisPayment(int total) async {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentChoiceScreen(total: total),
      ),
    );
  }

  Future<void> _submit(_OrderData o) async {
    if (_pay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih metode pembayaran dulu')),
      );
      return;
    }

    if (o.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada produk untuk checkout')),
      );
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    try {
      String paymentLabel;

      if (_pay == PayMethod.qris) {
        final paidLabel = await _openQrisPayment(o.total);
        if (!mounted) return;

        if (paidLabel == null) {
          setState(() => _loading = false);
          return;
        }
        paymentLabel = paidLabel;
      } else if (_pay == PayMethod.saldo) {
        if (o.total > _saldo) {
          setState(() => _loading = false);
          final action = await showPaymentFailedDialog(context);
          if (!mounted) return;
          if (action == PaymentFailedAction.retry) {
            await _submit(o);
          } else if (action == PaymentFailedAction.changeMethod) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Silakan pilih metode pembayaran lain')),
            );
          }
          return;
        }
        paymentLabel = 'Saldo Lunas';
      } else {
        paymentLabel = 'COD BUMDes';
      }

      if (!mounted) return;

      final now = DateTime.now();
      final id =
          'PSD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';

      if (_pay == PayMethod.saldo) {
        WalletBalance.balance.value = _saldo - o.total;
      }

      final note = _noteSaved ? _noteC.text.trim() : '';

      final lines = o.items.map<OrderLine>((line) {
        final product = line.product;
        return OrderLine(
          name: product.shortName,
          variant: '',
          price: product.price,
          qty: line.quantity,
          image: product.image,
        );
      }).toList();

      final courierTitle = _delivery == DeliveryOption.kurir
          ? 'Kurir Desa Sukorejo'
          : 'Ambil Mandiri di Pos BUMDes';

      final courierInfo = _delivery == DeliveryOption.kurir
          ? 'Estimasi diantar sore ini (15:00 - 17:00 WIB)'
          : 'Siap diambil setelah penjual mengonfirmasi';

      final entry = OrderEntry.fresh(
        id: id,
        seller: 'Poktan Krajan Makmur',
        lines: lines,
        total: o.total,
        paymentLabel: paymentLabel,
        courierTitle: courierTitle,
        courierInfo: courierInfo,
        receiverName: _name,
        receiverPhone: _phone,
        deliveryAddress: _address,
        deliveryNote: note,
      );

      orderStore.addOrder(entry);

      NotificationCenter.add(
        'Pesanan berhasil dibuat',
        'Pesanan $id sedang diproses penjual',
      );

      setState(() => _loading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderSuccessScreen(
            orderId: id,
            receiverName: _name,
            receiverPhone: _phone,
            address: _address,
            paymentLabel: _pay == PayMethod.qris ? paymentLabel : _payLabel,
            deliveryTitle: courierTitle,
            deliveryInfo: courierInfo,
            note: note,
            isPaid: _pay != PayMethod.cod,
            items: o.items,
            subtotal: o.subtotal,
            deliveryFee: o.fee,
            discount: o.discount,
            total: o.total,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final items = cart.items.where((i) => i.selected).toList();
        final subtotal = items.fold<int>(0, (s, i) => s + i.subtotal);
        final itemCount = items.fold<int>(0, (s, i) => s + i.quantity);
        final fee = _delivery == DeliveryOption.kurir ? _kurirFee : 0;
        final discount = cart.discount;
        final total = math.max(0, subtotal + fee - discount);
        final order = _OrderData(items, subtotal, fee, discount, total);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF8),
          body: SafeArea(
            child: Column(
              children: [
                const PasarDesaHeader(),
                _topBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _trustBanner(),
                        const SizedBox(height: 14),
                        _addressSection(),
                        const SizedBox(height: 16),
                        _deliverySection(),
                        const SizedBox(height: 16),
                        _sellerSection(items, subtotal, itemCount),
                        const SizedBox(height: 10),
                        _voucherRow(discount),
                        const SizedBox(height: 16),
                        _paymentSection(),
                        const SizedBox(height: 16),
                        _noteSection(),
                        const SizedBox(height: 16),
                        _summarySection(subtotal, fee, discount, total),
                        const SizedBox(height: 12),
                        const AmanahKasCard(),
                      ],
                    ),
                  ),
                ),
                _bottomBar(items.isEmpty, itemCount, total, order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E9E6))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.text),
          ),
          const Expanded(
            child: Text(
              'Checkout Pemesanan',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
          ),
          const Text('Langkah 2 dari 3',
              style: TextStyle(fontSize: 10, color: AppColors.muted)),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _trustBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined,
              size: 18, color: AppColors.green),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'BUMDes Sukorejo • Transaksi aman Pasar Desa',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.green,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Terverifikasi',
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _addressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('Alamat Pengiriman')),
            InkWell(
              onTap: _editAddress,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Text('Ubah Titik',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _card(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                    color: AppColors.greenLight, shape: BoxShape.circle),
                child: const Icon(Icons.location_on_outlined,
                    color: AppColors.green, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '$_name ',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w900)),
                      TextSpan(
                          text: '($_phone)',
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.muted)),
                    ])),
                    const SizedBox(height: 4),
                    Text(_address,
                        style: const TextStyle(
                            fontSize: 10.5,
                            height: 1.4,
                            color: AppColors.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Opsi Pengantaran Lokal'),
        const SizedBox(height: 8),
        _optionCard(
          selected: _delivery == DeliveryOption.kurir,
          onTap: () => setState(() => _delivery = DeliveryOption.kurir),
          icon: Icons.two_wheeler_outlined,
          title: 'Kurir Desa Sukorejo',
          badge: 'Cepat',
          subtitle: 'Estimasi diantar sore ini (15:00 - 17:00 WIB)',
          trailing: 'Rp ${formatRupiah(_kurirFee)}',
        ),
        const SizedBox(height: 8),
        _optionCard(
          selected: _delivery == DeliveryOption.ambil,
          onTap: () => setState(() => _delivery = DeliveryOption.ambil),
          icon: Icons.storefront_outlined,
          title: 'Ambil Mandiri di Pos BUMDes',
          subtitle: 'Siap diambil setelah penjual mengonfirmasi',
          trailing: 'Gratis',
          trailingGreen: true,
        ),
      ],
    );
  }

  Widget _optionCard({
    required bool selected,
    required VoidCallback onTap,
    required IconData icon,
    required String title,
    required String subtitle,
    required String trailing,
    String? badge,
    bool trailingGreen = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1FBF4) : Colors.white,
          border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
              width: selected ? 1.4 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.green),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Flexible(
                      child: Text(title,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(badge,
                            style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.orange.shade800)),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 9.5, color: AppColors.muted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(trailing,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: trailingGreen ? AppColors.green : AppColors.text)),
          ],
        ),
      ),
    );
  }

  Widget _sellerSection(List items, int subtotal, int itemCount) {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(10, 10, 10, 6),
          child: Row(children: [
            Icon(Icons.agriculture_outlined, size: 18, color: AppColors.green),
            SizedBox(width: 6),
            Text('Poktan Krajan Makmur',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
            SizedBox(width: 4),
            Icon(Icons.verified, size: 14, color: AppColors.green),
            Spacer(),
          ]),
        ),
        const Divider(height: 1, color: Color(0xFFE5E9E6)),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Belum ada produk.',
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
          ),
        ...items.map((line) {
          final product = line.product;
          return Padding(
            padding: const EdgeInsets.all(10),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(product.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                        width: 56,
                        height: 56,
                        color: AppColors.greenLight,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.green))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.shortName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Rp ${formatRupiah(product.price)}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.green,
                              fontWeight: FontWeight.w900)),
                    ]),
              ),
              Text('x${line.quantity}',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            ]),
          );
        }),
        const Divider(height: 1, color: Color(0xFFE5E9E6)),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(children: [
            Expanded(
                child: Text('Subtotal Kualitas ($itemCount item)',
                    style: const TextStyle(
                        fontSize: 10.5, color: AppColors.muted))),
            Text('Rp ${formatRupiah(subtotal)}',
                style: const TextStyle(
                    fontSize: 11.5, fontWeight: FontWeight.w900)),
          ]),
        ),
      ]),
    );
  }

  Widget _voucherRow(int discount) {
    return _card(
      child: Row(children: [
        Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(6)),
            child: Icon(Icons.local_activity_outlined,
                size: 18, color: Colors.red.shade400)),
        const SizedBox(width: 10),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('PANENRAYA',
                  style:
                      TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
              const SizedBox(width: 6),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Terpasang',
                      style: TextStyle(
                          fontSize: 8.5,
                          color: AppColors.green,
                          fontWeight: FontWeight.w800))),
            ]),
            const SizedBox(height: 3),
            Text(
                discount > 0
                    ? 'Subsidi Ongkir Desa -Rp ${formatRupiah(discount)}'
                    : 'Subsidi Ongkir Desa',
                style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
          ]),
        ),
      ]),
    );
  }

  Widget _paymentSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionTitle('Metode Pembayaran'),
      const SizedBox(height: 8),
      _payTile(
          value: PayMethod.qris,
          icon: Icons.qr_code_2,
          title: 'QRIS Desa / Transfer BUMDes',
          subtitle: 'QRIS, BCA, BRI, Mandiri, e-wallet'),
      const SizedBox(height: 8),
      _payTile(
          value: PayMethod.cod,
          icon: Icons.payments_outlined,
          title: 'Bayar di Tempat (COD) Pos BUMDes',
          subtitle: 'Bayar tunai saat pesanan diterima'),
      const SizedBox(height: 8),
      _payTile(
          value: PayMethod.saldo,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Saldo PasarDesa',
          subtitle: 'Saldo Rp ${formatRupiah(_saldo)}'),
    ]);
  }

  Widget _payTile({
    required PayMethod value,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _pay == value;
    return GestureDetector(
      onTap: () => setState(() => _pay = value),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: selected ? const Color(0xFFF1FBF4) : Colors.white,
            border: Border.all(
                color: selected ? AppColors.green : AppColors.border,
                width: selected ? 1.4 : 1),
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, size: 24, color: AppColors.text),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 11.5, fontWeight: FontWeight.w900)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 9.5, color: AppColors.muted)),
              ])),
          Icon(selected ? Icons.check_circle : Icons.circle_outlined,
              size: 20, color: selected ? AppColors.green : AppColors.muted),
        ]),
      ),
    );
  }

  Widget _noteSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Expanded(child: _SectionTitle('Catatan Pengiriman')),
        if (_noteSaved)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(20)),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_circle, size: 12, color: AppColors.green),
              SizedBox(width: 4),
              Text('Tersimpan',
                  style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green)),
            ]),
          ),
      ]),
      const SizedBox(height: 8),
      TextField(
        controller: _noteC,
        maxLines: 3,
        readOnly: _noteSaved,
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          hintText: 'Tulis pesan untuk penjual atau kurir desa...',
          hintStyle: const TextStyle(fontSize: 10.5, color: AppColors.muted),
          filled: true,
          fillColor: _noteSaved ? const Color(0xFFF1FBF4) : Colors.white,
          contentPadding: const EdgeInsets.all(10),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: _noteSaved ? AppColors.green : AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.green)),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        height: 40,
        child: _noteSaved
            ? OutlinedButton.icon(
                onPressed: () => setState(() => _noteSaved = false),
                icon: const Icon(Icons.edit_outlined,
                    size: 15, color: AppColors.green),
                label: const Text('Ubah Catatan',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green)),
                style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.green),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              )
            : ElevatedButton.icon(
                onPressed: () {
                  if (_noteC.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catatan masih kosong')));
                    return;
                  }
                  FocusScope.of(context).unfocus();
                  setState(() => _noteSaved = true);
                },
                icon: const Icon(Icons.save_outlined,
                    size: 15, color: Colors.white),
                label: const Text('Simpan Catatan',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
              ),
      ),
    ]);
  }

  Widget _summarySection(int subtotal, int fee, int discount, int total) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const _SectionTitle('Ringkasan Belanja'),
      const SizedBox(height: 8),
      _card(
        child: Column(children: [
          _summaryRow('Total harga produk', 'Rp ${formatRupiah(subtotal)}'),
          const SizedBox(height: 8),
          _summaryRow('Ongkos kirim', 'Rp ${formatRupiah(fee)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _summaryRow('Subsidi Kupon Desa', '- Rp ${formatRupiah(discount)}',
                green: true),
          ],
          const SizedBox(height: 8),
          _summaryRow('Biaya layanan', 'Gratis Warga', green: true),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1)),
          _summaryRow('Total Pembayaran', 'Rp ${formatRupiah(total)}',
              bold: true, green: true),
        ]),
      ),
    ]);
  }

  Widget _summaryRow(String title, String value,
      {bool bold = false, bool green = false}) {
    return Row(children: [
      Expanded(
          child: Text(title,
              style: TextStyle(
                  fontSize: bold ? 12 : 10.5,
                  color: bold ? AppColors.text : AppColors.muted,
                  fontWeight: bold ? FontWeight.w900 : FontWeight.w500))),
      Text(value,
          style: TextStyle(
              fontSize: bold ? 14 : 10.5,
              color: green ? AppColors.green : AppColors.text,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w700)),
    ]);
  }

  Widget _bottomBar(bool empty, int itemCount, int total, _OrderData order) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E9E6)))),
      child: SafeArea(
        top: false,
        child: Row(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Tagihan ($itemCount item)',
                style: const TextStyle(fontSize: 9.5, color: AppColors.muted)),
            Text('Rp ${formatRupiah(total)}',
                style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.green,
                    fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(width: 14),
          Expanded(
            child: GreenButton(
              text: _loading ? 'Memproses...' : 'Checkout →',
              onTap: (empty || _loading) ? null : () => _submit(order),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(10),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8)),
      child: child,
    );
  }
}

class _OrderData {
  final List items;
  final int subtotal;
  final int fee;
  final int discount;
  final int total;

  const _OrderData(
      this.items, this.subtotal, this.fee, this.discount, this.total);
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.text));
}

class AddressData {
  final String name;
  final String phone;
  final String address;

  const AddressData(this.name, this.phone, this.address);
}

class AddressSheet extends StatefulWidget {
  final AddressData data;
  const AddressSheet({super.key, required this.data});

  @override
  State<AddressSheet> createState() => _AddressSheetState();
}

class _AddressSheetState extends State<AddressSheet> {
  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _addrC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.data.name);
    _phoneC = TextEditingController(text: widget.data.phone);
    _addrC = TextEditingController(text: widget.data.address);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _addrC.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11, color: AppColors.muted),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.green)),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Ubah Titik Pengantaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        TextField(
            controller: _nameC, decoration: _dec('Masukkan nama penerima')),
        const SizedBox(height: 10),
        TextField(
            controller: _phoneC,
            keyboardType: TextInputType.phone,
            decoration: _dec('Masukkan nomor HP')),
        const SizedBox(height: 10),
        TextField(
            controller: _addrC,
            maxLines: 3,
            decoration: _dec('Masukkan alamat / titik drop-point')),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: GreenButton(
            text: 'Simpan Alamat',
            onTap: () {
              if (_nameC.text.trim().isEmpty || _addrC.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Nama dan alamat wajib diisi')));
                return;
              }
              Navigator.pop(
                  context,
                  AddressData(_nameC.text.trim(), _phoneC.text.trim(),
                      _addrC.text.trim()));
            },
          ),
        ),
      ]),
    );
  }
}

class PaymentChoiceScreen extends StatelessWidget {
  final int total;
  const PaymentChoiceScreen({super.key, required this.total});

  String _rp(int value) => value
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: const Text('Pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _paymentTotal('Total yang harus dibayar', 'Rp ${_rp(total)}'),
        const SizedBox(height: 16),
        const Text('Pilih cara pembayaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        _methodCard(context,
            icon: Icons.qr_code_2,
            title: 'QRIS',
            subtitle: 'Scan menggunakan GoPay, DANA, OVO, mobile banking, dll.',
            onTap: () async {
          final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                  builder: (_) => QrisPaymentScreen(total: total)));
          if (context.mounted && result != null) Navigator.pop(context, result);
        }),
        const SizedBox(height: 10),
        _methodCard(context,
            icon: Icons.account_balance_outlined,
            title: 'Transfer Bank BUMDes',
            subtitle: 'Transfer ke rekening BUMDes Sukorejo.', onTap: () async {
          final result = await Navigator.push<String>(
              context,
              MaterialPageRoute(
                  builder: (_) => BankTransferPaymentScreen(total: total)));
          if (context.mounted && result != null) Navigator.pop(context, result);
        }),
        const SizedBox(height: 16),
        _info('Pesanan baru dibuat setelah pembayaran berhasil dikonfirmasi.'),
      ]),
    );
  }

  Widget _paymentTotal(String a, String b) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Expanded(
            child: Text(a,
                style: const TextStyle(fontSize: 11, color: AppColors.muted))),
        Text(b,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.green)),
      ]));

  Widget _methodCard(BuildContext context,
      {required IconData icon,
      required String title,
      required String subtitle,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: AppColors.green)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 10.5, height: 1.35, color: AppColors.muted)),
              ])),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ]),
      ),
    );
  }

  Widget _info(String text) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.greenLight, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        const Icon(Icons.info_outline, size: 18, color: AppColors.green),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 10.5, color: AppColors.green, height: 1.35))),
      ]));
}

class QrisPaymentScreen extends StatelessWidget {
  final int total;
  const QrisPaymentScreen({super.key, required this.total});

  String _rp(int value) => value
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.text,
          elevation: 0,
          title: const Text('Bayar dengan QRIS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        _totalCard(),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            const Text('Scan QRIS BUMDes Sukorejo',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Container(
              width: 220,
              height: 220,
              padding: const EdgeInsets.all(10),
              color: Colors.white,
              child: CustomPaint(painter: _FakeQrPainter()),
            ),
            const SizedBox(height: 10),
            const Text('Gunakan aplikasi pembayaran yang mendukung QRIS.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, color: AppColors.muted)),
          ]),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () => _confirm(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Saya Sudah Bayar',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Untuk prototype ini, tombol konfirmasi mensimulasikan pembayaran berhasil. Produksi harus memakai status pembayaran dari backend/webhook.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 9.5, color: AppColors.muted, height: 1.35),
        ),
      ]),
    );
  }

  Widget _totalCard() => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppColors.greenLight, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        const Expanded(
            child: Text('Total pembayaran',
                style: TextStyle(fontSize: 11, color: AppColors.muted))),
        Text('Rp ${_rp(total)}',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.green)),
      ]));

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Pembayaran',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
            'Pastikan Anda sudah membayar sesuai nominal. Lanjutkan konfirmasi?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Belum')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white),
              child: const Text('Ya, Sudah Bayar')),
        ],
      ),
    );
    if (ok == true && context.mounted) Navigator.pop(context, 'QRIS Lunas');
  }
}

class BankTransferPaymentScreen extends StatelessWidget {
  final int total;
  const BankTransferPaymentScreen({super.key, required this.total});

  String _rp(int value) => value
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.text,
          elevation: 0,
          title: const Text('Transfer Bank BUMDes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Transfer ke rekening BUMDes',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            _bankRow('Bank', 'BRI'),
            _bankRow('Nomor Rekening', '1234 5678 9012'),
            _bankRow('Nama', 'BUMDes Sukorejo'),
            const Divider(height: 20),
            _bankRow('Nominal', 'Rp ${_rp(total)}', green: true),
          ]),
        ),
        const SizedBox(height: 14),
        _step(1, 'Transfer tepat sebesar nominal pembayaran.'),
        _step(2, 'Simpan bukti transfer jika diperlukan.'),
        _step(3, 'Tekan tombol konfirmasi setelah transfer selesai.'),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () => _confirm(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('Saya Sudah Transfer',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ]),
    );
  }

  Widget _bankRow(String a, String b, {bool green = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(
            child: Text(a,
                style:
                    const TextStyle(fontSize: 10.5, color: AppColors.muted))),
        Text(b,
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: green ? AppColors.green : AppColors.text)),
      ]));

  Widget _step(int n, String text) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CircleAvatar(
            radius: 11,
            backgroundColor: AppColors.green,
            child: Text('$n',
                style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w900))),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 10.5, color: AppColors.muted, height: 1.35))),
      ]));

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Transfer',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text(
            'Pastikan transfer sudah berhasil dan nominalnya sesuai. Lanjutkan?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Belum')),
          ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white),
              child: const Text('Ya, Sudah Transfer')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Navigator.pop(context, 'Transfer BUMDes Lunas');
    }
  }
}

class _FakeQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black;
    final cell = size.width / 29;

    void square(int x, int y, int n) {
      canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, n * cell, n * cell), p);
      final white = Paint()..color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(
              (x + 1) * cell, (y + 1) * cell, (n - 2) * cell, (n - 2) * cell),
          white);
      canvas.drawRect(
          Rect.fromLTWH(
              (x + 2) * cell, (y + 2) * cell, (n - 4) * cell, (n - 4) * cell),
          p);
    }

    square(0, 0, 7);
    square(22, 0, 7);
    square(0, 22, 7);

    final seed = <int>[17, 2, 8, 25, 13, 6, 21, 10, 28, 4, 16, 24, 12, 19];
    for (int y = 0; y < 29; y++) {
      for (int x = 0; x < 29; x++) {
        if ((x < 8 && y < 8) || (x >= 21 && y < 8) || (x < 8 && y >= 21)) {
          continue;
        }
        if ((x * 7 + y * 11 + seed[(x + y) % seed.length]) % 5 < 2) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), p);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
