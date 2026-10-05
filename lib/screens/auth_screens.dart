import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';

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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      errorMessage = null;
    });

    if (email == 'elsafe@gmail.com' && password == '123456') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DashboardScreen(),
        ),
      );
      return;
    }

    setState(() {
      errorMessage = 'Email atau password salah';
    });
  }

  InputDecoration _loginDecoration({
    required String hint,
    required IconData icon,
    bool error = false,
    Widget? suffixIcon,
  }) {
    final borderColor =
        error ? const Color(0xFFFF5A67) : const Color(0xFFD6DCD8);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFF8A928D),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        size: 17,
        color: const Color(0xFF69716C),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: error ? const Color(0xFFFF5A67) : AppColors.green,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFFFFB8BE),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 14,
            color: Color(0xFFE53935),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 9,
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pasarDesaLogo({double fontSize = 20}) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Pasar',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
              height: 1,
            ),
          ),
          TextSpan(
            text: 'Desa',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _umkmBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF2E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'UMKM DESA SUKOREJO',
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w800,
          color: AppColors.green,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            24,
            28,
            24,
            22,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: BrandMark(size: 58),
              ),
              const SizedBox(height: 8),
              Center(
                child: _pasarDesaLogo(
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Selamat Datang di PasarDesa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Silakan masuk untuk melanjutkan transaksi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF8A928D),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: _umkmBadge(),
              ),
              const SizedBox(height: 28),
              const Text(
                'Email atau Nomor HP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.text,
                ),
                decoration: _loginDecoration(
                  hint: 'Masukkan email atau nomor telepon',
                  icon: Icons.mail_outline,
                  error: errorMessage != null,
                ),
              ),
              const SizedBox(height: 17),
              const Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => login(),
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.text,
                ),
                decoration: _loginDecoration(
                  hint: 'Masukkan kata sandi',
                  icon: Icons.lock_outline,
                  error: errorMessage != null,
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    splashRadius: 18,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 17,
                      color: const Color(0xFF69716C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Lupa Kata Sandi?',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 3),
                _errorBox(errorMessage!),
              ],
              const SizedBox(height: 13),
              SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'Masuk Sekarang   →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 17),
              const Center(
                child: Text(
                  'ATAU',
                  style: TextStyle(
                    fontSize: 8,
                    color: Color(0xFF7F8782),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 11),
              SizedBox(
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.person_add_alt_1,
                    size: 16,
                    color: AppColors.text,
                  ),
                  label: const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFFBFC6C1),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF737B76),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Daftar sekarang',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 12,
                    color: AppColors.green,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Aman & Terpercaya untuk Warga Desa',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
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
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();

  bool submitted = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void submit() {
    setState(() {
      submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
        title: const Text(
          'Lupa Password',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 18),
              const Center(
                child: BrandMark(size: 60),
              ),
              const SizedBox(height: 18),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Pasar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                    TextSpan(
                      text: 'Desa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Lupa Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Masukkan email yang terdaftar.\n'
                'Kami akan membantu proses pemulihan akun.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _simpleDecoration(
                  hint: 'Masukkan email',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 14),
              if (submitted)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Text(
                    'Instruksi pemulihan password akan dikirim '
                    'ke email yang terdaftar.',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              GreenButton(
                text: 'Kirim Instruksi  →',
                onTap: submit,
              ),
            ],
          ),
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

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void register() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirm = confirmPasswordController.text;
    final emailAlreadyRegistered =
        email.toLowerCase() == 'budisantoso12@gmail.com';

    final failed = name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirm.isEmpty ||
        password != confirm ||
        !agreeTerms ||
        emailAlreadyRegistered;

    if (failed) {
      setState(() {
        registerFailed = true;
      });
      return;
    }

    setState(() {
      registerFailed = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Pendaftaran berhasil. Silakan login.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  InputDecoration _registerDecoration({
    required String hint,
    required IconData icon,
    bool error = false,
    Widget? suffix,
  }) {
    final borderColor =
        error ? const Color(0xFFFF5A67) : const Color(0xFFBFC7C2);

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 10,
        color: Color(0xFF8B938E),
      ),
      prefixIcon: Icon(
        icon,
        size: 16,
        color: const Color(0xFF66706A),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 11,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(7),
        borderSide: BorderSide(
          color: error ? const Color(0xFFFF5A67) : AppColors.green,
          width: 1.2,
        ),
      ),
    );
  }

  Widget _label(
    String text, {
    bool required = true,
    bool error = false,
  }) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: error ? const Color(0xFFE53935) : AppColors.text,
        ),
        children: [
          TextSpan(text: text),
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(
                color: error ? const Color(0xFFE53935) : AppColors.text,
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldError(String message) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
        left: 2,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 10,
            color: Color(0xFFE53935),
          ),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 7,
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pasarDesaLogo({
    double fontSize = 18,
  }) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Pasar',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: AppColors.green,
            ),
          ),
          TextSpan(
            text: 'Desa',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _umkmBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF2E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'UMKM DESA SUKOREJO',
        style: TextStyle(
          fontSize: 6,
          fontWeight: FontWeight.w800,
          color: AppColors.green,
          letterSpacing: .25,
        ),
      ),
    );
  }

  Widget _passwordToggle({
    required bool obscure,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      splashRadius: 18,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 16,
        color: const Color(0xFF68716B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailError = registerFailed &&
        emailController.text.trim().toLowerCase() == 'budisantoso12@gmail.com';
    final confirmError = registerFailed &&
        confirmPasswordController.text.isNotEmpty &&
        passwordController.text != confirmPasswordController.text;
    final nameError = registerFailed && nameController.text.trim().isEmpty;
    final phoneError = registerFailed && phoneController.text.trim().isEmpty;
    final passwordError = registerFailed && passwordController.text.isEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 17,
            color: AppColors.text,
          ),
        ),
        title: const Text(
          'DAFTAR AKUN',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            22,
            8,
            22,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: BrandMark(size: 48),
              ),
              const SizedBox(height: 6),
              Center(
                child: _pasarDesaLogo(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Selamat Datang di PasarDesa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Silakan lengkapi data untuk membuat akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 8,
                  color: Color(0xFF8A928D),
                ),
              ),
              const SizedBox(height: 7),
              Center(
                child: _umkmBadge(),
              ),
              const SizedBox(height: 16),
              if (registerFailed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F4),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: const Color(0xFFFFB8BE),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Color(0xFFE53935),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Pendaftaran Gagal\n'
                          'Mohon periksa kembali data yang ditandai merah.',
                          style: TextStyle(
                            fontSize: 8,
                            color: Color(0xFFE53935),
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
              _label(
                'NAMA LENGKAP',
                error: nameError,
              ),
              const SizedBox(height: 5),
              TextField(
                controller: nameController,
                onChanged: (_) {
                  setState(() {});
                },
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: _registerDecoration(
                  hint: 'Masukkan nama lengkap',
                  icon: Icons.person_outline,
                  error: nameError,
                ),
              ),
              if (nameError)
                _fieldError(
                  'Nama lengkap wajib diisi.',
                ),
              const SizedBox(height: 10),
              _label(
                'EMAIL',
                error: emailError,
              ),
              const SizedBox(height: 5),
              TextField(
                controller: emailController,
                onChanged: (_) {
                  setState(() {});
                },
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: _registerDecoration(
                  hint: 'Masukkan email',
                  icon: Icons.mail_outline,
                  error: emailError,
                ),
              ),
              if (emailError)
                _fieldError(
                  'Email sudah terdaftar. '
                  'Silakan gunakan email lain atau masuk.',
                ),
              const SizedBox(height: 10),
              _label(
                'NOMOR TELEPON',
                error: phoneError,
              ),
              const SizedBox(height: 5),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _registerDecoration(
                  hint: 'Masukkan nomor telepon',
                  icon: Icons.phone_outlined,
                  error: phoneError,
                ),
              ),
              if (phoneError)
                _fieldError(
                  'Nomor telepon wajib diisi.',
                ),
              const SizedBox(height: 10),
              _label(
                'PASSWORD',
                error: passwordError,
              ),
              const SizedBox(height: 5),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                onChanged: (_) {
                  setState(() {});
                },
                textInputAction: TextInputAction.next,
                decoration: _registerDecoration(
                  hint: 'Masukkan password',
                  icon: Icons.lock_outline,
                  error: passwordError,
                  suffix: _passwordToggle(
                    obscure: obscurePassword,
                    onTap: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              if (passwordError)
                _fieldError(
                  'Password wajib diisi.',
                ),
              const SizedBox(height: 10),
              _label(
                'KONFIRMASI PASSWORD',
                error: confirmError,
              ),
              const SizedBox(height: 5),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                onChanged: (_) {
                  setState(() {});
                },
                textInputAction: TextInputAction.done,
                decoration: _registerDecoration(
                  hint: 'Masukkan kembali password',
                  icon: Icons.lock_outline,
                  error: confirmError,
                  suffix: _passwordToggle(
                    obscure: obscureConfirmPassword,
                    onTap: () {
                      setState(() {
                        obscureConfirmPassword = !obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              if (confirmError)
                _fieldError(
                  'Konfirmasi password tidak cocok.',
                ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  setState(() {
                    agreeTerms = !agreeTerms;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 15,
                      height: 15,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: agreeTerms ? AppColors.green : Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: agreeTerms
                              ? AppColors.green
                              : const Color(0xFFBFC7C2),
                        ),
                      ),
                      child: agreeTerms
                          ? const Icon(
                              Icons.check,
                              size: 11,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 7),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 7,
                            color: Color(0xFF606862),
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: 'Saya menyetujui ',
                            ),
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(
                                color: AppColors.green,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' serta ',
                            ),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: TextStyle(
                                color: AppColors.green,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(
                              text: ' PasarDesa.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (registerFailed && !agreeTerms)
                _fieldError(
                  'Anda harus menyetujui '
                  'Syarat & Ketentuan.',
                ),
              const SizedBox(height: 14),
              SizedBox(
                height: 40,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: const Text(
                    'DAFTAR AKUN SEKARANG   →',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 13),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 8,
                      color: Color(0xFF737B76),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'MASUK',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 11),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 11,
                    color: AppColors.green,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Aman & Terpercaya untuk Warga Desa',
                    style: TextStyle(
                      fontSize: 7,
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
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
}

InputDecoration _simpleDecoration({
  required String hint,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
      fontSize: 10,
      color: AppColors.muted,
    ),
    prefixIcon: Icon(
      icon,
      size: 17,
      color: const Color(0xFF68716B),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 11,
      vertical: 12,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFD6DCD8),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: Color(0xFFD6DCD8),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(
        color: AppColors.green,
      ),
    ),
  );
}
