
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  Widget metric(String label, String value, {bool accent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 9,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: accent ? AppTheme.cyan : AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.panel,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.verified_user,
                size: 15,
                color: AppTheme.cyan,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  '[SYSTEM VERIFIED]',
                  style: TextStyle(
                    fontSize: 9,
                    color: AppTheme.cyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'LATENCY < 2MS',
                style: TextStyle(
                  fontSize: 8,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: metric('NEURAL ENGINE', 'ON-DEVICE V3.4'),
              ),
              Expanded(
                child: metric(
                  'PRIVACY POSTURE',
                  'ZERO CLOUD LOGS',
                  accent: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.panelDark,
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  color: AppTheme.purple,
                  size: 7,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'STREAM:\nNOTIFICATION_INTERCEPTOR_ACTIVE',
                    style: TextStyle(
                      fontSize: 8,
                      height: 1.5,
                      letterSpacing: 0.4,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                Text(
                  '100%\nSECURE',
                  style: TextStyle(
                    fontSize: 8,
                    height: 1.5,
                    color: AppTheme.purple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
