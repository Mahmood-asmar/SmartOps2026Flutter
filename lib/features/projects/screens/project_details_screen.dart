import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/core/widgets/status_chip.dart';
import 'package:smartops/features/projects/widgets/active_task_card.dart';
import 'package:smartops/features/projects/widgets/progress_card.dart';


class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key});

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'projects'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    title: 'Project Alpha',
                    onMenuTap: () => _openDrawer(context),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Project Alpha Zenith',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Project ID: SO-2024-587',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProgressCard(
                    title: 'Overall Completion',
                    value: '68%',
                    progressValue: 0.68,
                    color: Colors.blue.shade700,
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Priority',
                          style: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        StatusChip(
                          label: 'Critical Path',
                          color: Colors.red.shade700,
                        ),
                      ],
                    ),
                  ),
                  const ProgressCard(
                    title: 'Timeline Track',
                    value: 'Dec 12, 2026',
                    progressValue: 0.72,
                    color: Color(0xFF0B2E59),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Active Tasks',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ActiveTaskCard(
                    title: 'Architectural Blueprint Audit',
                    assignee: 'Assigned to Marcus Alpha',
                    status: 'Review',
                    statusColor: Colors.orange.shade700,
                  ),
                  ActiveTaskCard(
                    title: 'System Integration Testing',
                    assignee: 'Assigned to Sarah Jensen',
                    status: 'Progress',
                    statusColor: Colors.blue.shade700,
                  ),
                  ActiveTaskCard(
                    title: 'Final Compliance Check',
                    assignee: 'Assigned to David Ortiz',
                    status: 'Done',
                    statusColor: Colors.green.shade700,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2E59),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Template',
                          style: TextStyle(
                            color: Color(0xFFBFD4EA),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Enterprise Core v4.2',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Optimized for high-frequency collaboration and architectural automation workflows.',
                          style: TextStyle(
                            color: Color(0xFFD8E3F0),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
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