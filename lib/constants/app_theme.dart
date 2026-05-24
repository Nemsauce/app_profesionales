import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryTerracotta = Color(0xFFC0392B);
  static const Color secondaryOrange = Color(0xFFE67E22);
  static const Color navy = Color(0xFF1A3A5C);
  static const Color creamBackground = Color(0xFFFDF6EC);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color gold = Color(0xFFC9A84C);
  static const Color errorRed = Color(0xFFC62828);
  static const Color cardBackground = Colors.white;

  static const Color primaryBlue = primaryTerracotta;
  static const Color accentOrange = secondaryOrange;
  static const Color background = creamBackground;
  static const Color warningOrange = Color(0xFFFFF3E0);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryTerracotta,
      primary: primaryTerracotta,
      secondary: secondaryOrange,
      tertiary: navy,
      surface: cardBackground,
      error: errorRed,
    ),
    scaffoldBackgroundColor: creamBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryTerracotta,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryTerracotta,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryTerracotta,
        side: const BorderSide(color: primaryTerracotta),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryTerracotta, width: 2),
      ),
      prefixIconColor: navy,
      suffixIconColor: navy,
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 1.5,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: navy, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: navy, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: navy, fontWeight: FontWeight.bold),
    ),
  );
}
