import 'package:flutter/material.dart';

import 'package:smartops/core/models/app_user_model.dart';

class UserCard extends StatelessWidget {
  final AppUserModel user;
  final VoidCallback onDelete;

  const UserCard({
    super.key,
    required this.user,
    required this.onDelete,
  });

  Color get roleColor {
    switch (user.role) {
      case 'admin':
        return Colors.red.shade700;
      case 'employee':
        return Colors.blue.shade700;
      case 'client':
        return Colors.green.shade700;
      default:
        return const Color(0xFF0B2E59);
    }
  }

  IconData get roleIcon {
    switch (user.role) {
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      case 'employee':
        return Icons.engineering_outlined;
      case 'client':
        return Icons.person_outline;
      default:
        return Icons.account_circle_outlined;
    }
  }

  String get formattedRole {
    if (user.role.isEmpty) return 'Member';

    return user.role
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    })
        .join(' ');
  }

  String get initial {
    if (user.name.trim().isEmpty) return 'U';
    return user.name.trim()[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE6EEF8),
            child: Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF0B2E59),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0B2E59),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        roleIcon,
                        color: roleColor,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedRole.toUpperCase(),
                        style: TextStyle(
                          color: roleColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}