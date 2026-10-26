import 'package:flutter/material.dart';
import '../theme/history_theme.dart';
import '../widgets/activity_widgets.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: HistoryTheme.cyan.withValues(alpha: .6))), child: const Icon(Icons.shield_outlined, color: HistoryTheme.cyan, size: 18)),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MIVVI SECURE •', style: TextStyle(color: HistoryTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 2), Text('RIWAYAT', style: TextStyle(color: HistoryTheme.muted, fontSize: 8, letterSpacing: 1.3))])),
        IconButton.filled(onPressed: () {}, icon: const Icon(Icons.person_outline), style: IconButton.styleFrom(backgroundColor: HistoryTheme.cyan, foregroundColor: const Color(0xFF104750))),
      ]);
}

class HistorySearchBox extends StatelessWidget {
  const HistorySearchBox({super.key, required this.controller, required this.onChanged});
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: TextField(controller: controller, onChanged: onChanged, style: const TextStyle(color: HistoryTheme.ink, fontSize: 10), decoration: InputDecoration(hintText: 'Cari pengirim atau isi pesan', hintStyle: const TextStyle(color: HistoryTheme.muted), prefixIcon: const Icon(Icons.search, color: HistoryTheme.muted, size: 18), suffixText: 'REC/SCAN', suffixStyle: const TextStyle(color: HistoryTheme.muted, fontSize: 7), filled: true, fillColor: HistoryTheme.panel, contentPadding: const EdgeInsets.symmetric(vertical: 4), border: OutlineInputBorder(borderRadius: BorderRadius.circular(3), borderSide: BorderSide.none)))),
        const SizedBox(width: 5),
        IconButton(onPressed: () { controller.clear(); onChanged(''); }, icon: const Icon(Icons.clear), style: IconButton.styleFrom(backgroundColor: HistoryTheme.panel, foregroundColor: HistoryTheme.ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)))),
      ]);
}

class HistoryFilterBar extends StatelessWidget {
  const HistoryFilterBar({super.key, required this.selected, required this.onSelected});
  final int selected;
  final ValueChanged<int> onSelected;
  static const filters = [('Semua', 5), ('Aman', 2), ('Mencurigakan', 1), ('Phishing', 2)];
  @override
  Widget build(BuildContext context) => SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: List.generate(filters.length, (index) {
        final active = selected == index;
        final color = index == 1 ? HistoryTheme.cyan : index == 2 ? HistoryTheme.amber : index == 3 ? HistoryTheme.danger : HistoryTheme.cyan;
        return Padding(padding: const EdgeInsets.only(right: 6), child: TextButton(onPressed: () => onSelected(index), style: TextButton.styleFrom(backgroundColor: active ? color : HistoryTheme.panel, foregroundColor: active ? const Color(0xFF10111F) : HistoryTheme.ink, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), minimumSize: const Size(0, 0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))), child: Row(mainAxisSize: MainAxisSize.min, children: [if(index != 0 && !active) Icon(Icons.circle, size: 6, color: color), Text(filters[index].$1, style: const TextStyle(fontSize: 9, letterSpacing: .5)), const SizedBox(width: 5), Text('${filters[index].$2}', style: const TextStyle(fontSize: 8))])));
      })));
}

class HistoryEntryCard extends StatelessWidget {
  const HistoryEntryCard({super.key, required this.sample, required this.date, required this.onTap});
  final NotificationActivitySample sample;
  final String date;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final color = sample.kind == ActivityKind.phishing ? HistoryTheme.danger : sample.kind == ActivityKind.suspicious ? HistoryTheme.amber : HistoryTheme.cyan;
    final status = sample.kind == ActivityKind.phishing ? 'PHISHING' : sample.kind == ActivityKind.suspicious ? 'MENCURIGAKAN' : sample.kind == ActivityKind.safe ? 'AMAN' : 'BELUM DIPERIKSA';
    return Material(color: HistoryTheme.panel, borderRadius: BorderRadius.circular(4), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(4), child: Padding(padding: const EdgeInsets.all(11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3), color: const Color(0xFF303247), child: Text(sample.app.toUpperCase(), style: const TextStyle(color: HistoryTheme.cyan, fontSize: 7, letterSpacing: .7))), const SizedBox(width: 7), Expanded(child: Text('$date • ${sample.time}', style: const TextStyle(color: HistoryTheme.muted, fontSize: 8))), Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4), color: HistoryTheme.raised, child: const Text('DEMO', style: TextStyle(color: HistoryTheme.muted, fontSize: 7))), const SizedBox(width: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), color: color.withValues(alpha: .18), child: Text('$status (${sample.score})', style: TextStyle(color: color, fontSize: 7, letterSpacing: .5)))]),
      const SizedBox(height: 10),
      Row(children: [Expanded(child: Text(sample.title, style: const TextStyle(color: HistoryTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.w600, fontSize: 13))), Icon(sample.kind == ActivityKind.phishing ? Icons.highlight_off : sample.kind == ActivityKind.safe ? Icons.verified_outlined : Icons.help_outline, color: color, size: 14), const SizedBox(width: 8), const Icon(Icons.chevron_right, color: HistoryTheme.muted, size: 20)]),
      const SizedBox(height: 5),
      Text('“${sample.message}”', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFBEC4D2), fontSize: 9, height: 1.45)),
    ]))));
  }
}

class HistoryPrivacyNote extends StatelessWidget {
  const HistoryPrivacyNote({super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), color: HistoryTheme.panel, child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.shield_outlined, color: HistoryTheme.cyan, size: 18), SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text('KERAHASIAAN TINGKAT ENKLAVE', style: TextStyle(color: HistoryTheme.ink, fontSize: 9, letterSpacing: .8))), Text('AES-256\nGCM', style: TextStyle(color: HistoryTheme.cyan, fontSize: 7, letterSpacing: .8))]), SizedBox(height: 6), Text('Hasil analisis yang disimpan akan muncul di sini secara lokal dan terlindungi. Tidak ada rekaman log atau riwayat pesan yang dikirim ke cloud pihak ketiga.', style: TextStyle(color: HistoryTheme.muted, fontSize: 9, height: 1.55))])),
      ]));
}

class HistoryBottomNav extends StatelessWidget {
  const HistoryBottomNav({super.key, required this.onSelected});
  final ValueChanged<int> onSelected;
  static const items = [(Icons.shield_outlined, 'Beranda'), (Icons.notifications_none, 'Aktivitas'), (Icons.history, 'Riwayat'), (Icons.menu_book_outlined, 'Edukasi'), (Icons.tune, 'Pengaturan')];
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(5, 7, 5, 8), decoration: const BoxDecoration(color: Color(0xFF171927), border: Border(top: BorderSide(color: Color(0xFF292C43)))), child: Row(children: List.generate(items.length, (index) => Expanded(child: InkWell(onTap: () => onSelected(index), child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(items[index].$1, color: index == 2 ? HistoryTheme.cyan : HistoryTheme.muted, size: 17), const SizedBox(height: 3), Text(items[index].$2, style: TextStyle(color: index == 2 ? HistoryTheme.cyan : HistoryTheme.muted, fontSize: 7, letterSpacing: .5))]))))));
}


