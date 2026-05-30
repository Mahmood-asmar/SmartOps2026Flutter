import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String project;
  final String status;
  final Color statusColor;
  final String priority;

  const TaskCard({
    super.key,
    required this.title,
    required this.project,
    required this.status,
    required this.statusColor,
    required this.priority,
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
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'PROJECT',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                project,
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              StatusChip(
                label: priority,
                color: Colors.red.shade700,
              ),
              const Spacer(),
              StatusChip(
                label: status,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}