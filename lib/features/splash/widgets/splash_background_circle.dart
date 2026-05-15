import 'package:flutter/material.dart';

class SplashBackgroundCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const SplashBackgroundCircle({
    super.key,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        //color: Colors.white.withOpacity(opacity),
        color: Colors.white.withValues(alpha: opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}