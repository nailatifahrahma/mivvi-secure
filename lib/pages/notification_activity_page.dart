import 'package:flutter/material.dart';
import '../theme/activity_theme.dart';
import '../widgets/activity_widgets.dart';

class NotificationActivityPage extends StatefulWidget {
  const NotificationActivityPage({super.key});
  @override
  State<NotificationActivityPage> createState() => _NotificationActivityPageState();
}

class _NotificationActivityPageState extends State<NotificationActivityPage> {
  int _filter = 0;
  static const _samples = [
    NotificationActivitySample(app: 'WhatsApp', time: '10:42', senderId: 'BNI-0994', title: 'Bank BNI Customer Service', message: 'Akun Anda akan dinonaktifkan dalam 1x24 jam. Verifikasi sekarang di bit.ly/bni-verif24.', status: 'THREAT DETECTED  PHISHING', score: 13, kind: ActivityKind.phishing),
    NotificationActivitySample(app: 'WhatsApp', time: '09:15', senderId: 'PRM-4412', title: 'Promo Hadiah Undian', message: 'Selamat nomor Anda memenangkan saldo 50jt. Klaim melalui tautan ini.', highlight: 's.id/dana-kaget-', status: 'SUSPICIOUS  MENCURIGAKAN', score: 4, kind: ActivityKind.suspicious),
    NotificationActivitySample(app: 'SMS', time: '08:30', senderId: 'SHS-9811', title: 'Telkomsel Info', message: 'Paket data Anda telah aktif. Kuota utama 50GB berlaku hingga 30/12/2025.', status: 'VERIFIED  AMAN', score: 0, kind: ActivityKind.safe),
    NotificationActivitySample(app: 'WhatsApp', time: '07:12', senderId: 'ENC-1049', title: 'Teman Kantor', message: 'Pratinjau pesan tidak tersedia (Pengaturan privasi WhatsApp aktif).', status: 'BELUM DIANALISIS', score: 0, kind: ActivityKind.unavailable, needsManualReview: true),
  ];

  List<NotificationActivitySample> get _visibleSamples => switch (_filter) {
        1 => _samples.where((item) => item.app == 'SMS').toList(),
        2 => _samples.where((item) => item.app == 'WhatsApp').toList(),
        3 => _samples.where((item) => item.needsManualReview).toList(),
        _ => _samples,
      };

  @override
  Widget build(BuildContext context) => Theme(
        data: ActivityTheme.theme,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  children: [
                    const ActivityHeader(),
                    const SizedBox(height: 14),
                    const Row(children: [Icon(Icons.circle, color: ActivityTheme.cyan, size: 7), SizedBox(width: 7), Text('DIAGNOSTIK TELEMETRI REAL-TIME', style: TextStyle(color: ActivityTheme.cyan, fontSize: 8, letterSpacing: 1.2)), Spacer(), Text('DEMO_V2.4', style: TextStyle(color: ActivityTheme.muted, fontSize: 8, letterSpacing: 1))]),
                    const SizedBox(height: 8),
                    const Text('Aktivitas notifikasi', style: TextStyle(color: ActivityTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.w700, fontSize: 22)),
                    const SizedBox(height: 5),
                    const Text('Notifikasi pesan yang tersedia untuk dianalisis.', style: TextStyle(color: ActivityTheme.muted, fontSize: 10)),
                    const SizedBox(height: 14),
                    const ActivityStatusBanner(),
                    const SizedBox(height: 13),
                    ActivityFilterBar(selected: _filter, onSelected: (value) => setState(() => _filter = value)),
                    const SizedBox(height: 13),
                    for (final sample in _visibleSamples) ...[
                      NotificationActivityCard(sample: sample, onTap: () => _showDetails(sample), onManualAnalysis: () => _showManualMessage()),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 7),
                    const DataFlowInfo(),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: ActivityBottomNav(onSelected: _handleNav),
        ),
      );

  void _handleNav(int index) {
    if (index == 0) {
      Navigator.of(context).maybePop();
    } else if (index != 1) {
      final labels = ['Beranda', 'Aktivitas', 'Riwayat', 'Edukasi', 'Pengaturan'];
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${labels[index]} akan tersedia berikutnya.')));
    }
  }

  void _showDetails(NotificationActivitySample sample) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: ActivityTheme.panel,
        builder: (_) => SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sample.title, style: const TextStyle(color: ActivityTheme.ink, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(sample.message, style: const TextStyle(color: ActivityTheme.muted, height: 1.5)),
          const SizedBox(height: 14),
          Text('Skor risiko: ${sample.score}  •  ${sample.status}', style: const TextStyle(color: ActivityTheme.cyan, fontSize: 10)),
        ]))),
      );

  void _showManualMessage() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Analisis manual tersedia saat teks notifikasi dapat dibaca.')));
}
