import 'package:flutter/material.dart';

class TeamInsightCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String progress;
  final double progressValue;
  final Color progressColor;

  const TeamInsightCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressValue,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.insights_outlined,
            color: Color(0xFF0B2E59),
            size: 22,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'COMPLETION',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                progress,
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressValue,
            minHeight: 5,
            backgroundColor: const Color(0xFFE4E7EC),
            color: progressColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }
}