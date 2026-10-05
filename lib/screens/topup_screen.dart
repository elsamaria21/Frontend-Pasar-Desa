import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart' show NotificationCenter, DashboardNav;

class WalletBalance {
  static final ValueNotifier<int> balance = ValueNotifier<int>(340500);

  static void add(int amount) {
    balance.value = balance.value + amount;
  }
}

String _group(int value) {
  final text = value.toString();
  final buffer = StringBuffer();

  for (int i = 0; i < text.length; i++) {
    final fromEnd = text.length - i;
    buffer.write(text[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
  }

  return buffer.toString();
}

String formatRupiahId(int value) => 'Rp ${_group(value)}';

enum TopUpMethod { qris, transfer }

class _TopUpHeader extends StatelessWidget {
  const _TopUpHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 22,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const BrandMark(size: 29),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pasar',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(
                          text: 'Desa',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.circle, size: 6, color: Colors.redAccent),
                ],
              ),
              const Text(
                'UMKM DESA SUKOREJO',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.length > 9) digits = digits.substring(0, 9);

    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }

    final formatted = _group(int.parse(digits));

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  static const int minAmount = 10000;
  static const int maxAmount = 10000000;
  static const List<int> quickAmounts = [20000, 50000, 100000, 200000, 500000];

  final TextEditingController _controller =
      TextEditingController(text: '50.000');
  final FocusNode _focus = FocusNode();

  int _amount = 50000;
  TopUpMethod _method = TopUpMethod.qris;

  bool get _valid => _amount >= minAmount && _amount <= maxAmount;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _pickAmount(int value) {
    setState(() {
      _amount = value;
      _controller.text = _group(value);
      _controller.selection =
          TextSelection.collapsed(offset: _controller.text.length);
    });
    _focus.unfocus();
  }

  void _clear() {
    setState(() {
      _amount = 0;
      _controller.clear();
    });
  }

  void _custom() {
    setState(() {
      _amount = 0;
      _controller.clear();
    });
    _focus.requestFocus();
  }

  void _continue() {
    if (!_valid) return;

    _focus.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TopUpPaymentScreen(amount: _amount, method: _method),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopUpHeader(),
                const SizedBox(height: 14),
                _buildBalanceCard(),
                const SizedBox(height: 20),
                _buildNominalSection(),
                const SizedBox(height: 22),
                _buildMethodSection(),
                const SizedBox(height: 18),
                _buildSummary(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: 0,
        onTap: (index) => DashboardNav.goTo(context, index),
      ),
    );
  }

  Widget _buildBalanceCard() {
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
        child: Stack(
          children: [
            const Positioned(
              right: -8,
              bottom: -12,
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 92,
                color: Color.fromRGBO(255, 255, 255, 0.13),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'KOPERASI DESA SUKOREJO',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Terdaftar BUMDes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'SALDO AKTIF TABUNGAN KOPERASI',
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                ValueListenableBuilder<int>(
                  valueListenable: WalletBalance.balance,
                  builder: (context, balance, _) {
                    return Text(
                      formatRupiahId(balance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Terlindungi Aman',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNominalSection() {
    final tooLow = _amount > 0 && _amount < minAmount;
    final tooHigh = _amount > maxAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Nominal Top Up Saldo',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              'Bebas Biaya Admin',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (tooLow || tooHigh) ? Colors.redAccent : AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Ketik jumlah atau pilih di bawah (min. Rp 10.000)',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ),
                  if (_amount > 0)
                    InkWell(
                      onTap: _clear,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEDEFEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.muted,
                        ),
                      ),
                    ),
                ],
              ),
              TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                inputFormatters: [_ThousandsFormatter()],
                onChanged: (value) {
                  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                  setState(() {
                    _amount = digits.isEmpty ? 0 : int.parse(digits);
                  });
                },
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10231B),
                ),
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10231B),
                  ),
                  hintText: '0',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 6),
                ),
              ),
            ],
          ),
        ),
        if (tooLow || tooHigh)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              tooLow
                  ? 'Minimal top up ${formatRupiahId(minAmount)}'
                  : 'Maksimal top up ${formatRupiahId(maxAmount)}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 16) / 3;

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final value in quickAmounts)
                  _AmountChip(
                    width: width,
                    label: _group(value),
                    selected: _amount == value,
                    onTap: () => _pickAmount(value),
                  ),
                _AmountChip(
                  width: width,
                  label: 'Lainnya',
                  icon: Icons.edit_outlined,
                  selected: false,
                  onTap: _custom,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _valid ? _continue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFE2E6E3),
              disabledForegroundColor: const Color(0xFF98A19C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _valid
                          ? 'Lanjutkan Isi Saldo ${formatRupiahId(_amount)}  →'
                          : 'Masukkan nominal top up',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_user_outlined,
                size: 13, color: AppColors.green),
            SizedBox(width: 5),
            Flexible(
              child: Text(
                'Transaksi Instan & aman terverifikasi Koperasi Desa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(
              child: Text(
                'Pilih Metode Pengisian Resmi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              'Semua Resmi BUMDes',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _MethodCard(
          icon: Icons.qr_code_2_rounded,
          title: 'QRIS Desa (BUMDes Sukorejo)',
          tag: 'Instan',
          tagColor: AppColors.green,
          description:
              'Verifikasi instan otomatis, dukung BCA, BRI, Mandiri, GoPay, '
              'OVO, ShopeePay, dan e-wallet lainnya.',
          selected: _method == TopUpMethod.qris,
          onTap: () => setState(() => _method = TopUpMethod.qris),
        ),
        const SizedBox(height: 10),
        _MethodCard(
          icon: Icons.account_balance_outlined,
          title: 'Transfer Bank Kas BUMDes',
          tag: '1-5 Menit',
          tagColor: AppColors.muted,
          description:
              'Rekening Kas Desa via BRI, Bank Jatim & BNI. Konfirmasi '
              'otomatis setelah dana diterima.',
          selected: _method == TopUpMethod.transfer,
          onTap: () => setState(() => _method = TopUpMethod.transfer),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ValueListenableBuilder<int>(
        valueListenable: WalletBalance.balance,
        builder: (context, balance, _) {
          final nominal = _valid ? _amount : 0;

          return Column(
            children: [
              _summaryRow('Nominal Pengisian', formatRupiahId(nominal)),
              const SizedBox(height: 9),
              _summaryRow(
                'Biaya Layanan Koperasi',
                'Gratis (Rp 0)',
                valueColor: AppColors.green,
              ),
              const SizedBox(height: 9),
              _summaryRow('Saldo Saat Ini', formatRupiahId(balance)),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Divider(height: 1, color: Color(0xFFEEF2EF)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ESTIMASI SALDO BARU',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          formatRupiahId(balance + nominal),
                          style: const TextStyle(
                            fontSize: 22,
                            color: AppColors.green,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE1F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.green,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? AppColors.text,
          ),
        ),
      ],
    );
  }
}

class _AmountChip extends StatelessWidget {
  final double width;
  final String label;
  final bool selected;
  final IconData? icon;
  final VoidCallback onTap;

  const _AmountChip({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 44,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: selected ? AppColors.green : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                const Icon(Icons.check_circle_rounded,
                    size: 15, color: Colors.white),
                const SizedBox(width: 5),
              ],
              if (icon != null) ...[
                Icon(icon, size: 15, color: AppColors.text),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : AppColors.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String tag;
  final Color tagColor;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF1FBF5) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5E9),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.green, size: 24),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: tagColor == AppColors.green
                              ? AppColors.green
                              : const Color(0xFFEDEFEE),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: tagColor == AppColors.green
                                ? Colors.white
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.4,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Icon(Icons.local_offer_outlined,
                          size: 12, color: AppColors.green),
                      SizedBox(width: 4),
                      Text(
                        'Biaya Layanan: Gratis (Rp 0)',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.green : const Color(0xFFC9D0CC),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bank {
  final String logo;
  final Color color;
  final String name;
  final String code;
  final String number;

  const _Bank({
    required this.logo,
    required this.color,
    required this.name,
    required this.code,
    required this.number,
  });
}

const List<_Bank> _banks = [
  _Bank(
    logo: 'BRI',
    color: Color(0xFF0B5CAB),
    name: 'Bank Rakyat Indonesia',
    code: '002',
    number: '0142-01-002938-53-1',
  ),
  _Bank(
    logo: 'JATIM',
    color: Color(0xFFE5484D),
    name: 'Bank Jatim Syariah / Daerah',
    code: '114',
    number: '144-00-9821345-0',
  ),
];

class TopUpPaymentScreen extends StatefulWidget {
  final int amount;
  final TopUpMethod method;

  const TopUpPaymentScreen({
    super.key,
    required this.amount,
    required this.method,
  });

  @override
  State<TopUpPaymentScreen> createState() => _TopUpPaymentScreenState();
}

class _TopUpPaymentScreenState extends State<TopUpPaymentScreen> {
  static const int totalSeconds = 15 * 60;

  int _left = totalSeconds;
  Timer? _timer;
  late final String _orderId;

  int _bank = 0;
  bool _checking = false;

  bool get _isQris => widget.method == TopUpMethod.qris;
  bool get _expired => _left <= 0;

  @override
  void initState() {
    super.initState();

    _orderId = '#PD-SKR-${10000 + math.Random().nextInt(89999)}';

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_left <= 1) {
        timer.cancel();
        setState(() => _left = 0);
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

  String get _timeText {
    final m = (_left ~/ 60).toString().padLeft(2, '0');
    final s = (_left % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(milliseconds: 1200),
        ),
      );
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    _snack('$label disalin');
  }

  Future<void> _checkStatus() async {
    if (_checking || _expired) return;

    setState(() => _checking = true);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    _timer?.cancel();

    WalletBalance.add(widget.amount);

    NotificationCenter.add(
      'Top Up Berhasil',
      'Saldo Tabungan Koperasi bertambah ${formatRupiahId(widget.amount)}.',
    );

    setState(() => _checking = false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 30),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE1F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.green,
                    size: 38,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Top Up Berhasil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saldo bertambah ${formatRupiahId(widget.amount)}',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F9F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SALDO TABUNGAN KOPERASI',
                        style: TextStyle(
                          fontSize: 9.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        formatRupiahId(WalletBalance.balance.value),
                        style: const TextStyle(
                          fontSize: 22,
                          color: AppColors.green,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Selesai',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    // Tutup halaman pembayaran + halaman form top up
    int popped = 0;
    Navigator.of(context).popUntil((_) => popped++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopUpHeader(),
              const SizedBox(height: 14),
              _buildTimerCard(),
              const SizedBox(height: 12),
              _buildTotalCard(),
              const SizedBox(height: 12),
              _buildMethodLabel(),
              const SizedBox(height: 12),
              if (_isQris) _buildQrisCard() else _buildTransferSection(),
              const SizedBox(height: 14),
              _ExpandableSteps(
                title: _isQris
                    ? 'Petunjuk & Cara Pembayaran'
                    : 'Petunjuk Transfer BUMDes',
                steps: _isQris ? _qrisSteps : _transferSteps,
              ),
              const SizedBox(height: 18),
              _buildActions(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: 0,
        onTap: (index) => DashboardNav.goTo(context, index),
      ),
    );
  }

  Widget _buildTimerCard() {
    final color = _expired ? Colors.redAccent : AppColors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _expired ? const Color(0xFFFFF1F2) : const Color(0xFFE6F6EC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _expired
                  ? 'Waktu pembayaran habis'
                  : 'Selesaikan Pembayaran Dalam:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _timeText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Top Up:',
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  formatRupiahId(widget.amount),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10231B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: $_orderId',
                  style:
                      const TextStyle(fontSize: 10.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _copy(_orderId, 'ID transaksi'),
            icon: const Icon(Icons.copy_rounded, size: 15),
            label: const Text(
              'Salin',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.green,
              side: const BorderSide(color: Color(0xFFBDE8CE)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodLabel() {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isQris ? Icons.qr_code_2_rounded : Icons.account_balance_outlined,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isQris ? 'QRIS Desa' : 'Transfer BUMDes',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5484D),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Text(
                  'QRIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
                      'BUMDes Sukorejo Makmur',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'NMID: ID1234567234',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.green, size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: 210,
            height: 210,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Opacity(
              opacity: _expired ? 0.25 : 1,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _QrPainter(seed: widget.amount),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'BUMDes Sukorejo Makmur',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          const Text(
            'Desa Sukorejo, Kec. Pasir Sari',
            style: TextStyle(fontSize: 10.5, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FBF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD3EFDD)),
            ),
            child: const Text(
              'Mendukung semua pembayaran e-Wallet: GoPay, OVO, Dana, '
              "ShopeePay dan e-Banking (BCA, BRImo, Livin', BNI).",
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
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _snack(
                    'Unduh QR akan aktif setelah terhubung ke server pembayaran',
                  ),
                  icon: const Icon(Icons.download_rounded, size: 17),
                  label: const Text(
                    'Unduh QR',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  style: _outlineStyle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _copy(
                    'Top Up PasarDesa $_orderId - '
                        '${formatRupiahId(widget.amount)} (QRIS BUMDes Sukorejo Makmur)',
                    'Detail pembayaran',
                  ),
                  icon: const Icon(Icons.share_outlined, size: 17),
                  label: const Text(
                    'Bagikan',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                  ),
                  style: _outlineStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  ButtonStyle get _outlineStyle => OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        minimumSize: const Size.fromHeight(42),
        side: const BorderSide(color: Color(0xFFD9DEDB)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      );

  Widget _buildTransferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F6EC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_rounded,
                  color: AppColors.green, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekening Resmi Kas BUMDes',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sukorejo Makmur Mandiri. Verifikasi otomatis berlangsung '
                      '1-5 menit setelah dana terkirim.',
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
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pilih Rekening Tujuan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
              ),
            ),
            Text(
              '${_banks.length} Rekening Aktif',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.green,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (int i = 0; i < _banks.length; i++) ...[
          _buildBankCard(i),
          const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildBankCard(int index) {
    final bank = _banks[index];
    final selected = _bank == index;

    return InkWell(
      onTap: () => setState(() => _bank = index),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6F5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    bank.logo,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: bank.color,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bank.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Kode Bank: ${bank.code}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? AppColors.green : const Color(0xFFC9D0CC),
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Nama Pemilik Rekening:',
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
            const SizedBox(height: 2),
            const Text(
              'BUMDes Sukorejo Makmur — Rekening Kas',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(12, 9, 9, 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F9F6),
                borderRadius: BorderRadius.circular(10),
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
                            fontSize: 9,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          bank.number,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _copy(
                      bank.number.replaceAll('-', ''),
                      'Nomor rekening',
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded,
                              size: 13, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Salin',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
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
        ),
      ),
    );
  }

  List<String> get _qrisSteps => [
        'Buka aplikasi perbankan (m-Banking) atau dompet digital '
            '(e-Wallet) favorit Anda.',
        'Pilih menu Bayar / Scan QRIS dan arahkan kamera smartphone '
            'ke kode QR di atas.',
        'Pastikan nama merchant tertera BUMDes Sukorejo Makmur.',
        'Masukkan nominal tepat ${formatRupiahId(widget.amount)}, lalu '
            'selesaikan pembayaran dengan PIN/Biometrik.',
      ];

  List<String> get _transferSteps => [
        'Buka aplikasi m-Banking atau internet banking Anda.',
        'Pilih menu Transfer, lalu pilih bank sesuai rekening tujuan '
            '(${_banks[_bank].logo} - kode ${_banks[_bank].code}).',
        'Masukkan nomor rekening kas BUMDes. Pastikan nama penerima '
            'tertera BUMDes Sukorejo Makmur.',
        'Ketikkan jumlah transfer tepat ${formatRupiahId(widget.amount)}, '
            'lalu selesaikan dengan PIN dan simpan bukti transfer.',
      ];

  Widget _buildActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _expired
                ? () => Navigator.pop(context)
                : (_checking ? null : _checkStatus),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF7FC9A0),
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _checking
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _expired ? 'Buat Top Up Baru' : 'Cek Status Pembayaran',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: _checking ? null : () => Navigator.pop(context),
          child: const Text(
            'Ubah Nominal / Metode',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableSteps extends StatefulWidget {
  final String title;
  final List<String> steps;

  const _ExpandableSteps({required this.title, required this.steps});

  @override
  State<_ExpandableSteps> createState() => _ExpandableStepsState();
}

class _ExpandableStepsState extends State<_ExpandableSteps> {
  bool _open = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.help_outline_rounded,
                      size: 19, color: AppColors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Icon(
                    _open
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                children: [
                  for (int i = 0; i < widget.steps.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE1F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: AppColors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                widget.steps[i],
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  height: 1.45,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QrPainter extends CustomPainter {
  final int seed;

  const _QrPainter({required this.seed});

  static const int _n = 29;

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / _n;
    final dark = Paint()..color = const Color(0xFF111111);
    final light = Paint()..color = Colors.white;

    bool inFinder(int r, int c) {
      final tl = r < 8 && c < 8;
      final tr = r < 8 && c >= _n - 8;
      final bl = r >= _n - 8 && c < 8;
      return tl || tr || bl;
    }

    final random = math.Random(seed);

    for (int r = 0; r < _n; r++) {
      for (int c = 0; c < _n; c++) {
        final on = random.nextDouble() > 0.52;
        if (inFinder(r, c) || !on) continue;

        canvas.drawRect(
          Rect.fromLTWH(c * cell, r * cell, cell + 0.4, cell + 0.4),
          dark,
        );
      }
    }

    void finder(int row, int col) {
      final x = col * cell;
      final y = row * cell;

      canvas.drawRect(Rect.fromLTWH(x, y, cell * 7, cell * 7), dark);
      canvas.drawRect(
        Rect.fromLTWH(x + cell, y + cell, cell * 5, cell * 5),
        light,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + cell * 2, y + cell * 2, cell * 3, cell * 3),
        dark,
      );
    }

    finder(0, 0);
    finder(0, _n - 7);
    finder(_n - 7, 0);
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) =>
      oldDelegate.seed != seed;
}
