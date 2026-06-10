import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/widgets/app_button.dart';

import 'package:smartops/features/auth/screens/login.dart';
import 'package:smartops/features/dashboard/screens/dashboard_screen.dart';
import 'package:smartops/features/projects/screens/projects_screen.dart';
import 'package:smartops/features/tasks/screens/tasks_screen.dart';
import 'package:smartops/features/requests/screens/requests_screen.dart';
import 'package:smartops/features/templates/screens/templates_screen.dart';
import 'package:smartops/features/notifications/screens/notifications_screen.dart';
import 'package:smartops/core/services/notification_socket_service.dart';
import 'package:smartops/features/users/screens/users_screen.dart';



class AppDrawer extends StatelessWidget {
  final String activePage;

  const AppDrawer({
    super.key,
    required this.activePage,
  });

  void _navigate(BuildContext context, Widget screen) {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _logout(BuildContext context) async {
    Navigator.pop(context);

    NotificationSocketService.instance.disconnect();

    await context.read<AuthProvider>().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  String _formatRole(String role) {
    if (role.isEmpty) return 'Member';

    return role
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1)}';
    })
        .join(' ');
  }

  String _getInitial(String name) {
    if (name.trim().isEmpty) return 'U';
    return name.trim().characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final String role = authProvider.role;
    final bool isAdmin = authProvider.isAdmin;
    final bool isEmployee = authProvider.isEmployee;
    final bool isClient = authProvider.isClient;

    final String userName = authProvider.userName;
    final String userEmail = authProvider.userEmail;
    final String userInitial = _getInitial(userName);

    return Drawer(
      backgroundColor: const Color(0xFFF5F7FA),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2E59),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: SvgPicture.asset(
                        'assets/icons/compass.svg',
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SmartOps',
                        style: TextStyle(
                          color: Color(0xFF0B2E59),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Management AI',
                        style: TextStyle(
                          color: Color(0xFF98A2B3),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE9EEF5)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF0B2E59),
                      child: Text(
                        userInitial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF0B2E59),
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userEmail.isEmpty ? 'No email' : userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6EEF8),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              _formatRole(role),
                              style: const TextStyle(
                                color: Color(0xFF0B2E59),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _DrawerItem(
                      title: 'Dashboard',
                      icon: Icons.dashboard_outlined,
                      isActive: activePage == 'dashboard',
                      onTap: () => _navigate(
                        context,
                        const DashboardScreen(),
                      ),
                    ),


                    _DrawerItem(
                      title: 'Projects',
                      icon: Icons.folder_copy_outlined,
                      isActive: activePage == 'projects',
                      onTap: () => _navigate(
                        context,
                        const ProjectsScreen(),
                      ),
                    ),

                    if (isAdmin || isEmployee)
                      _DrawerItem(
                        title: 'Tasks',
                        icon: Icons.checklist_outlined,
                        isActive: activePage == 'tasks',
                        onTap: () => _navigate(
                          context,
                          const TasksScreen(),
                        ),
                      ),

                    if (isAdmin || isClient)
                      _DrawerItem(
                        title: 'Requests',
                        icon: Icons.assignment_outlined,
                        isActive: activePage == 'requests',
                        onTap: () => _navigate(
                          context,
                          const RequestsScreen(),
                        ),
                      ),

                    if (isAdmin || isClient)
                      _DrawerItem(
                        title: 'Templates',
                        icon: Icons.view_module_outlined,
                        isActive: activePage == 'templates',
                        onTap: () => _navigate(
                          context,
                          const TemplatesScreen(),
                        ),
                      ),

                    _DrawerItem(
                      title: 'Notifications',
                      icon: Icons.notifications_none,
                      isActive: activePage == 'notifications',
                      onTap: () => _navigate(
                        context,
                        const NotificationsScreen(),
                      ),
                    ),

                    if (isAdmin)
                      _DrawerItem(
                        title: 'Users',
                        icon: Icons.people_outline,
                        isActive: activePage == 'users',
                        onTap: () => _navigate(
                          context,
                          const UsersScreen(),
                        ),
                      ),


                  ],
                ),
              ),

              AppButton(
                text: 'Logout',
                icon: Icons.logout,
                backgroundColor: Colors.red,
                onPressed: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
    isActive ? const Color(0xFF0B2E59) : const Color(0xFF5F6C7B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: isActive ? const Color(0xFFE6EEF8) : Colors.transparent,
        leading: Icon(icon, color: color, size: 21),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        trailing: isActive
            ? Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF0B2E59),
            shape: BoxShape.circle,
          ),
        )
            : null,
      ),
    );
  }
}