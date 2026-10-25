import 'package:flutter/material.dart';
import '../theme/onboarding_theme.dart';
import '../widgets/onboarding_widgets.dart';
import 'notification_connect_page.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, this.onStart});
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const _BrandBar(),
                const SizedBox(height: 18),
                const SignalPreview(),
                const SizedBox(height: 18),
                const _Intro(),
                const SizedBox(height: 24),
                const FeatureCard(icon: Icons.radar, title: 'Analisis indikator pesan', tag: '[DETEKSI]', description: 'Mendeteksi pola kata kunci, urgensi waktu, dan kejanggalan format pesan.'),
                const SizedBox(height: 9),
                const FeatureCard(icon: Icons.link_off, title: 'Kenali tautan dan data sensitif', tag: '[VALIDASI]', description: 'Mengidentifikasi shortlink dan domain di luar whitelist resmi.'),
                const SizedBox(height: 9),
                const FeatureCard(icon: Icons.bug_report_outlined, title: 'Pahami alasan skor risiko', tag: '[TRANSPARAN]', description: 'Penjelasan transparan dengan sistem kalkulasi rule-based tanpa kotak hitam.'),

                const SizedBox(height: 24),
                const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.verified_user_outlined, size: 13, color: OnboardingTheme.cyan), SizedBox(width: 7), Text('ZERO-DATA LOGGING  //  ON-DEVICE EVALUATION', style: TextStyle(color: OnboardingTheme.muted, fontSize: 8, letterSpacing: 1))]),
                const SizedBox(height: 16),
                SizedBox(height: 52, child: FilledButton.icon(onPressed: onStart ?? () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const NotificationConnectPage())), iconAlignment: IconAlignment.end, icon: const Icon(Icons.arrow_forward, size: 19), label: const Text('MULAI PENGATURAN', style: TextStyle(letterSpacing: .5, fontWeight: FontWeight.bold)), style: FilledButton.styleFrom(backgroundColor: OnboardingTheme.cyan, foregroundColor: const Color(0xFF10444D), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))))),
                const SizedBox(height: 10),
                const Text('Konten yang dapat dianalisis bergantung pada\ninformasi yang tersedia di notifikasi.', textAlign: TextAlign.center, style: TextStyle(color: OnboardingTheme.muted, fontSize: 10, height: 1.5)),
              ]),
            ),
          )),
        ),
      );
}

class _BrandBar extends StatelessWidget {
  const _BrandBar();
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 42, height: 42, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: OnboardingTheme.cyan.withValues(alpha: .7))), child: const Icon(Icons.shield_outlined, color: OnboardingTheme.cyan, size: 22)),
    const SizedBox(width: 12),
    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MIVVI SECURE', style: TextStyle(color: OnboardingTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.bold, letterSpacing: .7, fontSize: 15)), SizedBox(height: 3), Text('PROTOCOL V4.2 // ACTIVE', style: TextStyle(color: OnboardingTheme.muted, fontSize: 8, letterSpacing: 1.4))])),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF222536), borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.circle, color: OnboardingTheme.cyan, size: 7), SizedBox(width: 6), Text('SECURE SHIELD', style: TextStyle(color: OnboardingTheme.cyan, fontSize: 8, letterSpacing: .8))])),
  ]);
}

class _Intro extends StatelessWidget {
  const _Intro();
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: OnboardingTheme.violet, borderRadius: BorderRadius.circular(12)), child: const Text('♢ PERLINDUNGAN KRIPTOGRAFIS NOTIFIKASI', style: TextStyle(color: Color(0xFFDAD1FF), fontSize: 8, letterSpacing: .6))),
    const SizedBox(height: 10),
    const Text('Pesan lebih aman.\nPikiran lebih tenang.', style: TextStyle(color: Color(0xFFD9E6F6), fontFamily: 'sans-serif', fontWeight: FontWeight.w700, fontSize: 22, height: 1.3)),
    const SizedBox(height: 5),
    const Text('MIVVI SECURE membantu mengenali indikator phishing dari konten notifikasi pesan yang tersedia di perangkatmu.', style: TextStyle(color: OnboardingTheme.muted, fontSize: 12, height: 1.55)),
  ]);
}





