import 'package:flutter/material.dart';
import 'package:smartops/core/theme/app_colors.dart';

class OnboardingPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  const OnboardingPage({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool smallScreen = constraints.maxHeight < 760;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            28,
            smallScreen ? 20 : 36,
            28,
            8,
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.architecture,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'SmartOps',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
              SizedBox(height: smallScreen ? 24 : 40),
              Container(
                height: smallScreen ? 255 : 315,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(32),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.primary,
                        size: 70,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: smallScreen ? 38 : 52),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: smallScreen ? 26 : 30,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -0.8,
                ),
              ),
              SizedBox(height: smallScreen ? 10 : 14),
              Flexible(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: smallScreen ? 3 : 4,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}