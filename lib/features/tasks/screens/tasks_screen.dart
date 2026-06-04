import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/tasks/widgets/filter_checkbox.dart';
import 'package:smartops/features/tasks/widgets/productivity_card.dart';
import 'package:smartops/features/tasks/widgets/task_card.dart';
import 'package:smartops/features/tasks/widgets/team_activity.dart';
import 'package:smartops/features/tasks/widgets/assign_task_sheet.dart';
import 'package:smartops/features/tasks/widgets/export_report_sheet.dart';
import 'package:smartops/features/tasks/screens/task_details_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  bool critical = true;
  bool high = true;
  bool medium = false;

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
  void _showAssignTaskSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AssignTaskSheet(),
  );
}

void _showExportReportSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ExportReportSheet(),
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
                    title: 'Tasks',
                    onMenuTap: () => _openDrawer(context),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tasks Overview',
                          style: TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'You have 12 tasks pending for this week.',
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                text: 'Assign Task',
                                onPressed: () => _showAssignTaskSheet(context) ,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton(
                                text: 'Export Report',
                                backgroundColor: const Color.fromARGB(255, 145, 144, 144),
                                onPressed: () => _showExportReportSheet(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const ProductivityCard(),

                  const SizedBox(height: 22),

                  const Text(
                    'Priority Filter',
                    style: TextStyle(
                      color: Color(0xFF98A2B3),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  FilterCheckbox(
                    title: 'Critical',
                    value: critical,
                    onChanged: (value) {
                      setState(() {
                        critical = value!;
                      });
                    },
                  ),

                  FilterCheckbox(
                    title: 'High',
                    value: high,
                    onChanged: (value) {
                      setState(() {
                        high = value!;
                      });
                    },
                  ),

                  FilterCheckbox(
                    title: 'Medium',
                    value: medium,
                    onChanged: (value) {
                      setState(() {
                        medium = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  const TeamActivity(),

                  const SizedBox(height: 22),

                  TaskCard(
                     title: 'Review architectural load-bearing calculations',
                      project: 'Neo-Brutalist Plaza',
                       status: 'In Progress',
                      statusColor: Colors.orange,
                      priority: 'Critical',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TaskDetailsScreen(
                              title: 'Review architectural load-bearing calculations',
                              project: 'Neo-Brutalist Plaza',
                              status: 'In Progress',
                              statusColor: Colors.orange,
                              priority: 'Critical',
                              priorityColor: Colors.red,
                              assignedUser: 'Jordan Smith',
                              deadline: 'Dec 20, 2026',
                              description:
                                  'Review architectural load-bearing calculations and verify compliance with structural requirements before final approval.',
                            ),
                          ),
                        );
                      },
                  ),

                  TaskCard(
                      title: 'Finalize structural assessment process',
                      project: 'SmartOps HQ',
                      status: 'Review',
                      statusColor: Colors.green,
                      priority: 'High',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TaskDetailsScreen(
                              title: 'Finalize structural assessment process',
                              project: 'SmartOps HQ',
                              status: 'Review',
                              statusColor: Colors.green,
                              priority: 'High',
                              priorityColor: Colors.red,
                              assignedUser: 'Sarah Johnson',
                              deadline: 'Jan 10, 2027',
                              description:
                                  'Finalize the structural assessment report and submit all findings for management review.',
                            ),
                          ),
                        );
                      },
                    ),

                    TaskCard(
                      title: 'Draft elevator scheduling revisions',
                      project: 'Crescent Tower',
                      status: 'Complete',
                      statusColor: Colors.blue,
                      priority: 'Medium',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TaskDetailsScreen(
                            title: 'Draft elevator scheduling revisions',
                              project: 'Crescent Tower',
                              status: 'Complete',
                              statusColor: Colors.blue,
                              priority: 'Medium',
                              priorityColor: Colors.orange,
                              assignedUser: 'Michael Brown',
                              deadline: 'Feb 01, 2027',
                              description:
                                  'Prepare updated elevator scheduling plans and optimize traffic flow during peak hours.',
                            ),
                         ),
                        );
                      },
                    ),

                  const SizedBox(height: 28),

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