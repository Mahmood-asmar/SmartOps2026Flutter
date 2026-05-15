import 'package:flutter/material.dart';

class PasswordRules extends StatelessWidget {
  const PasswordRules({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RuleText(text: 'At least 8 characters'),
        _RuleText(text: 'Includes uppercase and lowercase letters'),
        _RuleText(text: 'Includes at least one number'),
      ],
    );
  }
}

class _RuleText extends StatelessWidget {
  final String text;

  const _RuleText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Color(0xFF5F6C7B),
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF5F6C7B),
            ),
          ),
        ],
      ),
    );
  }
}