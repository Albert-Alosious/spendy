import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF1565C0);
  static const Color teal = Color(0xFF11A39F);
  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Colors.white;
  static const Color warning = Color(0xFFFFB300);
  static const Color danger = Color(0xFFD84315);
  static const Color success = Color(0xFF2E7D32);

  static final ThemeData light = ThemeData(
    useMaterial3: false,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: teal,
      surface: surface,
      background: background,
      error: danger,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Color(0xFF1F2A3D),
      onBackground: Color(0xFF1F2A3D),
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: Color(0xFF142033),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF142033),
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.06),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      backgroundColor: teal,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFD8DFEA)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFD8DFEA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.grey.shade200,
      labelStyle: const TextStyle(
        color: Color(0xFF1F2A3D),
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      selectedColor: primary.withOpacity(0.12),
      secondarySelectedColor: primary.withOpacity(0.12),
      deleteIconColor: primary,
      secondaryLabelStyle: const TextStyle(color: Color(0xFF1F2A3D)),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE6EBF3),
      thickness: 1,
      space: 24,
    ),
  );
}
