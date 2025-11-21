import 'package:flutter/material.dart';

class AppTheme {
  // Palette (base)
  static const Color primary = Color(0xFF8B5E3C); // Warm Brown
  static const Color secondary = Color(0xFF5D3A1A); // Deep Brown
  static const Color accentPink = Color(0xFFF2E2D2); // Soft Beige Pink
  static const Color accentAmber = Color(0xFFF59E0B); // Amber
  static const Color accentTeal = primary;
  static const Color accentCyan = secondary;
  static const Color background = Color(0xFF121212); // Dark neutral
  static const Color surface = Color(0xFF1E1E1E); // Dark surface
  static const Color subtle = Color(0xFF2A2A2A);
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Soft Red
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color darkBackground = Color(0xFF0B0B0C);
  static const Color darkSurface = Color(0xFF141416);
  static const Color darkSubtle = Color(0xFF1D1E20);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  static final ThemeData light = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      error: danger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onBackground: textPrimary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: subtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: subtle),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      labelStyle: const TextStyle(color: textSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surface,
      labelStyle: const TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: subtle),
      ),
      selectedColor: primary.withOpacity(0.12),
      secondarySelectedColor: primary.withOpacity(0.12),
      deleteIconColor: textSecondary,
      secondaryLabelStyle: const TextStyle(color: textPrimary),
    ),
    dividerTheme: DividerThemeData(
      color: subtle,
      thickness: 1,
      space: 24,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: textSecondary),
      labelLarge: TextStyle(color: textSecondary),
    ),
  );

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      surface: darkSurface,
      background: darkBackground,
      error: danger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextPrimary,
      onBackground: darkTextPrimary,
    ),
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: darkTextPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.4),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSubtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white24),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      labelStyle: const TextStyle(color: darkTextSecondary),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkSubtle,
      labelStyle: const TextStyle(
        color: darkTextPrimary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.white24),
      ),
      selectedColor: primary.withOpacity(0.18),
      secondarySelectedColor: primary.withOpacity(0.18),
      deleteIconColor: darkTextSecondary,
      secondaryLabelStyle: const TextStyle(color: darkTextPrimary),
      brightness: Brightness.dark,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF1F2937),
      thickness: 1,
      space: 24,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: darkTextPrimary, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: darkTextSecondary),
      labelLarge: TextStyle(color: darkTextSecondary),
    ),
  );
}
