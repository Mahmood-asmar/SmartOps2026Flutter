import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class ActiveTaskCard extends StatelessWidget {
  final String title;
  final String assignee;
  final String status;
  final Color statusColor;

  const ActiveTaskCard({
    super.key,
    required this.title,
    required this.assignee,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFE6EEF8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.task_alt_outlined,
              color: Color(0xFF0B2E59),
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  assignee,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          StatusChip(label: status, color: statusColor),
        ],
      ),
    );
  }
}