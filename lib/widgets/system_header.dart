
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SystemHeader extends StatelessWidget {
  const SystemHeader({super.key});

  Widget badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.cyan),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              letterSpacing: 0.5,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        badge(Icons.circle, 'DEFENSE MATRIX // ONLINE'),
        badge(Icons.lock, 'AES-256 GCM'),
      ],
    );
  }
}
