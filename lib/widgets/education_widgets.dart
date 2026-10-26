import 'package:flutter/material.dart';
import '../theme/education_theme.dart';

class EducationHeader extends StatelessWidget {
  const EducationHeader({super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: EducationTheme.cyan.withValues(alpha: .6))), child: const Icon(Icons.shield_outlined, color: EducationTheme.cyan, size: 18)),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MIVVI SECURE •', style: TextStyle(color: EducationTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.bold, fontSize: 14)), SizedBox(height: 2), Text('EDUKASI', style: TextStyle(color: EducationTheme.muted, fontSize: 8, letterSpacing: 1.3))])),
        IconButton.filled(onPressed: () {}, icon: const Icon(Icons.person_outline), style: IconButton.styleFrom(backgroundColor: EducationTheme.cyan, foregroundColor: const Color(0xFF104750))),
      ]);
}

class LearningModuleCard extends StatelessWidget {
  const LearningModuleCard({super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF342571), EducationTheme.panel, EducationTheme.panel]), borderRadius: BorderRadius.circular(8)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: const [Icon(Icons.verified_user_outlined, color: EducationTheme.cyan, size: 14), SizedBox(width: 6), Expanded(child: Text('ANALISIS INTELIJEN ANCAMAN', style: TextStyle(color: EducationTheme.cyan, fontSize: 8, letterSpacing: .9))), _Label('3 INDIKATOR', EducationTheme.purple)]),
        const SizedBox(height: 14),
        const Text('3 tanda pesan yang patut diwaspadai', style: TextStyle(color: EducationTheme.ink, fontFamily: 'sans-serif', fontWeight: FontWeight.w700, fontSize: 17)),
        const SizedBox(height: 4),
        const Text('Matriks pengenalan anomali rekayasa sosial sebelum terjadi pelanggaran sandi.', style: TextStyle(color: EducationTheme.muted, fontSize: 9, height: 1.5)),
        const SizedBox(height: 12),
        const _WarningSign(icon: Icons.link_off, title: 'Tautan tidak dikenal', code: 'SEC_01', description: 'Periksa alamat domain dan jangan langsung membuka tautan yang dikirim oleh pengirim tidak dikenal.', color: EducationTheme.purple),
        SizedBox(height: 7),
        const _WarningSign(icon: Icons.timer_outlined, title: 'Tekanan untuk segera bertindak', code: 'SEC_02', description: 'Waspadai pesan yang mengancam pemblokiran akun atau memberi batas waktu mendesak.', color: EducationTheme.danger),
        SizedBox(height: 7),
        const _WarningSign(icon: Icons.password_outlined, title: 'Permintaan data rahasia', code: 'SEC_03', description: 'Jangan pernah membagikan OTP, PIN, atau kata sandi melalui pesan yang mencurigakan.', color: EducationTheme.cyan),
      ]));
}

class ExampleMessageCard extends StatelessWidget {
  const ExampleMessageCard({super.key, required this.onAnalyze});
  final VoidCallback onAnalyze;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionHeading(icon: Icons.terminal, title: 'KENALI CONTOH PESANNYA', badge: 'SIMULASI REAL-TIME'),
        const SizedBox(height: 9),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: EducationTheme.panel, borderRadius: BorderRadius.circular(7)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.circle, color: EducationTheme.danger, size: 8), SizedBox(width: 6), Expanded(child: Text('[INCOMING SMS INTERCEPT]', style: TextStyle(color: EducationTheme.danger, fontSize: 8, letterSpacing: .9))), Text('HEX_ADDR: 0x9F4B', style: TextStyle(color: EducationTheme.muted, fontSize: 7, letterSpacing: .8))]),
          const SizedBox(height: 12),
          Row(children: const [Icon(Icons.account_balance_outlined, color: EducationTheme.ink, size: 20), SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('BANK-PUSAT-NOTIF', style: TextStyle(color: EducationTheme.ink, fontSize: 11, fontWeight: FontWeight.bold)), Text('+62 821-9901-XXXX (Masked Alias)', style: TextStyle(color: EducationTheme.muted, fontSize: 8))])), _Label('UNVERIFIED', EducationTheme.danger)]),
          const SizedBox(height: 11),
          Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: EducationTheme.raised, borderRadius: BorderRadius.circular(4)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('PENTING: Rekening Anda terdeteksi akses ilegal! Kami akan membekukan saldo Anda dalam waktu [Urgensi: 1x24 jam]. Segera verifikasi pembatalan lewat portal darurat: [Shortlink: bit.ly/aman-bank-id] dan masukkan [Permintaan Rahasia: Kode OTP] yang masuk ke ponsel Anda.', style: TextStyle(color: EducationTheme.ink, fontSize: 10, height: 1.7)),
            SizedBox(height: 10),
            _Label('⚠ Threat Score: 98/100', EducationTheme.danger),
            SizedBox(height: 5),
            _Label('◉ Signature: Phish.Bank.Urgency', EducationTheme.muted),
          ])),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 44, child: FilledButton.icon(onPressed: onAnalyze, icon: const Icon(Icons.psychology_alt_outlined, size: 17), label: const Text('LIHAT SIMULASI ANALISIS'), style: FilledButton.styleFrom(backgroundColor: EducationTheme.cyan, foregroundColor: const Color(0xFF104750), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))))),
        ])),
      ]);
}

class SecurityFaqList extends StatelessWidget {
  const SecurityFaqList({super.key});
  static const questions = [
    ('Bagaimana mengenali domain palsu?', 'Periksa ejaan alamat dengan teliti. Penipu sering meniru nama resmi dengan tambahan atau perubahan karakter dan memakai domain pendek.'),
    ('Mengapa shortlink sering digunakan?', 'Shortlink menyembunyikan alamat tujuan sebenarnya. Jangan membukanya jika pengirim dan konteksnya tidak jelas.'),
    ('Apakah MIVVI SECURE menyimpan pesan?', 'Contoh dan hasil analisis demo ditampilkan lokal. Aplikasi tidak mengirim isi notifikasi ke server dalam simulasi ini.'),
  ];
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _SectionHeading(icon: Icons.checklist, title: 'PANDUAN KEAMANAN & FAQ'),
        const SizedBox(height: 8),
        for (var i = 0; i < questions.length; i++)
          Padding(padding: const EdgeInsets.only(bottom: 7), child: _FaqTile(icon: [Icons.fact_check_outlined, Icons.link, Icons.cloud_off_outlined][i], question: questions[i].$1, answer: questions[i].$2, color: i == 1 ? EducationTheme.cyan : EducationTheme.purple)),
      ]);
}

class NextModuleCard extends StatelessWidget {
  const NextModuleCard({super.key});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: EducationTheme.panel, borderRadius: BorderRadius.circular(7)), child: const Row(children: [
        _ModuleIcon(), SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tingkatkan Naluri Bertahan', style: TextStyle(color: EducationTheme.ink, fontSize: 12, fontWeight: FontWeight.w600)), SizedBox(height: 4), Text('Lanjutkan ke modul berikutnya untuk simulasi intercept malware APK.', style: TextStyle(color: EducationTheme.muted, fontSize: 8, height: 1.5))])),
      ]));
}

class EducationBottomNav extends StatelessWidget {
  const EducationBottomNav({super.key, required this.onSelected});
  final ValueChanged<int> onSelected;
  static const items = [(Icons.shield_outlined, 'Beranda'), (Icons.notifications_none, 'Aktivitas'), (Icons.history, 'Riwayat'), (Icons.menu_book_outlined, 'Edukasi'), (Icons.tune, 'Pengaturan')];
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(5, 7, 5, 8), decoration: const BoxDecoration(color: Color(0xFF171927), border: Border(top: BorderSide(color: Color(0xFF292C43)))), child: Row(children: List.generate(items.length, (index) => Expanded(child: InkWell(onTap: () => onSelected(index), child: Padding(padding: const EdgeInsets.symmetric(vertical: 7), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(items[index].$1, color: index == 3 ? EducationTheme.cyan : EducationTheme.muted, size: 17), const SizedBox(height: 3), Text(items[index].$2, style: TextStyle(color: index == 3 ? EducationTheme.cyan : EducationTheme.muted, fontSize: 7, letterSpacing: .5))]))))));
}

class _WarningSign extends StatelessWidget {
  const _WarningSign({required this.icon, required this.title, required this.code, required this.description, required this.color});
  final IconData icon; final String title, code, description; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: EducationTheme.raised, borderRadius: BorderRadius.circular(4)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: 29, height: 29, decoration: BoxDecoration(color: color.withValues(alpha: .2), borderRadius: BorderRadius.circular(5)), child: Icon(icon, color: color, size: 16)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(title, style: const TextStyle(color: EducationTheme.ink, fontSize: 11, fontWeight: FontWeight.w600))), Text(code, style: const TextStyle(color: EducationTheme.muted, fontSize: 7, letterSpacing: .7))]), const SizedBox(height: 4), Text(description, style: const TextStyle(color: EducationTheme.muted, fontSize: 9, height: 1.5))]))]));
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.icon, required this.question, required this.answer, required this.color});
  final IconData icon; final String question, answer; final Color color;
  @override
  Widget build(BuildContext context) => Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: Container(decoration: BoxDecoration(color: EducationTheme.panel, borderRadius: BorderRadius.circular(6)), child: ExpansionTile(leading: Container(width: 26, height: 26, decoration: BoxDecoration(color: color.withValues(alpha: .2), borderRadius: BorderRadius.circular(4)), child: Icon(icon, color: color, size: 15)), title: Text(question, style: const TextStyle(color: EducationTheme.ink, fontSize: 10, fontWeight: FontWeight.w600)), iconColor: EducationTheme.muted, collapsedIconColor: EducationTheme.muted, childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14), children: [Text(answer, style: const TextStyle(color: EducationTheme.muted, fontSize: 9, height: 1.5))])));
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.icon, required this.title, this.badge});
  final IconData icon; final String title; final String? badge;
  @override
  Widget build(BuildContext context) => Row(children: [Icon(icon, color: EducationTheme.purple, size: 16), const SizedBox(width: 6), Expanded(child: Text(title, style: const TextStyle(color: EducationTheme.ink, fontSize: 12, fontWeight: FontWeight.w600))), if(badge != null) Text(badge!, style: const TextStyle(color: EducationTheme.cyan, fontSize: 7, letterSpacing: .7))]);
}

class _Label extends StatelessWidget {
  const _Label(this.text, this.color);
  final String text; final Color color;
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), color: color.withValues(alpha: .16), child: Text(text, style: TextStyle(color: color, fontSize: 7, letterSpacing: .7)));
}

class _ModuleIcon extends StatelessWidget {
  const _ModuleIcon();
  @override
  Widget build(BuildContext context) => Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF33227C), borderRadius: BorderRadius.circular(5)), child: const Icon(Icons.workspace_premium_outlined, color: EducationTheme.cyan, size: 22));
}
