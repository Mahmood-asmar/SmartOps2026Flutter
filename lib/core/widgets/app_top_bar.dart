import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final String? title;

  const AppTopBar({
    super.key,
    required this.onMenuTap,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onMenuTap,
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF0B2E59),
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
        if (title != null)
          Text(
            title!,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        const Spacer(),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            color: Color(0xFF0B2E59),
          ),
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF0B2E59),
          child: Text(
            'Y',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}