import 'package:flutter/material.dart';

/// Tema khusus dashboard Mivvi Secure.
class DashboardTheme {
  static const background = Color(0xFF10111F);
  static const surface = Color(0xFF1B1D2C);
  static const raised = Color(0xFF222436);
  static const cyan = Color(0xFF63E4F0);
  static const purple = Color(0xFF9B7BFF);
  static const ink = Color(0xFFE5E6F7);
  static const muted = Color(0xFF9297A9);
  static const danger = Color(0xFFFF5865);
  static const amber = Color(0xFFFFD98B);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: cyan,
          secondary: purple,
          surface: surface,
          onSurface: ink,
        ),
        fontFamily: 'monospace',
      );
}
