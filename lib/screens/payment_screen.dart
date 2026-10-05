import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'order_ui.dart';

enum PaymentTab { qris, transfer }

class _Bank {
  final String name;
  final String code;
  final String account;
  final String short;

  const _Bank(this.name, this.code, this.account, this.short);
}

const List<_Bank> _banks = [
  _Bank('Bank Rakyat Indonesia', '002', '0142-01-002938-53-1', 'BRI'),
  _Bank('Bank Jatim Syariah / Daerah', '114', '144-00-9821345-0', 'JATIM'),
];

class PaymentScreen extends StatefulWidget {
  final int total;
  final String orderRef;
  final PaymentTab initialTab;

  const PaymentScreen({
    super.key,
    required this.total,
    required this.orderRef,
    this.initialTab = PaymentTab.qris,
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
    return '#PYD-SKR-$tail';
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
        title: const Text(
          'Waktu Pembayaran Habis',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Pembayaran tidak diselesaikan dalam batas waktu. Pesanan belum '
          'dibuat dan tidak ada dana yang terpotong.',
          style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Kembali',
              style: TextStyle(
                color: AppColors.green,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context, false);
  }

  Future<bool> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Batalkan Pembayaran?',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Pesanan belum dibuat. Anda bisa kembali ke checkout dan '
          'memilih metode pembayaran lagi.',
          style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Lanjut Bayar',
                style: TextStyle(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Ya, Batalkan',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w900,
              ),
            ),
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
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.green,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Memverifikasi pembayaran Anda...',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
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
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || _busy) return;
        final leave = await _confirmLeave();
        if (leave && mounted) Navigator.pop(context, false);
      },
      child: OrderPageScaffold(
        title: 'Pembayaran',
        subtitle: 'Selesaikan pembayaran untuk membuat pesanan',
        bottomBar: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: kLine)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Total Tagihan',
                        style: TextStyle(fontSize: 10, color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text(
                      rp(widget.total),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 175,
                child: OButton(
                  'Saya Sudah Bayar',
                  icon: Icons.check_circle_outline_rounded,
                  onTap: _busy ? null : _verify,
                ),
              ),
            ],
          ),
        ),
        children: [
          _timerCard(),
          _tabs(),
          if (_tab == PaymentTab.qris) _qrisPanel() else _transferPanel(),
          _howCard(),
        ],
      ),
    );
  }

  Widget _timerCard() {
    final urgent = _left <= 60;

    return OCard(
      color: const Color(0xFFF2FBF5),
      borderColor: AppColors.green.withValues(alpha: 0.45),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Selesaikan Pembayaran Dalam:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted,
                  ),
                ),
              ),
              Pill(
                _clock,
                icon: Icons.timer_outlined,
                fg: Colors.white,
                bg: urgent ? AppColors.red : AppColors.green,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Tagihan Belanja',
                        style:
                            TextStyle(fontSize: 10.5, color: AppColors.muted)),
                    const SizedBox(height: 2),
                    Text(
                      rp(widget.total),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: $_paymentId',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () => _copy(_paymentId, 'ID pembayaran'),
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: kLine),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, size: 14, color: kInk),
                      SizedBox(width: 5),
                      Text('Salin',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w800)),
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
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: selected ? AppColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 17, color: selected ? Colors.white : kInk),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: selected ? Colors.white : kInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F3EC),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          tab('QRIS Desa', Icons.qr_code_2_rounded, PaymentTab.qris),
          tab('Transfer BUMDes', Icons.account_balance_outlined,
              PaymentTab.transfer),
        ],
      ),
    );
  }

  Widget _qrisPanel() {
    final seed = widget.orderRef.hashCode ^ widget.total;

    return OCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'QRIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BUMDes Krajan Sukorejo',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    Text(
                      'NMID: ID1024349671544',
                      style: TextStyle(fontSize: 9.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_rounded,
                  size: 20, color: AppColors.green),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kLine),
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: _QrPainter(seed),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'BUMDes Sukorejo Makmur',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: kInk,
            ),
          ),
          const Text(
            'Desa Sukorejo, Kec. Pasi Sakti',
            style: TextStyle(fontSize: 9.5, color: AppColors.muted),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Text(
              'Mendukung semua pembayaran e-Wallet (GoPay, OVO, Dana, '
              'ShopeePay) dan m-Banking (BCA, BRImo, Livin\', BNI).',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OButton(
                  'Unduh QR',
                  filled: false,
                  color: kInk,
                  icon: Icons.download_rounded,
                  onTap: () => _msg('Kode QR disimpan ke galeri (simulasi)'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OButton(
                  'Bagikan',
                  filled: false,
                  color: kInk,
                  icon: Icons.share_outlined,
                  onTap: () => _copy(_paymentId, 'ID pembayaran'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transferPanel() {
    return Column(
      children: [
        OCard(
          color: const Color(0xFFF2FBF5),
          borderColor: AppColors.green.withValues(alpha: 0.4),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_outlined,
                  size: 24, color: AppColors.green),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekening Resmi Kas BUMDes',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Verifikasi otomatis berlangsung 1–5 menit setelah '
                      'dana terkirim. Transfer hanya ke rekening di bawah '
                      'ini, atas nama BUMDes Sukorejo Makmur.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                        height: 1.4,
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
              const SectionHeading(
                'Pilih Rekening Tujuan',
                trailing: Text(
                  '2 Rekening Aktif',
                  style: TextStyle(fontSize: 9.5, color: AppColors.muted),
                ),
              ),
              for (int i = 0; i < _banks.length; i++) _bankTile(i),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bankTile(int i) {
    final bank = _banks[i];
    final selected = _bank == i;

    return InkWell(
      onTap: () => setState(() => _bank = i),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: i == _banks.length - 1 ? 0 : 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF2FBF5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : kLine,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF1FB),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    bank.short,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1D4F91),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: kInk,
                        ),
                      ),
                      Text(
                        'Kode Bank: ${bank.code}',
                        style: const TextStyle(
                            fontSize: 9.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.green : AppColors.border,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Nama Pemilik Rekening:',
                style: TextStyle(fontSize: 9.5, color: AppColors.muted)),
            const Text(
              'BUMDes Sukorejo Makmur - Rekening Kas',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: kInk,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF8),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: kLine),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NOMOR REKENING KAS',
                          style: TextStyle(
                            fontSize: 8,
                            letterSpacing: 0.3,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bank.account,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: kInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _copy(
                      bank.account.replaceAll('-', ''),
                      'Nomor rekening ${bank.short}',
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded,
                              size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Salin',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
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
        ),
      ),
    );
  }

  Widget _howCard() {
    final isQris = _tab == PaymentTab.qris;
    final bank = _banks[_bank];
    final amount = rp(widget.total);

    final steps = isQris
        ? [
            'Buka aplikasi perbankan (m-Banking) atau dompet digital '
                '(e-Wallet) favorit Anda.',
            'Pilih menu Bayar / Scan QRIS dan arahkan kamera smartphone '
                'ke kode QR di atas.',
            'Pastikan nama merchant tertera BUMDes Sukorejo Makmur.',
            'Masukkan nominal tepat $amount, lalu selesaikan dengan PIN '
                'keamanan Anda.',
          ]
        : [
            'Buka aplikasi m-Banking (BRImo, Livin\', BCA Mobile, dll) '
                'atau datangi mesin ATM terdekat.',
            'Pilih menu Transfer, lalu pilih ${bank.short} '
                '(kode ${bank.code}) sesuai rekening tujuan.',
            'Tempel nomor rekening kas BUMDes. Pastikan nama penerima '
                'tertulis BUMDes Sukorejo Makmur.',
            'Ketikkan jumlah transfer tepat $amount. Simpan bukti '
                'transfer Anda.',
          ];

    return OCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _showHow = !_showHow),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.green),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    isQris
                        ? 'Petunjuk & Cara Pembayaran'
                        : 'Petunjuk Transfer BUMDes',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: kInk,
                    ),
                  ),
                ),
                Icon(
                  _showHow
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
          if (_showHow) ...[
            const SizedBox(height: 12),
            for (int i = 0; i < steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.greenLight,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        steps[i],
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
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
    final dark = Paint()..color = const Color(0xFF10231B);
    final rng = Random(seed);

    for (int y = 0; y < _n; y++) {
      for (int x = 0; x < _n; x++) {
        final center = (x - _n ~/ 2).abs() < 4 && (y - _n ~/ 2).abs() < 4;
        if (_inFinder(x, y) || center) continue;
        if (rng.nextBool()) {
          canvas.drawRect(
            Rect.fromLTWH(x * cell, y * cell, cell + 0.4, cell + 0.4),
            dark,
          );
        }
      }
    }

    void finder(int ox, int oy) {
      final white = Paint()..color = Colors.white;
      canvas.drawRect(
          Rect.fromLTWH(ox * cell, oy * cell, 7 * cell, 7 * cell), dark);
      canvas.drawRect(
          Rect.fromLTWH((ox + 1) * cell, (oy + 1) * cell, 5 * cell, 5 * cell),
          white);
      canvas.drawRect(
          Rect.fromLTWH((ox + 2) * cell, (oy + 2) * cell, 3 * cell, 3 * cell),
          dark);
    }

    finder(0, 0);
    finder(_n - 7, 0);
    finder(0, _n - 7);
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
