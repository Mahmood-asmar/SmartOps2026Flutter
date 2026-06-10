import 'package:flutter/material.dart';
import 'package:smartops/core/models/task_model.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });

  Color _priorityColor(String priority) {
    if (priority == 'high') return Colors.red.shade700;
    if (priority == 'medium') return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  Color _statusColor(String status) {
    if (status == 'completed') return Colors.green.shade700;
    if (status == 'in_progress') return Colors.blue.shade700;
    return Colors.orange.shade700;
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    })
        .join(' ');
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not set';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9EEF5)),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6EEF8),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.task_alt_outlined,
                    color: Color(0xFF0B2E59),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      color: Color(0xFF0B2E59),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF98A2B3),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              task.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 14),

            _InfoRow(
              label: 'PROJECT',
              value: task.projectName ?? 'No project',
            ),

            const SizedBox(height: 10),

            _InfoRow(
              label: 'ASSIGNED TO',
              value: task.assignedUserEmail ??
                  task.assignedUserName ??
                  'Unassigned',
            ),

            const SizedBox(height: 10),

            _InfoRow(
              label: 'DEADLINE',
              value: _formatDate(task.deadline),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                StatusChip(
                  label: _formatLabel(task.priority),
                  color: _priorityColor(task.priority),
                ),
                const SizedBox(width: 8),
                StatusChip(
                  label: _formatLabel(task.status),
                  color: _statusColor(task.status),
                ),
              ],
            ),
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
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}