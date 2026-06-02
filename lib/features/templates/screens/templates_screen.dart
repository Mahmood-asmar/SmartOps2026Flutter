import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/templates/widgets/template_card.dart';

class TemplatesScreen extends StatelessWidget {
  final bool isClient;

  const TemplatesScreen({
    super.key,
    this.isClient = false,
  });

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'templates'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTopBar(
                    title: 'Templates',
                    onMenuTap: () => _openDrawer(context),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Project Templates',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isClient
                        ? 'Browse available project templates and request projects based on predefined structures.'
                        : 'System-wide architectural blueprints for automated operational scaling.',
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    text: isClient ? 'Request New Template' : 'Create Template',
                    icon: isClient ? Icons.add_comment_outlined : Icons.add,
                    onPressed: () {},
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: _TemplateMetric(
                            title: 'ACTIVE TEMPLATES',
                            value: '24',
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _TemplateMetric(
                            title: 'AVG EXECUTION',
                            value: '14 days',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Template Registry',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TemplateCard(
                    title: 'Commercial High-Rise V2',
                    description:
                        'Standardized structural framework for urban development.',
                    category: 'Architecture',
                    duration: '180 Days',
                    status: 'Verified',
                    statusColor: Colors.green.shade700,
                    isClient: isClient,
                  ),
                  TemplateCard(
                    title: 'Industrial Retrofit',
                    description:
                        'Facility conversion strategy for manufacturing legacy sites.',
                    category: 'Innovation',
                    duration: '90 Days',
                    status: 'Verified',
                    statusColor: Colors.green.shade700,
                    isClient: isClient,
                  ),
                  TemplateCard(
                    title: 'Urban Green Belt',
                    description:
                        'Sustainable urban ecosystem planning and zoning.',
                    category: 'Urban Planning',
                    duration: '220 Days',
                    status: 'Draft',
                    statusColor: Colors.orange.shade700,
                    isClient: isClient,
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

class _TemplateMetric extends StatelessWidget {
  final String title;
  final String value;

  const _TemplateMetric({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}