import 'package:flutter/material.dart';
import '../theme/analysis_detail_theme.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/analysis_detail_widgets.dart';

class AnalysisDetailPage extends StatefulWidget {
  const AnalysisDetailPage({super.key, required this.sample});
  final NotificationActivitySample sample;

  @override
  State<AnalysisDetailPage> createState() => _AnalysisDetailPageState();
}

class _AnalysisDetailPageState extends State<AnalysisDetailPage> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) => Theme(
        data: AnalysisDetailTheme.theme,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 22), children: [
                  AnalysisDetailHeader(onBack: () => Navigator.of(context).maybePop()),
                  AnalysisMetaStrip(sample: widget.sample),
                  const SizedBox(height: 12),
                  RawNotificationCard(sample: widget.sample),
                  const SizedBox(height: 12),
                  RiskScorePanel(sample: widget.sample),
                  const SizedBox(height: 12),
                  RiskFactorsPanel(sample: widget.sample),
                  const SizedBox(height: 12),
                  SafetyRecommendations(sample: widget.sample),
                  const SizedBox(height: 14),
                  AnalysisDetailActions(saved: _saved, onManual: _manualAnalysis, onSave: _save),
                  const SizedBox(height: 14),
                  const AnalysisDisclaimer(),
                ]),
              ),
            ),
          ),
        ),
      );

  void _manualAnalysis() => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih notifikasi lain untuk dianalisis secara manual.')));

  void _save() {
    setState(() => _saved = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hasil disimpan ke riwayat analisis.')));
  }
}
