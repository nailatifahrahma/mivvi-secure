import 'package:flutter/material.dart';
import '../theme/analysis_detail_theme.dart';
import '../widgets/activity_widgets.dart';

class AnalysisDetailHeader extends StatelessWidget {
  const AnalysisDetailHeader({super.key, required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Row(children: [
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: AnalysisDetailTheme.ink)),
        Container(width: 30, height: 30, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AnalysisDetailTheme.cyan.withValues(alpha: .6))), child: const Icon(Icons.shield_outlined, color: AnalysisDetailTheme.cyan, size: 17)),
        const SizedBox(width: 9),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MIVVI SECURE', style: TextStyle(color: AnalysisDetailTheme.ink, fontWeight: FontWeight.bold, fontSize: 13)), SizedBox(height: 2), Text('DETAIL ANCAMAN', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 8, letterSpacing: 1.2))])),
        IconButton.filled(onPressed: () {}, icon: const Icon(Icons.person_outline), style: IconButton.styleFrom(backgroundColor: AnalysisDetailTheme.cyan, foregroundColor: const Color(0xFF104750))),
      ]);
}

class AnalysisMetaStrip extends StatelessWidget {
  const AnalysisMetaStrip({super.key, required this.sample});
  final NotificationActivitySample sample;
  @override
  Widget build(BuildContext context) {
    final threat = sample.kind == ActivityKind.phishing;
    return Container(color: AnalysisDetailTheme.raised, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), child: Row(children: [
      Icon(Icons.circle, color: threat ? AnalysisDetailTheme.danger : AnalysisDetailTheme.cyan, size: 7),
      const SizedBox(width: 6),
      Expanded(child: Text(threat ? '[THREAT DETECTED]' : '[HASIL ANALISIS PESAN]', style: TextStyle(color: threat ? AnalysisDetailTheme.danger : AnalysisDetailTheme.cyan, fontSize: 8, letterSpacing: .9))),
      Text('SEC-ID #MIV-${sample.senderId}', style: const TextStyle(color: AnalysisDetailTheme.cyan, fontSize: 8, letterSpacing: .6)),
    ]));
  }
}

class RawNotificationCard extends StatelessWidget {
  const RawNotificationCard({super.key, required this.sample});
  final NotificationActivitySample sample;
  @override
  Widget build(BuildContext context) {
    final unknown = sample.kind == ActivityKind.phishing || sample.kind == ActivityKind.suspicious;
    return _DetailPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(sample.app == 'SMS' ? Icons.sms_outlined : Icons.chat_bubble_outline, size: 14, color: AnalysisDetailTheme.purple), const SizedBox(width: 6), Expanded(child: Text('${sample.app} Notifikasi', style: const TextStyle(color: AnalysisDetailTheme.ink, fontSize: 9))), const Icon(Icons.access_time, size: 13, color: AnalysisDetailTheme.muted), const SizedBox(width: 4), Text('${sample.time} WIB', style: const TextStyle(color: AnalysisDetailTheme.muted, fontSize: 8))]),
      const Divider(height: 16, color: Color(0xFF303344)),
      Row(children: [const Text('Pengirim', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 9)), const Spacer(), Text('+62 812-${sample.senderId}', style: const TextStyle(color: AnalysisDetailTheme.ink, fontSize: 9)), const SizedBox(width: 7), _SmallBadge(text: unknown ? 'Tidak Dikenal' : 'Terverifikasi', color: unknown ? AnalysisDetailTheme.danger : AnalysisDetailTheme.cyan)]),
      const SizedBox(height: 10),
      Container(width: double.infinity, padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AnalysisDetailTheme.raised, border: const Border(left: BorderSide(color: AnalysisDetailTheme.danger, width: 3)), borderRadius: BorderRadius.circular(4)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Row(children: [Expanded(child: Text('RAW PAYLOAD INTERCEPTED', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 8, letterSpacing: .8))), Icon(Icons.lock_outline, color: AnalysisDetailTheme.muted, size: 13)]), const SizedBox(height: 7), Text('“${sample.message}”', style: const TextStyle(color: AnalysisDetailTheme.ink, fontSize: 11, height: 1.6))]),
    ]));
  }
}

class RiskScorePanel extends StatelessWidget {
  const RiskScorePanel({super.key, required this.sample});
  final NotificationActivitySample sample;
  @override
  Widget build(BuildContext context) {
    final color = sample.kind == ActivityKind.phishing ? AnalysisDetailTheme.danger : sample.kind == ActivityKind.suspicious ? AnalysisDetailTheme.amber : AnalysisDetailTheme.cyan;
    final classification = sample.kind == ActivityKind.phishing ? 'PHISHING' : sample.kind == ActivityKind.suspicious ? 'MENCURIGAKAN' : sample.kind == ActivityKind.safe ? 'AMAN' : 'BELUM DIANALISIS';
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(gradient: LinearGradient(colors: [AnalysisDetailTheme.panel, color.withValues(alpha: .12)]), borderRadius: BorderRadius.circular(7)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(Icons.circle, color: color, size: 8), const SizedBox(width: 7), Expanded(child: Text('VEKTOR ANCAMAN ${sample.score >= 6 ? 'KRITIS' : 'TERPANTAU'}', style: TextStyle(color: color, fontSize: 8, letterSpacing: .9))), const _SmallBadge(text: 'RULE-ENGINE V4.2', color: AnalysisDetailTheme.muted)]),
      const SizedBox(height: 14), const Text('KLASIFIKASI SISTEM', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 8, letterSpacing: .8)),
      const SizedBox(height: 5), Text(classification, style: TextStyle(color: color, fontFamily: 'sans-serif', fontWeight: FontWeight.w800, fontSize: 23)),
      const SizedBox(height: 12),
      Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AnalysisDetailTheme.raised, borderRadius: BorderRadius.circular(5)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('KALKULASI TELEMETRI', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 8, letterSpacing: .8)), const SizedBox(height: 4), Text('Skor Risiko ${sample.score}', style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 12),
      Container(width: double.infinity, padding: const EdgeInsets.all(10), color: AnalysisDetailTheme.raised.withValues(alpha: .65), child: Text(_riskAdvice(sample), style: const TextStyle(color: AnalysisDetailTheme.ink, fontSize: 10, height: 1.5))),
      const SizedBox(height: 13),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('SKALA AMBANG RISIKO:', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 7, letterSpacing: .8)), Text('[6+ : TERCAPAI ${sample.score}]', style: TextStyle(color: color, fontSize: 7, letterSpacing: .7))]),
      const SizedBox(height: 6), ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (sample.score / 15).clamp(0, 1).toDouble(), minHeight: 6, backgroundColor: AnalysisDetailTheme.raised, valueColor: AlwaysStoppedAnimation(color))),
      const SizedBox(height: 5), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('0–2: AMAN', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 7)), Text('3–5: MENCURIGAKAN', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 7)), Text('6+: PHISHING', style: TextStyle(color: AnalysisDetailTheme.danger, fontSize: 7))]),
    ]));
  }
}

class RiskFactorsPanel extends StatelessWidget {
  const RiskFactorsPanel({super.key, required this.sample});
  final NotificationActivitySample sample;
  @override
  Widget build(BuildContext context) {
    final factors = _factorsFor(sample);
    return _DetailPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Icon(Icons.policy_outlined, color: AnalysisDetailTheme.cyan, size: 18), const SizedBox(width: 7), const Expanded(child: Text('Mengapa pesan ini berisiko?', style: TextStyle(color: AnalysisDetailTheme.ink, fontSize: 13, fontWeight: FontWeight.w600))), _SmallBadge(text: '${factors.length} TERDETEKSI', color: AnalysisDetailTheme.cyan)]),
      const SizedBox(height: 10),
      Text('Analisis heuristik menemukan anomali keamanan dengan bobot risiko berikut:', style: const TextStyle(color: AnalysisDetailTheme.muted, fontSize: 9, height: 1.5)),
      const SizedBox(height: 9),
      for (final factor in factors) ...[
        _FactorRow(factor: factor),
        const SizedBox(height: 6),
      ],
      Row(children: [const Expanded(child: Text('TOTAL SKOR RISIKO', style: TextStyle(color: AnalysisDetailTheme.ink, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: .6))), Text('${sample.score}', style: const TextStyle(color: AnalysisDetailTheme.danger, fontSize: 16, fontWeight: FontWeight.bold))]),
    ]));
  }
}

class SafetyRecommendations extends StatelessWidget {
  const SafetyRecommendations({super.key, required this.sample});
  final NotificationActivitySample sample;
  @override
  Widget build(BuildContext context) => _DetailPanel(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.health_and_safety_outlined, color: AnalysisDetailTheme.cyan, size: 18), SizedBox(width: 7), Text('Yang sebaiknya kamu lakukan', style: TextStyle(color: AnalysisDetailTheme.ink, fontSize: 13, fontWeight: FontWeight.w600))]),
        const SizedBox(height: 10),
        _AdviceRow(icon: Icons.remove_circle_outline, text: sample.kind == ActivityKind.safe ? 'Tetap periksa pengirim dan tautan sebelum membagikan informasi.' : 'Jangan membuka tautan atau mengunduh berkas apa pun dari pesan ini.'),
        const SizedBox(height: 6),
        const _AdviceRow(icon: Icons.lock_outline, text: 'Jangan pernah membagikan OTP, PIN, atau kata sandi kepada siapa pun dalam situasi apa pun.'),
        const SizedBox(height: 6),
        const _AdviceRow(icon: Icons.verified_user_outlined, text: 'Lakukan verifikasi mandiri hanya melalui aplikasi atau call center resmi.'),
      ]));
}

class AnalysisDetailActions extends StatelessWidget {
  const AnalysisDetailActions({super.key, required this.saved, required this.onManual, required this.onSave});
  final bool saved;
  final VoidCallback onManual;
  final VoidCallback onSave;
  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(width: double.infinity, height: 46, child: FilledButton.icon(onPressed: onManual, icon: const Icon(Icons.document_scanner_outlined, size: 17), label: const Text('Analisis Pesan Manual Lain'), style: FilledButton.styleFrom(backgroundColor: AnalysisDetailTheme.cyan, foregroundColor: const Color(0xFF104750), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))))),
        const SizedBox(height: 7),
        SizedBox(width: double.infinity, height: 43, child: OutlinedButton.icon(onPressed: onSave, icon: Icon(saved ? Icons.bookmark_added : Icons.bookmark_add_outlined, size: 17), label: Text(saved ? 'Tersimpan ke Riwayat Analisis' : 'Simpan ke Riwayat Analisis'), style: OutlinedButton.styleFrom(foregroundColor: AnalysisDetailTheme.ink, backgroundColor: AnalysisDetailTheme.panel, side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))))),
      ]);
}

class AnalysisDisclaimer extends StatelessWidget {
  const AnalysisDisclaimer({super.key});
  @override
  Widget build(BuildContext context) => const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.info_outline, color: AnalysisDetailTheme.muted, size: 14), SizedBox(width: 7), Expanded(child: Text('Penilaian berdasarkan indikator rule-based pada notifikasi, bukan kepastian mutlak bahwa pengirim adalah pelaku penipuan.', style: TextStyle(color: AnalysisDetailTheme.muted, fontSize: 8, height: 1.5)))]);
}

class _DetailPanel extends StatelessWidget {
  const _DetailPanel({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: AnalysisDetailTheme.panel, borderRadius: BorderRadius.circular(7)), child: child);
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), color: color.withValues(alpha: .14), child: Text(text, style: TextStyle(color: color, fontSize: 7, letterSpacing: .6)));
}

class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor});
  final _RiskFactor factor;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AnalysisDetailTheme.raised, borderRadius: BorderRadius.circular(4)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(factor.icon, color: factor.color, size: 15), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(factor.title, style: const TextStyle(color: AnalysisDetailTheme.ink, fontSize: 10)), const SizedBox(height: 4), Text(factor.evidence, style: const TextStyle(color: AnalysisDetailTheme.muted, fontSize: 8))])), Text('+${factor.points}', style: const TextStyle(color: AnalysisDetailTheme.danger, fontSize: 10, fontWeight: FontWeight.bold))]));
}

class _AdviceRow extends StatelessWidget {
  const _AdviceRow({required this.icon, required this.text});
  final IconData icon;
  final String text;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AnalysisDetailTheme.raised, borderRadius: BorderRadius.circular(4)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AnalysisDetailTheme.danger, size: 15), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(color: AnalysisDetailTheme.ink, fontSize: 9, height: 1.5)))]));
}

class _RiskFactor {
  const _RiskFactor(this.title, this.evidence, this.points, this.icon, this.color);
  final String title, evidence;
  final int points;
  final IconData icon;
  final Color color;
}

List<_RiskFactor> _factorsFor(NotificationActivitySample sample) {
  if (sample.kind == ActivityKind.phishing) return const [
    _RiskFactor('Keyword mencurigakan', '“TERBLOKIR”, “verifikasi”', 2, Icons.key_outlined, AnalysisDetailTheme.amber),
    _RiskFactor('Domain di luar whitelist resmi', 'bit.ly/verif-akun24', 3, Icons.link_off, AnalysisDetailTheme.danger),
    _RiskFactor('Menggunakan shortlink penyamaran', 'bit.ly mask', 2, Icons.visibility_off_outlined, AnalysisDetailTheme.purple),
    _RiskFactor('Pengirim tidak dikenal / nomor baru', 'Unverified sender', 2, Icons.person_outline, AnalysisDetailTheme.purple),
    _RiskFactor('Pola urgensi buatan', '“dalam 1x24 jam”', 1, Icons.timer_outlined, AnalysisDetailTheme.amber),
    _RiskFactor('Permintaan data sensitif', '“kode OTP”', 3, Icons.password_outlined, AnalysisDetailTheme.danger),
  ];
  if (sample.kind == ActivityKind.suspicious) return const [
    _RiskFactor('Klaim hadiah tidak terduga', '“memenangkan saldo”', 2, Icons.card_giftcard, AnalysisDetailTheme.amber),
    _RiskFactor('Tautan di luar kanal resmi', 's.id/dana-kaget-', 2, Icons.link_off, AnalysisDetailTheme.danger),
  ];
  if (sample.kind == ActivityKind.safe) return const [
    _RiskFactor('Pengirim dikenal', 'Sender cocok dengan label pesan', 0, Icons.verified_user_outlined, AnalysisDetailTheme.cyan),
    _RiskFactor('Tidak ada pola phishing utama', 'Tidak meminta OTP atau data sensitif', 0, Icons.check_circle_outline, AnalysisDetailTheme.cyan),
  ];
  return const [_RiskFactor('Pratinjau pesan tidak tersedia', 'Analisis otomatis terbatas', 0, Icons.visibility_off_outlined, AnalysisDetailTheme.muted)];
}

String _riskAdvice(NotificationActivitySample sample) => switch (sample.kind) {
      ActivityKind.phishing => 'Risiko tinggi — jangan klik tautan atau membagikan data sensitif.',
      ActivityKind.suspicious => 'Perlu waspada — periksa sumber pesan dan jangan berikan informasi pribadi.',
      ActivityKind.safe => 'Risiko rendah — tetap pastikan pesan sesuai konteks dan pengirimnya.',
      ActivityKind.unavailable => 'Pesan belum dapat dianalisis — pratinjau notifikasi tidak tersedia.',
    };

