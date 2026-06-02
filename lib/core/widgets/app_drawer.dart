import 'package:flutter/material.dart';
import 'package:smartops/core/widgets/app_button.dart';
import 'package:smartops/features/dashboard/screens/dashboard_screen.dart';
import 'package:smartops/features/projects/screens/projects_screen.dart';
import 'package:smartops/features/tasks/screens/tasks_screen.dart';
import 'package:smartops/features/requests/screens/requests_screen.dart';
import 'package:smartops/features/templates/screens/templates_screen.dart';
import 'package:smartops/features/notifications/screens/notifications_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

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

  @override
  Widget build(BuildContext context) {
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
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B2E59),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                       padding: const EdgeInsets.all(4),
                       child: SvgPicture.asset(
                       'assets/icons/compass.svg',
                       colorFilter: const ColorFilter.mode(
                        Colors.white,
                          BlendMode.srcIn,
                        ),
                       ),
                     ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SmartOps',
                    style: TextStyle(
                      color: Color(0xFF0B2E59),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _DrawerItem(
                title: 'Dashboard',
                icon: Icons.dashboard_outlined,
                isActive: activePage == 'dashboard',
                onTap: () => _navigate(context, const DashboardScreen()),
              ),

              _DrawerItem(
                title: 'Projects',
                icon: Icons.folder_copy_outlined,
                isActive: activePage == 'projects',
                onTap: () => _navigate(context, const ProjectsScreen()),
              ),

              _DrawerItem(
                title: 'Tasks',
                icon: Icons.checklist_outlined,
                isActive: activePage == 'tasks',
                onTap: () => _navigate(context, const TasksScreen()), 
              ),

              _DrawerItem(
                title: 'Requests',
                icon: Icons.assignment_outlined,
                isActive: activePage == 'requests',
                onTap: () => _navigate(context, const RequestsScreen()),
              ),

              _DrawerItem(
                 title: 'Templates',
                 icon: Icons.view_module_outlined,
                 isActive: activePage == 'templates',
                 onTap: () => _navigate(
                   context,
                   const TemplatesScreen(isClient: true),
                ),
              ),

              _DrawerItem(
                title: 'Notifications',
                icon: Icons.notifications_none,
                isActive: activePage == 'notifications',
                onTap: () => _navigate(context, const NotificationsScreen()),
              ),

              const Spacer(),

              AppButton(
                text: 'Logout',
                icon: Icons.logout,
                backgroundColor: Colors.red,
                onPressed: () {
                  Navigator.pop(context);

                    // TODO: clear local storage
                   // TODO: navigate to login
                },
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
    final Color color = isActive
    ? const Color(0xFF0B2E59)
    : const Color(0xFF5F6C7B);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        tileColor: isActive ? const Color(0xFFE6EEF8) : Colors.transparent,
        leading: Icon(icon, color: color, size: 20),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: isActive  ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}