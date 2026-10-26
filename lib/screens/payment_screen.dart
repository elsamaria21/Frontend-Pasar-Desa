import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'order_ui.dart' show rp;

const Color _green = Color(0xFF1B7F3C);
const Color _greenSoft = Color(0xFFE6F4EA);
const Color _greenBorder = Color(0xFFCDE6D5);
const Color _greenChip = Color(0xFFDCEFE2);
const Color _ink = Color(0xFF14201A);
const Color _muted = Color(0xFF1F2A24);
const Color _line = Color(0xFFE3E8E5);
const Color _fieldBg = Color(0xFFF1F5F2);
const Color _red = Color(0xFFC62828);
const Color _orange = Color(0xFFF59E0B);

enum PaymentTab { qris, transfer }

class _Bank {
  final String name;
  final String code;
  final String account;
  final String short;
  final Color color;

  const _Bank(this.name, this.code, this.account, this.short, this.color);
}

const List<_Bank> _banks = [
  _Bank('Bank Rakyat Indonesia', '002', '0142-01-002938-53-1', 'BRI',
      Color(0xFF1D5FA8)),
  _Bank('Bank Jatim Syariah / Daerah', '114', '144-00-9821345-0', 'JATIM',
      Color(0xFFE0782A)),
];

class PaymentScreen extends StatefulWidget {
  final int total;
  final String orderRef;
  final PaymentTab initialTab;
  final int cartCount;

  const PaymentScreen({
    super.key,
    required this.total,
    required this.orderRef,
    this.initialTab = PaymentTab.qris,
    this.cartCount = 0,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const int _limitSeconds = 15 * 60;

  late PaymentTab _tab = widget.initialTab;
  int _bank = 0;
  int _left = _limitSeconds;
  bool _showHow = true;
  bool _busy = false;
  Timer? _timer;

  String get _paymentId {
    final digits = widget.orderRef.replaceAll(RegExp(r'[^0-9]'), '');
    final tail =
        digits.length >= 5 ? digits.substring(digits.length - 5) : digits;
    return '#PD-SKR-$tail';
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _busy) return;
      if (_left <= 1) {
        _timer?.cancel();
        setState(() => _left = 0);
        _expired();
      } else {
        setState(() => _left--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _clock {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _copy(String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) _msg('$label disalin');
  }

  Future<void> _expired() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Waktu Pembayaran Habis',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        content: const Text(
          'Pembayaran tidak diselesaikan dalam batas waktu. Pesanan belum '
          'dibuat dan tidak ada dana yang terpotong.',
          style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Kembali',
                style: TextStyle(color: _green, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<bool> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Batalkan Pembayaran?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
        content: const Text(
          'Pesanan belum dibuat. Anda bisa kembali ke checkout dan '
          'memilih metode pembayaran lagi.',
          style: TextStyle(fontSize: 12, color: _muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Lanjut Bayar', style: TextStyle(color: _muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: _red, fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
    return leave == true;
  }

  Future<void> _verify() async {
    if (_busy) return;
    setState(() => _busy = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Row(
            children: [
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 3, color: _green),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text('Memverifikasi pembayaran Anda...',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    _timer?.cancel();
    Navigator.pop(
      context,
      _tab == PaymentTab.qris ? 'QRIS Lunas' : 'Transfer BUMDes Lunas',
    );
  }

  Future<void> _leaveToRoot() async {
    if (_busy) return;
    final leave = await _confirmLeave();
    if (leave && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _busy) return;
        final leave = await _confirmLeave();
        if (leave && context.mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  children: [
                    _timerCard(),
                    const SizedBox(height: 14),
                    _tabs(),
                    const SizedBox(height: 14),
                    if (_tab == PaymentTab.qris)
                      _qrisPanel()
                    else
                      _transferPanel(),
                    const SizedBox(height: 18),
                    _howCard(),
                    const SizedBox(height: 18),
                    _confirmButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _bottomNav(),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 6, 16, 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 24, color: _ink),
          ),
          const SizedBox(width: 2),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBFE0C9)),
                ),
                child: const Icon(Icons.shopping_bag_outlined,
                    size: 22, color: _green),
              ),
              Positioned(
                right: -6,
                top: -6,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.add, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: 'Pasar',
                    style: TextStyle(
                        color: _ink, fontWeight: FontWeight.w900, fontSize: 21),
                  ),
                  TextSpan(
                    text: 'Desa',
                    style: TextStyle(
                        color: _green,
                        fontWeight: FontWeight.w900,
                        fontSize: 21),
                  ),
                ]),
              ),
              Text(
                'UMKM DESA SUKOREJO',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: _green,
                  letterSpacing: 0.6,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _timerCard() {
    final urgent = _left <= 60;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _greenSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _greenBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _greenBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, size: 15, color: _ink),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Selesaikan Pembayaran Dalam:',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _ink),
                  ),
                ),
                Text(
                  _clock,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: urgent ? _red : _green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Tagihan Belanja',
                        style: TextStyle(fontSize: 12, color: _muted)),
                    const SizedBox(height: 3),
                    Text(
                      rp(widget.total),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                          height: 1.1),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: $_paymentId',
                      style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: _muted),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _copy(_paymentId, 'ID pembayaran'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _greenBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 14, color: _ink),
                      SizedBox(width: 5),
                      Text('Salin',
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: _ink)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    Widget tab(String text, IconData icon, PaymentTab value) {
      final selected = _tab == value;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tab = value),
          borderRadius: BorderRadius.circular(11),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: selected ? _green : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: selected ? Colors.white : _ink),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : _ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          tab('QRIS Desa', Icons.qr_code_2_rounded, PaymentTab.qris),
          const SizedBox(width: 4),
          tab('Transfer BUMDes', Icons.account_balance_outlined,
              PaymentTab.transfer),
        ],
      ),
    );
  }

  Widget _qrisPanel() {
    final seed = widget.orderRef.hashCode ^ widget.total;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text('QRIS',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('BUMDes Krajan Sukorejo',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _ink)),
                  SizedBox(height: 1),
                  Text('NMID: ID1024398712349',
                      style: TextStyle(fontSize: 11, color: _muted)),
                ],
              ),
            ),
            const Icon(Icons.verified_rounded, size: 21, color: _green),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _line),
          ),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(180, 180),
                  painter: _QrPainter(seed),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(3.5),
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.home_rounded,
                        size: 22, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text('BUMDes Sukorejo Makmur',
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, color: _ink)),
        const SizedBox(height: 2),
        const Text('Desa Sukorejo, Kec. Pasir Sakti',
            style: TextStyle(fontSize: 11, color: _muted)),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: _greenSoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _greenBorder),
          ),
          child: _rich(
            'Mendukung semua pembayaran e-Wallet (**GoPay, OVO, Dana, '
            'ShopeePay**) dan m-Banking (**BCA, BRImo, Livin\', BNI**).',
            const TextStyle(fontSize: 11.5, color: _muted, height: 1.45),
            center: true,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _softButton(
                'Unduh QR',
                Icons.download_rounded,
                () => _msg('Kode QR disimpan ke galeri (simulasi)'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _softButton(
                'Bagikan',
                Icons.share_outlined,
                () => _copy(_paymentId, 'ID pembayaran'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _softButton(String text, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: _fieldBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: _ink),
            const SizedBox(width: 6),
            Text(text,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800, color: _ink)),
          ],
        ),
      ),
    );
  }

  Widget _transferPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _greenSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _greenBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _green,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.verified_user_outlined,
                    size: 22, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Rekening Resmi Kas BUMDes',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _ink)),
                    SizedBox(height: 2),
                    Text('Sukorejo Makmur Mandiri',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _green)),
                    SizedBox(height: 5),
                    Text(
                      'Verifikasi otomatis berlangsung 1–5 menit setelah dana '
                      'terkirim dari sistem perbankan.',
                      style:
                          TextStyle(fontSize: 11, color: _muted, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: Text('Pilih Rekening Tujuan',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: _ink)),
            ),
            Text('2 Rekening Aktif',
                style: TextStyle(fontSize: 11, color: _muted)),
          ],
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < _banks.length; i++) _bankTile(i),
      ],
    );
  }

  Widget _bankTile(int i) {
    final bank = _banks[i];
    final selected = _bank == i;

    return InkWell(
      onTap: () => setState(() => _bank = i),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: EdgeInsets.only(bottom: i == _banks.length - 1 ? 0 : 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _greenSoft : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _greenBorder : _line,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: _line),
                  ),
                  child: Text(
                    bank.short,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: bank.color),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bank.name,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _ink)),
                      const SizedBox(height: 1),
                      Text('Kode Bank: ${bank.code}',
                          style: const TextStyle(fontSize: 11, color: _muted)),
                    ],
                  ),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? _green : const Color(0xFFB9C2BD),
                  size: 24,
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Nama Pemilik Rekening:',
                style: TextStyle(fontSize: 11, color: _muted)),
            const SizedBox(height: 2),
            const Text('BUMDes Sukorejo Makmur - Rekening Kas',
                style: TextStyle(
                    fontSize: 12.5, fontWeight: FontWeight.w900, color: _ink)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
              decoration: BoxDecoration(
                color: selected ? Colors.white : _fieldBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: selected ? _greenBorder : _line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NOMOR REKENING KAS',
                            style: TextStyle(
                                fontSize: 9.5,
                                letterSpacing: 0.3,
                                color: _muted)),
                        const SizedBox(height: 3),
                        Text(bank.account,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: _ink)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _copy(
                      bank.account.replaceAll('-', ''),
                      'Nomor rekening ${bank.short}',
                    ),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? _green : _greenChip,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded,
                              size: 13,
                              color: selected ? Colors.white : _green),
                          const SizedBox(width: 4),
                          Text('Salin',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: selected ? Colors.white : _green)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _howCard() {
    final isQris = _tab == PaymentTab.qris;
    final amount = rp(widget.total);

    final steps = isQris
        ? [
            'Buka aplikasi perbankan (m-Banking) atau dompet digital '
                '(e-Wallet) favorit Anda.',
            'Pilih menu **Bayar / Scan QRIS** dan arahkan kamera smartphone '
                'ke kode QR di atas.',
            'Pastikan nama merchant tertera **BUMDes Sukorejo Makmur**.',
            'Masukkan nominal tepat **$amount**, lalu selesaikan dengan PIN '
                'keamanan Anda.',
          ]
        : [
            'Buka aplikasi m-Banking (BRImo, Livin\', BCA Mobile, dll.) atau '
                'datang ke mesin ATM terdekat.',
            'Pilih menu **Transfer** > Pilih Bank BRI (002) atau Bank Jatim '
                '(114) sesuai pilihan Anda.',
            'Tempel nomor rekening kas BUMDes. Pastikan nama penerima '
                'tertulis **BUMDes Sukorejo Makmur.**',
            'Ketikkan jumlah transfer tepat **$amount**. Selesaikan proses '
                'pin/otentikasi lalu simpan tanda bukti.',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showHow = !_showHow),
          child: Row(
            children: [
              const Icon(Icons.help_outline_rounded, size: 20, color: _green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isQris
                      ? 'Petunjuk & Cara Pembayaran'
                      : 'Petunjuk Transfer BUMDes',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: _ink),
                ),
              ),
              Icon(
                _showHow
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: _ink,
              ),
            ],
          ),
        ),
        if (_showHow) ...[
          const SizedBox(height: 14),
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                        color: _greenChip, shape: BoxShape.circle),
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            color: _green)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: _rich(
                        steps[i],
                        const TextStyle(
                            fontSize: 12, color: _muted, height: 1.45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }

  Widget _rich(String text, TextStyle base, {bool center = false}) {
    final parts = text.split('**');
    return Text.rich(
      TextSpan(
        style: base,
        children: [
          for (int i = 0; i < parts.length; i++)
            TextSpan(
              text: parts[i],
              style: i.isOdd
                  ? const TextStyle(fontWeight: FontWeight.w900, color: _ink)
                  : null,
            ),
        ],
      ),
      textAlign: center ? TextAlign.center : TextAlign.start,
    );
  }

  Widget _confirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _busy ? null : _verify,
        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
        label: const Text('Saya Sudah Bayar'),
        style: ElevatedButton.styleFrom(
          backgroundColor: _green,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
        ),
      ),
    );
  }

  Widget _bottomNav() {
    Widget item(IconData icon, String label,
        {bool active = false, int badge = 0}) {
      final color = active ? _green : _ink;
      return Expanded(
        child: InkWell(
          onTap: _leaveToRoot,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, size: 22, color: color),
                    if (badge > 0)
                      Positioned(
                        right: -7,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: _red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('$badge',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color)),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            item(Icons.storefront_outlined, 'Beranda', active: true),
            item(Icons.grid_view_rounded, 'Kategori'),
            item(Icons.shopping_cart_outlined, 'Keranjang',
                badge: widget.cartCount),
            item(Icons.receipt_long_outlined, 'Pesanan'),
            item(Icons.person_outline_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final int seed;

  _QrPainter(this.seed);

  static const int _n = 29;

  bool _inFinder(int x, int y) {
    bool box(int ox, int oy) => x >= ox && x < ox + 8 && y >= oy && y < oy + 8;
    return box(0, 0) || box(_n - 8, 0) || box(0, _n - 8);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final dark = Paint()..color = _ink;
    final green = Paint()..color = _green;
    final rng = Random(seed);

    for (int y = 0; y < _n; y++) {
      for (int x = 0; x < _n; x++) {
        final center = (x - _n ~/ 2).abs() < 4 && (y - _n ~/ 2).abs() < 4;
        if (_inFinder(x, y) || center) continue;
        if (rng.nextBool()) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x * cell, y * cell, cell * 0.92, cell * 0.92),
              Radius.circular(cell * 0.22),
            ),
            dark,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      final white = Paint()..color = Colors.white;
      RRect r(double a, double b, double s, double rad) =>
          RRect.fromRectAndRadius(
            Rect.fromLTWH((ox + a) * cell, (oy + b) * cell, s * cell, s * cell),
            Radius.circular(rad * cell),
          );
      canvas.drawRRect(r(0, 0, 7, 1.6), green);
      canvas.drawRRect(r(1, 1, 5, 1.0), white);
      canvas.drawRRect(r(2, 2, 3, 0.7), green);
    }

    finder(0, 0);
    finder(_n - 7, 0);
    finder(0, _n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
