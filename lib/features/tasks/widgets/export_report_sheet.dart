import 'package:flutter/material.dart';

import 'package:smartops/core/models/app_user_model.dart';
import 'package:smartops/core/models/project_model.dart';
import 'package:smartops/core/models/task_model.dart';
import 'package:smartops/core/services/project_service.dart';
import 'package:smartops/core/services/report_service.dart';
import 'package:smartops/core/services/user_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/searchable_picker_field.dart';

class ExportReportSheet extends StatefulWidget {
  final List<TaskModel> tasks;

  const ExportReportSheet({
    super.key,
    required this.tasks,
  });

  @override
  State<ExportReportSheet> createState() => _ExportReportSheetState();
}

class _ExportReportSheetState extends State<ExportReportSheet> {
  String selectedFormat = 'PDF';
  String selectedReportType = 'task_report';

  int? selectedProjectId;

  List<ProjectModel> projects = [];
  List<AppUserModel> employees = [];

  bool isLoadingProjects = true;
  bool isGenerating = false;

  bool completedTasks = true;
  bool pendingTasks = true;
  bool inProgressTasks = true;
  bool employeePerformance = true;
  bool projectDeadlines = true;
  bool priorityDistribution = true;

  String? startDate;
  String? endDate;

  @override
  void initState() {
    super.initState();
    loadProjectsAndEmployees();
  }

  Future<void> loadProjectsAndEmployees() async {
    try {
      final projectsData = await ProjectService.getProjects();
      final usersData = await UserService.getUsers();

      final loadedProjects = projectsData
          .map(
            (item) => ProjectModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      final loadedEmployees = usersData
          .map(
            (item) => AppUserModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .where((user) => user.role == 'employee')
          .toList();

      final uniqueProjectsMap = <int, ProjectModel>{};
      for (final project in loadedProjects) {
        uniqueProjectsMap[project.projectId] = project;
      }

      final uniqueEmployeesMap = <int, AppUserModel>{};
      for (final employee in loadedEmployees) {
        uniqueEmployeesMap[employee.userId] = employee;
      }

      if (!mounted) return;

      setState(() {
        projects = uniqueProjectsMap.values.toList();
        employees = uniqueEmployeesMap.values.toList();
        isLoadingProjects = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        projects = [];
        employees = [];
        isLoadingProjects = false;
      });
    }
  }

  List<TaskModel> get filteredTasks {
    return widget.tasks.where((task) {
      final matchesProject =
          selectedProjectId == null || task.projectId == selectedProjectId;

      final deadline = DateTime.tryParse(task.deadline ?? '');

      final matchesStart = startDate == null ||
          deadline == null ||
          !deadline.isBefore(DateTime.parse(startDate!));

      final matchesEnd = endDate == null ||
          deadline == null ||
          !deadline.isAfter(DateTime.parse(endDate!));

      return matchesProject && matchesStart && matchesEnd;
    }).toList();
  }

  int get totalTasks => filteredTasks.length;

  int get completedCount {
    return filteredTasks.where((task) => task.status == 'completed').length;
  }

  int get pendingCount {
    return filteredTasks.where((task) => task.status == 'pending').length;
  }

  int get inProgressCount {
    return filteredTasks.where((task) => task.status == 'in_progress').length;
  }

  int get highPriorityCount {
    return filteredTasks.where((task) => task.priority == 'high').length;
  }

  int get mediumPriorityCount {
    return filteredTasks.where((task) => task.priority == 'medium').length;
  }

  int get lowPriorityCount {
    return filteredTasks.where((task) => task.priority == 'low').length;
  }

  int get overdueCount {
    final now = DateTime.now();

    return filteredTasks.where((task) {
      final deadline = DateTime.tryParse(task.deadline ?? '');

      if (deadline == null) return false;
      if (task.status == 'completed') return false;

      return deadline.isBefore(DateTime(now.year, now.month, now.day));
    }).length;
  }

  int get uniqueProjects {
    if (selectedProjectId != null) {
      return 1;
    }

    return projects.length;
  }

  int get uniqueEmployees {
    if (selectedProjectId == null) {
      return employees.length;
    }

    final employeesSet = filteredTasks
        .map((task) {
      if (task.assignedUser != null) {
        return 'id:${task.assignedUser}';
      }

      final email = task.assignedUserEmail?.trim();
      if (email != null && email.isNotEmpty) {
        return 'email:$email';
      }

      final name = task.assignedUserName?.trim();
      if (name != null && name.isNotEmpty) {
        return 'name:$name';
      }

      return null;
    })
        .whereType<String>()
        .toSet();

    return employeesSet.length;
  }

  int get completionRate {
    if (totalTasks == 0) return 0;

    return ((completedCount / totalTasks) * 100).round();
  }

  String get reportTypeLabel {
    switch (selectedReportType) {
      case 'task_report':
        return 'Task Report';
      case 'project_report':
        return 'Project Report';
      case 'employee_performance':
        return 'Employee Performance Report';
      case 'deadline_report':
        return 'Deadline Report';
      default:
        return 'Task Report';
    }
  }

  ProjectModel? _findProjectById(int? projectId) {
    if (projectId == null) return null;

    for (final project in projects) {
      if (project.projectId == projectId) {
        return project;
      }
    }

    return null;
  }

  Future<void> _pickDate({
    required bool isStart,
  }) async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0B2E59),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0B2E59),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final formattedDate =
        '${pickedDate.year.toString().padLeft(4, '0')}-'
        '${pickedDate.month.toString().padLeft(2, '0')}-'
        '${pickedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      if (isStart) {
        startDate = formattedDate;
      } else {
        endDate = formattedDate;
      }
    });
  }

  Future<void> _generateReport() async {
    if (isGenerating) return;

    final selectedProject = _findProjectById(selectedProjectId);

    final projectLabel = selectedProject == null
        ? 'All Projects'
        : '${selectedProject.name} - ID: ${selectedProject.projectId}';

    final dateRange = startDate == null && endDate == null
        ? 'All Dates'
        : '${startDate ?? 'Start'} → ${endDate ?? 'End'}';

    setState(() {
      isGenerating = true;
    });

    try {
      if (selectedFormat == 'PDF') {
        await ReportService.generatePdfReport(
          reportType: reportTypeLabel,
          reportFormat: selectedFormat,
          projectLabel: projectLabel,
          dateRange: dateRange,
          tasks: filteredTasks,
          totalTasks: totalTasks,
          completedCount: completedCount,
          pendingCount: pendingCount,
          inProgressCount: inProgressCount,
          overdueCount: overdueCount,
          highPriorityCount: highPriorityCount,
          mediumPriorityCount: mediumPriorityCount,
          lowPriorityCount: lowPriorityCount,
          completionRate: completionRate,
          projectsCount: uniqueProjects,
          employeesCount: uniqueEmployees,
        );
      } else {
        await ReportService.generateExcelReport(
          reportType: reportTypeLabel,
          projectLabel: projectLabel,
          dateRange: dateRange,
          tasks: filteredTasks,
          totalTasks: totalTasks,
          completedCount: completedCount,
          pendingCount: pendingCount,
          inProgressCount: inProgressCount,
          overdueCount: overdueCount,
          highPriorityCount: highPriorityCount,
          mediumPriorityCount: mediumPriorityCount,
          lowPriorityCount: lowPriorityCount,
          completionRate: completionRate,
          projectsCount: uniqueProjects,
          employeesCount: uniqueEmployees,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$selectedFormat report generated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHeader(
            title: 'Export Reports',
            subtitle: 'Generate task performance reports from live data.',
          ),
          const SizedBox(height: 20),
          _ReportTypeDropdown(
            selectedReportType: selectedReportType,
            onChanged: (value) {
              setState(() {
                selectedReportType = value;
              });
            },
          ),
          const SizedBox(height: 14),
          _ProjectSelectionDropdown(
            selectedProjectId: selectedProjectId,
            projects: projects,
            isLoading: isLoadingProjects,
            onChanged: (value) {
              setState(() {
                selectedProjectId = value;
              });
            },
          ),
          const SizedBox(height: 14),
          const Text(
            'DATE RANGE',
            style: TextStyle(
              color: Color(0xFF253B56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _DateBox(
                  text: startDate ?? 'Start Date',
                  onTap: () => _pickDate(isStart: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DateBox(
                  text: endDate ?? 'End Date',
                  onTap: () => _pickDate(isStart: false),
                ),
              ),
            ],
          ),
          if (startDate != null || endDate != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    startDate = null;
                    endDate = null;
                  });
                },
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Clear dates'),
              ),
            ),
          ],
          const SizedBox(height: 18),
          const Text(
            'REPORT FORMAT',
            style: TextStyle(
              color: Color(0xFF253B56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _FormatOption(
            title: 'Adobe PDF',
            subtitle: 'Best for presentations',
            icon: Icons.picture_as_pdf_outlined,
            color: Colors.red,
            isSelected: selectedFormat == 'PDF',
            onTap: () {
              setState(() {
                selectedFormat = 'PDF';
              });
            },
          ),
          const SizedBox(height: 10),
          _FormatOption(
            title: 'Excel Spreadsheet',
            subtitle: 'Best for data analysis',
            icon: Icons.table_chart_outlined,
            color: Colors.green,
            isSelected: selectedFormat == 'Excel',
            onTap: () {
              setState(() {
                selectedFormat = 'Excel';
              });
            },
          ),
          const SizedBox(height: 18),
          const Text(
            'INCLUDED STATISTICS',
            style: TextStyle(
              color: Color(0xFF253B56),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _CheckRow(
            title: 'Completed Tasks',
            value: completedTasks,
            onChanged: (value) {
              setState(() {
                completedTasks = value ?? false;
              });
            },
          ),
          _CheckRow(
            title: 'Pending Tasks',
            value: pendingTasks,
            onChanged: (value) {
              setState(() {
                pendingTasks = value ?? false;
              });
            },
          ),
          _CheckRow(
            title: 'In Progress Tasks',
            value: inProgressTasks,
            onChanged: (value) {
              setState(() {
                inProgressTasks = value ?? false;
              });
            },
          ),
          _CheckRow(
            title: 'Employee Performance',
            value: employeePerformance,
            onChanged: (value) {
              setState(() {
                employeePerformance = value ?? false;
              });
            },
          ),
          _CheckRow(
            title: 'Project Deadlines',
            value: projectDeadlines,
            onChanged: (value) {
              setState(() {
                projectDeadlines = value ?? false;
              });
            },
          ),
          _CheckRow(
            title: 'Priority Distribution',
            value: priorityDistribution,
            onChanged: (value) {
              setState(() {
                priorityDistribution = value ?? false;
              });
            },
          ),
          const SizedBox(height: 18),
          _LivePreview(
            totalTasks: totalTasks,
            completionRate: completionRate,
            projects: uniqueProjects,
            employees: uniqueEmployees,
            completedCount: completedCount,
            pendingCount: pendingCount,
            inProgressCount: inProgressCount,
            overdueCount: overdueCount,
            highPriorityCount: highPriorityCount,
            mediumPriorityCount: mediumPriorityCount,
            lowPriorityCount: lowPriorityCount,
          ),
          const SizedBox(height: 22),
          AppButton(
            text: isGenerating ? 'Generating...' : 'Generate Report',
            icon: Icons.download_outlined,
            isLoading: isGenerating,
            onPressed: _generateReport,
          ),
          TextButton(
            onPressed: isGenerating ? null : () => Navigator.pop(context),
            child: const Center(
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
                  'LIVE SUMMARY',
                  style: TextStyle(
                    color: Color(0xFFBFD4EA),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                _HistoryRow(label: 'Report Type', value: reportTypeLabel),
                const SizedBox(height: 10),
                _HistoryRow(label: 'Report Scope', value: '$totalTasks tasks'),
                const SizedBox(height: 10),
                _HistoryRow(label: 'Projects', value: '$uniqueProjects'),
                const SizedBox(height: 10),
                _HistoryRow(label: 'Employees', value: '$uniqueEmployees'),
                const SizedBox(height: 10),
                _HistoryRow(
                  label: 'Completion Rate',
                  value: '$completionRate%',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportTypeOption {
  final String value;
  final String title;
  final String subtitle;

  const _ReportTypeOption({
    required this.value,
    required this.title,
    required this.subtitle,
  });
}

class _ReportTypeDropdown extends StatelessWidget {
  final String selectedReportType;
  final ValueChanged<String> onChanged;

  const _ReportTypeDropdown({
    required this.selectedReportType,
    required this.onChanged,
  });

  static const options = [
    _ReportTypeOption(
      value: 'task_report',
      title: 'Task Report',
      subtitle: 'Task status, priority, deadline and completion summary',
    ),
    _ReportTypeOption(
      value: 'project_report',
      title: 'Project Report',
      subtitle: 'Project scope, progress and task distribution',
    ),
    _ReportTypeOption(
      value: 'employee_performance',
      title: 'Employee Performance Report',
      subtitle: 'Assigned tasks, completed tasks and productivity',
    ),
    _ReportTypeOption(
      value: 'deadline_report',
      title: 'Deadline Report',
      subtitle: 'Upcoming, overdue and completed deadline analysis',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = options.firstWhere(
          (option) => option.value == selectedReportType,
      orElse: () => options.first,
    );

    return SearchablePickerField<_ReportTypeOption>(
      label: 'Report Type (${options.length})',
      icon: Icons.description_outlined,
      selectedItem: selected,
      items: options,
      hint: 'Select report type',
      titleBuilder: (option) => option.title,
      subtitleBuilder: (option) => option.subtitle,
      searchTextBuilder: (option) {
        return '${option.title} ${option.subtitle} ${option.value}';
      },
      onSelected: (option) => onChanged(option.value),
    );
  }
}

class _ProjectSelectionDropdown extends StatelessWidget {
  final int? selectedProjectId;
  final List<ProjectModel> projects;
  final bool isLoading;
  final ValueChanged<int?> onChanged;

  const _ProjectSelectionDropdown({
    required this.selectedProjectId,
    required this.projects,
    required this.isLoading,
    required this.onChanged,
  });

  ProjectModel? _findSelectedProject() {
    if (selectedProjectId == null) return null;

    for (final project in projects) {
      if (project.projectId == selectedProjectId) {
        return project;
      }
    }

    return null;
  }

  String _subtitle(ProjectModel project) {
    final parts = <String>[];

    parts.add('ID: ${project.projectId}');

    if (project.category.trim().isNotEmpty) {
      parts.add(project.category);
    }

    parts.add(project.status.replaceAll('_', ' '));

    if (project.priority.trim().isNotEmpty) {
      parts.add('Priority: ${project.priority}');
    }

    if (project.deadline != null && project.deadline!.trim().isNotEmpty) {
      parts.add('Deadline: ${project.deadline}');
    }

    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _DropdownWrapper(
        label: 'Project Selection',
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF0B2E59),
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Loading projects...',
              style: TextStyle(
                color: Color(0xFF667085),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    final selectedProject = _findSelectedProject();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SearchablePickerField<ProjectModel>(
          label: 'Project Selection (${projects.length})',
          icon: Icons.folder_copy_outlined,
          selectedItem: selectedProject,
          items: projects,
          hint: 'All Projects',
          titleBuilder: (project) => project.name,
          subtitleBuilder: _subtitle,
          searchTextBuilder: (project) {
            return '${project.name} ${project.description} ${project.category} '
                '${project.status} ${project.priority} ${project.projectId} '
                '${project.deadline ?? ''}';
          },
          onSelected: (project) => onChanged(project.projectId),
        ),
        const SizedBox(height: 8),
        if (selectedProjectId != null)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => onChanged(null),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('All Projects'),
            ),
          ),
      ],
    );
  }
}

class _LivePreview extends StatelessWidget {
  final int totalTasks;
  final int completionRate;
  final int projects;
  final int employees;
  final int completedCount;
  final int pendingCount;
  final int inProgressCount;
  final int overdueCount;
  final int highPriorityCount;
  final int mediumPriorityCount;
  final int lowPriorityCount;

  const _LivePreview({
    required this.totalTasks,
    required this.completionRate,
    required this.projects,
    required this.employees,
    required this.completedCount,
    required this.pendingCount,
    required this.inProgressCount,
    required this.overdueCount,
    required this.highPriorityCount,
    required this.mediumPriorityCount,
    required this.lowPriorityCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LIVE EXPORT PREVIEW',
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
                child: _PreviewMetric(
                  value: '$totalTasks',
                  label: 'Tasks Analyzed',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  value: '$completionRate%',
                  label: 'Completion Rate',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PreviewMetric(
                  value: '$projects',
                  label: 'Projects',
                ),
              ),
              Expanded(
                child: _PreviewMetric(
                  value: '$employees',
                  label: 'Employees',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MiniStatRow(label: 'Completed', value: '$completedCount'),
          _MiniStatRow(label: 'Pending', value: '$pendingCount'),
          _MiniStatRow(label: 'In Progress', value: '$inProgressCount'),
          _MiniStatRow(label: 'Overdue', value: '$overdueCount'),
          const Divider(height: 22),
          _MiniStatRow(label: 'High Priority', value: '$highPriorityCount'),
          _MiniStatRow(label: 'Medium Priority', value: '$mediumPriorityCount'),
          _MiniStatRow(label: 'Low Priority', value: '$lowPriorityCount'),
        ],
      ),
    );
  }
}

class _DropdownWrapper extends StatelessWidget {
  final String label;
  final Widget child;

  const _DropdownWrapper({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF253B56),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(
            minHeight: 62,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EBEF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final Widget child;

  const _SheetContainer({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.only(
            left: 18,
            right: 18,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 18,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F7FA),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(26),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: child,
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SheetHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE6EEF8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.description_outlined,
            color: Color(0xFF0B2E59),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF667085),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _DateBox({
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = text != 'Start Date' && text != 'End Date';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EBEF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0B2E59) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: Color(0xFF667085),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF0B2E59)
                      : const Color(0xFF98A2B3),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormatOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0B2E59),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: color,
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF0B2E59),
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0B2E59),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}

class _PreviewMetric extends StatelessWidget {
  final String value;
  final String label;

  const _PreviewMetric({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _MiniStatRow extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStatRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String label;
  final String value;

  const _HistoryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            label.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFBFD4EA),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}