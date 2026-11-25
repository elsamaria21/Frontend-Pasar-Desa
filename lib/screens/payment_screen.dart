import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'order_ui.dart' show rp;

const Color _green = Color(0xFF1B7F3C);
const Color _greenSoft = Color(0xFFE6F4EA);
const Color _greenBorder = Color(0xFFCDE6D5);
const Color _ink = Color(0xFF14201A);
const Color _muted = Color(0xFF1F2A24);
const Color _line = Color(0xFFE3E8E5);
const Color _fieldBg = Color(0xFFF1F5F2);
const Color _red = Color(0xFFC62828);

enum PaymentTab { qris, transfer }

const String paymentChangeMethodResult = 'CHANGE_PAYMENT_METHOD';

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
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 23, 22, 21),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: _greenSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: _green,
                  size: 27,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Batalkan Pembayaran?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.2,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'Pesanan belum dibuat. Anda bisa kembali ke checkout '
                'untuk memilih metode pembayaran lainnya.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _muted,
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text(
                          'Lanjut Bayar',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text(
                          'Ya, Batalkan',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
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
    return leave == true;
  }

  void _changePaymentMethod() {
    if (_busy) return;
    _timer?.cancel();
    Navigator.pop(context, paymentChangeMethodResult);
  }

  Future<void> _verify() async {
    if (_busy) return;
    setState(() => _busy = true);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0x990D1711),
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 27, 24, 23),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: _greenBorder),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26000000),
                  blurRadius: 30,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: _greenSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.5,
                      color: _green,
                    ),
                  ),
                ),
                const SizedBox(height: 21),
                const Text(
                  'Memverifikasi Pembayaran',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mohon tunggu sebentar. Kami sedang memeriksa status pembayaran Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 21),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    minHeight: 5,
                    backgroundColor: _greenSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(_green),
                  ),
                ),
              ],
            ),
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
        backgroundColor: const Color(0xFFF5F8F6),
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
                    const SizedBox(height: 12),
                    _amountCard(),
                    const SizedBox(height: 16),
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
    return Container(
      color: const Color(0xFFF5F8F6),
      padding: const EdgeInsets.fromLTRB(8, 5, 18, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              if (_busy) return;
              final leave = await _confirmLeave();
              if (leave && mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: _ink),
          ),
          const SizedBox(width: 2),
          const Expanded(
            child: Text('Pembayaran',
                style: TextStyle(
                    color: _ink,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.4)),
          ),
        ],
      ),
    );
  }

  Widget _timerCard() {
    final urgent = _left <= 60;
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 12),
      decoration: BoxDecoration(
        color: _greenSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _greenBorder),
      ),
      child: Column(children: [
        Row(children: [
          const Expanded(
              child: Text('Selesaikan Pembayaran Dalam:',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _green))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: urgent ? _red : _green,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(_clock,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900)),
          ),
        ]),
        const SizedBox(height: 11),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: _left / _limitSeconds,
            minHeight: 5,
            backgroundColor: Colors.white,
            valueColor: AlwaysStoppedAnimation<Color>(urgent ? _red : _green),
          ),
        ),
      ]),
    );
  }

  Widget _amountCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(17, 15, 15, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x080D2818), blurRadius: 16, offset: Offset(0, 5)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Total Pembayaran',
            style: TextStyle(
                color: Color(0xFF7A8980),
                fontSize: 11.5,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 5),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(rp(widget.total),
                  style: const TextStyle(
                      color: _ink,
                      fontSize: 27,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.5)),
            ),
            Material(
              color: _greenSoft,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () => _copy(_paymentId, 'ID pembayaran'),
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.copy_rounded, size: 13, color: _green),
                    SizedBox(width: 6),
                    Text('Salin ID',
                        style: TextStyle(
                            color: _green,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900)),
                  ]),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text('ID: $_paymentId',
            style: const TextStyle(
                color: _muted, fontSize: 10, fontWeight: FontWeight.w500)),
      ]),
    );
  }

  Widget _tabs() {
    Widget tab(String text, IconData icon, PaymentTab value) {
      final selected = _tab == value;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tab = value),
          borderRadius: BorderRadius.circular(13),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? _green : Colors.transparent,
              borderRadius: BorderRadius.circular(13),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                          color: Color(0x241B7F3C),
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ]
                  : null,
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 17, color: selected ? Colors.white : _muted),
              const SizedBox(width: 7),
              Flexible(
                  child: Text(text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: selected ? Colors.white : _muted))),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _line),
      ),
      child: Row(children: [
        tab('QRIS Desa', Icons.qr_code_2_rounded, PaymentTab.qris),
        const SizedBox(width: 4),
        tab('Transfer BUMDes', Icons.account_balance_rounded,
            PaymentTab.transfer),
      ]),
    );
  }

  Widget _qrisPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(17, 18, 17, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _line),
        boxShadow: const [
          BoxShadow(
              color: Color(0x080D2818), blurRadius: 16, offset: Offset(0, 5)),
        ],
      ),
      child: Column(children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(8)),
            child: const Text('QRIS',
                style: TextStyle(
                    color: _red, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 10),
          const Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BUMDes Sukorejo Makmur',
                  style: TextStyle(
                      color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
              SizedBox(height: 3),
              Text('NMID: ID1234567234',
                  style: TextStyle(color: _muted, fontSize: 10.5)),
            ],
          )),
          const Icon(Icons.verified_rounded, color: _green, size: 21),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFDFC),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: _line),
          ),
          child: Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 205,
              height: 205,
              child: CustomPaint(
                painter: _QrPainter(widget.orderRef.hashCode ^ widget.total),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(13)),
              child: DecoratedBox(
                decoration: BoxDecoration(
                    color: _green, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.home_rounded,
                    color: Colors.white, size: 23),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        const Text('BUMDes Sukorejo Makmur',
            style: TextStyle(
                color: _ink, fontSize: 13, fontWeight: FontWeight.w900)),
        const SizedBox(height: 3),
        const Text('Desa Sukorejo, Kec. Pasir Sari',
            style: TextStyle(color: Color(0xFF7A8980), fontSize: 10.5)),
        const SizedBox(height: 13),
        Row(children: [
          Expanded(
              child: _softButton(
                  'Unduh QR',
                  Icons.download_rounded,
                  () => _msg(
                      'QR preview belum dapat diunduh sebagai kode pembayaran.'))),
          const SizedBox(width: 10),
          Expanded(
              child: _softButton('Bagikan', Icons.share_outlined,
                  () => _copy(_paymentId, 'ID pembayaran'))),
        ]),
      ]),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pilih Rekening Tujuan',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w900, color: _ink)),
      const SizedBox(height: 11),
      for (int i = 0; i < _banks.length; i++) _bankTile(i),
    ]);
  }

  Widget _bankTile(int i) {
    final bank = _banks[i];
    final selected = _bank == i;
    return InkWell(
      onTap: () => setState(() => _bank = i),
      borderRadius: BorderRadius.circular(19),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: EdgeInsets.only(bottom: i == _banks.length - 1 ? 0 : 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0F8F2) : Colors.white,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
              color: selected ? _green : _line, width: selected ? 1.5 : 1),
          boxShadow: const [
            BoxShadow(
                color: Color(0x070D2818), blurRadius: 14, offset: Offset(0, 5)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.fromBorderSide(BorderSide(color: _line)),
              ),
              child: Text(bank.short,
                  style: TextStyle(
                      color: bank.color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ),
            const SizedBox(width: 11),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank.name,
                    style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: _ink)),
                const SizedBox(height: 3),
                Text('Kode bank  ${bank.code}',
                    style: const TextStyle(fontSize: 10.5, color: _muted)),
              ],
            )),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: selected ? _green : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: selected ? _green : const Color(0xFFB9C2BD)),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
          ]),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NAMA PEMILIK REKENING',
                    style: TextStyle(
                        fontSize: 9,
                        letterSpacing: .7,
                        color: _muted,
                        fontWeight: FontWeight.w400)),
                SizedBox(height: 4),
                Text('BUMDes Sukorejo',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: _ink)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            decoration: BoxDecoration(
                color: selected ? _greenSoft : _fieldBg,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: selected ? _greenBorder : _line)),
            child: Row(children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NOMOR REKENING',
                      style: TextStyle(
                          fontSize: 9,
                          letterSpacing: .6,
                          color: _muted,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(bank.account,
                        style: const TextStyle(
                            fontSize: 16,
                            letterSpacing: .2,
                            fontWeight: FontWeight.w900,
                            color: _ink)),
                  ),
                ],
              )),
              const SizedBox(width: 8),
              Material(
                color: selected ? _green : _greenSoft,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => _copy(bank.account.replaceAll('-', ''),
                      'Nomor rekening ${bank.short}'),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.copy_rounded,
                          size: 13, color: selected ? Colors.white : _green),
                      const SizedBox(width: 5),
                      Text('Salin',
                          style: TextStyle(
                              color: selected ? Colors.white : _green,
                              fontSize: 11,
                              fontWeight: FontWeight.w900)),
                    ]),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _howCard() {
    final isQris = _tab == PaymentTab.qris;
    final amount = rp(widget.total);
    final steps = isQris
        ? [
            'Buka aplikasi perbankan (m-Banking) atau dompet digital favorit Anda.',
            'Pilih menu Bayar / Scan QRIS dan arahkan kamera ke kode QR.',
            'Pastikan nama merchant tertera BUMDes Sukorejo Makmur.',
            'Masukkan nominal tepat $amount, lalu selesaikan dengan PIN keamanan Anda.',
          ]
        : [
            'Buka aplikasi m-Banking (BRImo, Livin\', BCA Mobile, dll.) atau ATM.',
            'Pilih menu Transfer > pilih bank tujuan sesuai rekening yang dipilih.',
            'Masukkan nomor rekening kas. Pastikan nama penerima BUMDes Sukorejo Makmur.',
            'Transfer tepat $amount, selesaikan autentikasi, lalu simpan bukti transfer.',
          ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _showHow = !_showHow),
          borderRadius: BorderRadius.circular(10),
          child: Row(children: [
            Expanded(
                child: Text(
                    isQris
                        ? 'Panduan pembayaran QRIS'
                        : 'Panduan transfer bank',
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: _ink))),
            Icon(
                _showHow
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: _muted),
          ]),
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 180),
          crossFadeState:
              _showHow ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(children: [
              for (int i = 0; i < steps.length; i++)
                Padding(
                  padding:
                      EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 13),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 25,
                          height: 25,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: _greenSoft, shape: BoxShape.circle),
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  color: _green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: _rich(
                              steps[i],
                              const TextStyle(
                                  fontSize: 11.5, color: _muted, height: 1.5)),
                        )),
                      ]),
                ),
            ]),
          ),
          secondChild: const SizedBox(width: double.infinity),
        ),
      ]),
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100D2818),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _busy ? null : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _green.withValues(alpha: .65),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 19),
                textStyle: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_busy) ...[
                    const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    _busy ? 'Memeriksa Pembayaran...' : 'Cek Status Pembayaran',
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
        // Teks "Ubah Metode Pembayaran": hitam dan bisa diklik
        // (berlaku di tab QRIS maupun Transfer).
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _busy ? null : _changePaymentMethod,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                'Ubah Metode Pembayaran',
                style: TextStyle(
                  color: _busy ? const Color(0xFF9AA79F) : _ink,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
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
