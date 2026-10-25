import 'package:flutter/material.dart';
import '../theme/dashboard_theme.dart';
import '../pages/notification_activity_page.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        const _ShieldMark(size: 32),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MIVVI SECURE •', style: TextStyle(color: DashboardTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 2),
          Text('BERANDA', style: TextStyle(color: DashboardTheme.muted, fontSize: 8, letterSpacing: 1.3)),
        ])),
        IconButton.filled(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil pengguna'))), icon: const Icon(Icons.person_outline), style: IconButton.styleFrom(backgroundColor: DashboardTheme.cyan, foregroundColor: const Color(0xFF104750), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      ]);
}

class DashboardWelcomeCard extends StatelessWidget {
  const DashboardWelcomeCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF29204F), DashboardTheme.surface, DashboardTheme.surface]),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: DashboardTheme.background.withValues(alpha: .55), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const _ShieldMark(size: 32),
              const SizedBox(width: 10),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MIVVI SECURE •', style: TextStyle(color: DashboardTheme.cyan, fontWeight: FontWeight.bold, fontSize: 14)),
                SizedBox(height: 3),
                Text('KEAMANAN PESAN, DALAM KENDALIMU.', style: TextStyle(color: DashboardTheme.ink, fontSize: 8, letterSpacing: 1)),
              ])),
              const _LiveBadge(),
            ]),
          ),
          const SizedBox(height: 12),
          const Row(children: [Icon(Icons.terminal, color: DashboardTheme.cyan, size: 14), SizedBox(width: 6), Text('ID: PROTO-772  •  KONSOL PENGGUNA', style: TextStyle(color: DashboardTheme.muted, fontSize: 8, letterSpacing: 1))]),
          const SizedBox(height: 8),
          const Text('Lindungi dirimu dari pesan mencurigakan.', style: TextStyle(color: DashboardTheme.ink, fontFamily: 'sans-serif', fontSize: 21, height: 1.25, fontWeight: FontWeight.w700)),
          const SizedBox(height: 9),
          const Text('Selamat datang, Pengguna. MIVVI SECURE memeriksa indikator risiko dari konten notifikasi yang tersedia secara lokal dan transparan.', style: TextStyle(color: Color(0xFFBEC4D2), fontSize: 11, height: 1.6)),
          const SizedBox(height: 16),
          const Center(child: ProtectedEmblem()),
          const SizedBox(height: 10),
          const Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
            _StatusPill(icon: Icons.circle, label: 'Sistem Pemantau Aktif', color: DashboardTheme.cyan),
            SizedBox(width: 8),
            _StatusPill(label: 'MODE DEMO', color: DashboardTheme.muted),
          ])),
          const SizedBox(height: 20),
          const _AccessStatusCard(),
        ]),
      );
}

class ProtectedEmblem extends StatelessWidget {
  const ProtectedEmblem({super.key});
  @override
  Widget build(BuildContext context) => Container(
        width: 166,
        height: 166,
        decoration: BoxDecoration(color: DashboardTheme.raised, borderRadius: BorderRadius.circular(13)),
        child: Center(child: Container(
          width: 138,
          height: 138,
          decoration: BoxDecoration(color: const Color(0xFF29254D), borderRadius: BorderRadius.circular(12), border: Border.all(color: DashboardTheme.purple.withValues(alpha: .2))),
          child: Center(child: Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(color: DashboardTheme.background, borderRadius: BorderRadius.circular(13), border: Border.all(color: DashboardTheme.purple.withValues(alpha: .3))),
            child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shield, color: DashboardTheme.cyan, size: 37), Text('PROTECTED', style: TextStyle(color: DashboardTheme.cyan, fontSize: 8, letterSpacing: 1.2))]),
          )),
        )),
      );
}

class DashboardActionButtons extends StatelessWidget {
  const DashboardActionButtons({super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(width: double.infinity, height: 48, child: FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationActivityPage())), icon: const Icon(Icons.notifications_active_outlined, size: 18), label: const Text('Lihat aktivitas notifikasi'), iconAlignment: IconAlignment.start, style: FilledButton.styleFrom(backgroundColor: DashboardTheme.cyan, foregroundColor: const Color(0xFF104750), alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 14)))),
        const SizedBox(height: 6),
        SizedBox(width: double.infinity, height: 42, child: OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analisis pesan manual akan segera tersedia.'))), icon: const Icon(Icons.document_scanner_outlined, size: 17), label: const Text('Analisis pesan manual'), iconAlignment: IconAlignment.start, style: OutlinedButton.styleFrom(foregroundColor: DashboardTheme.ink, backgroundColor: DashboardTheme.raised, side: BorderSide.none, alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 14)))),
      ]);
}

class RiskLevels extends StatelessWidget {
  const RiskLevels({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionTitle(icon: Icons.bar_chart, title: 'TINGKAT RISIKO', trailing: 'STANDAR HEURISTIK'),
        const SizedBox(height: 8),
        Row(children: const [
          Expanded(child: _RiskCard(icon: Icons.check_circle_outline, title: 'Aman', score: 'Skor < 3', note: 'Risiko rendah', color: DashboardTheme.cyan, label: 'AMAN')),
          SizedBox(width: 6),
          Expanded(child: _RiskCard(icon: Icons.warning_amber_outlined, title: 'Curiga', score: 'Skor 3–5', note: 'Perlu periksa', color: DashboardTheme.amber, label: 'WASPADA')),
          SizedBox(width: 6),
          Expanded(child: _RiskCard(icon: Icons.gpp_bad_outlined, title: 'Phishing', score: 'Skor ≥ 6', note: 'Risiko tinggi', color: DashboardTheme.danger, label: 'BAHAYA')),
        ]),
      ]);
}

class RecentDetections extends StatelessWidget {
  const RecentDetections({super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        _SectionTitle(icon: Icons.history, title: 'TERAKHIR TERDETEKSI', trailing: '2 DATA BARU'),
        SizedBox(height: 8),
        _DetectionCard(sender: 'WhatsApp • Bank BNI Info', label: 'PHISHING (SKOR 13)', text: '“Rekening Anda terblokir, segera klik bit.ly/bni-verif24 untuk pemulihan.”', danger: true, footer: 'URGENCY: EKSTRIM     •     LINK PENDEK TERDETEKSI', action: 'TINDAKAN: BLOKIR'),
        SizedBox(height: 7),
        _DetectionCard(sender: 'SMS • Telkomsel', label: 'AMAN (SKOR 0)', text: '“Paket data 50GB aktif hingga 30/12/2025. Cek kuota berkala di aplikasi MyTelkomsel resmi.”', danger: false, footer: 'AUTENTIKASI: RESMI • BEBAS TAUTAN ASING', action: 'STATUS: BERSIH'),
      ]);
}

class DashboardSystemStatus extends StatelessWidget {
  const DashboardSystemStatus({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: DashboardTheme.background.withValues(alpha: .6), borderRadius: BorderRadius.circular(5)),
        child: const Row(children: [Icon(Icons.memory, color: DashboardTheme.cyan, size: 14), SizedBox(width: 8), Expanded(child: Text('RULE ENGINE V4.2.1 • OFFLINE NEURAL GUARD', style: TextStyle(color: DashboardTheme.muted, fontSize: 8, letterSpacing: 1))), Text('0\nLATENSI', textAlign: TextAlign.center, style: TextStyle(color: DashboardTheme.purple, fontSize: 8, letterSpacing: 1))]),
      );
}

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({super.key, required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  static const _items = [
    (Icons.shield_outlined, 'Beranda'),
    (Icons.notifications_none, 'Aktivitas'),
    (Icons.history, 'Riwayat'),
    (Icons.menu_book_outlined, 'Edukasi'),
    (Icons.tune, 'Pengaturan'),
  ];
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(5, 7, 5, 8),
        decoration: const BoxDecoration(color: Color(0xFF171927), border: Border(top: BorderSide(color: Color(0xFF292C43)))),
        child: Row(children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = selectedIndex == index;
          return Expanded(child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 7),
              decoration: BoxDecoration(color: selected ? const Color(0xFF33227C) : Colors.transparent, borderRadius: BorderRadius.circular(9)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(item.$1, color: selected ? DashboardTheme.cyan : DashboardTheme.muted, size: 17), const SizedBox(height: 3), Text(item.$2, style: TextStyle(color: selected ? DashboardTheme.cyan : DashboardTheme.muted, fontSize: 7, letterSpacing: .5))]),
            ),
          ));
        })),
      );
}

class _ShieldMark extends StatelessWidget {
  const _ShieldMark({required this.size});
  final double size;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: DashboardTheme.cyan.withValues(alpha: .55))), child: Icon(Icons.shield_outlined, color: DashboardTheme.cyan, size: size * .57));
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF332477), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, color: DashboardTheme.cyan, size: 6), SizedBox(width: 5), Text('LIVE\nDEMO', style: TextStyle(color: DashboardTheme.ink, fontSize: 7, letterSpacing: 1))]));
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({this.icon, required this.label, required this.color});
  final IconData? icon;
  final String label;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: DashboardTheme.raised, borderRadius: BorderRadius.circular(20)), child: Row(mainAxisSize: MainAxisSize.min, children: [if (icon != null) Icon(icon, color: color, size: 7), if (icon != null) const SizedBox(width: 5), Text(label, style: TextStyle(color: color, fontSize: 8, letterSpacing: .6))]));
}

class _AccessStatusCard extends StatelessWidget {
  const _AccessStatusCard();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: DashboardTheme.raised.withValues(alpha: .75), borderRadius: BorderRadius.circular(6)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: const [Icon(Icons.verified_user_outlined, color: DashboardTheme.cyan, size: 17), SizedBox(width: 8), Expanded(child: Text('Akses notifikasi aktif — Demo', style: TextStyle(color: DashboardTheme.ink, fontSize: 11, fontWeight: FontWeight.w600))), Icon(Icons.info_outline, color: DashboardTheme.muted, size: 15)]), const SizedBox(height: 7), const Padding(padding: EdgeInsets.only(left: 25), child: Text('Memeriksa pola teks mencurigakan (tautan pendek, urgensi palsu, impersonasi bank) secara privat di perangkat tanpa mengirim data ke server.', style: TextStyle(color: DashboardTheme.muted, fontSize: 9, height: 1.5)))]));
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title, required this.trailing});
  final IconData icon;
  final String title;
  final String trailing;
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, size: 14, color: DashboardTheme.purple), const SizedBox(width: 5), Expanded(child: Text(title, style: const TextStyle(color: DashboardTheme.ink, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: .6))), Text(trailing, style: const TextStyle(color: DashboardTheme.muted, fontSize: 7, letterSpacing: 1))]);
}

class _RiskCard extends StatelessWidget {
  const _RiskCard({required this.icon, required this.title, required this.score, required this.note, required this.color, required this.label});
  final IconData icon; final String title, score, note, label; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: DashboardTheme.surface, borderRadius: BorderRadius.circular(5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, size: 16, color: color), const Spacer(), Flexible(child: Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3), decoration: BoxDecoration(color: color.withValues(alpha: .13), borderRadius: BorderRadius.circular(3)), child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: color, fontSize: 6, letterSpacing: .7))))]), const SizedBox(height: 10), Text(title, style: const TextStyle(color: DashboardTheme.ink, fontSize: 12, fontWeight: FontWeight.w600)), Text(score, style: TextStyle(color: color, fontSize: 9)), Text(note, style: const TextStyle(color: DashboardTheme.muted, fontSize: 8))]));
}

class _DetectionCard extends StatelessWidget {
  const _DetectionCard({required this.sender, required this.label, required this.text, required this.danger, required this.footer, required this.action});
  final String sender, label, text, footer, action; final bool danger;
  @override
  Widget build(BuildContext context) {
    final color = danger ? DashboardTheme.danger : DashboardTheme.cyan;
    return Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: DashboardTheme.surface, borderRadius: BorderRadius.circular(7)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(danger ? Icons.crisis_alert : Icons.sms_outlined, color: danger ? DashboardTheme.amber : DashboardTheme.cyan, size: 13), const SizedBox(width: 5), Expanded(child: Text(sender, style: const TextStyle(color: DashboardTheme.ink, fontSize: 9))), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), color: color.withValues(alpha: .16), child: Text(label, style: TextStyle(color: color, fontSize: 7, letterSpacing: .6)))]), const SizedBox(height: 8), Text(text, style: const TextStyle(color: DashboardTheme.ink, fontSize: 10, height: 1.55)), const SizedBox(height: 8), Row(children: [Expanded(child: Text(footer, style: const TextStyle(color: DashboardTheme.muted, fontSize: 7, letterSpacing: .5))), Text(action, style: TextStyle(color: danger ? DashboardTheme.amber : DashboardTheme.cyan, fontSize: 7, letterSpacing: .5))]) ]));
  }
}

