import 'package:flutter/material.dart';
import 'package:smartops/core/models/project_request_model.dart';
import 'package:smartops/core/widgets/status_chip.dart';

class RequestCard extends StatelessWidget {
  final ProjectRequestModel request;
  final bool isAdmin;
  final bool isClient;
  final bool isLoading;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onDelete;

  const RequestCard({
    super.key,
    required this.request,
    required this.isAdmin,
    required this.isClient,
    this.isLoading = false,
    this.onApprove,
    this.onReject,
    this.onDelete,
  });

  bool get isPending => request.status == 'pending';
  bool get isApproved => request.status == 'approved';
  bool get isRejected => request.status == 'rejected';

  Color get statusColor {
    if (isApproved) return Colors.green.shade700;
    if (isRejected) return Colors.red.shade700;
    return Colors.orange.shade700;
  }

  String _formatStatus(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((item) {
      if (item.isEmpty) return item;
      return '${item[0].toUpperCase()}${item.substring(1)}';
    })
        .join(' ');
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not set';

    final date = DateTime.tryParse(value);

    if (date == null) return value;

    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final showAdminActions = isAdmin && isPending;
    final showClientDelete = isClient && isPending;

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
          StatusChip(label: _formatStatus(request.status), color: statusColor),

          const SizedBox(height: 12),

          Text(
            request.name,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            request.description,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          _InfoRow(
            label: 'Client',
            value: request.clientName ?? 'Client',
          ),

          const SizedBox(height: 8),

          _InfoRow(
            label: 'Category',
            value: request.category,
          ),

          const SizedBox(height: 8),

          _InfoRow(
            label: 'Deadline',
            value: _formatDate(request.deadline),
          ),

          const SizedBox(height: 8),

          _InfoRow(
            label: 'Template',
            value: request.templateName ?? 'Custom Request',
          ),

          const SizedBox(height: 8),

          _InfoRow(
            label: 'Created',
            value: _formatDate(request.createdAt),
          ),

          if (isRejected && request.rejectionReason != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REJECTION REASON',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    request.rejectionReason!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (showAdminActions || showClientDelete) ...[
            const SizedBox(height: 16),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    color: Color(0xFF0B2E59),
                  ),
                ),
              )
            else if (showAdminActions)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        'Reject',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B2E59),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        'Approve',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Pending Request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xFF98A2B3),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0B2E59),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}