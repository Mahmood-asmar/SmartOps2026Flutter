import 'package:flutter/material.dart';
import 'package:smartops/features/splash/screens/splash_screen.dart';

void main() {
  runApp(const SmartOpsApp());
}

class SmartOpsApp extends StatelessWidget {
  const SmartOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}