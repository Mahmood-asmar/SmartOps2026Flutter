import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class AiCard extends StatelessWidget {
  const AiCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Color(0xFF0B2E59),
              size: 18,
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Predictive Analytics',
              style: TextStyle(
                color: Color(0xFF0B2E59),
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            StatusChip(
              label: 'LIVE',
              color: Colors.blue.shade700,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Potential Delay',
                style: TextStyle(
                  color: Color(0xFFB42318),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Permit Acquisition',
                style: TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Estimated delay of 4.5 days.',
                style: TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 10),
              StatusChip(
                label: 'Action Required',
                color: Colors.red.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }
}