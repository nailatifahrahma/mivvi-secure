import 'package:flutter/material.dart';
import '../theme/onboarding_theme.dart';

class SignalPreview extends StatelessWidget {
  const SignalPreview({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(colors: [Color(0xFF292C3D), Color(0xFF20174B), Color(0xFF111321)]),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _bubble(icon: Icons.sms, label: 'SMS  //  +62 819-2819-XXXX BARU SAJA', text: 'Akun ditangguhkan. Verifikasi segera: s.id/bank-auth...', color: const Color(0xFF303247)),
          const SizedBox(height: 12),
          _bubble(icon: Icons.security, label: 'MIVVI INTERCEPT GUARD', text: 'Domain s.id/bank-auth bukan kanal kredibel perbankan resmi.', color: const Color(0xFF10121F), threat: true),
        ]),
      );

  Widget _bubble({required IconData icon, required String label, required String text, required Color color, bool threat = false}) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Icon(icon, size: 14, color: OnboardingTheme.cyan), const SizedBox(width: 6), Expanded(child: Text(label, style: const TextStyle(color: OnboardingTheme.cyan, fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.bold))), if (threat) const _ThreatBadge()],),
          const SizedBox(height: 7),
          Text(text, style: const TextStyle(color: Color(0xFFC3CAD5), fontSize: 11, height: 1.45)),
        ]),
      );
}

class _ThreatBadge extends StatelessWidget {
  const _ThreatBadge();
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFB90016), borderRadius: BorderRadius.circular(20)), child: const Text('THREAT DETECTED', style: TextStyle(fontSize: 8, letterSpacing: 1, color: Colors.white, fontWeight: FontWeight.bold)));
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({super.key, required this.icon, required this.title, required this.tag, required this.description});
  final IconData icon;
  final String title;
  final String tag;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: OnboardingTheme.panel, borderRadius: BorderRadius.circular(13)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: const Color(0xFF303344), borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: OnboardingTheme.cyan, size: 21)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Text(title, style: const TextStyle(fontFamily: 'sans-serif', color: OnboardingTheme.ink, fontWeight: FontWeight.w600, fontSize: 14))), const SizedBox(width: 5), Text(tag, style: const TextStyle(color: OnboardingTheme.cyan, fontSize: 8, letterSpacing: 1))]),
            const SizedBox(height: 5),
            Text(description, style: const TextStyle(color: OnboardingTheme.muted, fontSize: 10, height: 1.45)),
          ])),
        ]),
      );
}

