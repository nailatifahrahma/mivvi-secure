
import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'pages/splash_page.dart';

void main() {
  runApp(const MivviApp());
}

class MivviApp extends StatelessWidget {
  const MivviApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mivvi Secure',
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
    );
  }
}
