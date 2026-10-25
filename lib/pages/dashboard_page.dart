import 'package:flutter/material.dart';
import '../theme/dashboard_theme.dart';
import '../widgets/dashboard_widgets.dart';
import 'notification_activity_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) => Theme(
        data: DashboardTheme.theme,
        child: Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  children: const [
                    DashboardHeader(),
                    SizedBox(height: 12),
                    DashboardWelcomeCard(),
                    SizedBox(height: 16),
                    DashboardActionButtons(),
                    SizedBox(height: 22),
                    RiskLevels(),
                    SizedBox(height: 22),
                    RecentDetections(),
                    SizedBox(height: 16),
                    DashboardSystemStatus(),
                    SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: DashboardBottomNav(
            selectedIndex: _selectedTab,
            onSelected: (index) {
              if (index == 1) {
                Navigator.of(context)
                    .push(MaterialPageRoute<void>(builder: (_) => const NotificationActivityPage()))
                    .then((_) {
                  if (mounted) setState(() => _selectedTab = 0);
                });
              } else if (index == 0) {
                setState(() => _selectedTab = 0);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur ini akan tersedia berikutnya.')),
                );
              }
            },
          ),
        ),
      );

}







