import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../data/address_book.dart';
import '../data/repositories/order_repository.dart'
    show OrderItemInput, ServerOrder;
import '../providers/order_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_failed_dialog.dart';
import 'dashboard_screen.dart';
import 'order_models.dart';
import 'order_success_screen.dart';
import 'payment_screen.dart' show PaymentScreen, paymentChangeMethodResult;
import 'topup_screen.dart';
import '../widgets/app_image.dart';

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

  static const String _voucherCode = 'PANENRAYA';
  static const int _voucherValue = 5000;

  int get _saldo => WalletBalance.balance.value;

  DeliveryOption _delivery = DeliveryOption.kurir;
  PayMethod? _pay = PayMethod.qris;
  bool _noteSaved = false;
  bool _loading = false;
  bool _voucherApplied = false;

  final _noteC = TextEditingController();
  final _voucherC = TextEditingController();

  static const int _maxAddresses = 4;

  List<AddressData> _addresses = [];
  int _selectedAddress = 0;
  bool _addressesReady = false;
  bool _addressListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _initializeAddressBook();
  }

  Future<void> _initializeAddressBook() async {
    try {
      await AddressBook.init();
      if (!mounted) return;

      AddressBook.addresses.addListener(_onSharedAddressesChanged);
      _addressListenerAttached = true;

      setState(() {
        _loadSharedAddresses();
        _addressesReady = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _addresses = [];
        _selectedAddress = 0;
        _addressesReady = true;
      });
      _toast('Alamat belum dapat dimuat. Silakan coba lagi.');
    }
  }

  void _loadSharedAddresses({String? preserveId}) {
    _addresses = AddressBook.snapshot().map(_toCheckoutAddress).toList();

    if (_addresses.isEmpty) {
      _selectedAddress = 0;
      return;
    }

    final preservedIndex = preserveId == null
        ? -1
        : _addresses.indexWhere((address) => address.id == preserveId);
    final mainIndex = _addresses.indexWhere((address) => address.isMain);

    if (preservedIndex >= 0) {
      _selectedAddress = preservedIndex;
    } else if (mainIndex >= 0) {
      _selectedAddress = mainIndex;
    } else {
      _selectedAddress = 0;
    }
  }

  AddressData _toCheckoutAddress(AddressItem address) {
    final savedDusun = address.dusun.trim();
    final hasRtRwInDusun =
        RegExp(r'\bRT\b|\bRW\b', caseSensitive: false).hasMatch(savedDusun);
    final legacyRegion = [
      if (savedDusun.isNotEmpty) savedDusun,
      if (!hasRtRwInDusun && address.rt.trim().isNotEmpty)
        'RT ${address.rt.trim()}',
      if (!hasRtRwInDusun && address.rw.trim().isNotEmpty)
        'RW ${address.rw.trim()}',
    ].join(', ');
    final detail = address.detail.trim();
    final fullAddress = [
      if (legacyRegion.isNotEmpty) legacyRegion,
      if (detail.isNotEmpty) detail,
    ].join(', ');

    return AddressData(
      address.recipient,
      address.phone,
      fullAddress,
      id: address.id,
      label: address.label,
      isMain: address.isPrimary,
      dusun: '',
      detail: fullAddress,
      courierNote: '',
      pickupPoint: address.pickupPoint,
    );
  }

  List<AddressItem> _toSharedAddresses(List<AddressData> list) {
    return List.generate(list.length, (index) {
      final address = list[index];
      final fullAddress = address.detail.trim().isNotEmpty
          ? address.detail.trim()
          : address.address.trim();

      return AddressItem(
        id: address.id.isNotEmpty
            ? address.id
            : 'shared-address-${DateTime.now().microsecondsSinceEpoch}-$index',
        recipient: address.name,
        phone: address.phone,
        dusun: '',
        rt: '',
        rw: '',
        detail: fullAddress,
        note: '',
        label: address.label,
        pickupPoint: address.pickupPoint,
        isPrimary: address.isMain,
      );
    });
  }

  void _onSharedAddressesChanged() {
    if (!mounted) return;
    final preserveId = _addresses.isNotEmpty &&
            _selectedAddress >= 0 &&
            _selectedAddress < _addresses.length
        ? _addresses[_selectedAddress].id
        : null;
    setState(() => _loadSharedAddresses(preserveId: preserveId));
  }

  AddressData get _currentAddress => _addresses[_selectedAddress];
  String get _name => _currentAddress.name;
  String get _phone => _currentAddress.phone;
  String get _address => _currentAddress.address;

  @override
  void dispose() {
    if (_addressListenerAttached) {
      AddressBook.addresses.removeListener(_onSharedAddressesChanged);
    }
    _noteC.dispose();
    _voucherC.dispose();
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

  void _toast(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  /// Notifikasi singkat bergaya "produk masuk keranjang":
  /// kartu hijau gelap, judul tebal putih, teks kedua dengan bagian
  /// yang disorot hijau muda. Tanpa tombol dan tidak pindah halaman
  /// saat disentuh.
  ///
  /// Notifikasi ini tampil di BAGIAN ATAS layar (di bawah status bar).
  void _showNotice(
    String title,
    String message, {
    String? highlight,
    int milliseconds = 2600,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final media = MediaQuery.of(context);

    // Floating SnackBar secara bawaan menempel di bawah. Dengan margin
    // bawah yang besar, kartunya terdorong ke atas layar.
    // 120 = perkiraan tinggi kartu + jarak dari status bar.
    final bottomMargin = math.max(
      16.0,
      media.size.height - media.padding.top - 120,
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          dismissDirection: DismissDirection.up,
          duration: Duration(milliseconds: milliseconds),
          margin: EdgeInsets.fromLTRB(14, 0, 14, bottomMargin),
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF073D27),
              borderRadius: BorderRadius.circular(17),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: Color(0xFFD4E9DC),
                      fontSize: 12,
                      height: 1.3,
                    ),
                    children: [
                      if (highlight != null)
                        TextSpan(
                          text: highlight,
                          style: const TextStyle(
                            color: Color(0xFF8DE0AE),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      TextSpan(
                        text: highlight != null ? ' $message' : message,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  /// Notifikasi "Pembayaran dibatalkan": tampil di ATAS layar, tanpa ikon.
  void _showPaymentCancelledNotice() {
    final messenger = ScaffoldMessenger.of(context);
    final media = MediaQuery.of(context);

    // Margin bawah besar mendorong SnackBar floating ke atas layar.
    final bottomMargin = math.max(
      16.0,
      media.size.height - media.padding.top - 120,
    );

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          dismissDirection: DismissDirection.up,
          duration: const Duration(milliseconds: 2800),
          margin: EdgeInsets.fromLTRB(14, 0, 14, bottomMargin),
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF073D27),
              borderRadius: BorderRadius.circular(17),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pembayaran dibatalkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pesanan tidak jadi dibuat.',
                  style: TextStyle(
                    color: Color(0xFFD4E9DC),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void _applyVoucher() {
    final code = _voucherC.text.trim().toUpperCase();

    if (code.isEmpty) {
      _toast('Masukkan kode voucher terlebih dahulu');
      return;
    }

    if (code != _voucherCode) {
      _toast('Kode voucher tidak valid');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _voucherApplied = true);
    _toast('Voucher $_voucherCode berhasil dipasang');
  }

  void _removeVoucher() {
    setState(() {
      _voucherApplied = false;
      _voucherC.clear();
    });
  }

  Future<void> _openAddressSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddressListSheet(
        addresses: _addresses,
        selectedIndex: _selectedAddress,
        maxAddresses: _maxAddresses,
        onChanged: (list, selected) {
          if (!mounted) return;
          setState(() {
            _addresses = List<AddressData>.of(list);
            _selectedAddress =
                list.isEmpty ? 0 : selected.clamp(0, list.length - 1).toInt();
          });
          unawaited(
            AddressBook.replace(_toSharedAddresses(list)).catchError((error) {
              if (mounted) {
                _toast('Alamat belum berhasil disimpan. Coba lagi.');
              }
            }),
          );
        },
      ),
    );
  }

  Future<String?> _openQrisPayment(int total) async {
    final now = DateTime.now();
    final ref =
        'PSD-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}';

    return Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          total: total,
          orderRef: ref,
          cartCount: context.read<CartProvider>().items.length,
        ),
      ),
    );
  }

  Future<void> _submit(_OrderData o) async {
    if (!_addressesReady || _addresses.isEmpty) {
      _toast('Tambahkan alamat pengiriman terlebih dahulu.');
      if (_addressesReady) await _openAddressSheet();
      return;
    }

    if (_pay == null) {
      _showNotice(
        'Metode pembayaran belum dipilih',
        'metode pembayaran dulu.',
        highlight: 'Silakan pilih',
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

    ServerOrder? serverOrder;
    var orderTuntas = false;

    try {
      if (_pay == PayMethod.saldo && o.total > _saldo) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _pay = null;
        });
        _toast(
          'Saldo PasarDesa tidak cukup. Saldo Anda Rp ${formatRupiah(_saldo)}, '
          'sedangkan total pembayaran Rp ${formatRupiah(o.total)}. '
          'Silakan pilih metode pembayaran lain.',
        );
        return;
      }

      final catatanAlamat = _currentAddress.courierNote.trim();
      final catatanUser = _noteSaved ? _noteC.text.trim() : '';

      serverOrder = await orderStore.kirimPesanan(
        items: o.items
            .map((l) => OrderItemInput(
                  productId: l.product.id,
                  quantity: l.quantity,
                ))
            .toList(),
        receiverName: _name,
        receiverPhone: _phone,
        address: _address,
        delivery:
            _delivery == DeliveryOption.kurir ? 'kurir-desa' : 'ambil-mandiri',
        paymentMethod: _pay == PayMethod.qris
            ? 'QRIS'
            : _pay == PayMethod.saldo
                ? 'Saldo PasarDesa'
                : 'COD BUMDes',
        landmark: catatanAlamat,
        note: catatanUser,
        voucherCode: _voucherApplied ? _voucherCode : '',
      );

      if (serverOrder.total != o.total) {
        final serverTotal = serverOrder.total;
        await orderStore.batalkanDiServer(serverOrder.id);
        serverOrder = null;
        throw StateError(
          'Total pesanan dari server (Rp ${formatRupiah(serverTotal)}) '
          'tidak sama dengan total checkout (Rp ${formatRupiah(o.total)}). '
          'Silakan muat ulang keranjang.',
        );
      }

      String paymentLabel;

      if (_pay == PayMethod.qris) {
        final paidLabel = await _openQrisPayment(o.total);
        if (!mounted) {
          try {
            await orderStore.batalkanDiServer(serverOrder.id);
          } catch (cleanupError) {
            debugPrint(
                'Gagal membatalkan pesanan setelah layar checkout ditutup: $cleanupError');
          }
          return;
        }

        if (paidLabel == paymentChangeMethodResult) {
          await orderStore.batalkanDiServer(serverOrder.id);
          serverOrder = null;
          if (!mounted) return;
          setState(() {
            _loading = false;
            _pay = null;
          });
          _showNotice(
            'Pilih metode pembayaran',
            'metode pembayaran lain.',
            highlight: 'Silakan pilih',
          );
          return;
        }

        if (paidLabel == null) {
          await orderStore.batalkanDiServer(serverOrder.id);
          serverOrder = null;
          if (!mounted) return;
          setState(() {
            _loading = false;
            _pay = null;
          });
          _showPaymentCancelledNotice();
          return;
        }

        paymentLabel = paidLabel;
      } else if (_pay == PayMethod.saldo) {
        paymentLabel = 'Saldo Lunas';
      } else {
        paymentLabel = 'COD BUMDes';
      }

      if (!mounted) return;

      final id = serverOrder.kode;

      final userNote = _noteSaved ? _noteC.text.trim() : '';
      final addressNote = _currentAddress.courierNote.trim();
      final note = [
        if (addressNote.isNotEmpty) addressNote,
        if (userNote.isNotEmpty) userNote,
      ].join(' • ');

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

      await orderStore.addOrder(entry);
      if (_pay == PayMethod.saldo) {
        WalletBalance.balance.value = _saldo - o.total;
      }
      orderTuntas = true;

      if (!mounted) return;

      context.read<CartProvider>().removeSelected();

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
      final dibuat = serverOrder;
      if (dibuat != null && !orderTuntas) {
        try {
          await orderStore.batalkanDiServer(dibuat.id);
        } catch (cleanupError) {
          debugPrint(
              'Gagal membatalkan pesanan saat checkout gagal: $cleanupError');
        }
      }
      if (!mounted) return;
      setState(() => _loading = false);
      await _handleFailure(o, describeCheckoutError(e));
    }
  }

  Future<void> _handleFailure(_OrderData o, String reason) async {
    if (!mounted) return;

    final action = await showCheckoutFailedDialog(context, reason: reason);
    if (!mounted) return;

    if (action == CheckoutFailAction.retry) {
      await _submit(o);
    } else {
      setState(() => _pay = null);
      _showNotice(
        'Pilih metode pembayaran',
        'metode pembayaran lain.',
        highlight: 'Silakan pilih',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final items =
            cart.items.where((i) => i.selected && !i.isOutOfStock).toList();
        final subtotal = items.fold<int>(0, (s, i) => s + i.subtotal);
        final itemCount = items.fold<int>(0, (s, i) => s + i.quantity);
        final fee = _delivery == DeliveryOption.kurir ? _kurirFee : 0;
        final discount = (_delivery == DeliveryOption.kurir && _voucherApplied)
            ? math.min(fee, _voucherValue)
            : 0;

        final total = math.max(0, subtotal + fee - discount);
        final order = _OrderData(items, subtotal, fee, discount, total);

        return Scaffold(
          backgroundColor: const Color(0xFFF3F7F4),
          body: SafeArea(
            child: Column(
              children: [
                _topBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _addressSection(),
                        const SizedBox(height: 24),
                        _deliverySection(),
                        const SizedBox(height: 24),
                        _sellerSection(items, subtotal, itemCount),
                        const SizedBox(height: 16),
                        _voucherRow(discount),
                        const SizedBox(height: 24),
                        _paymentSection(),
                        const SizedBox(height: 24),
                        _noteSection(),
                        const SizedBox(height: 24),
                        _summarySection(subtotal, fee, discount, total),
                      ],
                    ),
                  ),
                ),
                _bottomBar(
                    items.isEmpty || !_addressesReady || _addresses.isEmpty,
                    total,
                    order),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _topBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE7EEE8)),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x080D2818),
            blurRadius: 16,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            splashRadius: 22,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.text,
            ),
          ),
          const Expanded(
            child: Text(
              'Checkout Pemesanan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.45,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressSection() {
    final hasAddress = _addresses.isNotEmpty &&
        _selectedAddress >= 0 &&
        _selectedAddress < _addresses.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('Alamat Pengiriman')),
            InkWell(
              onTap: _addressesReady ? _openAddressSheet : null,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Text(
                  hasAddress ? 'Ubah Alamat' : 'Tambah Alamat',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        if (!_addressesReady)
          _card(
            child: const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Memuat alamat tersimpan...',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          )
        else if (!hasAddress)
          _emptyAddressCard()
        else
          _card(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.green,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${_currentAddress.name} ',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            TextSpan(
                              text: '(${_currentAddress.phone})',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        _currentAddress.address,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.muted,
                        ),
                      ),
                      if (_currentAddress.isMain) ...[
                        const SizedBox(height: 9),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F6ED),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Alamat utama',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _emptyAddressCard() {
    return _card(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              size: 32,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'Belum Ada Alamat Pengiriman',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Tambahkan alamat Anda agar kurir dapat mengantar pesanan Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _openAddressSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Tambah Alamat Pertama',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _deliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Opsi Pengantaran Lokal'),
        const SizedBox(height: 10),
        _optionCard(
          selected: _delivery == DeliveryOption.kurir,
          onTap: () => setState(() => _delivery = DeliveryOption.kurir),
          icon: Icons.two_wheeler_outlined,
          title: 'Kurir Desa Sukorejo',
          badge: 'Cepat',
          subtitle: 'Estimasi diantar sore ini (15:00 - 17:00 WIB)',
          trailing: 'Rp ${formatRupiah(_kurirFee)}',
        ),
        const SizedBox(height: 10),
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3FBF5) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.green : const Color(0xFFE5EBE6),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  selected ? const Color(0x160B7A3E) : const Color(0x060D2818),
              blurRadius: selected ? 18 : 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 24, color: AppColors.green),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 7,
                    runSpacing: 3,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.green,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  trailing,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: trailingGreen ? AppColors.green : AppColors.text,
                  ),
                ),
                if (selected) ...[
                  const SizedBox(height: 5),
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.green,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sellerSection(List items, int subtotal, int itemCount) {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Row(
              children: [
                Icon(
                  Icons.agriculture_outlined,
                  size: 22,
                  color: AppColors.green,
                ),
                SizedBox(width: 8),
                Text(
                  'Poktan Krajan Makmur',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(width: 5),
                Icon(Icons.verified_rounded, size: 15, color: AppColors.green),
                Spacer(),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDF1ED)),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Text(
                'Belum ada produk.',
                style: TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ),
          ...items.map((line) {
            final product = line.product;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: smartImage(
                      product.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 70,
                        height: 70,
                        color: AppColors.greenLight,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.shortName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Rp ${formatRupiah(product.price)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE9EEE9)),
                    ),
                    child: Text(
                      'x${line.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 1, color: Color(0xFFEDF1ED)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Subtotal Kualitas ($itemCount item)',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                Text(
                  'Rp ${formatRupiah(subtotal)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _voucherIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.local_activity_outlined,
        size: 22,
        color: AppColors.green,
      ),
    );
  }

  Widget _voucherRow(int discount) {
    if (_voucherApplied) {
      final isPickup = _delivery == DeliveryOption.ambil;

      final description = isPickup
          ? 'Terpasang, tetapi gratis ongkir hanya berlaku untuk Kurir Desa'
          : 'Gratis ongkir -Rp ${formatRupiah(discount)}';

      return _card(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _voucherIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          _voucherCode,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Terpasang',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color:
                          isPickup ? Colors.orange.shade800 : AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _removeVoucher,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.red,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(40, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lepas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      );
    }

    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _voucherIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kode Voucher',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gratis ongkir Rp ${formatRupiah(_voucherValue)} untuk Kurir Desa',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _voucherC,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _applyVoucher(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan kode, mis. $_voucherCode',
                      hintStyle: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFFBFCFB),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: Color(0xFFE5EBE6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(13),
                        borderSide: const BorderSide(
                          color: AppColors.green,
                          width: 1.3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _applyVoucher,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Pasang',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Metode Pembayaran'),
        const SizedBox(height: 10),
        _payTile(
          value: PayMethod.qris,
          icon: Icons.qr_code_2,
          title: 'QRIS Desa / Transfer BUMDes',
          subtitle: 'QRIS, BCA, BRI, Mandiri, e-wallet',
        ),
        const SizedBox(height: 10),
        _payTile(
          value: PayMethod.cod,
          icon: Icons.payments_outlined,
          title: 'Bayar di Tempat (COD) Pos BUMDes',
          subtitle: 'Bayar tunai saat pesanan diterima',
        ),
        const SizedBox(height: 10),
        _payTile(
          value: PayMethod.saldo,
          icon: Icons.account_balance_wallet_outlined,
          title: 'Saldo PasarDesa',
          subtitle: 'Saldo Rp ${formatRupiah(_saldo)}',
        ),
      ],
    );
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF3FBF5) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.green : const Color(0xFFE5EBE6),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color:
                  selected ? const Color(0x160B7A3E) : const Color(0x060D2818),
              blurRadius: selected ? 18 : 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, size: 24, color: AppColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 20,
              color: selected ? AppColors.green : const Color(0xFFB7C1BA),
            ),
          ],
        ),
      ),
    );
  }

  Widget _noteSection() {
    // Garis tepi kotak catatan berwarna hijau supaya jelas terlihat
    // walaupun kotak masih kosong (tanpa teks contoh).
    const noteBorder = AppColors.green;
    const noteBorderSaved = Color(0xFF9CCFAE);

    OutlineInputBorder noteOutline(Color color, [double width = 1.3]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(child: _SectionTitle('Catatan Pengiriman')),
            if (_noteSaved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 12, color: AppColors.green),
                    SizedBox(width: 5),
                    Text(
                      'Tersimpan',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 9),
        TextField(
          controller: _noteC,
          maxLines: 3,
          readOnly: _noteSaved,
          style: const TextStyle(
            fontSize: 14,
            height: 1.4,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _noteSaved ? const Color(0xFFF6FBF7) : Colors.white,
            contentPadding: const EdgeInsets.all(16),
            border: noteOutline(_noteSaved ? noteBorderSaved : noteBorder),
            enabledBorder:
                noteOutline(_noteSaved ? noteBorderSaved : noteBorder),
            focusedBorder: noteOutline(AppColors.green, 1.6),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: _noteSaved
              ? OutlinedButton.icon(
                  onPressed: () => setState(() => _noteSaved = false),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.green,
                  ),
                  label: const Text(
                    'Ubah Catatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.green),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )
              : ElevatedButton(
                  onPressed: () {
                    if (_noteC.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catatan masih kosong')),
                      );
                      return;
                    }
                    FocusScope.of(context).unfocus();
                    setState(() => _noteSaved = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Catatan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _summarySection(int subtotal, int fee, int discount, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Ringkasan Belanja'),
        const SizedBox(height: 9),
        _card(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _summaryRow('Total harga produk', 'Rp ${formatRupiah(subtotal)}'),
              const SizedBox(height: 13),
              _summaryRow('Ongkos kirim', 'Rp ${formatRupiah(fee)}'),
              if (discount > 0) ...[
                const SizedBox(height: 13),
                _summaryRow(
                  'Voucher Gratis Ongkir',
                  '- Rp ${formatRupiah(discount)}',
                  green: true,
                ),
              ],
              const SizedBox(height: 13),
              _summaryRow('Biaya layanan', 'Gratis Warga', green: true),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Divider(height: 1, color: Color(0xFFE9EEE9)),
              ),
              _summaryRow(
                'Total Pembayaran',
                'Rp ${formatRupiah(total)}',
                bold: true,
                green: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
    bool green = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: bold ? 12.5 : 11,
              color: bold ? AppColors.text : AppColors.muted,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 14.5 : 11.5,
            color: green ? AppColors.green : AppColors.text,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _bottomBar(
    bool empty,
    int total,
    _OrderData order,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 13),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE9EEE9))),
        boxShadow: [
          BoxShadow(
            color: Color(0x080D2818),
            blurRadius: 18,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Total Pembayaran',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Rp ${formatRupiah(total)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x220B7A3E),
                      blurRadius: 13,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: (empty || _loading) ? null : () => _submit(order),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    disabledBackgroundColor: const Color(0xFFB8C8BE),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Checkout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.15,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5EEE7)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x090D2818),
            blurRadius: 22,
            offset: Offset(0, 6),
          ),
        ],
      ),
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
    this.items,
    this.subtotal,
    this.fee,
    this.discount,
    this.total,
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.2,
          color: AppColors.text,
        ),
      );
}

class AddressData {
  final String id;
  final String name;
  final String phone;

  final String address;
  final String label;
  final bool isMain;

  final String dusun;
  final String detail;
  final String courierNote;
  final String? pickupPoint;

  const AddressData(
    this.name,
    this.phone,
    this.address, {
    this.id = '',
    this.label = 'Rumah',
    this.isMain = false,
    this.dusun = '',
    this.detail = '',
    this.courierNote = '',
    this.pickupPoint,
  });

  AddressData copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? label,
    bool? isMain,
    String? dusun,
    String? detail,
    String? courierNote,
    String? pickupPoint,
  }) {
    return AddressData(
      name ?? this.name,
      phone ?? this.phone,
      address ?? this.address,
      id: id ?? this.id,
      label: label ?? this.label,
      isMain: isMain ?? this.isMain,
      dusun: dusun ?? this.dusun,
      detail: detail ?? this.detail,
      courierNote: courierNote ?? this.courierNote,
      pickupPoint: pickupPoint ?? this.pickupPoint,
    );
  }
}

const Color _kAddrSoft = Color(0xFFEAF7EE);
const Color _kAddrSoftBorder = Color(0xFFCDEBD6);

class AddressListSheet extends StatefulWidget {
  final List<AddressData> addresses;
  final int selectedIndex;
  final int maxAddresses;
  final void Function(List<AddressData> addresses, int selectedIndex) onChanged;

  const AddressListSheet({
    super.key,
    required this.addresses,
    required this.selectedIndex,
    required this.maxAddresses,
    required this.onChanged,
  });

  @override
  State<AddressListSheet> createState() => _AddressListSheetState();
}

class _AddressListSheetState extends State<AddressListSheet> {
  late List<AddressData> _list;
  late int _selected;

  @override
  void initState() {
    super.initState();
    _list = List.of(widget.addresses);
    _selected = _list.isEmpty
        ? -1
        : widget.selectedIndex.clamp(0, _list.length - 1).toInt();
  }

  bool get _isFull => _list.length >= widget.maxAddresses;

  void _emit() => widget.onChanged(List.of(_list), _selected);

  void _normalizeMain({int? preferIndex}) {
    if (_list.isEmpty) return;
    int main = preferIndex ?? _list.indexWhere((a) => a.isMain);
    if (main < 0) main = 0;

    for (int i = 0; i < _list.length; i++) {
      final shouldBeMain = i == main;
      if (_list[i].isMain != shouldBeMain) {
        _list[i] = _list[i].copyWith(isMain: shouldBeMain);
      }
    }
  }

  Future<AddressData?> _openForm({AddressData? initial}) {
    return Navigator.push<AddressData>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutAddressFormScreen(initial: initial),
      ),
    );
  }

  Future<void> _add() async {
    if (_isFull) return;

    final result = await _openForm();
    if (result == null || !mounted || _isFull) return;

    setState(() {
      _list.add(result);
      _selected = _list.length - 1;
      _normalizeMain(preferIndex: result.isMain ? _list.length - 1 : null);
    });
    _emit();
  }

  Future<void> _edit(int index) async {
    final result = await _openForm(initial: _list[index]);
    if (result == null || !mounted) return;

    setState(() {
      _list[index] = result;
      _normalizeMain(preferIndex: result.isMain ? index : null);
    });
    _emit();
  }

  void _select(int index) {
    if (index < 0 || index >= _list.length) return;
    setState(() => _selected = index);
    _emit();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Alamat Pengiriman',
                      style: TextStyle(
                        fontSize: 20.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 22, color: AppColors.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_list.isEmpty) _emptyListState(),
                      for (int i = 0; i < _list.length; i++) _addressCard(i),
                      _addButton(),
                      if (_isFull) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Maksimal ${widget.maxAddresses} alamat. '
                          'Alamat yang sudah ada masih bisa diubah.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
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

  Widget _emptyListState() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4ECE6)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 36,
            color: AppColors.green,
          ),
          SizedBox(height: 10),
          Text(
            'Belum ada alamat tersimpan',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Isi data Anda dengan benar dan sesuai titik lokasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(int index) {
    final a = _list[index];
    final selected = index == _selected;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _select(index),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? _kAddrSoft : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (a.isMain) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B7A3E),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'ALAMAT UTAMA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : const Color(0xFFF1F3F2),
                      borderRadius: BorderRadius.circular(5),
                      border: selected
                          ? Border.all(color: const Color(0xFFE0E5E2))
                          : null,
                    ),
                    child: Text(
                      a.label,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 24,
                    color: selected ? AppColors.green : const Color(0xFFC3CBC6),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${a.name} ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    if (a.phone.isNotEmpty)
                      TextSpan(
                        text: '(${a.phone})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                a.address,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Spacer(),
                  InkWell(
                    onTap: () => _edit(index),
                    borderRadius: BorderRadius.circular(6),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ubah Alamat',
                            style: TextStyle(
                              fontSize: 13,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _addButton() {
    final full = _isFull;

    return Material(
      color: full ? const Color(0xFFEEF1EF) : AppColors.green,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: full ? null : _add,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Center(
            child: Text(
              full
                  ? 'Batas ${widget.maxAddresses} Alamat Tercapai'
                  : _list.isEmpty
                      ? 'Tambah Alamat Pertama'
                      : 'Tambah Alamat Baru (${_list.length}/${widget.maxAddresses})',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: full ? AppColors.muted : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const Color _kFormText = Color(0xFF10231B);

class _LabelOpt {
  final String name;
  final IconData icon;

  const _LabelOpt(this.name, this.icon);
}

const List<_LabelOpt> _kLabelOpts = [
  _LabelOpt('Rumah', Icons.home_outlined),
  _LabelOpt('Toko / Lapak', Icons.storefront_outlined),
  _LabelOpt('Kantor Desa', Icons.account_balance_outlined),
];

class _PinSpot {
  final Alignment align;
  final String coord;

  const _PinSpot(this.align, this.coord);
}

const List<_PinSpot> _kPinSpots = [
  _PinSpot(Alignment(0, -0.1), '-7.5381, 110.8294'),
  _PinSpot(Alignment(-0.35, 0.1), '-7.5384, 110.8290'),
  _PinSpot(Alignment(0.35, -0.25), '-7.5379, 110.8298'),
];

class CheckoutAddressFormScreen extends StatefulWidget {
  final AddressData? initial;

  const CheckoutAddressFormScreen({super.key, this.initial});

  @override
  State<CheckoutAddressFormScreen> createState() =>
      _CheckoutAddressFormScreenState();
}

class _CheckoutAddressFormScreenState extends State<CheckoutAddressFormScreen> {
  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _detailC;

  late String _label;
  late bool _isMain;
  int _pin = 0;
  bool _pinPreviewSelected = false;

  bool get _editing => widget.initial != null;
  bool get _lockMain => widget.initial?.isMain ?? false;

  static String _phoneToField(String phone) {
    var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('62')) {
      digits = '0${digits.substring(2)}';
    }
    return digits;
  }

  @override
  void initState() {
    super.initState();
    final address = widget.initial;

    _nameC = TextEditingController(text: address?.name ?? '');
    _phoneC = TextEditingController(
      text: _phoneToField(address?.phone ?? ''),
    );

    final initialDetail = address?.detail.trim().isNotEmpty == true
        ? address!.detail
        : address?.address ?? '';
    _detailC = TextEditingController(text: initialDetail);

    _label = _kLabelOpts.any((option) => option.name == address?.label)
        ? address!.label
        : _kLabelOpts.first.name;
    _isMain = address?.isMain ?? false;

    final savedPin = address?.pickupPoint;
    final savedPinIndex =
        _kPinSpots.indexWhere((spot) => spot.coord == savedPin);
    if (savedPinIndex >= 0) {
      _pin = savedPinIndex;
      _pinPreviewSelected = true;
    }
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _detailC.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameC.text.trim();
    final phoneRaw = _phoneC.text.trim();
    final detail = _detailC.text.trim();
    final phoneDigits = phoneRaw.replaceAll(RegExp(r'[^0-9]'), '');

    String? error;
    if (name.isEmpty) {
      error = 'Nama penerima wajib diisi';
    } else if (phoneDigits.length < 9) {
      error = 'Nomor telepon / WhatsApp belum benar';
    } else if (detail.isEmpty) {
      error = 'Alamat lengkap wajib diisi';
    }

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    var phone = phoneDigits;
    if (phone.startsWith('62')) {
      phone = '0${phone.substring(2)}';
    } else if (!phone.startsWith('0')) {
      phone = '0$phone';
    }

    Navigator.pop(
      context,
      AddressData(
        name,
        phone,
        detail,
        id: widget.initial?.id ??
            'address-${DateTime.now().microsecondsSinceEpoch}',
        label: _label,
        isMain: _isMain,
        dusun: '',
        detail: detail,
        courierNote: '',
        pickupPoint: _pinPreviewSelected
            ? _kPinSpots[_pin].coord
            : widget.initial?.pickupPoint,
      ),
    );
  }

  InputDecoration _decoration() {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      disabledBorder: border(AppColors.border),
      errorBorder: border(AppColors.red),
      focusedBorder: border(AppColors.green, 1.5),
      focusedErrorBorder: border(AppColors.red, 1.5),
      counterText: '',
    );
  }

  Widget _fieldLabel(String text, {bool required = false, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(
                text: text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _kFormText,
                ),
                children: [
                  if (required)
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(color: AppColors.red),
                    ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      splashRadius: 22,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _editing ? 'Ubah Alamat' : 'Tambah Alamat Baru',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _kFormText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabel('Nama Penerima', required: true),
                      TextField(
                        controller: _nameC,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(fontSize: 15),
                        decoration: _decoration(),
                      ),
                      _fieldLabel('Nomor Telepon', required: true),
                      TextField(
                        controller: _phoneC,
                        keyboardType: TextInputType.phone,
                        autofillHints: const [AutofillHints.telephoneNumber],
                        style: const TextStyle(fontSize: 15),
                        decoration: _decoration(),
                      ),
                      _fieldLabel('Alamat Lengkap', required: true),
                      TextField(
                        controller: _detailC,
                        minLines: 3,
                        maxLines: 3,
                        maxLength: 150,
                        style: const TextStyle(fontSize: 15, height: 1.35),
                        decoration: _decoration().copyWith(
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 13, 12, 13),
                        ),
                      ),
                      _fieldLabel('Pilihan Label Alamat'),
                      Row(
                        children: [
                          for (var i = 0; i < _kLabelOpts.length; i++) ...[
                            if (i > 0) const SizedBox(width: 6),
                            Expanded(child: _labelChip(_kLabelOpts[i])),
                          ],
                        ],
                      ),
                      _fieldLabel('Titik Lokasi Pengiriman'),
                      _mapCard(),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: _kAddrSoft,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _kAddrSoftBorder),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Jadikan sebagai Alamat Utama',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  color: _kFormText,
                                ),
                              ),
                            ),
                            Switch(
                              value: _isMain,
                              activeThumbColor: Colors.white,
                              activeTrackColor: AppColors.green,
                              onChanged: _lockMain
                                  ? null
                                  : (value) => setState(() => _isMain = value),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE3E7E4))),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Alamat',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
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

  Widget _mapCard() {
    final spot = _kPinSpots[_pin];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kAddrSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kAddrSoftBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 128,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _AddrMapPainter()),
                  ),
                  Align(
                    alignment: spot.align,
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.green,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                size: 18,
                color: AppColors.green,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Titik Lokasi Pengiriman',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: _kFormText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Koordinat pratinjau: ${spot.coord}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => setState(() {
                  _pin = (_pin + 1) % _kPinSpots.length;
                  _pinPreviewSelected = true;
                }),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Ubah Pin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelChip(_LabelOpt option) {
    final selected = _label == option.name;

    return InkWell(
      onTap: () => setState(() => _label = option.name),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.green : _kAddrSoft,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.green : _kAddrSoftBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              size: 14,
              color: selected ? Colors.white : AppColors.muted,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? Colors.white : AppColors.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddrMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = const Color(0xFFE1EAE4);
    canvas.drawRect(Offset.zero & size, background);

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final thinRoad = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.62),
      Offset(size.width, size.height * 0.38),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.42, size.height),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, 0),
      Offset(size.width * 0.8, size.height),
      thinRoad,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.28),
      thinRoad,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _paymentTotal('Total yang harus dibayar', 'Rp ${_rp(total)}'),
          const SizedBox(height: 16),
          const Text(
            'Pilih cara pembayaran',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _methodCard(
            context,
            icon: Icons.qr_code_2,
            title: 'QRIS',
            subtitle: 'Scan menggunakan GoPay, DANA, OVO, mobile banking, dll.',
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => QrisPaymentScreen(total: total),
                ),
              );
              if (context.mounted && result != null) {
                Navigator.pop(context, result);
              }
            },
          ),
          const SizedBox(height: 10),
          _methodCard(
            context,
            icon: Icons.account_balance_outlined,
            title: 'Transfer Bank BUMDes',
            subtitle: 'Transfer ke rekening BUMDes Sukorejo.',
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => BankTransferPaymentScreen(total: total),
                ),
              );
              if (context.mounted && result != null) {
                Navigator.pop(context, result);
              }
            },
          ),
          const SizedBox(height: 16),
          _info(
            'Pesanan baru dibuat setelah pembayaran berhasil dikonfirmasi.',
          ),
        ],
      ),
    );
  }

  Widget _paymentTotal(String a, String b) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                a,
                style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
            ),
            Text(
              b,
              style: const TextStyle(
                fontSize: 18.5,
                fontWeight: FontWeight.w900,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      );

  Widget _methodCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Widget _info(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: AppColors.green),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.green,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
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
        title: const Text(
          'Bayar dengan QRIS',
          style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _totalCard(),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Scan QRIS BUMDes Sukorejo',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Container(
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: CustomPaint(painter: _FakeQrPainter()),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Gunakan aplikasi pembayaran yang mendukung QRIS.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Saya Sudah Bayar',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Untuk prototype ini, tombol konfirmasi mensimulasikan pembayaran berhasil. Produksi harus memakai status pembayaran dari backend/webhook.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalCard() => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.greenLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Total pembayaran',
                style: TextStyle(fontSize: 12.5, color: AppColors.muted),
              ),
            ),
            Text(
              'Rp ${_rp(total)}',
              style: const TextStyle(
                fontSize: 20.5,
                fontWeight: FontWeight.w900,
                color: AppColors.green,
              ),
            ),
          ],
        ),
      );

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Konfirmasi Pembayaran',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Pastikan Anda sudah membayar sesuai nominal. Lanjutkan konfirmasi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Belum'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Sudah Bayar'),
          ),
        ],
      ),
    );

    if (ok == true && context.mounted) {
      Navigator.pop(context, 'QRIS Lunas');
    }
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
        title: const Text(
          'Transfer Bank BUMDes',
          style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transfer ke rekening BUMDes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                _bankRow('Bank', 'BRI'),
                _bankRow('Nomor Rekening', '1234 5678 9012'),
                _bankRow('Nama', 'BUMDes Sukorejo'),
                const Divider(height: 20),
                _bankRow('Nominal', 'Rp ${_rp(total)}', green: true),
              ],
            ),
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Saya Sudah Transfer',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bankRow(String a, String b, {bool green = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(
              child: Text(
                a,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ),
            Text(
              b,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: green ? AppColors.green : AppColors.text,
              ),
            ),
          ],
        ),
      );

  Widget _step(int n, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 11,
              backgroundColor: AppColors.green,
              child: Text(
                '$n',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );

  Future<void> _confirm(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'Konfirmasi Transfer',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Pastikan transfer sudah berhasil dan nominalnya sesuai. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Belum'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Sudah Transfer'),
          ),
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
      canvas.drawRect(
        Rect.fromLTWH(x * cell, y * cell, n * cell, n * cell),
        p,
      );

      final white = Paint()..color = Colors.white;
      canvas.drawRect(
        Rect.fromLTWH(
          (x + 1) * cell,
          (y + 1) * cell,
          (n - 2) * cell,
          (n - 2) * cell,
        ),
        white,
      );
      canvas.drawRect(
        Rect.fromLTWH(
          (x + 2) * cell,
          (y + 2) * cell,
          (n - 4) * cell,
          (n - 4) * cell,
        ),
        p,
      );
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
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell, cell),
            p,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
