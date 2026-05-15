import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final roles = ['Admin', 'Employee', 'Client'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ROLE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: Color(0xFF253B56),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: roles.map((role) {
            final isSelected = selectedRole == role;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(role),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0B2E59)
                        : const Color(0xFFE8EBEF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    role,
                    style: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF253B56),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}