import 'package:flutter/material.dart';

/// Tema visual khusus halaman Hubungkan Notifikasi.
class NotificationConnectTheme {
  static const background = Color(0xFF10111F);
  static const panel = Color(0xFF1B1D2C);
  static const cyan = Color(0xFF63E4F0);
  static const purple = Color(0xFF9B7BFF);
  static const ink = Color(0xFFE5E6F7);
  static const muted = Color(0xFF9297A9);
  static const violet = Color(0xFF382477);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        fontFamily: 'monospace',
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: purple,
          surface: panel,
          onSurface: ink,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: muted, height: 1.5),
          titleMedium: TextStyle(color: ink, fontWeight: FontWeight.w600),
        ),
      );
}
