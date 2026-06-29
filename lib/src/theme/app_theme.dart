import 'package:flutter/material.dart';

class AppTheme {
  static const Color brand = Color(0xFFFCC419);
  static const Color royalBlue = Color(0xFF163EAE);
  static const Color dark = Color(0xFF121212);
  static const Color soft = Color(0xFFF5F5F5);
  static const Color mist = Color(0xFFDCE8F1);

  static ThemeData get lightTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        primary: brand,
        secondary: dark,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'SF Pro Display',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: brand),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: brand,
        brightness: Brightness.dark,
        primary: brand,
        secondary: brand,
        surface: dark,
      ),
      scaffoldBackgroundColor: dark,
      fontFamily: 'SF Pro Display',
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1B1B1B),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B1B1B),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          borderSide: BorderSide(color: brand),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: AppTheme.dark,
      ),
    );
  }
}
