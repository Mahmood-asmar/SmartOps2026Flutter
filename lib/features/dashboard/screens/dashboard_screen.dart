import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/notification_model.dart';
import 'package:smartops/core/models/project_model.dart';
import 'package:smartops/core/models/project_request_model.dart';
import 'package:smartops/core/models/task_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/notification_service.dart';
import 'package:smartops/core/services/project_service.dart';
import 'package:smartops/core/services/request_service.dart';
import 'package:smartops/core/services/task_service.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/core/widgets/status_chip.dart';
import 'package:smartops/features/dashboard/widgets/ai_card.dart';
import 'package:smartops/features/dashboard/widgets/overview_card.dart';
import 'package:smartops/features/dashboard/widgets/recent_activity_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ProjectModel> projects = [];
  List<TaskModel> tasks = [];
  List<ProjectRequestModel> requests = [];
  List<NotificationModel> notifications = [];

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadDashboardData();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> loadDashboardData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final authProvider = context.read<AuthProvider>();

      final isAdmin = authProvider.isAdmin;
      final isEmployee = authProvider.isEmployee;
      final isClient = authProvider.isClient;

      List<ProjectModel> loadedProjects = [];
      List<TaskModel> loadedTasks = [];
      List<ProjectRequestModel> loadedRequests = [];
      List<NotificationModel> loadedNotifications = [];

      try {
        final projectsData = await ProjectService.getProjects();

        loadedProjects = projectsData
            .map(
              (item) => ProjectModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      } catch (_) {
        loadedProjects = [];
      }

      if (isAdmin || isEmployee) {
        try {
          final tasksData = await TaskService.getTasks();

          loadedTasks = tasksData
              .map(
                (item) => TaskModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();
        } catch (_) {
          loadedTasks = [];
        }
      }

      if (isAdmin || isClient) {
        try {
          final requestsData = await RequestService.getProjectRequests();

          loadedRequests = requestsData
              .map(
                (item) => ProjectRequestModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
              .toList();
        } catch (_) {
          loadedRequests = [];
        }
      }

      try {
        final notificationsData = await NotificationService.getNotifications();

        loadedNotifications = notificationsData
            .map(
              (item) => NotificationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      } catch (_) {
        loadedNotifications = [];
      }

      loadedTasks.sort((a, b) {
        final aDate = DateTime.tryParse(a.deadline ?? '');
        final bDate = DateTime.tryParse(b.deadline ?? '');

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      });

      if (!mounted) return;

      setState(() {
        projects = loadedProjects;
        tasks = loadedTasks;
        requests = loadedRequests;
        notifications = loadedNotifications;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = _cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  int get totalProjects => projects.length;

  int get activeProjects {
    return projects.where((project) => project.status == 'in_progress').length;
  }

  int get completedProjects {
    return projects.where((project) => project.status == 'completed').length;
  }

  int get totalTasks => tasks.length;

  int get completedTasks {
    return tasks.where((task) => task.status == 'completed').length;
  }

  int get pendingTasks {
    return tasks.where((task) => task.status == 'pending').length;
  }

  int get inProgressTasks {
    return tasks.where((task) => task.status == 'in_progress').length;
  }

  int get pendingRequests {
    return requests.where((request) => request.status == 'pending').length;
  }

  int get unreadNotifications {
    return notifications.where((notification) => !notification.isRead).length;
  }

  int get overdueTasks {
    final today = DateTime.now();

    return tasks.where((task) {
      final deadline = DateTime.tryParse(task.deadline ?? '');

      if (deadline == null) return false;
      if (task.status == 'completed') return false;

      return deadline.isBefore(
        DateTime(today.year, today.month, today.day),
      );
    }).length;
  }

  int get completionRate {
    if (totalTasks == 0) return 0;

    return ((completedTasks / totalTasks) * 100).round();
  }

  List<TaskModel> get recentTasks {
    final sortedTasks = [...tasks];

    sortedTasks.sort((a, b) {
      final aDate = DateTime.tryParse(a.deadline ?? '');
      final bDate = DateTime.tryParse(b.deadline ?? '');

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return aDate.compareTo(bDate);
    });

    return sortedTasks.take(4).toList();
  }

  List<TaskModel> get upcomingDeadlines {
    final now = DateTime.now();

    final filtered = tasks.where((task) {
      final deadline = DateTime.tryParse(task.deadline ?? '');

      if (deadline == null) return false;
      if (task.status == 'completed') return false;

      return !deadline.isBefore(DateTime(now.year, now.month, now.day));
    }).toList();

    filtered.sort((a, b) {
      final aDate = DateTime.tryParse(a.deadline ?? '');
      final bDate = DateTime.tryParse(b.deadline ?? '');

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return aDate.compareTo(bDate);
    });

    return filtered.take(3).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green.shade700;
      case 'in_progress':
        return Colors.blue.shade700;
      case 'pending':
        return Colors.orange.shade700;
      case 'cancelled':
        return Colors.red.shade700;
      default:
        return Colors.blueGrey.shade700;
    }
  }

  String _formatStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    })
        .join(' ');
  }

  String _dashboardSubtitle({
    required bool isAdmin,
    required bool isEmployee,
    required bool isClient,
  }) {
    if (isAdmin) {
      return 'System overview is based on live projects, tasks, requests, and notifications.';
    }

    if (isEmployee) {
      return 'Track assigned tasks, upcoming deadlines, and recent activity from your workspace.';
    }

    if (isClient) {
      return 'Monitor your projects, submitted requests, and latest updates in one place.';
    }

    return 'Live operational overview from SmartOps workspace.';
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 90),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF0B2E59),
        ),
      ),
    );
  }

  Widget _buildError() {
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
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
            size: 42,
          ),
          const SizedBox(height: 12),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: loadDashboardData,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEfficiencyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2E59),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EFFICIENCY',
            style: TextStyle(
              color: Color(0xFFBFD4EA),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$completionRate%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: completionRate / 100,
            minHeight: 7,
            backgroundColor: const Color(0xFF385274),
            color: Colors.green.shade400,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 10),
          Text(
            '$completedTasks of $totalTasks tasks completed',
            style: const TextStyle(
              color: Color(0xFFD8E3F0),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingDeadlines() {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isClient) {
      final clientDeadlines = projects.where((project) {
        final deadline = DateTime.tryParse(project.deadline ?? '');

        if (deadline == null) return false;
        if (project.status == 'completed') return false;
        if (project.status == 'cancelled') return false;

        final now = DateTime.now();

        return !deadline.isBefore(
          DateTime(now.year, now.month, now.day),
        );
      }).toList();

      clientDeadlines.sort((a, b) {
        final aDate = DateTime.tryParse(a.deadline ?? '');
        final bDate = DateTime.tryParse(b.deadline ?? '');

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return aDate.compareTo(bDate);
      });

      final items = clientDeadlines.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Deadlines',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const _EmptyDashboardCard(
              icon: Icons.event_available_outlined,
              title: 'No upcoming deadlines',
              subtitle: 'Your active project deadlines will appear here.',
            )
          else
            Column(
              children: items.map((project) {
                return _ProjectDeadlineCard(
                  project: project,
                  statusColor: _statusColor(project.status),
                  statusLabel: _formatStatus(project.status),
                );
              }).toList(),
            ),
        ],
      );
    }

    final deadlines = upcomingDeadlines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Deadlines',
          style: TextStyle(
            color: Color(0xFF0B2E59),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (deadlines.isEmpty)
          const _EmptyDashboardCard(
            icon: Icons.event_available_outlined,
            title: 'No upcoming deadlines',
            subtitle: 'There are no active task deadlines right now.',
          )
        else
          Column(
            children: deadlines.map((task) {
              return _DeadlineCard(
                task: task,
                statusColor: _statusColor(task.status),
                statusLabel: _formatStatus(task.status),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.isClient) {
      final recentRequests = [...requests];

      recentRequests.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '');
        final bDate = DateTime.tryParse(b.createdAt ?? '');

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      final items = recentRequests.take(4).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const _EmptyDashboardCard(
              icon: Icons.history_outlined,
              title: 'No recent activity',
              subtitle: 'Your submitted project requests will appear here.',
            )
          else
            Column(
              children: items.map((request) {
                return _RequestActivityCard(
                  request: request,
                  statusColor: _statusColor(request.status),
                  statusLabel: _formatStatus(request.status),
                );
              }).toList(),
            ),
        ],
      );
    }

    final recent = recentTasks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            color: Color(0xFF0B2E59),
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          const _EmptyDashboardCard(
            icon: Icons.history_outlined,
            title: 'No recent activity',
            subtitle: 'Recent task updates will appear here.',
          )
        else
          Column(
            children: recent.map((task) {
              return RecentActivityTile(
                project: task.projectName ?? 'Unknown Project',
                task: task.title,
                owner: task.assignedUserName ??
                    task.assignedUserEmail ??
                    'Unassigned',
                status: _formatStatus(task.status),
                statusColor: _statusColor(task.status),
              );
            }).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final userName = authProvider.userName.trim().isEmpty
        ? 'User'
        : authProvider.userName.trim();

    final isAdmin = authProvider.isAdmin;
    final isEmployee = authProvider.isEmployee;
    final isClient = authProvider.isClient;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'dashboard'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              color: const Color(0xFF0B2E59),
              onRefresh: loadDashboardData,
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
                      title: 'SmartOps',
                      onMenuTap: () => _openDrawer(context),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome back, $userName.',
                      style: const TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _dashboardSubtitle(
                        isAdmin: isAdmin,
                        isEmployee: isEmployee,
                        isClient: isClient,
                      ),
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      _buildLoading()
                    else if (errorMessage.isNotEmpty)
                      _buildError()
                    else ...[
                        OverviewCard(
                          title: 'Total Projects',
                          value: '$totalProjects',
                          icon: Icons.folder_copy_outlined,
                        ),
                        const SizedBox(height: 12),
                        OverviewCard(
                          title: 'Active Projects',
                          value: '$activeProjects',
                          icon: Icons.trending_up_outlined,
                        ),
                        const SizedBox(height: 12),
                        OverviewCard(
                          title: 'Tasks',
                          value: '$totalTasks',
                          icon: Icons.checklist_outlined,
                        ),
                        const SizedBox(height: 12),
                        if (isAdmin || isClient)
                          OverviewCard(
                            title: 'Pending Requests',
                            value: '$pendingRequests',
                            icon: Icons.assignment_outlined,
                          ),
                        if (isAdmin || isClient) const SizedBox(height: 12),
                        OverviewCard(
                          title: 'Unread Notifications',
                          value: '$unreadNotifications',
                          icon: Icons.notifications_none,
                        ),
                        const SizedBox(height: 12),
                        _buildEfficiencyCard(),
                        const SizedBox(height: 24),
                        AiCard(
                          overdueTasks: overdueTasks,
                          pendingRequests: pendingRequests,
                          completionRate: completionRate,
                          activeProjects: activeProjects,
                        ),
                        const SizedBox(height: 24),
                        _buildUpcomingDeadlines(),
                        const SizedBox(height: 24),
                        _buildRecentActivity(),
                      ],
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

class _DeadlineCard extends StatelessWidget {
  final TaskModel task;
  final Color statusColor;
  final String statusLabel;

  const _DeadlineCard({
    required this.task,
    required this.statusColor,
    required this.statusLabel,
  });

  String _formatDeadline(String? value) {
    if (value == null || value.trim().isEmpty) return 'No deadline';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            task.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            task.projectName ?? 'Unknown Project',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF98A2B3),
                size: 15,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatDeadline(task.deadline),
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusChip(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProjectDeadlineCard extends StatelessWidget {
  final ProjectModel project;
  final Color statusColor;
  final String statusLabel;

  const _ProjectDeadlineCard({
    required this.project,
    required this.statusColor,
    required this.statusLabel,
  });

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'No deadline';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            project.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF98A2B3),
                size: 15,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _formatDate(project.deadline),
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              StatusChip(
                label: statusLabel,
                color: statusColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RequestActivityCard extends StatelessWidget {
  final ProjectRequestModel request;
  final Color statusColor;
  final String statusLabel;

  const _RequestActivityCard({
    required this.request,
    required this.statusColor,
    required this.statusLabel,
  });

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'No date';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            request.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          _InfoLine(
            label: 'CATEGORY',
            value: request.category,
          ),
          const SizedBox(height: 8),
          _InfoLine(
            label: 'SUBMITTED',
            value: _formatDate(request.createdAt),
          ),
          const SizedBox(height: 10),
          StatusChip(
            label: statusLabel,
            color: statusColor,
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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


class _EmptyDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyDashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF98A2B3),
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}