
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/system_header.dart';
import '../widgets/security_emblem.dart';
import '../widgets/system_status_card.dart';
import '../widgets/protection_buttons.dart';
import 'onboarding_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.15),
            radius: 1.1,
            colors: [
              Color(0xFF242047),
              AppTheme.background,
              AppTheme.background,
            ],
            stops: [0, 0.55, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                const SystemHeader(),
                const SizedBox(height: 16),

                const SecurityEmblem(),

                const SizedBox(height: 8),

                RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 29,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                    children: [
                      TextSpan(
                        text: 'MIVVI ',
                        style: TextStyle(color: AppTheme.cyan),
                      ),
                      TextSpan(
                        text: 'SECURE',
                        style: TextStyle(color: AppTheme.purple),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24,
                      height: 1,
                      color: AppTheme.cyan,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'CORE TELEMETRY',
                      style: TextStyle(
                        color: AppTheme.cyan,
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 24,
                      height: 1,
                      color: AppTheme.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                const Text(
                  'Your messages. Your safety.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.panel,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Cybersecurity Assistant Notifikasi Android',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                const SystemStatusCard(),

                const SizedBox(height: 24),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 15,
                      color: Color(0xFFFFD98B),
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Kenali risiko. Lindungi dirimu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFFD98B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: AppTheme.panel.withValues(alpha: 0.65),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.memory,
                        size: 13,
                        color: AppTheme.cyan,
                      ),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'LIGHTWEIGHT ON-DEVICE RULE-BASED RISK ENGINE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 8,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                ProtectionButtons(
                  onStartProtection: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (_) => const OnboardingPage(),
                      ),
                    );
                  },
                  onInspect: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: AppTheme.panel,
                      builder: (context) => const SafeArea(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SECURITY MODULES',
                                style: TextStyle(
                                  color: AppTheme.cyan,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 18),
                              ListTile(
                                leading: Icon(
                                  Icons.rule,
                                  color: AppTheme.cyan,
                                ),
                                title: Text('Rule-based risk engine'),
                                subtitle: Text('UI demo'),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.notifications_active_outlined,
                                  color: AppTheme.purple,
                                ),
                                title: Text('Notification monitoring'),
                                subtitle: Text('Belum diaktifkan'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                const Text(
                  '● MIVVI SECURE V1.0 • ANDROID SECURITY EDITION',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


