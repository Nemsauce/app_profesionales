import 'package:flutter/material.dart';

class AppTheme {
  static const Color darkBackground = Color(0xFF1A0A0A);
  static const Color darkBackgroundAlt = Color(0xFF2A1010);
  static const Color terracottaRed = Color(0xFFC0392B);
  static const Color warmOrange = Color(0xFFE67E22);
  static const Color verifiedGold = Color(0xFFC9A84C);
  static const Color glassWhite = Color(0x14FFFFFF);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Colors.white70;
  static const Color errorRed = Color(0xFFC62828);
  static const Color successGreen = Color(0xFF2E7D32);

  static const Color darkSurface = darkBackgroundAlt;
  static const Color goldAccent = verifiedGold;
  static const Color glassWhiteStrong = Color(0x26FFFFFF);
  static const Color glassWhiteSoft = glassWhite;
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color textWhite = textPrimaryDark;
  static const Color textWhiteMuted = textSecondaryDark;
  static const Color textWhiteSubtle = Color(0x66FFFFFF);

  static const Color primaryTerracotta = terracottaRed;
  static const Color secondaryOrange = warmOrange;
  static const Color navy = textWhite;
  static const Color creamBackground = darkBackground;
  static const Color gold = goldAccent;

  static const Color primaryBlue = terracottaRed;
  static const Color accentOrange = warmOrange;
  static const Color background = darkBackground;
  static const Color cardBackground = glassWhiteSoft;
  static const Color warningOrange = Color(0x26C9A84C);
  static const Color warningText = goldAccent;

  static const double defaultRadius = 16.0;
  static const double largeRadius = 28.0;
  static const double screenPadding = 24.0;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: terracottaRed,
      brightness: Brightness.dark,
      primary: terracottaRed,
      secondary: warmOrange,
      surface: darkSurface,
      error: errorRed,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: textWhite,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: terracottaRed,
        foregroundColor: textWhite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: warmOrange,
        side: const BorderSide(color: warmOrange),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultRadius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: glassWhiteSoft,
      labelStyle: const TextStyle(color: textWhiteMuted),
      hintStyle: const TextStyle(color: textWhiteSubtle),
      prefixIconColor: textWhiteMuted,
      suffixIconColor: textWhiteMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: const BorderSide(color: glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: const BorderSide(color: glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: const BorderSide(color: warmOrange, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: const BorderSide(color: errorRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        borderSide: const BorderSide(color: errorRed, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: cardBackground,
      elevation: 6,
      margin: EdgeInsets.zero,
      shadowColor: terracottaRed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(defaultRadius),
        side: const BorderSide(color: glassBorder),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: textWhite),
      bodyMedium: TextStyle(color: textWhiteMuted),
      bodySmall: TextStyle(color: textWhiteSubtle),
      labelLarge: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
    ),
  );
}
