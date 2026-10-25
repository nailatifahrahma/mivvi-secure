import 'package:flutter/material.dart';
import '../theme/notification_connect_theme.dart';
import '../widgets/notification_connect_widgets.dart';
import 'dashboard_page.dart';

class NotificationConnectPage extends StatefulWidget {
  const NotificationConnectPage({super.key, this.onLater});

  final VoidCallback? onLater;

  @override
  State<NotificationConnectPage> createState() => _NotificationConnectPageState();
}

class _NotificationConnectPageState extends State<NotificationConnectPage> {
  bool _demoMode = true;
  bool _notificationEnabled = false;

  @override
  Widget build(BuildContext context) {
    final connected = _notificationEnabled;

    return Theme(data: NotificationConnectTheme.theme, child: Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const NotificationConnectHeader(),
                  const SizedBox(height: 24),
                  const NotificationStepLabel(),
                  const SizedBox(height: 9),
                  const Text(
                    'Aktifkan akses notifikasi',
                    style: TextStyle(
                      color: NotificationConnectTheme.ink,
                      fontFamily: 'sans-serif',
                      fontSize: 23,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Agar MIVVI SECURE dapat memeriksa pesan yang muncul di notifikasi, izinkan akses notifikasi melalui pengaturan Android.',
                    style: TextStyle(color: NotificationConnectTheme.muted, height: 1.55, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  DemoModeCard(
                    enabled: _demoMode,
                    onChanged: (value) => setState(() => _demoMode = value),
                  ),
                  const SizedBox(height: 16),
                  MonitoredChannels(connected: connected),
                  const SizedBox(height: 16),
                  const InspectionCard(),
                  const SizedBox(height: 16),
                  const PrivacyCard(),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _openSimulatedSettings,
                      icon: const Icon(Icons.settings, size: 18),
                      label: Text(connected ? 'Akses notifikasi aktif' : 'Buka pengaturan akses (Simulasi)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: NotificationConnectTheme.cyan,
                        foregroundColor: const Color(0xFF104750),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: widget.onLater ?? () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const DashboardPage())),
                    child: const Text('Nanti saja / Masuk ke Beranda  →'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }

  void _openSimulatedSettings() {
    setState(() => _notificationEnabled = true);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DashboardPage()),
    );
  }
}







