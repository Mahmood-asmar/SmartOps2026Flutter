import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/api_service.dart';
import 'package:smartops/features/splash/screens/splash_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  ApiService.init();

  runApp(const SmartOpsApp());
}

class SmartOpsApp extends StatelessWidget {
  const SmartOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final authProvider = AuthProvider();
        authProvider.loadAuthData();
        return authProvider;
      },
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      ),
    );
  }
}