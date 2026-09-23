import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool failed;

  const LoginScreen({
    super.key,
    this.failed = false,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscure = true;

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 390,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 25),

                  const BrandMark(size: 52),

                  const SizedBox(height: 10),

                  const Text(
                    'PasarDesa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Selamat Datang di PasarDesa',
                    style: titleStyle(size: 14),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Silakan masuk untuk melanjutkan transaksi',
                    style: TextStyle(
                      fontSize: 9,
                      color: AppColors.muted,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDDF3E3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'UMKM DESA SUKOREJO',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  _label('Email atau Nomor HP'),

                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Masukkan email atau no. handphone',
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        size: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 17),

                  _label('Kata Sandi'),

                  TextField(
                    controller: password,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        size: 16,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 17,
                        ),
                        onPressed: () {
                          setState(() {
                            obscure = !obscure;
                          });
                        },
                      ),
                      errorText: widget.failed
                          ? 'Email atau password salah'
                          : null,
                    ),
                  ),

                  if (widget.failed)
                    const SizedBox(height: 5),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 3),

                  GreenButton(
                    text: 'Masuk Sekarang  →',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DashboardScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 13),

                  const Text(
                    'ATAU',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  GreenButton(
                    text: 'Daftar Akun Baru',
                    outlined: true,
                    icon: Icons.person_add_alt_1,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 17),

                  const Text.rich(
                    TextSpan(
                      text: 'Belum punya akun? ',
                      style: TextStyle(fontSize: 9),
                      children: [
                        TextSpan(
                          text: 'Daftar sekarang',
                          style: TextStyle(
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 7),

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

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final bool failed;

  const RegisterScreen({
    super.key,
    this.failed = false,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool obscure1 = true;
  bool obscure2 = true;
  bool buyer = true;
  bool agree = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 19,
          ),
        ),
        title: const Text(
          'DAFTAR AKUN',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: RoundAvatar(),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
          child: Column(
            children: [
              const BrandMark(size: 52),

              const SizedBox(height: 9),

              const Text(
                'PasarDesa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),

              const SizedBox(height: 4),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDDF3E3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'UMKM DESA SUKOREJO',
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              if (widget.failed) ...[
                const SizedBox(height: 13),
                _errorBanner(
                  'Pendaftaran Gagal',
                  'Mohon periksa kembali data yang ditandai merah',
                ),
              ],

              const SizedBox(height: 13),

              _field(
                'NAMA LENGKAP*',
                'Budi Santoso',
              ),

              _field(
                'EMAIL*',
                widget.failed
                    ? 'budisantoso12@gmail.com'
                    : 'budisantoso@gmail.com',
                error: widget.failed
                    ? 'Email sudah terdaftar. Silakan gunakan email lain atau masuk'
                    : null,
              ),

              _field(
                'NOMOR TELEPON*',
                '+62 8xx-xxx-xxxx',
              ),

              _field(
                'PASSWORD*',
                'rahasiaBudi123',
                obscure: obscure1,
                toggle: () {
                  setState(() {
                    obscure1 = !obscure1;
                  });
                },
              ),

              _field(
                'KONFIRMASI PASSWORD*',
                widget.failed
                    ? 'rahasiaBudi999'
                    : 'rahasiaBudi123',
                obscure: obscure2,
                toggle: () {
                  setState(() {
                    obscure2 = !obscure2;
                  });
                },
                error: widget.failed
                    ? 'Konfirmasi password tidak cocok'
                    : null,
              ),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DAFTAR SEBAGAI*',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              Row(
                children: [
                  _role(
                    'PEMBELI',
                    'Warga / Belanja',
                    buyer,
                    () {
                      setState(() {
                        buyer = true;
                      });
                    },
                  ),
                  const SizedBox(width: 7),
                  _role(
                    'PEDAGANG',
                    'Buka Lapak Desa',
                    !buyer,
                    () {
                      setState(() {
                        buyer = false;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: agree,
                    onChanged: (value) {
                      setState(() {
                        agree = value ?? false;
                      });
                    },
                    activeColor: AppColors.green,
                    visualDensity: VisualDensity.compact,
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text.rich(
                        TextSpan(
                          text: 'Saya menyetujui ',
                          style: TextStyle(fontSize: 8),
                          children: [
                            TextSpan(
                              text: 'Syarat & Ketentuan',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(text: ' serta '),
                            TextSpan(
                              text: 'Kebijakan Privasi',
                              style: TextStyle(
                                color: AppColors.green,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: ' PasarDesa.',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              GreenButton(
                text: 'DAFTAR AKUN SEKARANG  →',
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              const Text.rich(
                TextSpan(
                  text: 'Sudah punya akun? ',
                  style: TextStyle(fontSize: 9),
                  children: [
                    TextSpan(
                      text: 'MASUK',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

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

  Widget _field(
    String label,
    String hint, {
    bool obscure = false,
    VoidCallback? toggle,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: error == null
                  ? AppColors.text
                  : AppColors.red,
            ),
          ),

          const SizedBox(height: 4),

          TextField(
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              suffixIcon: toggle == null
                  ? null
                  : TextButton(
                      onPressed: toggle,
                      child: const Text(
                        'LIHAT',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
            ),
          ),

          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                '● $error',
                style: const TextStyle(
                  fontSize: 7.5,
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _role(
    String title,
    String sub,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.green
                : Colors.white,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected
                  ? AppColors.green
                  : const Color(0xFFB9DCC7),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.check_box
                    : Icons.check_box_outline_blank,
                color: selected
                    ? Colors.white
                    : Colors.black38,
                size: 18,
              ),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: selected
                          ? Colors.white
                          : AppColors.text,
                    ),
                  ),
                  Text(
                    sub,
                    style: TextStyle(
                      fontSize: 7,
                      color: selected
                          ? Colors.white
                          : AppColors.muted,
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

  Widget _errorBanner(
    String title,
    String sub,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFFFA8B2),
        ),
        borderRadius: BorderRadius.circular(7),
        color: const Color(0xFFFFF9FA),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.red,
            size: 18,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppColors.red,
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