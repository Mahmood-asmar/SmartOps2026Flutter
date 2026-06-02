import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class TemplateCard extends StatelessWidget {
  final String title;
  final String description;
  final String category;
  final String duration;
  final String status;
  final Color statusColor;
  final bool isClient;

  const TemplateCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.duration,
    required this.status,
    required this.statusColor,
    this.isClient = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EEF8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.view_module_outlined,
                  color: Color(0xFF0B2E59),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(Icons.more_vert, color: Color(0xFF98A2B3)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusChip(label: category, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              StatusChip(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'DURATION',
                style: TextStyle(
                  color: Color(0xFF98A2B3),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                duration,
                style: const TextStyle(
                  color: Color(0xFF0B2E59),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isClient)
            AppButton(
              text: 'Use Template',
              icon: Icons.send_outlined,
              onPressed: () {
                // TODO: client requests a project using this template
              },
            )
          else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Delete',
                    icon: Icons.delete_outline,
                    backgroundColor: Colors.red,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}