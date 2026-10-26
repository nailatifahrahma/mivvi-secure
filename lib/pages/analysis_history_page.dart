import 'package:flutter/material.dart';
import '../theme/history_theme.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/history_widgets.dart';
import 'analysis_detail_page.dart';
import 'notification_activity_page.dart';
import 'security_education_page.dart';

class AnalysisHistoryPage extends StatefulWidget {
  const AnalysisHistoryPage({super.key});
  @override
  State<AnalysisHistoryPage> createState() => _AnalysisHistoryPageState();
}

class _AnalysisHistoryPageState extends State<AnalysisHistoryPage> {
  final _searchController = TextEditingController();
  int _filter = 0;
  static const _entries = [
    ('12 Okt 2025', NotificationActivitySample(app: 'WhatsApp', time: '10:42', senderId: 'BNI-0994', title: 'Bank BNI CS (Palsu)', message: 'Info Rek TERBLOKIR klik bit.ly/verif-akun24…', status: 'PHISHING', score: 13, kind: ActivityKind.phishing)),
    ('11 Okt 2025', NotificationActivitySample(app: 'SMS', time: '14:10', senderId: 'PJK-1084', title: 'Ditjen Pajak Fake', message: 'Surat tagihan dana pajak Anda terlampir s.id/pjk-cek…', status: 'PHISHING', score: 9, kind: ActivityKind.phishing)),
    ('10 Okt 2025', NotificationActivitySample(app: 'WhatsApp', time: '18:20', senderId: 'KUR-2207', title: 'Kurir Paket Online', message: 'Paket Anda tertahan di gudang, mohon konfirmasi alamat…', status: 'MENCURIGAKAN', score: 4, kind: ActivityKind.suspicious)),
    ('10 Okt 2025', NotificationActivitySample(app: 'SMS', time: '12:05', senderId: 'BCA-0071', title: 'Bank BCA Resmi', message: 'BCA: Transaksi QRIS Rp 45.000 berhasil di Kopi Senja…', status: 'AMAN', score: 0, kind: ActivityKind.safe)),
    ('08 Okt 2025', NotificationActivitySample(app: 'WhatsApp', time: '09:30', senderId: 'ALM-2088', title: 'Komunitas Alumni', message: 'Halo teman-teman, jadwal reuni bulan depan sudah diupdate di drive resmi…', status: 'AMAN', score: 0, kind: ActivityKind.safe)),
  ];

  List<(String, NotificationActivitySample)> get _visibleEntries {
    final query = _searchController.text.toLowerCase();
    return _entries.where((entry) {
      final sample = entry.$2;
      final matchesSearch = query.isEmpty || sample.title.toLowerCase().contains(query) || sample.message.toLowerCase().contains(query) || sample.app.toLowerCase().contains(query);
      final matchesFilter = switch (_filter) {
        1 => sample.kind == ActivityKind.safe,
        2 => sample.kind == ActivityKind.suspicious,
        3 => sample.kind == ActivityKind.phishing,
        _ => true,
      };
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(data: HistoryTheme.theme, child: Scaffold(
        body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), children: [
          const HistoryHeader(),
          const SizedBox(height: 14),
          const Row(children: [Icon(Icons.circle, size: 7, color: HistoryTheme.cyan), SizedBox(width: 7), Text('ENCRYPTED LOGS // V3.2', style: TextStyle(color: HistoryTheme.cyan, fontSize: 8, letterSpacing: 1.1))]),
          const SizedBox(height: 8),
          const Text('Riwayat Analisis', style: TextStyle(color: HistoryTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.w700, fontSize: 22)),
          const SizedBox(height: 5),
          const Text('Periksa kembali hasil yang tersimpan.', style: TextStyle(color: HistoryTheme.muted, fontSize: 10)),
          const SizedBox(height: 14),
          HistorySearchBox(controller: _searchController, onChanged: (_) => setState(() {})),
          const SizedBox(height: 10),
          HistoryFilterBar(selected: _filter, onSelected: (value) => setState(() => _filter = value)),
          const SizedBox(height: 13),
          for (final entry in _visibleEntries) ...[
            HistoryEntryCard(sample: entry.$2, date: entry.$1, onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AnalysisDetailPage(sample: entry.$2)))),
            const SizedBox(height: 8),
          ],
          if (_visibleEntries.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('Tidak ada riwayat yang cocok dengan pencarian ini.', textAlign: TextAlign.center, style: TextStyle(color: HistoryTheme.muted, fontSize: 10))),
          const SizedBox(height: 8),
          const HistoryPrivacyNote(),
        ])))),
        bottomNavigationBar: HistoryBottomNav(onSelected: _handleNav),
      ));

  void _handleNav(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const NotificationActivityPage()));
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const SecurityEducationPage()));
    } else if (index != 2) {
      const labels = ['Beranda', 'Aktivitas', 'Riwayat', 'Edukasi', 'Pengaturan'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${labels[index]} akan tersedia berikutnya.')));
    }
  }
}


