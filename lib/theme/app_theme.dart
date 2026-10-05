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
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
          borderSide: BorderSide(
            color: AppColors.green,
            width: 1.5,
          ),
        ),
      ),
    );
  }

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

final appTheme = AppTheme.theme;

TextStyle titleStyle({
  double size = 18,
  FontWeight weight = FontWeight.w700,
}) {
  return AppTheme.titleStyle(
    size: size,
    weight: weight,
  );
}

TextStyle greenStyle({
  double size = 13,
  FontWeight weight = FontWeight.w700,
}) {
  return AppTheme.greenStyle(
    size: size,
    weight: weight,
  );
}
