import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/wallet_history.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart'
    show NotificationCenter, NotificationTarget, DashboardNav, TopCartToast;
import 'profile_features.dart' show SaldoScreen;

WalletTx _autoTx(int delta) {
  return delta < 0
      ? WalletTx(
          title: 'Pembayaran Berhasil',
          subtitle: 'Dibayar dengan Saldo Dompet',
          amount: delta,
          channel: 'Saldo Dompet',
        )
      : WalletTx(
          title: 'Saldo Masuk',
          subtitle: 'Penambahan / pengembalian saldo',
          amount: delta,
          channel: 'Saldo Dompet',
        );
}

class _WalletNotifier extends ValueNotifier<int> {
  _WalletNotifier(super.value);

  WalletTx? _pending;

  void applyWithTx(int newValue, WalletTx tx) {
    _pending = tx;
    value = newValue;
  }

  @override
  set value(int newValue) {
    final delta = newValue - super.value;
    final tx = _pending;
    _pending = null;
    if (delta == 0) return;
    super.value = newValue;
    WalletHistory.add(tx ?? _autoTx(delta));
  }
}

class WalletBalance {
  static final _WalletNotifier _notifier = _WalletNotifier(340500);

  static ValueNotifier<int> get balance => _notifier;

  static void add(
    int amount, {
    String? title,
    String? subtitle,
    String? channel,
  }) {
    if (amount == 0) return;
    final auto = _autoTx(amount);
    _notifier.applyWithTx(
      _notifier.value + amount,
      WalletTx(
        title: title ?? auto.title,
        subtitle: subtitle ?? auto.subtitle,
        amount: amount,
        channel: channel ?? auto.channel,
      ),
    );
  }

  static void failed(
    int amount, {
    String title = 'Pembayaran Pesanan Gagal',
    String subtitle = 'Pembayaran dengan Saldo Dompet tidak berhasil',
    String channel = 'Saldo Dompet',
  }) {
    WalletHistory.add(
      WalletTx(
        title: title,
        subtitle: subtitle,
        amount: -amount.abs(),
        channel: channel,
        success: false,
      ),
    );
  }

  static void spend(
    int amount, {
    String? title,
    String? subtitle,
    String? channel,
  }) {
    add(-amount.abs(), title: title, subtitle: subtitle, channel: channel);
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

const Color _ink = Color(0xFF10231B);
const Color _forest = AppColors.green;
const Color _bg = Color(0xFFF6F9F7);
const Color _mint = Color(0xFFE1F5E9);
const Color _line = Color(0xFFE2EDE6);

const LinearGradient _brandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF1FA05C), Color(0xFF0F6E3C)],
);

final List<BoxShadow> _softShadow = [
  BoxShadow(
    color: _ink.withValues(alpha: 0.045),
    blurRadius: 28,
    offset: const Offset(0, 12),
  ),
];

List<BoxShadow> _brandShadow([double alpha = 0.22]) => [
      BoxShadow(
        color: _forest.withValues(alpha: alpha),
        blurRadius: 26,
        offset: const Offset(0, 12),
      ),
    ];

BoxDecoration _surface({
  double radius = 24,
  Color color = Colors.white,
  Color? border,
  double borderWidth = 1,
  bool shadow = true,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border ?? _line, width: borderWidth),
    boxShadow: shadow ? _softShadow : null,
  );
}

class WalletBalanceCard extends StatelessWidget {
  final VoidCallback? onTopUp;

  const WalletBalanceCard({super.key, this.onTopUp});

  static const String rekening = 'BUMD-SKR-9921';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: _brandGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _brandShadow(0.25),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -90,
            top: -100,
            child: IgnorePointer(
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.13),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -50,
            top: -60,
            child: IgnorePointer(
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.13),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 36,
            bottom: -46,
            child: IgnorePointer(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.09),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Saya',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ValueListenableBuilder<int>(
                      valueListenable: WalletBalance.balance,
                      builder: (context, balance, _) {
                        return Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Rp ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                              TextSpan(
                                text: _group(balance),
                                style: const TextStyle(
                                  fontSize: 38,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 22),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0B5F35),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NOMOR REKENING',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    letterSpacing: 0.9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white.withValues(alpha: 0.7),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  rekening,
                                  style: TextStyle(
                                    fontSize: 15,
                                    letterSpacing: 0.6,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                Clipboard.setData(
                                    const ClipboardData(text: rekening));
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    const SnackBar(
                                      content: Text('Nomor rekening disalin'),
                                    ),
                                  );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.copy_rounded,
                                        size: 13, color: _forest),
                                    SizedBox(width: 5),
                                    Text(
                                      'Salin',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w800,
                                        color: _forest,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onTopUp != null) ...[
                      const SizedBox(height: 12),
                      Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onTopUp,
                          child: const SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_rounded,
                                    size: 18, color: _forest),
                                SizedBox(width: 8),
                                Text(
                                  'Isi Saldo',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: _forest,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopUpHeader extends StatelessWidget {
  const _TopUpHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Navigator.maybePop(context),
          child: const SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.chevron_left_rounded,
              size: 34,
              color: _ink,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Expanded(
          child: Text(
            'Saldo Dompet',
            style: TextStyle(
              color: _ink,
              fontSize: 21,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;

  final VoidCallback? onPressed;

  final bool loading;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = onPressed != null || loading;
    final tappable = onPressed != null && !loading;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: active ? _brandGradient : null,
        color: active ? null : const Color(0xFFE3E8E5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: active ? _brandShadow() : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: tappable ? onPressed : null,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 15,
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? Colors.white
                                  : const Color(0xFF98A19C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / 9).floor();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(width: 4, height: 1.5, color: _line),
          ),
        );
      },
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;

  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _forest : Colors.transparent,
        border: Border.all(
          color: selected ? _forest : const Color(0xFFC9D0CC),
          width: 1.6,
        ),
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
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

  static const List<int> quickAmounts = [10000, 50000, 100000, 200000, 500000];

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
      backgroundColor: _bg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopUpHeader(),
                const SizedBox(height: 18),
                _buildBalanceCard(),
                const SizedBox(height: 28),
                _buildNominalSection(),
                const SizedBox(height: 28),
                _buildMethodSection(),
                const SizedBox(height: 20),
                _buildSummary(),
                const SizedBox(height: 18),
                _PrimaryButton(
                  label: 'Isi Saldo',
                  onPressed: _valid ? _continue : null,
                ),
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

  Widget _buildBalanceCard() => const WalletBalanceCard();

  Widget _buildNominalSection() {
    final tooLow = _amount > 0 && _amount < minAmount;

    final tooHigh = _amount > maxAmount;

    final hasError = tooLow || tooHigh;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Nominal Pengisian',
                style: TextStyle(
                  fontSize: 16.5,
                  letterSpacing: -0.3,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _mint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Bebas Biaya Admin',
                style: TextStyle(
                  color: _forest,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListenableBuilder(
          listenable: _focus,
          builder: (context, _) => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 18, 16, 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Color(0xFFF0F9F3)],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: hasError
                    ? Colors.redAccent
                    : (_focus.hasFocus ? _forest : _line),
                width: (hasError || _focus.hasFocus) ? 1.6 : 1,
              ),
              boxShadow: _focus.hasFocus ? _brandShadow(0.12) : _softShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsFormatter()],
                    cursorColor: _forest,
                    onChanged: (value) {
                      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

                      setState(() {
                        _amount = digits.isEmpty ? 0 : int.parse(digits);
                      });
                    },
                    style: const TextStyle(
                      fontSize: 40,
                      letterSpacing: -0.8,
                      fontWeight: FontWeight.w800,
                      color: _ink,
                    ),
                    decoration: const InputDecoration(
                      prefixText: 'Rp ',
                      prefixStyle: TextStyle(
                        fontSize: 40,
                        letterSpacing: -0.8,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                      hintText: '0',
                      hintStyle: TextStyle(color: Color(0xFFC9D0CC)),
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
                if (_amount > 0)
                  InkWell(
                    onTap: _clear,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF1EF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              tooLow
                  ? 'Minimal top up ${formatRupiahId(minAmount)}'
                  : 'Maksimal top up ${formatRupiahId(maxAmount)}',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 20) / 3;

            return Wrap(
              spacing: 10,
              runSpacing: 10,
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
                  selected: false,
                  onTap: _custom,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pengisian',
          style: TextStyle(
            fontSize: 16.5,
            letterSpacing: -0.3,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 14),
        _MethodCard(
          icon: Icons.qr_code_2_rounded,
          title: 'QRIS Desa',
          tag: 'Instan',
          tagColor: AppColors.green,
          selected: _method == TopUpMethod.qris,
          onTap: () => setState(() => _method = TopUpMethod.qris),
        ),
        const SizedBox(height: 12),
        _MethodCard(
          icon: Icons.account_balance_outlined,
          title: 'Transfer Bank',
          tag: '1-5 Menit',
          tagColor: AppColors.muted,
          selected: _method == TopUpMethod.transfer,
          onTap: () => setState(() => _method = TopUpMethod.transfer),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: _surface(radius: 24),
      child: ValueListenableBuilder<int>(
        valueListenable: WalletBalance.balance,
        builder: (context, balance, _) {
          final nominal = _valid ? _amount : 0;

          return Column(
            children: [
              _summaryRow('Nominal Pengisian', formatRupiahId(nominal)),
              const SizedBox(height: 12),
              _summaryRow('Saldo Saat Ini', formatRupiahId(balance)),
              const SizedBox(height: 16),
              const _DashedLine(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estimasi saldo baru',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: child,
                          ),
                          child: Text(
                            formatRupiahId(balance + nominal),
                            key: ValueKey(balance + nominal),
                            style: const TextStyle(
                              fontSize: 26,
                              letterSpacing: -0.6,
                              color: _forest,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _mint,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: _forest,
                      size: 24,
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
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor ?? _ink,
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

  final VoidCallback onTap;

  const _AmountChip({
    required this.width,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: selected ? _brandGradient : null,
          color: selected ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.transparent : _line),
          boxShadow: selected ? _brandShadow(0.22) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : _ink,
                  ),
                ),
              ],
            ),
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

  final bool selected;

  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = tagColor == AppColors.green;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: _surface(
        radius: 24,
        color: selected ? const Color(0xFFF3FAF5) : Colors.white,
        border: selected ? _forest : _line,
        borderWidth: selected ? 1.6 : 1,
        shadow: !selected,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: selected ? _forest : _mint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: selected ? Colors.white : _forest,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: highlight ? _mint : const Color(0xFFEEF1EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: highlight ? _forest : AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: _RadioDot(selected: selected),
                ),
              ],
            ),
          ),
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

        if (!_checking) {
          WalletHistory.add(
            WalletTx(
              title: 'Isi Saldo Gagal',
              subtitle: '$_orderId • Waktu pembayaran habis',
              amount: widget.amount,
              channel: _isQris ? 'QRIS Desa' : 'Transfer Bank',
              success: false,
            ),
          );
        }
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
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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

    WalletBalance.add(
      widget.amount,
      title: 'Isi saldo berhasil',
      subtitle:
          '$_orderId • ${_isQris ? 'QRIS Desa' : 'Transfer ${_banks[_bank].logo}'}',
      channel: _isQris ? 'QRIS Desa' : 'Transfer Bank',
    );

    NotificationCenter.add(
      'Isi saldo berhasil',
      'Saldo Dompet bertambah ${formatRupiahId(widget.amount)}.',
      target: NotificationTarget.wallet,
    );

    setState(() => _checking = false);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 30, 22, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        gradient: _brandGradient,
                        shape: BoxShape.circle,
                        boxShadow: _brandShadow(0.35),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Isi Saldo Berhasil',
                  style: TextStyle(
                    fontSize: 22,
                    letterSpacing: -0.4,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saldo bertambah ${formatRupiahId(widget.amount)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F7F5),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: _line),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SALDO DOMPET',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiahId(WalletBalance.balance.value),
                        style: const TextStyle(
                          fontSize: 27,
                          letterSpacing: -0.6,
                          color: _ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _PrimaryButton(
                  label: 'Selesai',
                  onPressed: () => Navigator.pop(dialogContext),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    final nav = Navigator.of(context, rootNavigator: true);
    TopCartToast.show(
      context,
      formatRupiahId(widget.amount),
      title: 'Isi saldo berhasil',
      suffix: ' masuk ke Saldo Dompet',
      actionLabel: 'Lihat',
      actionIcon: Icons.account_balance_wallet_rounded,
      onTap: () => nav.push(
        MaterialPageRoute(builder: (_) => const SaldoScreen()),
      ),
    );

    int popped = 0;

    Navigator.of(context).popUntil((_) => popped++ >= 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopUpHeader(),
              const SizedBox(height: 18),
              _buildTimerCard(),
              const SizedBox(height: 14),
              _buildTotalCard(),
              const SizedBox(height: 14),
              if (_isQris) _buildQrisCard() else _buildTransferSection(),
              const SizedBox(height: 14),
              _ExpandableSteps(
                title: _isQris
                    ? 'Petunjuk & Cara Pembayaran'
                    : 'Petunjuk Transfer BUMDes',
                steps: _isQris ? _qrisSteps : _transferSteps,
              ),
              const SizedBox(height: 22),
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
    final color = _expired ? Colors.redAccent : _forest;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: _expired ? const Color(0xFFFFF1F2) : _mint,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _expired ? const Color(0xFFFFD0D4) : const Color(0xFFD2EBDB),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _expired
                      ? 'Waktu pembayaran habis'
                      : 'Selesaikan Pembayaran Dalam:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _timeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _left / totalSeconds,
              minHeight: 5,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: _surface(radius: 24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Isi Saldo',
                  style: TextStyle(fontSize: 12.5, color: AppColors.muted),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiahId(widget.amount),
                  style: const TextStyle(
                    fontSize: 30,
                    letterSpacing: -0.8,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ID: $_orderId',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: _mint,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () => _copy(_orderId, 'ID transaksi'),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy_rounded, size: 15, color: _forest),
                    SizedBox(width: 6),
                    Text(
                      'Salin',
                      style: TextStyle(
                        color: _forest,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrisCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _surface(radius: 28),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5484D),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'QRIS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
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
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                    SizedBox(height: 1),
                    Text(
                      'NMID: ID1234567234',
                      style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.verified_rounded, color: _forest, size: 24),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 236,
            height: 236,
            child: CustomPaint(
              foregroundPainter: const _CornerPainter(),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Opacity(
                  opacity: _expired ? 0.2 : 1,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _QrPainter(seed: widget.amount),
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            gradient: _brandGradient,
                            borderRadius: BorderRadius.circular(10),
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
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'BUMDes Sukorejo Makmur',
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Desa Sukorejo, Kec. Pasir Sari',
            style: TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _snack(
                    'Unduh QR akan aktif setelah terhubung ke server pembayaran',
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text(
                    'Unduh QR',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text(
                    'Bagikan',
                    style:
                        TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
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
        foregroundColor: _ink,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: _line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );

  Widget _buildTransferSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Rekening Tujuan',
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const SizedBox(height: 12),
        for (int i = 0; i < _banks.length; i++) ...[
          _buildBankCard(i),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildBankCard(int index) {
    final bank = _banks[index];

    final selected = _bank == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: _surface(
        radius: 24,
        border: selected ? _forest : _line,
        borderWidth: selected ? 1.6 : 1,
        shadow: !selected,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _bank = index),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: bank.color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bank.logo,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: bank.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bank.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'Kode Bank: ${bank.code}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _RadioDot(selected: selected),
                  ],
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.only(left: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Pemilik Rekening',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'BUMDes Sukorejo',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 11, 11, 11),
                  decoration: BoxDecoration(
                    color: selected ? _mint : const Color(0xFFF5F7F6),
                    borderRadius: BorderRadius.circular(18),
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
                                fontSize: 9.5,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              bank.number,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: _ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: _forest,
                        borderRadius: BorderRadius.circular(30),
                        child: InkWell(
                          onTap: () => _copy(
                            bank.number.replaceAll('-', ''),
                            'Nomor rekening',
                          ),
                          borderRadius: BorderRadius.circular(30),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 9,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.copy_rounded,
                                    size: 13, color: Colors.white),
                                SizedBox(width: 5),
                                Text(
                                  'Salin',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
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
        _PrimaryButton(
          label: _expired ? 'Buat Top Up Baru' : 'Cek Status Pembayaran',
          loading: _checking,
          onPressed: _expired ? () => Navigator.pop(context) : _checkStatus,
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: _checking ? null : () => Navigator.pop(context),
          child: const Text(
            'Ubah Nominal / Metode',
            style: TextStyle(
              color: AppColors.muted,
              fontWeight: FontWeight.w600,
              fontSize: 13,
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
      decoration: _surface(radius: 24),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: _ink,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _open
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
                    child: Column(
                      children: [
                        for (int i = 0; i < widget.steps.length; i++)
                          _buildStep(i),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int i) {
    final last = i == widget.steps.length - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: _mint,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: _forest,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Center(
                      child: Container(width: 1.5, color: _line),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4, bottom: last ? 0 : 16),
              child: Text(
                widget.steps[i],
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: AppColors.muted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _forest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    const len = 26.0;
    const r = 14.0;
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(0, len)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..lineTo(len, 0)
      ..moveTo(w - len, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, len)
      ..moveTo(w, h - len)
      ..lineTo(w, h - r)
      ..quadraticBezierTo(w, h, w - r, h)
      ..lineTo(w - len, h)
      ..moveTo(len, h)
      ..lineTo(r, h)
      ..quadraticBezierTo(0, h, 0, h - r)
      ..lineTo(0, h - len);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
