import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/local/storage/app_preferences.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/settings_provider.dart';

import 'screens/auth_screens.dart';
import 'screens/dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppPreferences.getInstance();

  runApp(const PasarDesaApp());
}

class PasarDesaApp extends StatelessWidget {
  const PasarDesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider.value(
          value: orderStore,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PasarDesa UMKM Desa Sukorejo',
        theme: appTheme,
        home: const AppEntryGate(),
      ),
    );
  }
}

class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  bool _splashFinished = false;

  @override
  void initState() {
    super.initState();

    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future.delayed(
      const Duration(seconds: 4),
    );

    if (!mounted) return;

    setState(() {
      _splashFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!_splashFinished || auth.isLoading) {
      return const SplashScreen();
    }

    if (auth.isAuthenticated) {
      return const DashboardScreen();
    }

    return const LoginScreen();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const Color backgroundColor = Color(0xFFF8FFFB);
  static const Color primaryGreen = Color(0xFF00B879);
  static const Color subtitleColor = Color(0xFF719585);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SizedBox.expand(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ANIMASI GIF TAS BELANJA
              Image.asset(
                'assets/images/splash_screen.gif',
                width: 280,
                height: 250,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),

              const SizedBox(height: 12),

              const Text(
                'PASAR DESA',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Belanja Mudah, Produk Desa Berkualitas',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
