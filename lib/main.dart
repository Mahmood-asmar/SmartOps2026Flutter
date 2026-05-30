import 'package:flutter/material.dart';
import 'package:smartops/features/dashboard/screens/dashboard_screen.dart';

void main() {
  runApp(const SmartOpsApp());
}

class SmartOpsApp extends StatelessWidget {
  const SmartOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}