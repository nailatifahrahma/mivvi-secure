import 'package:flutter/material.dart';
import '../theme/education_theme.dart';
import '../widgets/education_widgets.dart';
import '../widgets/activity_widgets.dart';
import 'analysis_detail_page.dart';
import 'analysis_history_page.dart';
import 'notification_activity_page.dart';

class SecurityEducationPage extends StatelessWidget {
  const SecurityEducationPage({super.key});

  @override
  Widget build(BuildContext context) => Theme(data: EducationTheme.theme, child: Scaffold(
        body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 18), children: [
          const EducationHeader(),
          const SizedBox(height: 14),
          const Row(children: [Text('MODUL TELEMETRI [08]', style: TextStyle(color: EducationTheme.cyan, backgroundColor: Color(0xFF1C3440), fontSize: 8, letterSpacing: .9)), SizedBox(width: 7), Icon(Icons.circle, color: EducationTheme.purple, size: 5), SizedBox(width: 5), Text('LEVEL 01 // DASAR', style: TextStyle(color: EducationTheme.muted, fontSize: 8, letterSpacing: .9))]),
          const SizedBox(height: 8),
          const Text('Kenali pola phishing', style: TextStyle(color: EducationTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.w700, fontSize: 22)),
          const SizedBox(height: 5),
          const Text('Sedikit lebih waspada, jauh lebih terlindungi.', style: TextStyle(color: EducationTheme.muted, fontSize: 11)),
          const SizedBox(height: 18),
          const LearningModuleCard(),
          const SizedBox(height: 18),
          ExampleMessageCard(onAnalyze: () => _openSampleAnalysis(context)),
          const SizedBox(height: 18),
          const SecurityFaqList(),
          const SizedBox(height: 14),
          const NextModuleCard(),
        ])))),
        bottomNavigationBar: EducationBottomNav(onSelected: (index) => _handleNav(context, index)),
      ));

  void _openSampleAnalysis(BuildContext context) {
    const sample = NotificationActivitySample(app: 'SMS', time: '10:42', senderId: 'PUSAT-9901', title: 'BANK-PUSAT-NOTIF', message: 'PENTING: Rekening Anda terdeteksi akses ilegal! Kami akan membekukan saldo dalam waktu 1x24 jam. Segera verifikasi lewat bit.ly/aman-bank-id dan masukkan kode OTP.', status: 'THREAT DETECTED  PHISHING', score: 13, kind: ActivityKind.phishing);
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AnalysisDetailPage(sample: sample)));
  }

  void _handleNav(BuildContext context, int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (index == 1) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const NotificationActivityPage()));
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const AnalysisHistoryPage()));
    } else if (index != 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan akan tersedia berikutnya.')));
    }
  }
}

