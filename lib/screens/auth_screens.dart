import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

const Color _line = Color(0xFFDCE8E0);
const Color _hint = Color(0xFF9AA39D);
const Color _iconColor = Color(0xFF5F7A68);
const Color _danger = Color(0xFFE53935);
const Color _dangerBg = Color(0xFFFFF3F4);
const Color _dangerLine = Color(0xFFFFC5CA);
const Color _subtle = Color(0xFF6F7C74);

const Color _sheetTop = Color(0xFFE6F5EC);
const Color _sheetBottom = Color(0xFFF5FBF7);

bool _isEmail(String v) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

String _stripPhone(String v) => v.replaceAll(RegExp(r'[\s\-\.\(\)]'), '');

bool _isPhone(String v) => RegExp(r'^\+?\d{9,15}$').hasMatch(_stripPhone(v));

void _showNotice(BuildContext context, String message) {
  final media = MediaQuery.of(context);
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xF0102A1C),
      elevation: 0,
      duration: const Duration(milliseconds: 2600),
      margin: EdgeInsets.fromLTRB(
        28,
        0,
        28,
        math.max(0.0, media.size.height - media.padding.top - 78),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
      ),
    ),
  );
}

class _AuthShell extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBack;
  final bool showBadge;
  final bool showBrand;
  final bool titleLeft;
  final double logoSize;
  final double wordmarkSize;

  const _AuthShell({
    required this.child,
    this.title,
    this.showBack = false,
    this.showBadge = false,
    this.showBrand = true,
    this.titleLeft = false,
    this.logoSize = 64,
    this.wordmarkSize = 28,
  });

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white.withValues(alpha: 0.18),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => Navigator.pop(context),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: titleLeft ? 14 : 0),
            child: Text(
              title ?? '',
              textAlign: titleLeft ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: titleLeft ? 21 : 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
        if (!titleLeft) const SizedBox(width: 42),
      ],
    );
  }

  Widget _brand() {
    final shadow = [
      Shadow(
        color: Colors.black.withValues(alpha: 0.22),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LogoMark(size: logoSize),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Pasar',
                style: TextStyle(
                  fontSize: wordmarkSize,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -0.3,
                  shadows: shadow,
                ),
              ),
              TextSpan(
                text: 'Desa',
                style: TextStyle(
                  fontSize: wordmarkSize,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFCFF3DC),
                  height: 1,
                  letterSpacing: -0.3,
                  shadows: shadow,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hero(
    BuildContext context,
    double height,
    double topInset,
    double overlap,
  ) {
    final dark = Color.lerp(AppColors.green, Colors.black, 0.32)!;
    final light = Color.lerp(AppColors.green, Colors.white, 0.12)!;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [dark, AppColors.green, light],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),
          const Positioned.fill(
            child: CustomPaint(painter: _HeroPatternPainter()),
          ),
          if (showBack)
            Positioned(
              top: topInset + 8,
              left: 16,
              right: 16,
              child: _topBar(context),
            ),
          if (showBrand)
            Positioned.fill(
              top: topInset + (showBack ? 54 : 14),
              bottom: overlap + 8,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _brand(),
                    if (showBadge) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'UMKM DESA SUKOREJO',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.95),
                            letterSpacing: 2.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _sheetBottom,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final topInset = MediaQuery.of(context).padding.top;
            final heroHeight =
                (showBrand ? (showBack ? 285.0 : 310.0) : 120.0) + topInset;
            const overlap = 34.0;
            final sheetMinHeight =
                math.max(0.0, constraints.maxHeight - heroHeight + overlap);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  _hero(context, heroHeight, topInset, overlap),
                  Transform.translate(
                    offset: const Offset(0, -overlap),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 480,
                          minHeight: sheetMinHeight,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.fromLTRB(
                            24,
                            34,
                            24,
                            36 + MediaQuery.of(context).padding.bottom,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_sheetTop, _sheetBottom],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.10),
                                blurRadius: 26,
                                offset: const Offset(0, -8),
                              ),
                            ],
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  final double size;

  const _LogoMark({required this.size});

  @override
  Widget build(BuildContext context) {
    final badge = size * 0.34;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE9F6EE), Color(0xFFCDEBD9)],
                ),
                borderRadius: BorderRadius.circular(size * 0.3),
                border: Border.all(
                  color: const Color(0xFF8FD3A9),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: size * 0.5,
                color: AppColors.green,
              ),
            ),
          ),
          Positioned(
            top: -badge * 0.28,
            right: -badge * 0.28,
            child: Container(
              width: badge,
              height: badge,
              decoration: BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.8),
              ),
              child: Icon(Icons.add_rounded,
                  size: badge * 0.68, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPatternPainter extends CustomPainter {
  const _HeroPatternPainter();

  void _leaf(Canvas canvas, Offset center, double s, double angle, Paint p) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, -s)
      ..quadraticBezierTo(s * 0.85, 0, 0, s)
      ..quadraticBezierTo(-s * 0.85, 0, 0, -s)
      ..close();
    canvas.drawPath(path, p);
    canvas.drawLine(
      Offset(0, -s * 0.9),
      Offset(0, s * 0.9),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.10)
        ..strokeWidth = 1,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = Colors.white.withValues(alpha: 0.07);
    final soft = Paint()..color = Colors.white.withValues(alpha: 0.05);
    final leaf = Paint()..color = Colors.white.withValues(alpha: 0.09);

    final ringCenter = Offset(size.width * 0.94, size.height * 0.10);
    canvas.drawCircle(ringCenter, 110, fill);
    for (var i = 0; i < 4; i++) {
      canvas.drawCircle(
        ringCenter,
        70.0 + i * 34,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = Colors.white.withValues(alpha: 0.16 - i * 0.03),
      );
    }

    canvas.drawCircle(Offset(-30, size.height * 0.72), 120, soft);
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.88), 34, fill);

    _leaf(
        canvas, Offset(size.width * 0.10, size.height * 0.20), 34, -0.6, leaf);
    _leaf(canvas, Offset(size.width * 0.20, size.height * 0.30), 22, 0.5, leaf);
    _leaf(canvas, Offset(size.width * 0.88, size.height * 0.62), 30, 0.8, leaf);
    _leaf(
        canvas, Offset(size.width * 0.80, size.height * 0.52), 18, -0.4, leaf);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color titleColor;

  const _AuthHeading({
    required this.title,
    required this.subtitle,
    this.titleColor = AppColors.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: titleColor,
            height: 1.2,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            color: _subtle,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  final bool error;

  const _FieldLabel(
    this.text, {
    this.required = false,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = error ? _danger : AppColors.text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            color: color,
          ),
          children: [
            TextSpan(text: text),
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: _danger),
              ),
          ],
        ),
      ),
    );
  }
}

class _FieldError extends StatelessWidget {
  final String message;

  const _FieldError(this.message);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.error_outline, size: 14, color: _danger),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: _danger,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBox(this.message, {this.isError = false});

  @override
  Widget build(BuildContext context) {
    final color = isError ? _danger : AppColors.green;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isError ? _dangerBg : AppColors.greenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? _dangerLine : AppColors.greenLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isError) ...[
            Icon(
              Icons.check_circle_outline,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 9),
          ],
          Expanded(
            child: Text(
              message,
              textAlign: isError ? TextAlign.center : TextAlign.start,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(AppColors.green, Colors.black, 0.18)!;
    final light = Color.lerp(AppColors.green, Colors.white, 0.14)!;

    return Opacity(
      opacity: loading ? 0.8 : 1,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [dark, AppColors.green, light],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.32),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.transparent,
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
        ),
      ),
    );
  }
}

class _CheckTile extends StatelessWidget {
  final bool value;
  final VoidCallback onTap;

  const _CheckTile({required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: value ? AppColors.green : Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: value ? AppColors.green : const Color(0xFFB4C4BA),
          width: 1.4,
        ),
      ),
      child: value
          ? const Icon(Icons.check_rounded, size: 15, color: Colors.white)
          : null,
    );
  }
}

InputDecoration _fieldDecoration({
  required String hint,
  required IconData icon,
  bool error = false,
  Widget? suffix,
}) {
  OutlineInputBorder border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontSize: 14,
      color: _hint,
      fontWeight: FontWeight.w400,
    ),
    prefixIcon: Icon(
      icon,
      size: 21,
      color: error ? _danger : _iconColor,
    ),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.72),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    border: border(error ? _danger : _line),
    enabledBorder: border(error ? _danger : _line),
    focusedBorder: border(error ? _danger : AppColors.green, 1.6),
  );
}

Widget _softShadow(Widget child) {
  return DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.green.withValues(alpha: 0.07),
          blurRadius: 14,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: child,
  );
}

Widget _visibilityToggle({
  required bool obscure,
  required VoidCallback onTap,
}) {
  return IconButton(
    onPressed: onTap,
    splashRadius: 20,
    tooltip: obscure ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
    icon: Icon(
      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      size: 21,
      color: _iconColor,
    ),
  );
}

const TextStyle _inputStyle = TextStyle(
  fontSize: 15,
  color: AppColors.text,
  fontWeight: FontWeight.w500,
);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  String? errorMessage;
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.savedEmail.isNotEmpty) {
        emailController.text = auth.savedEmail;
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final rawIdentifier = emailController.text.trim();
    final password = passwordController.text;

    if (rawIdentifier.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email/nomor HP dan kata sandi wajib diisi';
      });
      return;
    }

    final isEmail = _isEmail(rawIdentifier);
    final isPhone = !isEmail && _isPhone(rawIdentifier);

    if (!isEmail && !isPhone) {
      setState(() {
        errorMessage = 'Masukkan email atau nomor HP yang valid';
      });
      return;
    }

    final identifier = isPhone ? _stripPhone(rawIdentifier) : rawIdentifier;

    setState(() {
      errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: identifier,
      password: password,
      rememberEmail: rememberMe,
    );

    debugPrint('LOGIN success=$success, error=${authProvider.errorMessage}');

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
    } else {
      setState(() {
        final msg = authProvider.errorMessage;
        errorMessage = (msg == null || msg.trim().isEmpty)
            ? 'Email/nomor HP atau kata sandi salah'
            : msg;
      });
    }
  }

  void _openRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;

    return _AuthShell(
      showBadge: true,
      logoSize: 68,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _AuthHeading(
            title: 'Selamat Datang di PasarDesa',
            titleColor: AppColors.green,
            subtitle: 'Masuk untuk mulai belanja produk UMKM desa',
          ),
          const _FieldLabel('Email atau Nomor HP'),
          _softShadow(
            TextField(
              controller: emailController,
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              style: _inputStyle,
              decoration: _fieldDecoration(
                hint: 'Masukkan email atau nomor telepon',
                icon: Icons.person_outline_rounded,
                error: hasError,
              ),
            ),
          ),
          const SizedBox(height: 18),
          const _FieldLabel('Kata Sandi'),
          _softShadow(
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => login(),
              style: _inputStyle,
              decoration: _fieldDecoration(
                hint: 'Masukkan kata sandi',
                icon: Icons.lock_outline,
                error: hasError,
                suffix: _visibilityToggle(
                  obscure: obscurePassword,
                  onTap: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    rememberMe = !rememberMe;
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CheckTile(
                        value: rememberMe,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ingat Saya',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (hasError) ...[
            const SizedBox(height: 12),
            _MessageBox(errorMessage!, isError: true),
          ],
          const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return _PrimaryButton(
                text: 'Masuk',
                loading: auth.isLoading,
                onPressed: login,
              );
            },
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belum punya akun? ',
                style: TextStyle(fontSize: 13, color: _subtle),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openRegister,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    'Daftar sekarang',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.green,
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
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const int _maxDigits = 13;

  String _phone = '';
  bool _submitting = false;
  String? _errorMessage;

  void _addDigit(String digit) {
    if (_submitting || _phone.length >= _maxDigits) return;
    HapticFeedback.selectionClick();
    setState(() {
      _phone += digit;
      _errorMessage = null;
    });
  }

  void _deleteDigit() {
    if (_submitting || _phone.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _phone = _phone.substring(0, _phone.length - 1);
      _errorMessage = null;
    });
  }

  void _clearAll() {
    if (_submitting || _phone.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _phone = '';
      _errorMessage = null;
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final phone = _phone.trim();
    if (phone.isEmpty || phone.length < 9) {
      setState(() {
        _errorMessage = 'Masukkan nomor WhatsApp yang valid.';
      });
      _showNotice(context, 'Masukkan nomor WhatsApp yang valid.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().requestPasswordResetOtp(
            phone: phone,
          );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyOtpScreen(phone: phone),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final msg = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorMessage = msg;
      });
      _showNotice(context, msg);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _digitBoxes() {
    final hasError = _errorMessage != null;
    final total = math.min(_maxDigits, math.max(12, _phone.length));

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 12,
      children: List.generate(total, (i) {
        final filled = i < _phone.length;
        final active = i == _phone.length && !hasError;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 46,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled
                ? Colors.white
                : Colors.white.withValues(alpha: active ? 0.14 : 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFFF8A8F)
                  : active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.22),
              width: active || hasError ? 1.8 : 1.2,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: filled
              ? Text(
                  _phone[i],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                )
              : null,
        );
      }),
    );
  }

  Widget _keypad() {
    Widget digit(String d) => Expanded(
          child: _KeypadKey(
            onTap: () => _addDigit(d),
            child: Text(
              d,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );

    Widget row(List<String> digits) =>
        Row(children: digits.map(digit).toList());

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        children: [
          row(const ['1', '2', '3']),
          row(const ['4', '5', '6']),
          row(const ['7', '8', '9']),
          Row(
            children: [
              const Expanded(child: SizedBox(height: 68)),
              digit('0'),
              Expanded(
                child: _KeypadKey(
                  onTap: _deleteDigit,
                  onLongPress: _clearAll,
                  child: const Icon(
                    Icons.backspace_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sendCard() {
    return Material(
      color: const Color(0xFFD9F5E3),
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _submitting ? null : _submit,
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: Center(
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.green,
                    ),
                  )
                : const Text(
                    'Kirim Kode OTP',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(AppColors.green, Colors.black, 0.42)!;
    final mid = Color.lerp(AppColors.green, Colors.black, 0.12)!;
    final light = Color.lerp(AppColors.green, Colors.white, 0.08)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: dark,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [mid, dark, light],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: CustomPaint(painter: _FluidBackgroundPainter()),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 44),
                                const Text(
                                  'Masukkan Nomor WhatsApp Kamu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Kami akan mengirim kode OTP untuk '
                                  'pemulihan akun',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 400),
                                    child: _digitBoxes(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                _keypad(),
                                const SizedBox(height: 14),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  child: _sendCard(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeypadKey extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _KeypadKey({
    required this.child,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 68,
      child: InkResponse(
        onTap: onTap,
        onLongPress: onLongPress,
        radius: 38,
        highlightColor: Colors.white.withValues(alpha: 0.10),
        splashColor: Colors.white.withValues(alpha: 0.18),
        child: Center(child: child),
      ),
    );
  }
}

class _FluidBackgroundPainter extends CustomPainter {
  const _FluidBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const blur = MaskFilter.blur(BlurStyle.normal, 70);

    void blob(double dx, double dy, double r, Color c) {
      canvas.drawCircle(
        Offset(size.width * dx, size.height * dy),
        r,
        Paint()
          ..color = c
          ..maskFilter = blur,
      );
    }

    blob(0.95, 0.12, 170, Colors.white.withValues(alpha: 0.16));
    blob(0.05, 0.45, 210, Colors.black.withValues(alpha: 0.22));
    blob(0.90, 0.62, 190, Colors.white.withValues(alpha: 0.10));
    blob(0.30, 0.90, 220, Colors.black.withValues(alpha: 0.20));
    blob(0.80, 0.98, 150, Colors.white.withValues(alpha: 0.08));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class VerifyOtpScreen extends StatefulWidget {
  final String phone;

  const VerifyOtpScreen({
    super.key,
    required this.phone,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  static const int _otpLength = 6;

  String _otp = '';
  bool _submitting = false;
  String? _errorMessage;

  void _addDigit(String digit) {
    if (_submitting || _otp.length >= _otpLength) return;
    HapticFeedback.selectionClick();
    setState(() {
      _otp += digit;
      _errorMessage = null;
    });
  }

  void _deleteDigit() {
    if (_submitting || _otp.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _otp = _otp.substring(0, _otp.length - 1);
      _errorMessage = null;
    });
  }

  void _clearAll() {
    if (_submitting || _otp.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _otp = '';
      _errorMessage = null;
    });
  }

  Future<void> _verify() async {
    if (_submitting) return;

    if (_otp.length != _otpLength) {
      setState(() {
        _errorMessage = 'Masukkan kode OTP 6 digit.';
      });
      _showNotice(context, 'Masukkan kode OTP 6 digit.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      final resetToken =
          await context.read<AuthProvider>().verifyPasswordResetOtp(
                phone: widget.phone,
                otp: _otp,
              );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(resetToken: resetToken),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final msg = error.toString().replaceFirst('Exception: ', '');
      setState(() {
        _errorMessage = msg;
      });
      _showNotice(context, msg);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _otpBoxes() {
    final hasError = _errorMessage != null;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 12,
      children: List.generate(_otpLength, (i) {
        final filled = i < _otp.length;
        final active = i == _otp.length && !hasError;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 46,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled
                ? Colors.white
                : Colors.white.withValues(alpha: active ? 0.14 : 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasError
                  ? const Color(0xFFFF8A8F)
                  : active
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.22),
              width: active || hasError ? 1.8 : 1.2,
            ),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: filled
              ? Text(
                  _otp[i],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                )
              : null,
        );
      }),
    );
  }

  Widget _keypad() {
    Widget digit(String d) => Expanded(
          child: _KeypadKey(
            onTap: () => _addDigit(d),
            child: Text(
              d,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        );

    Widget row(List<String> digits) =>
        Row(children: digits.map(digit).toList());

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        children: [
          row(const ['1', '2', '3']),
          row(const ['4', '5', '6']),
          row(const ['7', '8', '9']),
          Row(
            children: [
              const Expanded(child: SizedBox(height: 68)),
              digit('0'),
              Expanded(
                child: _KeypadKey(
                  onTap: _deleteDigit,
                  onLongPress: _clearAll,
                  child: const Icon(
                    Icons.backspace_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _verifyCard() {
    return Material(
      color: const Color(0xFFD9F5E3),
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _submitting ? null : _verify,
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: Center(
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.green,
                    ),
                  )
                : const Text(
                    'Verifikasi OTP',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(AppColors.green, Colors.black, 0.42)!;
    final mid = Color.lerp(AppColors.green, Colors.black, 0.12)!;
    final light = Color.lerp(AppColors.green, Colors.white, 0.08)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: dark,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [mid, dark, light],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: CustomPaint(painter: _FluidBackgroundPainter()),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 44),
                                const Text(
                                  'Masukkan Kode OTP Kamu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Kode 6 digit sudah dikirim ke WhatsApp '
                                  'kamu dan berlaku selama 5 menit',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Center(
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 400),
                                    child: _otpBoxes(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              children: [
                                _keypad(),
                                const SizedBox(height: 14),
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 400),
                                  child: _verifyCard(),
                                ),
                                const SizedBox(height: 6),
                                TextButton(
                                  onPressed: _submitting
                                      ? null
                                      : () => Navigator.pop(context),
                                  child: const Text(
                                    'Ganti nomor WhatsApp',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFFCFF3DC),
                                      fontWeight: FontWeight.w800,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _fail(String message) {
    setState(() {
      _errorMessage = message;
    });
    _showNotice(context, message);
  }

  Future<void> _savePassword() async {
    if (_submitting) return;

    final password = passwordController.text;
    final confirmation = confirmPasswordController.text;

    if (password.length < 8) {
      _fail('Password baru minimal 8 karakter.');
      return;
    }

    if (password != confirmation) {
      _fail('Konfirmasi password tidak sama.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().resetPassword(
            resetToken: widget.resetToken,
            newPassword: password,
          );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.green,
                  size: 42,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Password Berhasil Diubah',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan masuk menggunakan password baru kamu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: _subtle,
                  height: 1.45,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      _fail(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
    );
  }

  Widget _passwordCard({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    required TextInputAction action,
    VoidCallback? onSubmitted,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textInputAction: action,
        onChanged: (_) => _clearError(),
        onSubmitted: onSubmitted == null ? null : (_) => onSubmitted(),
        style: _inputStyle,
        decoration: _fieldDecoration(
          hint: hint,
          icon: Icons.lock_outline,
          error: _errorMessage != null,
          suffix: _visibilityToggle(obscure: obscure, onTap: onToggle),
        ).copyWith(
          fillColor: Colors.white.withValues(alpha: 0.96),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 19,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: _errorMessage != null
                  ? const Color(0xFFFF8A8F)
                  : Colors.transparent,
              width: 1.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: _errorMessage != null
                  ? const Color(0xFFFF8A8F)
                  : const Color(0xFFCFF3DC),
              width: 1.8,
            ),
          ),
        ),
      ),
    );
  }

  Widget _saveCard() {
    return Material(
      color: const Color(0xFFD9F5E3),
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: _submitting ? null : _savePassword,
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: Center(
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.green,
                    ),
                  )
                : const Text(
                    'Simpan Password',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                      letterSpacing: 0.4,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(AppColors.green, Colors.black, 0.42)!;
    final mid = Color.lerp(AppColors.green, Colors.black, 0.12)!;
    final light = Color.lerp(AppColors.green, Colors.white, 0.08)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: dark,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [mid, dark, light],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
              ),
            ),
            const Positioned.fill(
              child: CustomPaint(painter: _FluidBackgroundPainter()),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: SizedBox(
                      height: math.max(constraints.maxHeight, 560.0),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 44),
                                const Text(
                                  'Buat Password Baru',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Gunakan minimal 8 karakter untuk akun '
                                  'PasarDesa kamu',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    height: 1.4,
                                    color: Colors.white.withValues(alpha: 0.75),
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        _label('Password Baru'),
                                        _passwordCard(
                                          controller: passwordController,
                                          hint: 'Masukkan password baru',
                                          obscure: _obscurePassword,
                                          onToggle: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                          action: TextInputAction.next,
                                        ),
                                        const SizedBox(height: 22),
                                        _label('Konfirmasi Password'),
                                        _passwordCard(
                                          controller: confirmPasswordController,
                                          hint: 'Ulangi password baru',
                                          obscure: _obscureConfirmPassword,
                                          onToggle: () => setState(
                                            () => _obscureConfirmPassword =
                                                !_obscureConfirmPassword,
                                          ),
                                          action: TextInputAction.done,
                                          onSubmitted: _savePassword,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                _saveCard(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeTerms = false;
  bool registerFailed = false;
  bool emailTaken = false;
  bool _submitting = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (_submitting) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;

    final failed = name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        password != confirm ||
        !agreeTerms;

    if (failed) {
      setState(() {
        registerFailed = true;
        emailTaken = false;
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        registerFailed = true;
        emailTaken = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi minimal 8 karakter.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      registerFailed = false;
      emailTaken = false;
      _submitting = true;
    });

    final error = await context.read<AuthProvider>().register(
          name: name,
          email: email,
          phone: phone,
          password: password,
        );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _submitting = false;
        registerFailed = true;
        emailTaken = error.toLowerCase().contains('email sudah terdaftar');
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran berhasil. Silakan login.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final emailError = registerFailed && emailTaken;
    final confirmError = registerFailed &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text;
    final nameError = registerFailed && nameController.text.trim().isEmpty;
    final phoneError = registerFailed && phoneController.text.trim().isEmpty;
    final passwordError = registerFailed && passwordController.text.isEmpty;
    final termsError = registerFailed && !agreeTerms;

    return _AuthShell(
      title: 'Daftar Akun',
      showBack: true,
      showBrand: false,
      titleLeft: true,
      logoSize: 58,
      wordmarkSize: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (registerFailed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: _dangerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _dangerLine),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 20,
                    color: _danger,
                  ),
                  SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      'Pendaftaran Gagal\n'
                      'Mohon periksa kembali data yang ditandai merah.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _danger,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],
          _FieldLabel('Nama Lengkap', required: true, error: nameError),
          _softShadow(
            TextField(
              controller: nameController,
              onChanged: (_) => setState(() {}),
              style: _inputStyle,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                hint: 'Masukkan nama lengkap',
                icon: Icons.person_outline,
                error: nameError,
              ),
            ),
          ),
          if (nameError) const _FieldError('Nama lengkap wajib diisi.'),
          const SizedBox(height: 16),
          _FieldLabel('Email', required: true, error: emailError),
          _softShadow(
            TextField(
              controller: emailController,
              onChanged: (_) => setState(() {}),
              style: _inputStyle,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                hint: 'Masukkan email',
                icon: Icons.mail_outline,
                error: emailError,
              ),
            ),
          ),
          if (emailError)
            const _FieldError(
              'Email sudah terdaftar. Silakan gunakan email lain atau masuk.',
            ),
          const SizedBox(height: 16),
          _FieldLabel('Nomor Telepon', required: true, error: phoneError),
          _softShadow(
            TextField(
              controller: phoneController,
              onChanged: (_) => setState(() {}),
              style: _inputStyle,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                hint: 'Masukkan nomor telepon',
                icon: Icons.phone_outlined,
                error: phoneError,
              ),
            ),
          ),
          if (phoneError) const _FieldError('Nomor telepon wajib diisi.'),
          const SizedBox(height: 16),
          _FieldLabel('Password', required: true, error: passwordError),
          _softShadow(
            TextField(
              controller: passwordController,
              obscureText: obscurePassword,
              onChanged: (_) => setState(() {}),
              style: _inputStyle,
              textInputAction: TextInputAction.next,
              decoration: _fieldDecoration(
                hint: 'Masukkan password',
                icon: Icons.lock_outline,
                error: passwordError,
                suffix: _visibilityToggle(
                  obscure: obscurePassword,
                  onTap: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),
          if (passwordError) const _FieldError('Password wajib diisi.'),
          const SizedBox(height: 16),
          _FieldLabel(
            'Konfirmasi Password',
            required: true,
            error: confirmError,
          ),
          _softShadow(
            TextField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              onChanged: (_) => setState(() {}),
              style: _inputStyle,
              textInputAction: TextInputAction.done,
              decoration: _fieldDecoration(
                hint: 'Masukkan kembali password',
                icon: Icons.lock_outline,
                error: confirmError,
                suffix: _visibilityToggle(
                  obscure: obscureConfirmPassword,
                  onTap: () {
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
          ),
          if (confirmError)
            const _FieldError('Konfirmasi password tidak cocok.'),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                agreeTerms = !agreeTerms;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _CheckTile(value: agreeTerms, onTap: () {}),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Saya menyetujui Syarat & Ketentuan serta '
                      'Kebijakan Privasi PasarDesa.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF1A1F1C),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (termsError)
            const _FieldError('Anda harus menyetujui Syarat & Ketentuan.'),
          const SizedBox(height: 22),
          _PrimaryButton(
            text: 'Daftar Akun',
            loading: _submitting,
            onPressed: register,
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah punya akun? ',
                style: TextStyle(
                  fontSize: 13,
                  color: _subtle,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
