import 'package:flutter/material.dart';

class TeamActivity extends StatelessWidget {
  const TeamActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Activity',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              CircleAvatar(radius: 16, child: Text('A')),
              SizedBox(width: 8),
              CircleAvatar(radius: 16, child: Text('M')),
              SizedBox(width: 8),
              CircleAvatar(radius: 16, child: Text('S')),
              SizedBox(width: 8),
              CircleAvatar(radius: 16, child: Text('D')),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TASKS COMPLETED',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '114 THIS WEEK',
                style: TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}