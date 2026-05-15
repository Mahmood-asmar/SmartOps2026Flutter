import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartops/core/theme/app_colors.dart';
import 'package:smartops/features/onboarding/screens/main_onboarding_screen.dart';

import '../widgets/splash_background_circle.dart';
import '../widgets/splash_footer.dart';
import '../widgets/splash_loading_bar.dart';
import '../widgets/splash_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainOnboardingScreen(),
        ),
      );

    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primaryContainer,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: -80,
                    left: -80,
                    child: SplashBackgroundCircle(
                      size: 220,
                      opacity: 0.10,
                    ),
                  ),

                  const Positioned(
                    bottom: 60,
                    right: -120,
                    child: SplashBackgroundCircle(
                      size: 320,
                      opacity: 0.16,
                    ),
                  ),

                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 360,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SplashLogo(),

                          const SizedBox(height: 32),

                          const Text(
                            'SmartOps',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.5,
                            ),
                          ),

                          const SizedBox(height: 16),

                          const Text(
                            'Smart project management for modern teams',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.onPrimaryContainer,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 48),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha:0.04),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha:0.10),
                                ),
                              ),
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBsco_XsoQGZ4AjpUBCNENN8AovNcWfXsJM-ZVwN10iaqlGMT4D7KEgS1gEkzip5qs-8reRMiWAHb2x0coTr5TMa2iDWCwDhip1aF_HXRy_IZUN22vkCXleJrHC5k-PYuXNGAhwuP3NW48X0ofd4_-tn4N3yj6A1cSLeJUe9WGhN48pvGVBDqW6JaC6o1ncnCVGh_2ZDz82AzAVECS2MBVRy1UPgE3EFxMqfgyTJYGm-geooGGJZjcuSMe5uo7iNKwibMqW1Lctq0I',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 40,
                    child: Column(
                      children: [
                        SplashLoadingBar(),
                        SizedBox(height: 24),
                        Text(
                          'ENTERPRISE MERIDIAN V2.4.0',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SplashFooter(),
        ],
      ),
    );
  }
}