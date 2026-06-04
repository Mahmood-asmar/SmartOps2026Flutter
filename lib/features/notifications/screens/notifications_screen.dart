import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/notifications/widgets/notifications_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'notifications'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    title: 'Notifications',
                    onMenuTap: () => _openDrawer(context),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Notifications',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Communication center for project updates, tasks, and system activity.',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Mark as read'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B2E59),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.filter_list, size: 18),
                          label: const Text('Filters'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0B2E59),
                            side: const BorderSide(
                              color: Color(0xFF0B2E59),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  NotificationCard(
                    title: 'New Project Proposal',
                    message:
                        'Sky-Garden Phase II has been submitted for review. Please check the attached proposal.',
                    time: '12 min ago',
                    icon: Icons.assignment_outlined,
                    iconColor: Colors.blue.shade700,
                    isHighlighted: true,
                  ),

                  NotificationCard(
                    title: 'Task Completed',
                    message:
                        'The Site Topography Scan task was completed and added to project history.',
                    time: '1 hour ago',
                    icon: Icons.check_circle_outline,
                    iconColor: Colors.green.shade700,
                    isHighlighted: true,
                  ),

                  NotificationCard(
                    title: 'Meeting Reminder',
                    message:
                        'Quarterly architectural review with stakeholders starts in 30 minutes.',
                    time: 'Yesterday',
                    icon: Icons.calendar_month_outlined,
                    iconColor: Colors.grey.shade700,
                  ),

                  NotificationCard(
                    title: 'System Update',
                    message:
                        'SmartOps v2.4 is now live. Explore the new project chart visualizations.',
                    time: 'Oct 24, 2024',
                    icon: Icons.system_update_alt_outlined,
                    iconColor: Colors.blueGrey.shade700,
                  ),

                  const SizedBox(height: 18),

                  Container(
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
                          'OVERVIEW',
                          style: TextStyle(
                            color: Color(0xFFBFD4EA),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          '12',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pending actions',
                          style: TextStyle(
                            color: Color(0xFFD8E3F0),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 14),
                        LinearProgressIndicator(
                          value: 0.72,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF385274),
                          color: Colors.green.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Pinned Threads',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const NotificationCard(
                    title: 'Sky-Garden Phase II Submitted',
                    message: 'A new client request is awaiting admin review.',
                    time: '5h ago',
                    icon: Icons.push_pin_outlined,
                    iconColor: Color(0xFF2563EB),
                  ),

                  const NotificationCard(
                    title: 'Project Review Site Audit',
                    message: 'Initial project review is waiting for approval.',
                    time: '1d ago',
                    icon: Icons.push_pin_outlined,
                    iconColor: Color(0xFF16A34A),
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