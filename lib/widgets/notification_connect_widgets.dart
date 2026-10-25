import 'package:flutter/material.dart';
import '../theme/notification_connect_theme.dart';

class NotificationConnectHeader extends StatelessWidget {
  const NotificationConnectHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              border: Border.all(color: NotificationConnectTheme.cyan.withValues(alpha: .5)),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_outlined, size: 18, color: NotificationConnectTheme.cyan),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MIVVI SECURE', style: TextStyle(color: NotificationConnectTheme.ink, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 2),
                Text('PERM-INIT // SYS_V3.9', style: TextStyle(color: NotificationConnectTheme.muted, fontSize: 8, letterSpacing: 1)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            color: const Color(0xFF222536),
            child: const Row(children: [Icon(Icons.shield, size: 11, color: NotificationConnectTheme.cyan), SizedBox(width: 5), Text('AIR-GAP SHIELD', style: TextStyle(color: NotificationConnectTheme.cyan, fontSize: 8, letterSpacing: 1))]),
          ),
        ],
      );
}

class NotificationStepLabel extends StatelessWidget {
  const NotificationStepLabel();
  @override
  Widget build(BuildContext context) => const Row(children: [
        _Tag('OTORISASI TELEMETRI'),
        SizedBox(width: 10),
        Text('STEP 02/03', style: TextStyle(color: NotificationConnectTheme.muted, fontSize: 8, letterSpacing: 1.2)),
      ]);
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: const Color(0xFF20293A),
        child: Text(text, style: const TextStyle(color: NotificationConnectTheme.cyan, fontSize: 8, letterSpacing: 1)),
      );
}

class DemoModeCard extends StatelessWidget {
  const DemoModeCard({required this.enabled, required this.onChanged});
  final bool enabled;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: NotificationConnectTheme.panel, borderRadius: BorderRadius.circular(5)),
        child: Row(children: [
          const _IconTile(icon: Icons.terminal, tint: NotificationConnectTheme.purple),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MODE DEMO AKTIF', style: TextStyle(color: NotificationConnectTheme.purple, fontSize: 9, letterSpacing: 1)), SizedBox(height: 3), Text('Simulasi Akses Notifikasi Android untuk Prototype', style: TextStyle(color: NotificationConnectTheme.muted, fontSize: 10))])),
          Switch(value: enabled, onChanged: onChanged),
        ]),
      );
}

class MonitoredChannels extends StatelessWidget {
  const MonitoredChannels({required this.connected});
  final bool connected;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: NotificationConnectTheme.panel.withValues(alpha: .78), borderRadius: BorderRadius.circular(5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('SALURAN TERPANTAU', style: TextStyle(color: NotificationConnectTheme.muted, fontSize: 8, letterSpacing: 1)),
            Text('STATE: ${connected ? 'CONNECTED' : 'DISCONNECTED'}', style: TextStyle(color: connected ? NotificationConnectTheme.cyan : NotificationConnectTheme.purple, fontSize: 8, letterSpacing: 1)),
          ]),
          const SizedBox(height: 10),
          _ChannelRow(icon: Icons.sms_outlined, title: 'Notifikasi pesan', port: 'PORT: 01', status: connected ? 'Terhubung' : 'Belum Terhubung', enabled: connected),
          const SizedBox(height: 8),
          const _ChannelRow(icon: Icons.chat_bubble_outline, title: 'Notifikasi aplikasi', port: 'INT: 02', status: 'Siap Dikonfigurasi', enabled: true),
        ]),
      );
}

class _ChannelRow extends StatelessWidget {
  const _ChannelRow({required this.icon, required this.title, required this.port, required this.status, required this.enabled});
  final IconData icon;
  final String title;
  final String port;
  final String status;
  final bool enabled;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(9),
        color: const Color(0xFF202231),
        child: Row(children: [
          _IconTile(icon: icon, tint: NotificationConnectTheme.cyan),
          const SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: NotificationConnectTheme.ink, fontSize: 11)), Text(enabled ? 'Filter aktif untuk pesan' : 'Filter belum aktif', style: const TextStyle(color: NotificationConnectTheme.muted, fontSize: 9))])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(port, style: const TextStyle(color: NotificationConnectTheme.muted, fontSize: 7, letterSpacing: 1)), const SizedBox(height: 3), Text(status, style: TextStyle(color: enabled ? NotificationConnectTheme.cyan : NotificationConnectTheme.muted, fontSize: 8))]),
          const SizedBox(width: 8),
          Icon(enabled ? Icons.toggle_on : Icons.toggle_off, color: enabled ? NotificationConnectTheme.purple : NotificationConnectTheme.muted, size: 27),
        ]),
      );
}

class InspectionCard extends StatelessWidget {
  const InspectionCard();
  @override
  Widget build(BuildContext context) => _InfoCard(
        icon: Icons.fact_check_outlined,
        title: 'Apa yang akan diperiksa?',
        child: const Column(children: [
          _Bullet('Konten teks notifikasi yang tersedia (preview teks saat pesan masuk).'),
          _Bullet('Informasi pengirim yang ditampilkan oleh notifikasi Android.'),
          _Bullet('Indikator seperti keyword mencurigakan, tautan shortlink, urgensi, dan permintaan data sensitif.'),
        ]),
      );
}

class PrivacyCard extends StatelessWidget {
  const PrivacyCard();
  @override
  Widget build(BuildContext context) => _InfoCard(
        icon: Icons.verified_user_outlined,
        title: 'Privasi tetap penting',
        child: const Text(
          'MIVVI SECURE tidak mengasumsikan bahwa seluruh isi percakapan tersedia. Jika pratinjau pesan disembunyikan di WhatsApp, analisis otomatis mungkin tidak dapat dilakukan.',
          style: TextStyle(color: NotificationConnectTheme.muted, fontSize: 10, height: 1.55),
        ),
        accent: true,
      );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.child, this.accent = false});
  final IconData icon;
  final String title;
  final Widget child;
  final bool accent;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: accent ? NotificationConnectTheme.panel.withValues(alpha: .8) : NotificationConnectTheme.background.withValues(alpha: .35), borderRadius: BorderRadius.circular(5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _IconTile(icon: icon, tint: accent ? NotificationConnectTheme.purple : NotificationConnectTheme.cyan),
            const SizedBox(width: 9),
            Text(title, style: TextStyle(color: accent ? const Color(0xFFC8B8FF) : NotificationConnectTheme.ink, fontSize: 13, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 9),
          child,
        ]),
      );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_circle_outline, size: 14, color: NotificationConnectTheme.cyan),
          const SizedBox(width: 7),
          Expanded(child: Text(text, style: const TextStyle(color: NotificationConnectTheme.ink, fontSize: 10, height: 1.45))),
        ]),
      );
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.tint});
  final IconData icon;
  final Color tint;
  @override
  Widget build(BuildContext context) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: NotificationConnectTheme.background, borderRadius: BorderRadius.circular(4)),
        child: Icon(icon, color: tint, size: 18),
      );
}




