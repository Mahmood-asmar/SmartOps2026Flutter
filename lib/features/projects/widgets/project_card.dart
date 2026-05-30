import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class ProjectCard extends StatelessWidget {
  final String title;
  final String client;
  final String priority;
  final Color priorityColor;
  final String status;
  final Color statusColor;
  final String deadline;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.client,
    required this.priority,
    required this.priorityColor,
    required this.status,
    required this.statusColor,
    required this.deadline,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEF8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.apartment_outlined,
                    color: Color(0xFF0B2E59),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, color: Color(0xFF98A2B3)),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(label: 'CLIENT', value: client),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'PRIORITY',
                  style: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                StatusChip(label: priority, color: priorityColor),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text(
                  'STATUS',
                  style: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                StatusChip(label: status, color: statusColor),
              ],
            ),
            const SizedBox(height: 10),
            _InfoRow(label: 'DEADLINE', value: deadline),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}