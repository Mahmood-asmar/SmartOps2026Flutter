import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_text_field.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/features/projects/screens/project_details_screen.dart';
import 'package:smartops/features/projects/widgets/project_card.dart';
import 'package:smartops/features/projects/widgets/team_insight_card.dart';


class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void _goToDetails(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProjectDetailsScreen(),
      ),
    );
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
                    title: 'SmartOps',
                    onMenuTap: () => _openDrawer(context),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Project Portfolio',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Managing 24 active systems',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const AppTextField(
                    label: 'Search',
                    hint: 'Search operations...',
                    prefixIcon: Icons.search,
                  ),
                  
                  const SizedBox(height: 22),
                  ProjectCard(
                    title: 'Cloud Studio Infrastructure',
                    client: 'Global Stream Inc.',
                    priority: 'Critical',
                    priorityColor: Colors.red.shade700,
                    status: 'In Progress',
                    statusColor: Colors.blue.shade700,
                    deadline: 'Oct 24, 2026',
                    onTap: () => _goToDetails(context),
                  ),
                  ProjectCard(
                    title: 'Sustainable Data Hub',
                    client: 'Eco-Dynamics',
                    priority: 'Medium',
                    priorityColor: Colors.orange.shade700,
                    status: 'Stable',
                    statusColor: Colors.green.shade700,
                    deadline: 'Nov 12, 2026',
                    onTap: () => _goToDetails(context),
                  ),
                  ProjectCard(
                    title: 'Security Audit Alpha',
                    client: 'Shield Group',
                    priority: 'High',
                    priorityColor: Colors.deepOrange.shade700,
                    status: 'Review Required',
                    statusColor: Colors.orange.shade700,
                    deadline: 'Dec 02, 2026',
                    onTap: () => _goToDetails(context),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Team Insights',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TeamInsightCard(
                    title: 'Neural Network Phase 2',
                    subtitle: 'Integration of LLM processing units for architectural automation workflows.',
                    progress: '80%',
                    progressValue: 0.8,
                    progressColor: Colors.blue.shade700,
                  ),
                  TeamInsightCard(
                    title: 'API Gateway Upgrade',
                    subtitle: 'Securing internal endpoints with zero-trust architecture protocols.',
                    progress: '98%',
                    progressValue: 0.98,
                    progressColor: Colors.green.shade700,
                  ),
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