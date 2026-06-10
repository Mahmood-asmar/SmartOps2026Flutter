import 'package:flutter/material.dart';

import 'package:smartops/core/models/task_model.dart';

class TeamActivity extends StatelessWidget {
  final List<TaskModel> tasks;

  const TeamActivity({
    super.key,
    required this.tasks,
  });

  List<String> get _teamInitials {
    final names = tasks
        .map((task) => task.assignedUserName ?? task.assignedUserEmail ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .take(4)
        .toList();

    if (names.isEmpty) return ['U'];

    return names.map((name) {
      final trimmed = name.trim();
      return trimmed.isEmpty ? 'U' : trimmed[0].toUpperCase();
    }).toList();
  }

  int get _completedTasks {
    return tasks.where((task) => task.status == 'completed').length;
  }

  int get _activeMembers {
    return tasks
        .map((task) => task.assignedUserEmail ?? task.assignedUserName ?? '')
        .where((name) => name.trim().isNotEmpty)
        .toSet()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    final initials = _teamInitials;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Activity',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: initials.map((initial) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE6EEF8),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Color(0xFF0B2E59),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TASKS COMPLETED',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$_completedTasks TOTAL',
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ACTIVE MEMBERS',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$_activeMembers MEMBERS',
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}