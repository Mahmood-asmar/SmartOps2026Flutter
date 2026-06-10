import 'package:flutter/material.dart';

import 'package:smartops/core/models/app_user_model.dart';
import 'package:smartops/core/models/project_model.dart';
import 'package:smartops/core/services/project_service.dart';
import 'package:smartops/core/services/task_service.dart';
import 'package:smartops/core/services/user_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_text_field.dart';
import 'package:smartops/core/widgets/searchable_picker_field.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class AssignTaskSheet extends StatefulWidget {
  const AssignTaskSheet({super.key});

  @override
  State<AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends State<AssignTaskSheet> {
  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final deadlineController = TextEditingController();

  List<AppUserModel> employees = [];
  List<ProjectModel> projects = [];

  AppUserModel? selectedEmployee;
  ProjectModel? selectedProject;

  String selectedPriority = 'high';

  bool isLoading = true;
  bool isSubmitting = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    return null;
  }

  Future<void> loadInitialData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final usersData = await UserService.getUsers();
      final projectsData = await ProjectService.getProjects();

      final loadedUsers = usersData
          .map(
            (item) => AppUserModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .where((user) => user.role == 'employee')
          .toList();

      final loadedProjects = projectsData
          .map(
            (item) => ProjectModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      setState(() {
        employees = loadedUsers;
        projects = loadedProjects;

        if (employees.isNotEmpty) {
          selectedEmployee = employees.first;
        }

        if (projects.isNotEmpty) {
          selectedProject = projects.first;
        }
      });
    } catch (error) {
      setState(() {
        errorMessage = _cleanErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
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
      deadlineController.text = formattedDate;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedEmployee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an employee.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedProject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a project.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await TaskService.createTask(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        assignedUser: selectedEmployee!.userId,
        projectId: selectedProject!.projectId,
        deadline: deadlineController.text.trim(),
        priority: selectedPriority,
      );

      if (!mounted) return;

      Navigator.pop(context, true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task assigned successfully.'),
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
        setState(() => isSubmitting = false);
      }
    }
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF0B2E59)),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 38),
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
              backgroundColor: Colors.red.shade700,
              onPressed: loadInitialData,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: isLoading
          ? _buildLoading()
          : errorMessage.isNotEmpty
          ? _buildError()
          : Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHeader(
              title: 'Assign New Task',
              subtitle: 'Create a project task for an employee.',
            ),

            const SizedBox(height: 20),

            AppTextField(
              label: 'Task Title',
              hint: 'Enter task title',
              controller: titleController,
              validator: (value) => _required(value, 'Task title'),
            ),

            const SizedBox(height: 14),

            AppTextField(
              label: 'Description',
              hint: 'Describe the task requirements...',
              controller: descriptionController,
              validator: (value) => _required(value, 'Description'),
            ),

            const SizedBox(height: 14),

            _EmployeeDropdown(
              employees: employees,
              selectedEmployee: selectedEmployee,
              onChanged: (value) {
                setState(() {
                  selectedEmployee = value;
                });
              },
            ),

            const SizedBox(height: 14),

            _ProjectDropdown(
              projects: projects,
              selectedProject: selectedProject,
              onChanged: (value) {
                setState(() {
                  selectedProject = value;
                });
              },
            ),

            const SizedBox(height: 14),

            TextFormField(
              controller: deadlineController,
              readOnly: true,
              onTap: _pickDeadline,
              validator: (value) => _required(value, 'Deadline'),
              decoration: InputDecoration(
                labelText: 'DEADLINE',
                hintText: 'YYYY-MM-DD',
                prefixIcon:
                const Icon(Icons.calendar_today_outlined),
                suffixIcon: const Icon(Icons.keyboard_arrow_down),
                filled: true,
                fillColor: const Color(0xFFE8EBEF),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'PRIORITY',
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
                _PriorityButton(
                  text: 'Low',
                  isSelected: selectedPriority == 'low',
                  onTap: () {
                    setState(() => selectedPriority = 'low');
                  },
                  color: Colors.green,
                ),
                const SizedBox(width: 8),
                _PriorityButton(
                  text: 'Medium',
                  isSelected: selectedPriority == 'medium',
                  onTap: () {
                    setState(() => selectedPriority = 'medium');
                  },
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _PriorityButton(
                  text: 'High',
                  isSelected: selectedPriority == 'high',
                  onTap: () {
                    setState(() => selectedPriority = 'high');
                  },
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Text(
                  'CURRENT STATUS',
                  style: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                StatusChip(
                  label: 'Pending',
                  color: Colors.orange.shade700,
                ),
              ],
            ),

            const SizedBox(height: 22),

            AppButton(
              text: 'Assign Task',
              icon: Icons.check,
              isLoading: isSubmitting,
              onPressed: _submit,
            ),

            TextButton(
              onPressed:
              isSubmitting ? null : () => Navigator.pop(context),
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
          ],
        ),
      ),
    );
  }
}

class _EmployeeDropdown extends StatelessWidget {
  final List<AppUserModel> employees;
  final AppUserModel? selectedEmployee;
  final ValueChanged<AppUserModel?> onChanged;

  const _EmployeeDropdown({
    required this.employees,
    required this.selectedEmployee,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SearchablePickerField<AppUserModel>(
      label: 'Assigned User (${employees.length})',
      icon: Icons.person_outline,
      selectedItem: selectedEmployee,
      items: employees,
      hint: 'Select employee',
      titleBuilder: (employee) => employee.name,
      subtitleBuilder: (employee) {
        return '${employee.email} • ${employee.role} • ID: ${employee.userId}';
      },
      searchTextBuilder: (employee) {
        return '${employee.name} ${employee.email} ${employee.role} ${employee.userId}';
      },
      onSelected: onChanged,
    );
  }
}

class _ProjectDropdown extends StatelessWidget {
  final List<ProjectModel> projects;
  final ProjectModel? selectedProject;
  final ValueChanged<ProjectModel?> onChanged;

  const _ProjectDropdown({
    required this.projects,
    required this.selectedProject,
    required this.onChanged,
  });

  String _formatProjectSubtitle(ProjectModel project) {
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
    return SearchablePickerField<ProjectModel>(
      label: 'Project (${projects.length})',
      icon: Icons.folder_copy_outlined,
      selectedItem: selectedProject,
      items: projects,
      hint: 'Select project',
      titleBuilder: (project) => project.name,
      subtitleBuilder: _formatProjectSubtitle,
      searchTextBuilder: (project) {
        return '${project.name} ${project.description} ${project.category} '
            '${project.status} ${project.priority} ${project.projectId} '
            '${project.deadline ?? ''}';
      },
      onSelected: onChanged,
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
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
            Icons.assignment_add,
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

class _PriorityButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _PriorityButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.color = const Color(0xFF0B2E59),
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? color : const Color(0xFFE8EBEF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0B2E59),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}