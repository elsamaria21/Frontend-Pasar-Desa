import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xFF118B45);
  static const greenDark = Color(0xFF087B3A);
  static const greenLight = Color(0xFFE9F8EE);
  static const mint = Color(0xFFDDF6E7);
  static const orange = Color(0xFFFF7A2F);
  static const red = Color(0xFFE95667);
  static const text = Color(0xFF171A19);
  static const muted = Color(0xFF747C76);
  static const border = Color(0xFFD7DDD9);
  static const bg = Color(0xFFF8FAF8);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.green,
        primary: AppColors.green,
      ),
      fontFamily: 'Arial',
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: 13,
          color: AppColors.text,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          borderSide: const BorderSide(
            color: AppColors.green,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // Helper TextStyles untuk dipakai di halaman/screen lain
  static TextStyle titleStyle({
    double size = 18,
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: AppColors.text,
    );
  }

  static TextStyle greenStyle({
    double size = 13,
    FontWeight weight = FontWeight.w700,
  }) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: AppColors.green,
    );
  }
}