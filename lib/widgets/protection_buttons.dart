
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProtectionButtons extends StatelessWidget {
  final VoidCallback onStartProtection;
  final VoidCallback onInspect;

  const ProtectionButtons({
    super.key,
    required this.onStartProtection,
    required this.onInspect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onStartProtection,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radar, size: 19),
                SizedBox(width: 9),
                Text(
                  'MULAI PROTEKSI',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.7,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 19),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: TextButton(
            onPressed: onInspect,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.terminal, size: 15),
                SizedBox(width: 8),
                Text(
                  'INSPEKSI MODUL KEAMANAN',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
