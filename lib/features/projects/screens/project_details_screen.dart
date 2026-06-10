import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/ai_analysis_model.dart';
import 'package:smartops/core/models/project_model.dart';
import 'package:smartops/core/models/task_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/project_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/core/widgets/status_chip.dart';
import 'package:smartops/features/projects/widgets/active_task_card.dart';
import 'package:smartops/features/projects/widgets/ai_analysis_card.dart';
import 'package:smartops/features/projects/widgets/progress_card.dart';
import 'package:smartops/features/tasks/widgets/assign_task_sheet.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final int projectId;
  final ProjectModel? initialProject;

  const ProjectDetailsScreen({
    super.key,
    required this.projectId,
    this.initialProject,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  ProjectModel? project;
  List<TaskModel> projectTasks = [];

  AiAnalysisModel? aiAnalysis;
  bool isLoadingAiAnalysis = false;
  bool isGeneratingAiAnalysis = false;
  String aiAnalysisError = '';

  bool isLoading = true;
  String errorMessage = '';
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialProject != null) {
      project = widget.initialProject;
    }

    loadProjectDetails();
    loadAiAnalysis();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  Future<void> _openAssignTaskSheet() async {
    if (project == null) return;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AssignTaskSheet(
          initialProjectId: project!.projectId,
          initialProjectName: project!.name,
        );
      },
    );

    if (!mounted) return;

    if (created == true) {
      await loadProjectDetails();
      await loadAiAnalysis();
    }
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> loadProjectDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final authProvider = context.read<AuthProvider>();

      ProjectModel? loadedProject = widget.initialProject;
      List<TaskModel> loadedTasks = [];

      if (!authProvider.isClient) {
        final projectData = await ProjectService.getProjectDetails(
          widget.projectId,
        );

        loadedProject = ProjectModel.fromJson(projectData);
      }

      if (authProvider.isAdmin || authProvider.isEmployee) {
        final tasksData = await ProjectService.getTasks();

        loadedTasks = tasksData
            .map(
              (item) => TaskModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .where((task) => task.projectId == widget.projectId)
            .toList();
      }

      if (!mounted) return;

      setState(() {
        project = loadedProject;
        projectTasks = loadedTasks;
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

  Future<void> loadAiAnalysis() async {
    setState(() {
      isLoadingAiAnalysis = true;
      aiAnalysisError = '';
    });

    try {
      final loadedAnalysis = await ProjectService.getLatestProjectAiAnalysis(
        widget.projectId,
      );

      if (!mounted) return;

      setState(() {
        aiAnalysis = loadedAnalysis;
      });
    } catch (error) {
      if (!mounted) return;

      final message = _cleanErrorMessage(error);

      setState(() {
        if (message.toLowerCase().contains('not found') ||
            message.toLowerCase().contains('no ai analysis')) {
          aiAnalysis = null;
        } else {
          aiAnalysisError = message;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingAiAnalysis = false;
        });
      }
    }
  }

  Future<void> generateAiAnalysis() async {
    setState(() {
      isGeneratingAiAnalysis = true;
      aiAnalysisError = '';
    });

    try {
      final generatedAnalysis = await ProjectService.generateProjectAiAnalysis(
        widget.projectId,
      );

      if (!mounted) return;

      setState(() {
        aiAnalysis = generatedAnalysis;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI analysis generated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      final message = _cleanErrorMessage(error);

      setState(() {
        aiAnalysisError = message;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingAiAnalysis = false;
        });
      }
    }
  }

  double get completionRate {
    if (projectTasks.isEmpty) return 0;

    final completed = projectTasks
        .where((task) => task.status == 'completed')
        .length;

    return completed / projectTasks.length;
  }

  String get completionLabel {
    return '${(completionRate * 100).round()}%';
  }

  Color _priorityColor(String priority) {
    if (priority == 'high') return Colors.red.shade700;
    if (priority == 'medium') return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  Color _statusColor(String status) {
    if (status == 'completed') return Colors.green.shade700;
    if (status == 'in_progress') return Colors.blue.shade700;
    if (status == 'cancelled') return Colors.red.shade700;
    return Colors.orange.shade700;
  }

  String _formatLabel(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    }).join(' ');
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not set';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _updateProject({
    String? status,
    String? priority,
  }) async {
    if (project == null) return;

    setState(() {
      isUpdating = true;
    });

    try {
      await ProjectService.updateProject(
        projectId: project!.projectId,
        status: status,
        priority: priority,
      );

      setState(() {
        project = project!.copyWith(
          status: status,
          priority: priority,
        );
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project updated successfully.'),
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
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  double _timelineProgress(ProjectModel item) {
    if (item.status == 'completed') return 1;
    if (item.status == 'in_progress') return 0.65;
    if (item.status == 'cancelled') return 0.15;
    return 0.3;
  }

  bool _canAddTask(ProjectModel item) {
    final authProvider = context.read<AuthProvider>();

    return authProvider.isAdmin &&
        item.status != 'completed' &&
        item.status != 'cancelled';
  }

  Widget _buildLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.only(top: 80),
        child: CircularProgressIndicator(
          color: Color(0xFF0B2E59),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Container(
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
              errorMessage.isEmpty
                  ? 'Unable to load project details.'
                  : errorMessage,
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
              onPressed: loadProjectDetails,
              backgroundColor: Colors.red.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader(ProjectModel item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Project ID: ${item.projectId}',
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          item.description,
          style: const TextStyle(
            color: Color(0xFF667085),
            fontSize: 13,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminControls(ProjectModel item) {
    final authProvider = context.watch<AuthProvider>();

    if (!authProvider.isAdmin) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
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
          const Text(
            'ADMIN CONTROLS',
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SmallSelect(
                  value: item.status,
                  values: const [
                    'pending',
                    'in_progress',
                    'completed',
                    'cancelled',
                  ],
                  labelBuilder: _formatLabel,
                  onChanged: isUpdating
                      ? null
                      : (value) => _updateProject(status: value),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallSelect(
                  value: item.priority,
                  values: const [
                    'low',
                    'medium',
                    'high',
                  ],
                  labelBuilder: _formatLabel,
                  onChanged: isUpdating
                      ? null
                      : (value) => _updateProject(priority: value),
                ),
              ),
            ],
          ),
          if (isUpdating) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              color: Color(0xFF0B2E59),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoPanel(ProjectModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9EEF5),
        ),
      ),
      child: Column(
        children: [
          _InfoRow(
            label: 'Client',
            value: item.clientName ?? 'No client',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Category',
            value: item.category,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Template',
            value: item.templateName ?? 'No template',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Start Date',
            value: _formatDate(item.startDate),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Deadline',
            value: _formatDate(item.deadline),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Created By',
            value: item.createdByName ?? 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityStatus(ProjectModel item) {
    return Row(
      children: [
        Expanded(
          child: _StatusBlock(
            title: 'Priority',
            label: _formatLabel(item.priority),
            color: _priorityColor(item.priority),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatusBlock(
            title: 'Status',
            label: _formatLabel(item.status),
            color: _statusColor(item.status),
          ),
        ),
      ],
    );
  }

  Widget _buildTasks() {
    if (projectTasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
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
              Icons.task_alt_outlined,
              color: Color(0xFF98A2B3),
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'No active tasks yet',
              style: TextStyle(
                color: Color(0xFF0B2E59),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Tasks assigned to this project will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF667085),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: projectTasks.map((task) {
        return ActiveTaskCard(
          title: task.title,
          assignee: task.assignedUserEmail != null
              ? 'Assigned to ${task.assignedUserEmail}'
              : 'Assigned to ${task.assignedUserName ?? 'Unknown'}',
          status: _formatLabel(task.status),
          statusColor: _statusColor(task.status),
        );
      }).toList(),
    );
  }

  Widget _buildTemplatePanel(ProjectModel item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2E59),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Active Template',
            style: TextStyle(
              color: Color(0xFFBFD4EA),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.templateName ?? 'No template',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.templateName == null
                ? 'This project was created without a predefined template.'
                : 'This project is based on a reusable SmartOps project template.',
            style: const TextStyle(
              color: Color(0xFFD8E3F0),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = project;
    final authProvider = context.watch<AuthProvider>();
    final canViewTasks = authProvider.isAdmin || authProvider.isEmployee;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'projects'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: () async {
                await loadProjectDetails();
                await loadAiAnalysis();
              },
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
                      title: 'Project Details',
                      onMenuTap: () => _openDrawer(context),
                    ),
                    const SizedBox(height: 20),
                    if (isLoading)
                      _buildLoading()
                    else if (errorMessage.isNotEmpty)
                      _buildError()
                    else if (item == null)
                        _buildError()
                      else ...[
                          _buildProjectHeader(item),
                          const SizedBox(height: 18),
                          ProgressCard(
                            title: canViewTasks
                                ? 'Overall Completion'
                                : 'Timeline Progress',
                            value: canViewTasks
                                ? completionLabel
                                : _formatLabel(item.status),
                            progressValue: canViewTasks
                                ? completionRate
                                : _timelineProgress(item),
                            color: Colors.blue.shade700,
                          ),
                          AiAnalysisCard(
                            analysis: aiAnalysis,
                            isLoading: isLoadingAiAnalysis,
                            isGenerating: isGeneratingAiAnalysis,
                            errorMessage: aiAnalysisError,
                            onGenerate: generateAiAnalysis,
                            onRefresh: loadAiAnalysis,
                          ),
                          _buildPriorityStatus(item),
                          const SizedBox(height: 14),
                          _buildAdminControls(item),
                          _buildInfoPanel(item),
                          ProgressCard(
                            title: 'Timeline Track',
                            value: _formatDate(item.deadline),
                            progressValue: _timelineProgress(item),
                            color: const Color(0xFF0B2E59),
                          ),
                          if (canViewTasks) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Active Tasks',
                                    style: TextStyle(
                                      color: Color(0xFF0B2E59),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (_canAddTask(item))
                                  TextButton.icon(
                                    onPressed: _openAssignTaskSheet,
                                    icon: const Icon(
                                      Icons.add_task_outlined,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Add Task',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF0B2E59),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildTasks(),
                            const SizedBox(height: 16),
                          ],
                          _buildTemplatePanel(item),
                        ],
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

class _StatusBlock extends StatelessWidget {
  final String title;
  final String label;
  final Color color;

  const _StatusBlock({
    required this.title,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 14),
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
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          StatusChip(
            label: label,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallSelect extends StatelessWidget {
  final String value;
  final List<String> values;
  final String Function(String value) labelBuilder;
  final ValueChanged<String>? onChanged;

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
      onChanged: onChanged == null
          ? null
          : (selected) {
        if (selected != null) {
          onChanged!(selected);
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