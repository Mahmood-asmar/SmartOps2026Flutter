import 'package:flutter/material.dart';

import 'package:smartops/core/models/task_model.dart';
import 'package:smartops/core/services/task_service.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_text_field.dart';

class EditTaskSheet extends StatefulWidget {
  final TaskModel task;

  const EditTaskSheet({
    super.key,
    required this.task,
  });

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController deadlineController;

  late String selectedPriority;
  late String selectedStatus;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.task.title);
    descriptionController = TextEditingController(
      text: widget.task.description,
    );
    deadlineController = TextEditingController(
      text: _formatDate(widget.task.deadline),
    );

    selectedPriority = widget.task.priority;
    selectedStatus = widget.task.status;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    deadlineController.dispose();
    super.dispose();
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return '';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }

    return null;
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();

    DateTime initialDate = now;
    final parsed = DateTime.tryParse(deadlineController.text.trim());

    if (parsed != null && parsed.isAfter(now)) {
      initialDate = parsed;
    }

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 1),
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

  String _cleanErrorMessage(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isSubmitting = true);

    try {
      await TaskService.updateTask(
        taskId: widget.task.taskId,
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        deadline: deadlineController.text.trim(),
        priority: selectedPriority,
        status: selectedStatus,
      );

      final updatedTask = widget.task.copyWith(
        title: titleController.text.trim(),
        description: descriptionController.text.trim(),
        deadline: deadlineController.text.trim(),
        priority: selectedPriority,
        status: selectedStatus,
      );

      if (!mounted) return;

      Navigator.pop(context, updatedTask);
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

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Task',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Update task details and progress.',
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 22),

                  AppTextField(
                    label: 'Task Title',
                    hint: 'Enter task title',
                    controller: titleController,
                    validator: (value) => _required(value, 'Task title'),
                  ),

                  const SizedBox(height: 14),

                  AppTextField(
                    label: 'Description',
                    hint: 'Enter description',
                    controller: descriptionController,
                    validator: (value) => _required(value, 'Description'),
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
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
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

                  const SizedBox(height: 18),

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
                      _ChoiceButton(
                        text: 'Low',
                        value: 'low',
                        color: Colors.green,
                        isSelected: selectedPriority == 'low',
                        onTap: () {
                          setState(() => selectedPriority = 'low');
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChoiceButton(
                        text: 'Medium',
                        value: 'medium',
                        color: Colors.orange,
                        isSelected: selectedPriority == 'medium',
                        onTap: () {
                          setState(() => selectedPriority = 'medium');
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChoiceButton(
                        text: 'High',
                        value: 'high',
                        color: Colors.red,
                        isSelected: selectedPriority == 'high',
                        onTap: () {
                          setState(() => selectedPriority = 'high');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'STATUS',
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
                      _ChoiceButton(
                        text: 'Pending',
                        value: 'pending',
                        isSelected: selectedStatus == 'pending',
                        onTap: () {
                          setState(() => selectedStatus = 'pending');
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChoiceButton(
                        text: 'Progress',
                        value: 'in_progress',
                        color: Colors.blue,
                        isSelected: selectedStatus == 'in_progress',
                        onTap: () {
                          setState(() => selectedStatus = 'in_progress');
                        },
                      ),
                      const SizedBox(width: 8),
                      _ChoiceButton(
                        text: 'Done',
                        value: 'completed',
                        color: Colors.green,
                        isSelected: selectedStatus == 'completed',
                        onTap: () {
                          setState(() => selectedStatus = 'completed');
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  AppButton(
                    text: 'Save Changes',
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
          ),
        );
      },
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String text;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _ChoiceButton({
    required this.text,
    required this.value,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF0B2E59),
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}