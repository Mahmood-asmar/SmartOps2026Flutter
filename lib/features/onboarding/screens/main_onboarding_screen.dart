import 'package:flutter/material.dart';
import 'package:smartops/core/theme/app_colors.dart';
import 'package:smartops/features/auth/screens/login.dart';
import 'package:smartops/features/onboarding/widgets/onboarding_dots.dart';
import 'package:smartops/features/onboarding/widgets/onboarding_page.dart';
import 'package:smartops/core/local_storage/local_storage.dart';


class MainOnboardingScreen extends StatefulWidget {
  const MainOnboardingScreen({super.key});

  @override
  State<MainOnboardingScreen> createState() => _MainOnboardingScreenState();
}

class _MainOnboardingScreenState extends State<MainOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      imageUrl:
      'assets/images/on1.png',
      title: 'Manage Projects Efficiently',
      description:
        ' Organize your architectural workflows, set firm deadlines, and manage complex project lifecycles with surgical precision.'
    ),
    _OnboardingItem(
      imageUrl:
      'assets/images/on2.png',
      title: 'Track Tasks & Progress',
      description:
        'Assign tasks to your team and monitor real-time progress through intuitive boards and productivity charts. Stay ahead of deadlines with precise oversight.'
    ),
    _OnboardingItem(
      imageUrl:
      'assets/images/on3.png',
      title: 'Collaborate Securely',
      description:
        '    Connect admins, employees, and clients in a unified, secure ecosystem with real-time notifications and encrypted communication.'
    ),
  ];

  Future<void> _nextPage() async {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {

      await LocalStorage.setOnboardingSeen();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );

    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skip() {
    // TODO: Navigate to login screen.
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentIndex == _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final item = _items[index];

                  return OnboardingPage(
                    imageUrl: item.imageUrl,
                    title: item.title,
                    description: item.description,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OnboardingDots(
                    currentIndex: _currentIndex,
                    itemCount: _items.length,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      SizedBox(
                        width: 95,
                        child: InkWell(
                          onTap: _currentIndex > 0 ? _previousPage : _skip,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_currentIndex > 0) ...[
                                  const Icon(
                                    Icons.arrow_back,
                                    color: AppColors.primary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Back',
                                    style: TextStyle(
                                      inherit: true,
                                      color: AppColors.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ] else ...[
                                  const Text(
                                    'Skip',
                                    style: TextStyle(
                                      inherit: true,
                                      color: AppColors.secondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  inherit: true,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '© 2026 SmartOps Meridian',
                    style: TextStyle(
                      color: AppColors.outline,
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
    );
  }
}

class _OnboardingItem {
  final String imageUrl;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}