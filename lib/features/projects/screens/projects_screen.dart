import 'package:flutter/material.dart';

import 'package:smartops/core/models/project_model.dart';
import 'package:smartops/core/services/project_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/projects/screens/project_details_screen.dart';
import 'package:smartops/features/projects/widgets/project_card.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final TextEditingController searchController = TextEditingController();

  List<ProjectModel> projects = [];
  bool isLoading = true;
  String errorMessage = '';

  String statusFilter = 'all';
  String priorityFilter = 'all';
  String sortBy = 'deadline';

  @override
  void initState() {
    super.initState();
    loadProjects();
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

  Future<void> loadProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await ProjectService.getProjects();

      if (!mounted) return;

      setState(() {
        projects = data
            .map(
              (item) => ProjectModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = _cleanErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<ProjectModel> get filteredProjects {
    final query = searchController.text.trim().toLowerCase();

    final filtered = projects.where((project) {
      final matchesSearch = query.isEmpty ||
          [
            project.projectId.toString(),
            project.name,
            project.description,
            project.category,
            project.clientName,
            project.templateName,
            project.status,
            project.priority,
            project.deadline,
          ].whereType<String>().join(' ').toLowerCase().contains(query);

      final matchesStatus =
          statusFilter == 'all' || project.status == statusFilter;

      final matchesPriority =
          priorityFilter == 'all' || project.priority == priorityFilter;

      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();

    filtered.sort((a, b) {
      if (sortBy == 'priority') {
        return _priorityRank(b.priority).compareTo(_priorityRank(a.priority));
      }

      if (sortBy == 'status') {
        return a.status.compareTo(b.status);
      }

      if (sortBy == 'name') {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
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

  int get activeCount {
    return projects
        .where((project) => project.status == 'in_progress')
        .length;
  }

  int get completedCount {
    return projects.where((project) => project.status == 'completed').length;
  }

  int get highPriorityCount {
    return projects.where((project) => project.priority == 'high').length;
  }

  void _goToDetails(ProjectModel project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectDetailsScreen(
          projectId: project.projectId,
          initialProject: project,
        ),
      ),
    );
  }

  void _resetFilters() {
    searchController.clear();

    setState(() {
      statusFilter = 'all';
      priorityFilter = 'all';
      sortBy = 'deadline';
    });
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

  Widget _buildMetrics() {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            title: 'TOTAL',
            value: '${projects.length}',
            icon: Icons.account_tree_outlined,
            color: const Color(0xFF0B2E59),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'ACTIVE',
            value: '$activeCount',
            icon: Icons.rocket_launch_outlined,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            title: 'HIGH',
            value: '$highPriorityCount',
            icon: Icons.priority_high,
            color: Colors.red.shade700,
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
            hintText: 'Search projects by name, client, category, status...',
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
              borderSide: const BorderSide(
                color: Color(0xFFE9EEF5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFFE9EEF5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF0B2E59),
              ),
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
                onTap: () {
                  setState(() {
                    statusFilter = 'all';
                  });
                },
              ),
              _FilterChipButton(
                label: 'Pending',
                active: statusFilter == 'pending',
                onTap: () {
                  setState(() {
                    statusFilter = 'pending';
                  });
                },
              ),
              _FilterChipButton(
                label: 'In Progress',
                active: statusFilter == 'in_progress',
                onTap: () {
                  setState(() {
                    statusFilter = 'in_progress';
                  });
                },
              ),
              _FilterChipButton(
                label: 'Completed',
                active: statusFilter == 'completed',
                onTap: () {
                  setState(() {
                    statusFilter = 'completed';
                  });
                },
              ),
              _FilterChipButton(
                label: 'Cancelled',
                active: statusFilter == 'cancelled',
                onTap: () {
                  setState(() {
                    statusFilter = 'cancelled';
                  });
                },
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
                values: const [
                  'all',
                  'low',
                  'medium',
                  'high',
                ],
                labelBuilder: (value) {
                  return value == 'all'
                      ? 'All Priorities'
                      : _formatLabel(value);
                },
                onChanged: (value) {
                  setState(() {
                    priorityFilter = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SmallSelect(
                value: sortBy,
                values: const [
                  'deadline',
                  'priority',
                  'status',
                  'name',
                ],
                labelBuilder: (value) {
                  return 'Sort: ${_formatLabel(value)}';
                },
                onChanged: (value) {
                  setState(() {
                    sortBy = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _resetFilters,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Color(0xFFE9EEF5),
                ),
              ),
              icon: const Icon(
                Icons.restart_alt,
              ),
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
          child: CircularProgressIndicator(
            color: Color(0xFF0B2E59),
          ),
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
          border: Border.all(
            color: Colors.red.shade100,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 38,
            ),
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
              onPressed: loadProjects,
              backgroundColor: Colors.red.shade700,
            ),
          ],
        ),
      );
    }

    if (filteredProjects.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFE9EEF5),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.folder_off_outlined,
              color: Color(0xFF98A2B3),
              size: 44,
            ),
            SizedBox(height: 12),
            Text(
              'No matching projects found',
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
      children: filteredProjects.map((project) {
        return ProjectCard(
          project: project,
          onTap: () => _goToDetails(project),
        );
      }).toList(),
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
            return RefreshIndicator(
              onRefresh: loadProjects,
              color: const Color(0xFF0B2E59),
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
                      title: 'Projects',
                      onMenuTap: () => _openDrawer(context),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Project Portfolio',
                      style: TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isLoading
                          ? 'Loading projects from database...'
                          : 'Managing ${projects.length} projects across active client workspaces.',
                      style: const TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildMetrics(),
                    const SizedBox(height: 18),
                    _buildSearchAndFilters(),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Text(
                          'Project Registry',
                          style: TextStyle(
                            color: Color(0xFF0B2E59),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filteredProjects.length} shown',
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
        border: Border.all(
          color: const Color(0xFFE9EEF5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
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
        side: const BorderSide(
          color: Color(0xFFE9EEF5),
        ),
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
        if (selected != null) {
          onChanged(selected);
        }
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
          borderSide: const BorderSide(
            color: Color(0xFFE9EEF5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE9EEF5),
          ),
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