import 'package:flutter/material.dart';

class ProductivityCard extends StatelessWidget {
  final double completionRate;
  final String completionLabel;

  const ProductivityCard({
    super.key,
    required this.completionRate,
    required this.completionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final safeRate = completionRate.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2E59),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'COMPLETION RATE',
            style: TextStyle(
              color: Color(0xFFBFD4EA),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            completionLabel,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: safeRate,
              minHeight: 7,
              backgroundColor: const Color(0xFF385274),
              color: const Color(0xFF8CF29A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Task success rate from live task data.',
            style: TextStyle(
              color: Color(0xFFD8E3F0),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}