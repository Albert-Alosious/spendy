import 'package:flutter/material.dart';

class AppTheme {
  // Nothing OS-inspired monochrome palette with cohesive neon accents.
  static const Color primary = Color(0xFFF2F2F2);
  static const Color accentCyan = Color(0xFF7CF4E1);
  static const Color accentTeal = Color(0xFF3CF0C5);
  static const Color accentPink = Color(0xFFFF6FA0);
  static const Color accentAmber = Color(0xFFFFC857);
  static const Color background = Color(0xFF0A0B0D);
  static const Color surface = Color(0xFF14161A);
  static const Color subtle = Color(0xFF1E2026);
  static const Color warning = Color(0xFFFFC857);
  static const Color danger = Color(0xFFFF5C8D);
  static const Color success = Color(0xFF8AE234);
  static const Color teal = Color(0xFF008080);

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: false,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accentTeal,
      surface: surface,
      background: background,
      error: danger,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: primary,
      onBackground: primary,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: primary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.25),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.black,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: subtle,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white24),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accentCyan, width: 1.4),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: subtle,
      labelStyle: const TextStyle(
        color: primary,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.white24),
      ),
      selectedColor: accentCyan.withOpacity(0.2),
      secondarySelectedColor: accentCyan.withOpacity(0.2),
      deleteIconColor: primary,
      secondaryLabelStyle: const TextStyle(color: primary),
      brightness: Brightness.dark,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2E3036),
      thickness: 1,
      space: 24,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: primary, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(color: primary, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(color: Colors.white70),
      labelLarge: TextStyle(color: Colors.white60),
    ),
  );
}
