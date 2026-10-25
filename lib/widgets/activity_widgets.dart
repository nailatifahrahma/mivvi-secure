import 'package:flutter/material.dart';
import '../theme/activity_theme.dart';

class ActivityHeader extends StatelessWidget {
  const ActivityHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        const _BrandShield(),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('MIVVI SECURE •', style: TextStyle(color: ActivityTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 2),
          Text('AKTIVITAS', style: TextStyle(color: ActivityTheme.muted, fontSize: 8, letterSpacing: 1.3)),
        ])),
        IconButton.filled(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil pengguna'))), icon: const Icon(Icons.person_outline), style: IconButton.styleFrom(backgroundColor: ActivityTheme.cyan, foregroundColor: const Color(0xFF104750), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))),
      ]);
}

class ActivityStatusBanner extends StatelessWidget {
  const ActivityStatusBanner({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(color: ActivityTheme.raised, borderRadius: BorderRadius.circular(6)),
        child: const Row(children: [
          _GlyphTile(icon: Icons.notifications_active_outlined, color: ActivityTheme.cyan),
          SizedBox(width: 9),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Akses notifikasi aktif', style: TextStyle(color: ActivityTheme.cyan, fontSize: 10, letterSpacing: .7)),
            SizedBox(height: 3),
            Text('• Filter: WhatsApp & SMS', style: TextStyle(color: ActivityTheme.muted, fontSize: 9, letterSpacing: .5)),
          ])),
          Text('(Mode Demo)', style: TextStyle(color: ActivityTheme.amber, fontSize: 8)),
          SizedBox(width: 5),
          Icon(Icons.shield_outlined, color: ActivityTheme.cyan, size: 16),
        ]),
      );
}

class ActivityFilterBar extends StatelessWidget {
  const ActivityFilterBar({super.key, required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  static const _filters = [('Semua', 4), ('SMS', 1), ('WhatsApp', 3), ('Perlu diperiksa', 1)];

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: List.generate(_filters.length, (index) {
          final item = _filters[index];
          final active = selected == index;
          return Padding(
            padding: EdgeInsets.only(right: index == _filters.length - 1 ? 0 : 6),
            child: TextButton(
              onPressed: () => onSelected(index),
              style: TextButton.styleFrom(
                backgroundColor: active ? ActivityTheme.cyan : ActivityTheme.panel,
                foregroundColor: active ? const Color(0xFF104750) : ActivityTheme.ink,
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                minimumSize: const Size(0, 0),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (index == 3) const Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.circle, size: 6, color: ActivityTheme.danger)),
                Text(item.$1, style: const TextStyle(fontSize: 9, letterSpacing: .5)),
                const SizedBox(width: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2), decoration: BoxDecoration(color: active ? Colors.black.withValues(alpha: .1) : ActivityTheme.raised, borderRadius: BorderRadius.circular(10)), child: Text('${item.$2}', style: const TextStyle(fontSize: 8))),
              ]),
            ),
          );
        })),
      );
}

class NotificationActivitySample {
  const NotificationActivitySample({required this.app, required this.time, required this.senderId, required this.title, required this.message, required this.status, required this.score, required this.kind, this.needsManualReview = false, this.highlight});
  final String app, time, senderId, title, message, status;
  final int score;
  final ActivityKind kind;
  final bool needsManualReview;
  final String? highlight;
}

enum ActivityKind { phishing, suspicious, safe, unavailable }

class NotificationActivityCard extends StatelessWidget {
  const NotificationActivityCard({super.key, required this.sample, required this.onTap, required this.onManualAnalysis});
  final NotificationActivitySample sample;
  final VoidCallback onTap;
  final VoidCallback onManualAnalysis;

  @override
  Widget build(BuildContext context) {
    final color = switch (sample.kind) {
      ActivityKind.phishing => ActivityTheme.danger,
      ActivityKind.suspicious => ActivityTheme.amber,
      ActivityKind.safe => ActivityTheme.cyan,
      ActivityKind.unavailable => ActivityTheme.muted,
    };
    return Material(
      color: ActivityTheme.panel,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: ActivityTheme.raised,
            child: Row(children: [
              Icon(sample.app == 'SMS' ? Icons.sms_outlined : Icons.chat_bubble_outline, color: ActivityTheme.cyan, size: 13),
              const SizedBox(width: 5),
              Text(sample.app.toUpperCase(), style: const TextStyle(color: ActivityTheme.ink, fontSize: 8, letterSpacing: .8)),
              const SizedBox(width: 8),
              Text('• ${sample.time}', style: const TextStyle(color: ActivityTheme.muted, fontSize: 8)),
              const SizedBox(width: 5),
              Expanded(child: Text('ID: ${sample.senderId}', style: const TextStyle(color: ActivityTheme.muted, fontSize: 7, letterSpacing: .5), overflow: TextOverflow.ellipsis)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), color: const Color(0xFF494342), child: const Text('DATA CONTOH / DEMO', style: TextStyle(color: ActivityTheme.amber, fontSize: 7, letterSpacing: .7))),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(11, 10, 11, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text(sample.title, style: const TextStyle(color: ActivityTheme.ink, fontFamily: 'sans-serif', fontSize: 13, fontWeight: FontWeight.w600))), Icon(_statusIcon(sample.kind), color: color, size: 15), const SizedBox(width: 6), const Icon(Icons.chevron_right, color: ActivityTheme.muted, size: 20)]),
            const SizedBox(height: 5),
            Text(sample.message, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFBEC4D2), fontSize: 10, height: 1.55)),
            if (sample.highlight != null) ...[
              const SizedBox(height: 3),
              Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2), color: ActivityTheme.amber.withValues(alpha: .2), child: Text(sample.highlight!, style: const TextStyle(color: ActivityTheme.amber, fontSize: 10))),
            ],
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: sample.needsManualReview ? OutlinedButton.icon(onPressed: onManualAnalysis, icon: const Icon(Icons.workspace_premium_outlined, size: 13), label: const Text('ANALISIS SECARA MANUAL', style: TextStyle(fontSize: 7, letterSpacing: .5)), style: OutlinedButton.styleFrom(foregroundColor: ActivityTheme.purple, side: BorderSide.none, backgroundColor: const Color(0xFF39249A), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5), minimumSize: const Size(0, 28))) : Align(alignment: Alignment.centerLeft, child: _StatusChip(text: sample.status, color: color))),
              const SizedBox(width: 7),
              _ScoreChip(score: sample.score),
            ]),
          ])),
        ]),
      ),
    );
  }

  IconData _statusIcon(ActivityKind kind) => switch (kind) {
        ActivityKind.phishing => Icons.warning_amber_outlined,
        ActivityKind.suspicious => Icons.help_outline,
        ActivityKind.safe => Icons.check_circle_outline,
        ActivityKind.unavailable => Icons.lock_outline,
      };
}

class DataFlowInfo extends StatelessWidget {
  const DataFlowInfo({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: ActivityTheme.panel, borderRadius: BorderRadius.circular(6)),
        child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _GlyphTile(icon: Icons.sync_alt, color: ActivityTheme.cyan),
          SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('STATUS ALIRAN DATA', style: TextStyle(color: ActivityTheme.ink, fontSize: 8, letterSpacing: .8)),
            SizedBox(height: 6),
            Text('Belum ada notifikasi lain yang dapat dianalisis. Notifikasi akan ditampilkan jika kontennya tersedia dan pratinjau diizinkan.', style: TextStyle(color: ActivityTheme.muted, fontSize: 9, height: 1.55)),
          ])),
        ]),
      );
}

class ActivityBottomNav extends StatelessWidget {
  const ActivityBottomNav({super.key, required this.onSelected});
  final ValueChanged<int> onSelected;
  static const _items = [(Icons.shield_outlined, 'Beranda'), (Icons.notifications_none, 'Aktivitas'), (Icons.history, 'Riwayat'), (Icons.menu_book_outlined, 'Edukasi'), (Icons.tune, 'Pengaturan')];
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(5, 7, 5, 8),
        decoration: const BoxDecoration(color: Color(0xFF171927), border: Border(top: BorderSide(color: Color(0xFF292C43)))),
        child: Row(children: List.generate(_items.length, (index) => Expanded(child: InkWell(
          onTap: () => onSelected(index),
          child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(_items[index].$1, color: index == 1 ? ActivityTheme.cyan : ActivityTheme.muted, size: 17), const SizedBox(height: 3), Text(_items[index].$2, style: TextStyle(color: index == 1 ? ActivityTheme.cyan : ActivityTheme.muted, fontSize: 7, letterSpacing: .5))])),
        )))),
      );
}

class _BrandShield extends StatelessWidget {
  const _BrandShield();
  @override
  Widget build(BuildContext context) => Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ActivityTheme.cyan.withValues(alpha: .55))), child: const Icon(Icons.shield_outlined, color: ActivityTheme.cyan, size: 18));
}

class _GlyphTile extends StatelessWidget {
  const _GlyphTile({required this.icon, required this.color});
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(width: 32, height: 32, decoration: BoxDecoration(color: ActivityTheme.background, borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: color, size: 17));
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: color.withValues(alpha: .15), borderRadius: BorderRadius.circular(2)), child: Text(text, style: TextStyle(color: color, fontSize: 7, letterSpacing: .6)));
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({required this.score});
  final int score;
  @override
  Widget build(BuildContext context) { final color = score >= 6 ? ActivityTheme.danger : score >= 3 ? ActivityTheme.amber : ActivityTheme.cyan; return Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), color: ActivityTheme.raised, child: Text('SKOR RISIKO: $score', style: TextStyle(color: color, fontSize: 7, letterSpacing: .5))); }
}
