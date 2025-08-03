import 'package:flutter/material.dart';

class AppTheme {
  // Palet Warna Utama
  static const Color primaryColor = Color(0xFF0D47A1); // Biru Tua
  static const Color secondaryColor = Color(0xFF1976D2); // Biru Terang
  static const Color accentColor = Color(0xFF42A5F5); // Biru Muda

  // Warna Status
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFFA000);

  // Warna Teks dan Latar Belakang
  static const Color surfaceColor = Color(0xFFF5F5F5); // Latar Belakang
  static const Color onPrimaryColor = Colors.white; // Teks di atas Primary
  static const Color primaryTextColor = Color(0xFF212121); // Teks Utama
  static const Color secondaryTextColor = Color(0xFF757575); // Teks Sekunder

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: onPrimaryColor,
        elevation: 1,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: primaryTextColor, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: primaryTextColor, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(color: secondaryTextColor),
      ),
    );
  }
}