import 'package:flutter/material.dart';

import 'package:smartops/core/models/task_model.dart';
import 'package:smartops/core/services/task_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/core/widgets/status_chip.dart';
import 'package:smartops/features/tasks/widgets/edit_task_sheet.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  late TaskModel task;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

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

  Future<void> _showEditTaskSheet() async {
    final updatedTask = await showModalBottomSheet<TaskModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTaskSheet(task: task),
    );

    if (updatedTask != null) {
      setState(() {
        task = updatedTask;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _markAsComplete() async {
    setState(() => isUpdating = true);

    try {
      await TaskService.updateTask(
        taskId: task.taskId,
        status: 'completed',
      );

      setState(() {
        task = task.copyWith(status: 'completed');
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task marked as complete.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanErrorMessage(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isUpdating = false);
      }
    }
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label.toUpperCase(),
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
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String time,
    required Color color,
  }) {
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

  @override
  Widget build(BuildContext context) {
    final assignedTo =
        task.assignedUserEmail ?? task.assignedUserName ?? 'Unassigned';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'tasks'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 16,
              ),
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

                        const SizedBox(height: 18),

                        Text(
                          task.title,
                          style: const TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            const Icon(
                              Icons.folder_copy_outlined,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.projectName ?? 'No project',
                                style: const TextStyle(
                                  color: Color(0xFF0B2E59),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        _buildInfoRow(
                          label: 'Assigned To',
                          value: assignedTo,
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 18),

                        _buildInfoRow(
                          label: 'Deadline',
                          value: _formatDate(task.deadline),
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
                          task.description,
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
                      onPressed: isUpdating ? null : _showEditTaskSheet,
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text(
                        'Edit Task',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B2E59),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: isUpdating || task.status == 'completed'
                          ? null
                          : _markAsComplete,
                      icon: isUpdating
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(
                        task.status == 'completed'
                            ? 'Task Completed'
                            : 'Mark as Complete',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0B2E59),
                        side: const BorderSide(color: Color(0xFFE4E7EC)),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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

                  _buildActivityItem(
                    title: 'Task loaded from SmartOps database',
                    time: 'LIVE DATA',
                    color: Colors.blue,
                  ),

                  _buildActivityItem(
                    title: 'Current status: ${_formatLabel(task.status)}',
                    time: 'NOW',
                    color: _statusColor(task.status),
                  ),

                  _buildActivityItem(
                    title: 'Priority: ${_formatLabel(task.priority)}',
                    time: 'NOW',
                    color: _priorityColor(task.priority),
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