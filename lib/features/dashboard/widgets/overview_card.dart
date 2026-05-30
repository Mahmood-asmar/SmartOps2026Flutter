import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const OverviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            icon,
            color: const Color(0xFF98A2B3),
            size: 20,
          ),
        ],
      ),
    );
  }
}