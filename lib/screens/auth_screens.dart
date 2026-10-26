import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      if (auth.savedEmail.isNotEmpty) {
        emailController.text = auth.savedEmail;
        setState(() {
          rememberMe = auth.rememberEmail;
        });
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
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Email dan kata sandi wajib diisi';
      });
      return;
    }

    setState(() {
      errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: email,
      password: password,
      rememberEmail: rememberMe,
    );

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
        errorMessage = authProvider.errorMessage ?? 'Email atau password salah';
      });
    }
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
        fontSize: 14,
        color: Color(0xFF8A928D),
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(
        icon,
        size: 21,
        color: const Color(0xFF69716C),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: error ? const Color(0xFFFF5A67) : AppColors.green,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _errorBox(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFFB8BE),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            size: 18,
            color: Color(0xFFE53935),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pasarDesaLogo({double fontSize = 28}) {
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
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF2E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'UMKM DESA SUKOREJO',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.green,
          letterSpacing: 0.4,
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
                child: BrandMark(size: 64),
              ),
              const SizedBox(height: 10),
              Center(
                child: _pasarDesaLogo(
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'Selamat Datang di PasarDesa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Silakan masuk untuk melanjutkan transaksi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A928D),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: _umkmBadge(),
              ),
              const SizedBox(height: 30),
              const Text(
                'Email atau Nomor HP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.text,
                ),
                decoration: _loginDecoration(
                  hint: 'Masukkan email atau nomor telepon',
                  icon: Icons.mail_outline,
                  error: errorMessage != null,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Kata Sandi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => login(),
                style: const TextStyle(
                  fontSize: 15,
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
                    splashRadius: 20,
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 21,
                      color: const Color(0xFF69716C),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        rememberMe = !rememberMe;
                      });
                    },
                    borderRadius: BorderRadius.circular(4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: rememberMe,
                            activeColor: AppColors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (v) {
                              setState(() {
                                rememberMe = v ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
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
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                _errorBox(errorMessage!),
              ],
              const SizedBox(height: 14),
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Masuk Sekarang   →',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'ATAU',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7F8782),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
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
                    size: 20,
                    color: AppColors.text,
                  ),
                  label: const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(
                      fontSize: 15,
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
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum punya akun? ',
                    style: TextStyle(
                      fontSize: 13,
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
                        fontSize: 13,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 16,
                    color: AppColors.green,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Aman & Terpercaya untuk Warga Desa',
                    style: TextStyle(
                      fontSize: 12,
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
            fontSize: 18,
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
                child: BrandMark(size: 64),
              ),
              const SizedBox(height: 18),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Pasar',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                    TextSpan(
                      text: 'Desa',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Lupa Password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan email yang terdaftar.\n'
                'Kami akan membantu proses pemulihan akun.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15),
                decoration: _simpleDecoration(
                  hint: 'Masukkan email',
                  icon: Icons.email_outlined,
                ),
              ),
              const SizedBox(height: 16),
              if (submitted)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Instruksi pemulihan password akan dikirim '
                    'ke email yang terdaftar.',
                    style: TextStyle(
                      fontSize: 13,
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
        fontSize: 14,
        color: Color(0xFF8B938E),
      ),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: const Color(0xFF66706A),
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(
          color: error ? const Color(0xFFFF5A67) : AppColors.green,
          width: 1.4,
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
          fontSize: 13,
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
        top: 5,
        left: 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(
              Icons.error_outline,
              size: 14,
              color: Color(0xFFE53935),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
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
    double fontSize = 26,
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
        horizontal: 11,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFDDF2E3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'UMKM DESA SUKOREJO',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: AppColors.green,
          letterSpacing: .3,
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
      splashRadius: 20,
      icon: Icon(
        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: const Color(0xFF68716B),
      ),
    );
  }

  TextStyle get _inputStyle => const TextStyle(
        fontSize: 15,
        color: AppColors.text,
      );

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
            size: 20,
            color: AppColors.text,
          ),
        ),
        title: const Text(
          'DAFTAR AKUN',
          style: TextStyle(
            fontSize: 18,
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
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 18,
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
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: BrandMark(size: 56),
              ),
              const SizedBox(height: 8),
              Center(
                child: _pasarDesaLogo(
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Selamat Datang di PasarDesa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Silakan lengkapi data untuk membuat akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8A928D),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: _umkmBadge(),
              ),
              const SizedBox(height: 18),
              if (registerFailed) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3F4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFB8BE),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 20,
                        color: Color(0xFFE53935),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pendaftaran Gagal\n'
                          'Mohon periksa kembali data yang ditandai merah.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFFE53935),
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              _label(
                'NAMA LENGKAP',
                error: nameError,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                onChanged: (_) {
                  setState(() {});
                },
                style: _inputStyle,
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
              const SizedBox(height: 12),
              _label(
                'EMAIL',
                error: emailError,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: emailController,
                onChanged: (_) {
                  setState(() {});
                },
                style: _inputStyle,
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
              const SizedBox(height: 12),
              _label(
                'NOMOR TELEPON',
                error: phoneError,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: phoneController,
                style: _inputStyle,
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
              const SizedBox(height: 12),
              _label(
                'PASSWORD',
                error: passwordError,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                onChanged: (_) {
                  setState(() {});
                },
                style: _inputStyle,
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
              const SizedBox(height: 12),
              _label(
                'KONFIRMASI PASSWORD',
                error: confirmError,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: confirmPasswordController,
                obscureText: obscureConfirmPassword,
                onChanged: (_) {
                  setState(() {});
                },
                style: _inputStyle,
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
              const SizedBox(height: 14),
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
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: agreeTerms ? AppColors.green : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: agreeTerms
                              ? AppColors.green
                              : const Color(0xFFBFC7C2),
                        ),
                      ),
                      child: agreeTerms
                          ? const Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 9),
                    const Expanded(
                      child: Text.rich(
                        TextSpan(
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF606862),
                            height: 1.45,
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
              const SizedBox(height: 16),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'DAFTAR AKUN SEKARANG   →',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF737B76),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'MASUK',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 15,
                    color: AppColors.green,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Aman & Terpercaya untuk Warga Desa',
                    style: TextStyle(
                      fontSize: 12,
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
      fontSize: 14,
      color: AppColors.muted,
    ),
    prefixIcon: Icon(
      icon,
      size: 20,
      color: const Color(0xFF68716B),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 13,
      vertical: 15,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFFD6DCD8),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: Color(0xFFD6DCD8),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(
        color: AppColors.green,
        width: 1.4,
      ),
    ),
  );
}
