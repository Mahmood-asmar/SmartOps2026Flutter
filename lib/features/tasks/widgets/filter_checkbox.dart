import 'package:flutter/material.dart';

class FilterCheckbox extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const FilterCheckbox({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          activeColor: const Color(0xFF0B2E59),
          onChanged: onChanged,
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0B2E59),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}