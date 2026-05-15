import 'package:flutter/material.dart';
import 'package:smartops/core/theme/app_colors.dart';

class OnboardingDots extends StatelessWidget {
  final int currentIndex;
  final int itemCount;

  const OnboardingDots({
    super.key,
    required this.currentIndex,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryContainer
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(50),
          ),
        );
      }),
    );
  }
}