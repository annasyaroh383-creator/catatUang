import 'package:flutter/material.dart';
import 'pages/dashboard_page.dart';

void main() {
  runApp(const KoenkuApp());
}

class KoenkuApp extends StatelessWidget {
  const KoenkuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Koenku',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const DashboardPage(),
    );
  }
}
