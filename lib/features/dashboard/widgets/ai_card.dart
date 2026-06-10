import 'package:flutter/material.dart';

import 'package:smartops/core/widgets/status_chip.dart';

class AiCard extends StatelessWidget {
  final int overdueTasks;
  final int pendingRequests;
  final int completionRate;
  final int activeProjects;

  const AiCard({
    super.key,
    required this.overdueTasks,
    required this.pendingRequests,
    required this.completionRate,
    required this.activeProjects,
  });

  bool get hasRisk {
    return overdueTasks > 0 || pendingRequests > 0 || completionRate < 50;
  }

  String get title {
    if (overdueTasks > 0) {
      return 'Potential Delay';
    }

    if (pendingRequests > 0) {
      return 'Pending Review';
    }

    if (completionRate >= 80) {
      return 'Strong Performance';
    }

    if (completionRate >= 50) {
      return 'Stable Progress';
    }

    return 'Needs Attention';
  }

  String get subject {
    if (overdueTasks > 0) {
      return '$overdueTasks overdue task(s)';
    }

    if (pendingRequests > 0) {
      return '$pendingRequests pending request(s)';
    }

    if (activeProjects > 0) {
      return '$activeProjects active project(s)';
    }

    return 'Workspace Overview';
  }

  String get description {
    if (overdueTasks > 0) {
      return 'AI suggests reviewing delayed tasks and reassigning urgent work.';
    }

    if (pendingRequests > 0) {
      return 'There are project requests waiting for admin review.';
    }

    if (completionRate >= 80) {
      return 'Task completion is healthy. Keep the current execution pace.';
    }

    if (completionRate >= 50) {
      return 'Progress is stable, but some tasks still need follow-up.';
    }

    return 'Completion rate is low. Focus on pending and in-progress tasks.';
  }

  Color get cardColor {
    if (hasRisk) return const Color(0xFFFFF1F1);
    return const Color(0xFFEFFAF3);
  }

  Color get titleColor {
    if (hasRisk) return const Color(0xFFB42318);
    return const Color(0xFF15803D);
  }

  Color get chipColor {
    if (hasRisk) return Colors.red.shade700;
    return Colors.green.shade700;
  }

  String get chipLabel {
    if (hasRisk) return 'Action Required';
    return 'Healthy';
  }

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
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: titleColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subject,
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              StatusChip(
                label: chipLabel,
                color: chipColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}