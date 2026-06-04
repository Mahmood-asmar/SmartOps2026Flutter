import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_text_field.dart';

class EditTaskSheet extends StatefulWidget {
  final String title;
  final String description;
  final String assignedUser;
  final String deadline;
  final String priority;
  final String status;

  const EditTaskSheet({
    super.key,
    required this.title,
    required this.description,
    required this.assignedUser,
    required this.deadline,
    required this.priority,
    required this.status,
  });

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController assignedUserController;
  late TextEditingController deadlineController;

  late String selectedPriority;
  late String selectedStatus;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.title);
    descriptionController = TextEditingController(text: widget.description);
    assignedUserController = TextEditingController(text: widget.assignedUser);
    deadlineController = TextEditingController(text: widget.deadline);

    selectedPriority = widget.priority;
    selectedStatus = widget.status;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    assignedUserController.dispose();
    deadlineController.dispose();
    super.dispose();
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
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Description',
                  hint: 'Enter description',
                  controller: descriptionController,
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Assigned User',
                  hint: 'Assigned user',
                  controller: assignedUserController,
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Deadline',
                  hint: 'Deadline',
                  controller: deadlineController,
                  prefixIcon: Icons.calendar_today_outlined,
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
                      color: Colors.yellow,
                      isSelected: selectedPriority == 'Low',
                      onTap: () => setState(() => selectedPriority = 'Low'),
                    ),
                    const SizedBox(width: 8),
                    _ChoiceButton(
                      text: 'Medium',
                      isSelected: selectedPriority == 'Medium',
                      onTap: () => setState(() => selectedPriority = 'Medium'),
                    ),
                    const SizedBox(width: 8),
                    _ChoiceButton(
                      text: 'High',
                      color: Colors.red,
                      isSelected: selectedPriority == 'High' ||
                          selectedPriority == 'Critical',
                      onTap: () => setState(() => selectedPriority = 'High'),
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
                      text: 'Todo',
                      isSelected: selectedStatus == 'Todo',
                      onTap: () => setState(() => selectedStatus = 'Todo'),
                    ),
                    const SizedBox(width: 8),
                    _ChoiceButton(
                      text: 'In Progress',
                      color: Colors.orange,
                      isSelected: selectedStatus == 'In Progress',
                      onTap: () {
                        setState(() => selectedStatus = 'In Progress');
                      },
                    ),
                    const SizedBox(width: 8),
                    _ChoiceButton(
                      text: 'Complete',
                      color: Colors.green,
                      isSelected: selectedStatus == 'Complete',
                      onTap: () => setState(() => selectedStatus = 'Complete'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                AppButton(
                  text: 'Save Changes',
                  icon: Icons.check,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task updated successfully'),
                      ),
                    );
                  },
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
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
      },
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _ChoiceButton({
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
              fontSize: 11,
            ),
          ),
        ),
      ),
    );
  }
}