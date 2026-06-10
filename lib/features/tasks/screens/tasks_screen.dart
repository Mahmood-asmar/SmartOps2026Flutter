import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/task_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/task_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/tasks/screens/task_details_screen.dart';
import 'package:smartops/features/tasks/widgets/assign_task_sheet.dart';
import 'package:smartops/features/tasks/widgets/export_report_sheet.dart';
import 'package:smartops/features/tasks/widgets/productivity_card.dart';
import 'package:smartops/features/tasks/widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TextEditingController searchController = TextEditingController();

  List<TaskModel> tasks = [];
  bool isLoading = true;
  String errorMessage = '';

  String statusFilter = 'all';
  String priorityFilter = 'all';
  String sortBy = 'deadline';

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> loadTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await TaskService.getTasks();

      setState(() {
        tasks = data
            .map(
              (item) => TaskModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      });
    } catch (error) {
      setState(() {
        errorMessage = _cleanErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  List<TaskModel> get filteredTasks {
    final query = searchController.text.trim().toLowerCase();

    final filtered = tasks.where((task) {
      final matchesSearch = query.isEmpty ||
          [
            task.taskId.toString(),
            task.title,
            task.description,
            task.projectName,
            task.assignedUserName,
            task.assignedUserEmail,
            task.status,
            task.priority,
            task.deadline,
          ].whereType<String>().join(' ').toLowerCase().contains(query);

      final matchesStatus =
          statusFilter == 'all' || task.status == statusFilter;

      final matchesPriority =
          priorityFilter == 'all' || task.priority == priorityFilter;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();

    filtered.sort((a, b) {
      if (sortBy == 'priority') {
        return _priorityRank(b.priority).compareTo(_priorityRank(a.priority));
      }

      if (sortBy == 'status') {
        return a.status.compareTo(b.status);
      }

      if (sortBy == 'title') {
        return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }

      final firstDate = DateTime.tryParse(a.deadline ?? '');
      final secondDate = DateTime.tryParse(b.deadline ?? '');

      if (firstDate == null && secondDate == null) return 0;
      if (firstDate == null) return 1;
      if (secondDate == null) return -1;

      return firstDate.compareTo(secondDate);
    });

    return filtered;
  }

  int _priorityRank(String priority) {
    if (priority == 'high') return 3;
    if (priority == 'medium') return 2;
    return 1;
  }

  int get pendingCount {
    return tasks.where((task) => task.status == 'pending').length;
  }

  int get inProgressCount {
    return tasks.where((task) => task.status == 'in_progress').length;
  }

  int get completedCount {
    return tasks.where((task) => task.status == 'completed').length;
  }

  double get completionRate {
    if (tasks.isEmpty) return 0;
    return completedCount / tasks.length;
  }

  String get completionLabel {
    return '${(completionRate * 100).round()}%';
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

  void _resetFilters() {
    searchController.clear();

    setState(() {
      statusFilter = 'all';
      priorityFilter = 'all';
      sortBy = 'deadline';
    });
  }

  void _showAssignTaskSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AssignTaskSheet(),
    );

    if (result == true) {
      await loadTasks();
    }
  }

  void _showExportReportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportReportSheet(tasks: tasks),
    );
  }

  void _goToDetails(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailsScreen(task: task),
      ),
    ).then((_) => loadTasks());
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

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not set';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildMetrics() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'TOTAL',
            value: '${tasks.length}',
            icon: Icons.checklist_outlined,
            color: const Color(0xFF0B2E59),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'PROGRESS',
            value: '$inProgressCount',
            icon: Icons.trending_up_outlined,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'DONE',
            value: '$completedCount',
            icon: Icons.task_alt_outlined,
            color: Colors.green.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search tasks by title, project, employee, status...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
              onPressed: () {
                searchController.clear();
                setState(() {});
              },
              icon: const Icon(Icons.close),
            )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF0B2E59)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterChipButton(
                label: 'All Status',
                active: statusFilter == 'all',
                onTap: () => setState(() => statusFilter = 'all'),
              ),
              _FilterChipButton(
                label: 'Pending',
                active: statusFilter == 'pending',
                onTap: () => setState(() => statusFilter = 'pending'),
              ),
              _FilterChipButton(
                label: 'In Progress',
                active: statusFilter == 'in_progress',
                onTap: () => setState(() => statusFilter = 'in_progress'),
              ),
              _FilterChipButton(
                label: 'Completed',
                active: statusFilter == 'completed',
                onTap: () => setState(() => statusFilter = 'completed'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SmallSelect(
                value: priorityFilter,
                values: const ['all', 'low', 'medium', 'high'],
                labelBuilder: (value) =>
                value == 'all' ? 'All Priorities' : _formatLabel(value),
                onChanged: (value) {
                  setState(() => priorityFilter = value);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SmallSelect(
                value: sortBy,
                values: const ['deadline', 'priority', 'status', 'title'],
                labelBuilder: (value) => 'Sort: ${_formatLabel(value)}',
                onChanged: (value) {
                  setState(() => sortBy = value);
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _resetFilters,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE9EEF5)),
              ),
              icon: const Icon(Icons.restart_alt),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF0B2E59)),
        ),
      );
    }

    if (errorMessage.isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 38),
            const SizedBox(height: 10),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            AppButton(
              text: 'Try Again',
              icon: Icons.refresh,
              onPressed: loadTasks,
              backgroundColor: Colors.red.shade700,
            ),
          ],
        ),
      );
    }

    if (filteredTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EEF5)),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.assignment_late_outlined,
              color: Color(0xFF98A2B3),
              size: 44,
            ),
            SizedBox(height: 12),
            Text(
              'No matching tasks found',
              style: TextStyle(
                color: Color(0xFF0B2E59),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Try changing your search text or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filteredTasks.map((task) {
        return TaskCard(
          task: task,
          onTap: () => _goToDetails(task),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bool isAdmin = authProvider.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'tasks'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: loadTasks,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTopBar(
                      title: 'Tasks',
                      onMenuTap: () => _openDrawer(context),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE9EEF5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tasks Overview',
                            style: TextStyle(
                              color: Color(0xFF0B2E59),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isLoading
                                ? 'Loading tasks from database...'
                                : 'You have ${tasks.length} tasks across active projects.',
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              if (isAdmin)
                                Expanded(
                                  child: AppButton(
                                    text: 'Assign Task',
                                    onPressed: () =>
                                        _showAssignTaskSheet(context),
                                  ),
                                ),
                              if (isAdmin) const SizedBox(width: 10),
                              Expanded(
                                child: AppButton(
                                  text: 'Export Report',
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    145,
                                    144,
                                    144,
                                  ),
                                  onPressed: () =>
                                      _showExportReportSheet(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    _buildMetrics(),

                    const SizedBox(height: 18),

                    ProductivityCard(
                      completionRate: completionRate,
                      completionLabel: completionLabel,
                    ),

                    const SizedBox(height: 22),

                    _buildSearchAndFilters(),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Text(
                          'Task Registry',
                          style: TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filteredTasks.length} shown',
                          style: const TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    _buildBody(),

                    const SizedBox(height: 28),

                    AppFooter(
                      text: 'Need help?',
                      actionText: 'Contact Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChipButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: active,
        label: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : const Color(0xFF0B2E59),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        selectedColor: const Color(0xFF0B2E59),
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xFFE9EEF5)),
        onSelected: (_) => onTap(),
      ),
    );
  }
}

class _SmallSelect extends StatelessWidget {
  final String value;
  final List<String> values;
  final String Function(String value) labelBuilder;
  final ValueChanged<String> onChanged;

  const _SmallSelect({
    required this.value,
    required this.values,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = values.contains(value) ? value : values.first;

    return DropdownButtonFormField<String>(
      value: safeValue,
      items: values
          .map(
            (item) => DropdownMenuItem(
          value: item,
          child: Text(
            labelBuilder(item),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      )
          .toList(),
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE9EEF5)),
        ),
      ),
      style: const TextStyle(
        color: Color(0xFF0B2E59),
        fontSize: 12,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}