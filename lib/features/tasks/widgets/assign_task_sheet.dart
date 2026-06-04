import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/app_text_field.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class AssignTaskSheet extends StatefulWidget {
  const AssignTaskSheet({super.key});

  @override
  State<AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends State<AssignTaskSheet> {
  String selectedPriority = 'High';

  @override
  Widget build(BuildContext context) {
    return _SheetContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHeader(
            title: 'Assign New Task',
            subtitle: 'Create a project task for an employee.',
          ),
          const SizedBox(height: 20),

          const AppTextField(
            label: 'Task Title',
            hint: 'Enter task title',
          ),
          const SizedBox(height: 14),

          const AppTextField(
            label: 'Description',
            hint: 'Describe the task requirements...',
          ),
          const SizedBox(height: 14),

          const _DropdownBox(
            label: 'Assigned User',
            value: 'Jordan Smith',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),

          const _DropdownBox(
            label: 'Project',
            value: 'Cloud Infrastructure v2',
            icon: Icons.folder_copy_outlined,
          ),
          const SizedBox(height: 14),

          const AppTextField(
            label: 'Deadline',
            hint: 'mm/dd/yyyy',
            prefixIcon: Icons.calendar_today_outlined,
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
                isSelected: selectedPriority == 'Low',
                onTap: () => setState(() => selectedPriority = 'Low'),
                color: Colors.yellow
              ),
              const SizedBox(width: 8),
              _PriorityButton(
                text: 'Medium',
                isSelected: selectedPriority == 'Medium',
                onTap: () => setState(() => selectedPriority = 'Medium'),
              ),
              const SizedBox(width: 8),
              _PriorityButton(
                text: 'High',
                isSelected: selectedPriority == 'High',
                onTap: () => setState(() => selectedPriority = 'High'),
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
              StatusChip(label: 'Pending', color: Colors.green.shade700),
            ],
          ),

          const SizedBox(height: 22),

          AppButton(
            text: 'Assign Task',
            icon: Icons.check,
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Task assigned successfully')),
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
    );
  }
}

class _SheetContainer extends StatelessWidget {
  final Widget child;

  const _SheetContainer({required this.child});

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

class _DropdownBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DropdownBox({
    required this.label,
    required this.value,
    required this.icon,
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
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8EBEF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF7B8794), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down),
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