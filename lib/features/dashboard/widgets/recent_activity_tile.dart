import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class RecentActivityTile extends StatelessWidget {
  final String project;
  final String task;
  final String owner;
  final String status;
  final Color statusColor;

  const RecentActivityTile({
    super.key,
    required this.project,
    required this.task,
    required this.owner,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'PROJECT', value: project),
          const SizedBox(height: 8),
          _InfoRow(label: 'TASK', value: task),
          const SizedBox(height: 8),
          _InfoRow(label: 'OWNER', value: owner),
          const SizedBox(height: 10),
          StatusChip(label: status, color: statusColor),
        ],
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
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}