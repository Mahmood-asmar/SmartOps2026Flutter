import 'package:flutter/material.dart';

import 'package:smartops/core/models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  IconData get _icon {
    switch (notification.type.toLowerCase()) {
      case 'project':
      case 'project_update':
      case 'project_request':
        return Icons.folder_copy_outlined;
      case 'task':
      case 'task_update':
      case 'task_completed':
        return Icons.task_alt_outlined;
      case 'request':
      case 'approval':
        return Icons.assignment_outlined;
      case 'system':
        return Icons.system_update_alt_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color get _iconColor {
    switch (notification.type.toLowerCase()) {
      case 'project':
      case 'project_update':
      case 'project_request':
        return Colors.blue.shade700;
      case 'task':
      case 'task_update':
      case 'task_completed':
        return Colors.green.shade700;
      case 'request':
      case 'approval':
        return Colors.orange.shade700;
      case 'system':
        return Colors.blueGrey.shade700;
      default:
        return const Color(0xFF0B2E59);
    }
  }

  String get _title {
    switch (notification.type.toLowerCase()) {
      case 'project':
      case 'project_update':
        return 'Project Update';
      case 'project_request':
        return 'Project Request';
      case 'task':
      case 'task_update':
        return 'Task Update';
      case 'task_completed':
        return 'Task Completed';
      case 'request':
        return 'Request Update';
      case 'approval':
        return 'Approval Update';
      case 'system':
        return 'System Notification';
      default:
        return 'Notification';
    }
  }

  String _formatTime(String? value) {
    if (value == null || value.trim().isEmpty) return 'Just now';

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;

    final now = DateTime.now();
    final diff = now.difference(parsed.toLocal());

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          left: BorderSide(
            color: isUnread ? const Color(0xFF2563EB) : Colors.transparent,
            width: 4,
          ),
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _icon,
              color: _iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF0B2E59),
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(notification.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF98A2B3),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isUnread
                            ? const Color(0xFFE6EEF8)
                            : const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        isUnread ? 'UNREAD' : 'READ',
                        style: TextStyle(
                          color: isUnread
                              ? const Color(0xFF0B2E59)
                              : const Color(0xFF667085),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isUnread)
                      TextButton.icon(
                        onPressed: onMarkAsRead,
                        icon: const Icon(Icons.done, size: 15),
                        label: const Text('Read'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0B2E59),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 19,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}