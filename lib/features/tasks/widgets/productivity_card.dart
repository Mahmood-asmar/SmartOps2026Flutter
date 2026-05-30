import 'package:flutter/material.dart';

class ProductivityCard extends StatelessWidget {
  const ProductivityCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Text(
            '84%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const LinearProgressIndicator(
              value: 0.84,
              minHeight: 7,
              backgroundColor: Color(0xFF385274),
              color: Color(0xFF8CF29A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Task success rate this week.',
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