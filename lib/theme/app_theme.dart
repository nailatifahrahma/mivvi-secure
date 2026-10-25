
import 'package:flutter/material.dart';

class AppTheme {
  static const background = Color(0xFF10111F);
  static const panel = Color(0xFF1B1D2C);
  static const panelDark = Color(0xFF111320);

  static const cyan = Color(0xFF63E4F0);
  static const cyanGlow = Color(0xFF9AF7FF);
  static const purple = Color(0xFF9B7BFF);

  static const textPrimary = Color(0xFFE5E6F7);
  static const textMuted = Color(0xFF9297A9);

  static const border = Color(0xFF292C43);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      fontFamily: 'monospace',
      colorScheme: const ColorScheme.dark(
        primary: cyan,
        secondary: purple,
        surface: panel,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: const Color(0xFF104750),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }
}
