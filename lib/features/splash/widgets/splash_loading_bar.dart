import 'package:flutter/material.dart';

class SplashLoadingBar extends StatelessWidget {
  const SplashLoadingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.10),
        borderRadius: BorderRadius.circular(50),
      ),
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.35,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
    );
  }
}