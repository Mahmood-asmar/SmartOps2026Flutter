import 'package:flutter/material.dart';
import 'package:smartops/core/models/project_template_model.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class TemplateCard extends StatelessWidget {
  final ProjectTemplateModel template;
  final bool isClient;
  final bool isAdmin;
  final VoidCallback? onUseTemplate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TemplateCard({
    super.key,
    required this.template,
    this.isClient = false,
    this.isAdmin = false,
    this.onUseTemplate,
    this.onEdit,
    this.onDelete,
  });

  Color _categoryColor(String category) {
    final normalized = category.toLowerCase();

    if (normalized.contains('mobile')) return Colors.green.shade700;
    if (normalized.contains('web')) return Colors.blue.shade700;
    if (normalized.contains('ai')) return Colors.purple.shade700;
    if (normalized.contains('architecture')) return Colors.orange.shade700;

    return Colors.blueGrey.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _categoryColor(template.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6EEF8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.view_module_outlined,
                  color: Color(0xFF0B2E59),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  template.name,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFF98A2B3),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            template.description,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              StatusChip(label: template.category, color: categoryColor),
              const SizedBox(width: 8),
              StatusChip(label: 'Verified', color: Colors.green.shade700),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9EEF5)),
            ),
            child: Row(
              children: [
                const Text(
                  'ESTIMATED DURATION',
                  style: TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Text(
                  '${template.estimatedDuration} days',
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Edit',
                    icon: Icons.edit_outlined,
                    onPressed: onEdit,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    text: 'Delete',
                    icon: Icons.delete_outline,
                    backgroundColor: Colors.red,
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
          ],
          if (isClient) ...[
            const SizedBox(height: 14),
            AppButton(
              text: 'Request This Template',
              icon: Icons.send_outlined,
              onPressed: onUseTemplate,
            ),
          ],
        ],
      ),
    );
  }
}