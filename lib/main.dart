import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/cart_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screens.dart';

void main() {
  runApp(const PasarDesaApp());
}

class PasarDesaApp extends StatelessWidget {
  const PasarDesaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PasarDesa UMKM Desa Sukorejo',
        theme: appTheme,
        home: const LoginScreen(),
      ),
    );
  }
}