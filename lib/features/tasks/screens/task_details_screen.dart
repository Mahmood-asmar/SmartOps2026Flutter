import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/core/widgets/status_chip.dart';
import 'package:smartops/features/tasks/widgets/edit_task_sheet.dart';

class TaskDetailsScreen extends StatelessWidget {
  final String title;
  final String project;
  final String status;
  final Color statusColor;
  final String priority;
  final Color priorityColor;
  final String assignedUser;
  final String deadline;
  final String description;

  const TaskDetailsScreen({
    super.key,
    required this.title,
    required this.project,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.priorityColor,
    required this.assignedUser,
    required this.deadline,
    required this.description,
  });

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void _showEditTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTaskSheet(
        title: title,
        description: description,
        assignedUser: assignedUser,
        deadline: deadline,
        priority: priority,
        status: status,
      ),
    );
  }

  void _markAsComplete(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task marked as complete'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'tasks'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    title: 'Task Details',
                    onMenuTap: () => _openDrawer(context),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Task Details',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'View task information and update task progress.',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusChip(
                              label: priority,
                              color: priorityColor,
                            ),
                            const SizedBox(width: 8),
                            StatusChip(
                              label: status,
                              color: statusColor,
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Text(
                          title,
                          style: const TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _IconInfoRow(
                          icon: Icons.folder_copy_outlined,
                          value: project,
                        ),

                        const SizedBox(height: 24),

                        _DetailRow(
                          label: 'ASSIGNED TO',
                          value: assignedUser,
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 18),

                        _DetailRow(
                          label: 'DEADLINE',
                          value: deadline,
                          icon: Icons.calendar_today_outlined,
                        ),

                        const SizedBox(height: 22),

                        const Text(
                          'DESCRIPTION',
                          style: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          description,
                          style: const TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () => _showEditTaskSheet(context),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(
                        'Edit Task',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B2E59),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _markAsComplete(context),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(
                        'Mark as Complete',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B2E59),
                        side: const BorderSide(color: Color(0xFFE4E7EC)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 34),

                  const Text(
                    'RECENT TASK ACTIVITY',
                    style: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _ActivityItem(
                    title: 'Task assigned to Jordan Smith',
                    time: '2 HOURS AGO',
                    color: Colors.blue,
                  ),

                  const _ActivityItem(
                    title: 'Priority changed to Critical',
                    time: '4 HOURS AGO',
                    color: Colors.red,
                  ),

                  const _ActivityItem(
                    title: 'Deadline updated to Dec 20, 2026',
                    time: 'YESTERDAY',
                    color: Color(0xFFCBD5E1),
                  ),

                  const SizedBox(height: 24),

                  AppFooter(
                    text: 'Need help?',
                    actionText: 'Contact Support',
                    onTap: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _IconInfoRow({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF2563EB),
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        Icon(
          icon,
          color: const Color(0xFF0B2E59),
          size: 17,
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String title;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.title,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 17,
            height: 17,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color,
                width: 3,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                  time,
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}