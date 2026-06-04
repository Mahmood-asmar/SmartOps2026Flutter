import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/features/dashboard/widgets/ai_card.dart';
import 'package:smartops/features/dashboard/widgets/overview_card.dart';
import 'package:smartops/features/dashboard/widgets/recent_activity_tile.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'dashboard'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    title: 'SmartOps',
                    onMenuTap: () => _openDrawer(context),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome back, Alex.',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'System status is optimal. AI analysis suggests focusing on the Neo-Brutalist Plaza project today.',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const OverviewCard(
                    title: 'Total Projects',
                    value: '24',
                    icon: Icons.folder_copy_outlined,
                  ),
                  const SizedBox(height: 12),
                  const OverviewCard(
                    title: 'Tasks',
                    value: '142',
                    icon: Icons.checklist_outlined,
                  ),
                  const SizedBox(height: 12),
                  const OverviewCard(
                    title: 'Requests',
                    value: '12',
                    icon: Icons.assignment_outlined,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2E59),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Efficiency',
                          style: TextStyle(
                            color: Color(0xFFBFD4EA),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '94%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const AiCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RecentActivityTile(
                    project: 'Skyline Atrium',
                    task: 'Material Selection - Glass',
                    owner: 'Elena V.',
                    status: 'Complete',
                    statusColor: Colors.green.shade700,
                  ),
                  RecentActivityTile(
                    project: 'Park Avenue Loft',
                    task: 'Initial Load Calculations',
                    owner: 'Marcus K.',
                    status: 'In Progress',
                    statusColor: Colors.blue.shade700,
                  ),
                  RecentActivityTile(
                    project: 'Urban Library',
                    task: 'Acoustical Panel Design',
                    owner: 'Sarah J.',
                    status: 'Delayed',
                    statusColor: Colors.red.shade700,
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