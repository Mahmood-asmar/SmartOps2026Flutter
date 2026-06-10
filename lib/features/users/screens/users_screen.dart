import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/app_user_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/user_service.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/users/widgets/add_user_sheet.dart';
import 'package:smartops/features/users/widgets/user_card.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<AppUserModel> users = [];

  bool isLoading = true;
  bool isDeleting = false;

  String errorMessage = '';
  String selectedRole = 'all';

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> loadUsers() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await UserService.getUsers();

      final loadedUsers = data
          .map(
            (item) => AppUserModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      loadedUsers.sort((a, b) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

      if (!mounted) return;

      setState(() {
        users = loadedUsers;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = _cleanError(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  List<AppUserModel> get filteredUsers {
    final query = searchController.text.trim().toLowerCase();

    return users.where((user) {
      final matchesRole = selectedRole == 'all' || user.role == selectedRole;

      final matchesSearch = query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);

      return matchesRole && matchesSearch;
    }).toList();
  }

  int get totalUsers => users.length;

  int get adminsCount {
    return users.where((user) => user.role == 'admin').length;
  }

  int get employeesCount {
    return users.where((user) => user.role == 'employee').length;
  }

  int get clientsCount {
    return users.where((user) => user.role == 'client').length;
  }

  Future<void> _openAddUserSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return AddUserSheet(
          onUserCreated: loadUsers,
        );
      },
    );
  }

  Future<void> _confirmDelete(AppUserModel user) async {
    final authProvider = context.read<AuthProvider>();

    if (authProvider.userEmail == user.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You cannot delete your own account.'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete User'),
          content: Text(
            'Are you sure you want to delete ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _deleteUser(user);
  }

  Future<void> _deleteUser(AppUserModel user) async {
    setState(() {
      isDeleting = true;
    });

    try {
      await UserService.deleteUser(user.userId);

      setState(() {
        users = users.where((item) => item.userId != user.userId).toList();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_cleanError(error)),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  Widget _buildFilterChip({
    required String role,
    required String label,
    required int count,
  }) {
    final isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0B2E59) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0B2E59)
                  : const Color(0xFFE9EEF5),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF0B2E59),
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFBFD4EA)
                      : const Color(0xFF667085),
                  fontWeight: FontWeight.w800,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      controller: searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Search users by name, email, or role...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: const Color(0xFFE8EBEF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B2E59),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'USERS OVERVIEW',
            style: TextStyle(
              color: Color(0xFFBFD4EA),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$totalUsers',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Total active accounts',
            style: TextStyle(
              color: Color(0xFFD8E3F0),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: totalUsers == 0 ? 0 : employeesCount / totalUsers,
            minHeight: 6,
            backgroundColor: const Color(0xFF385274),
            color: Colors.green.shade400,
            borderRadius: BorderRadius.circular(8),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF0B2E59)),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700, size: 40),
          const SizedBox(height: 10),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.red.shade700,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: loadUsers,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF5)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.people_outline,
            color: Color(0xFF98A2B3),
            size: 46,
          ),
          SizedBox(height: 12),
          Text(
            'No users found',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try changing the search or selected filter.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF667085),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredUsers;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'users'),
      floatingActionButton: FloatingActionButton(
        onPressed: isLoading || isDeleting ? null : _openAddUserSheet,
        backgroundColor: const Color(0xFF0B2E59),
        child: const Icon(
          Icons.person_add_alt_1_outlined,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              color: const Color(0xFF0B2E59),
              onRefresh: loadUsers,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTopBar(
                      title: 'Users',
                      onMenuTap: () => _openDrawer(context),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Users Management',
                      style: TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Manage admin, employee, and client accounts from one place.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildOverviewCard(),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _buildFilterChip(
                          role: 'all',
                          label: 'ALL',
                          count: totalUsers,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          role: 'admin',
                          label: 'ADMINS',
                          count: adminsCount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFilterChip(
                          role: 'employee',
                          label: 'EMPLOYEES',
                          count: employeesCount,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          role: 'client',
                          label: 'CLIENTS',
                          count: clientsCount,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildSearchBox(),
                    const SizedBox(height: 22),
                    if (isLoading)
                      _buildLoading()
                    else if (errorMessage.isNotEmpty)
                      _buildError()
                    else if (items.isEmpty)
                        _buildEmpty()
                      else
                        Column(
                          children: items.map((user) {
                            return UserCard(
                              user: user,
                              onDelete: () => _confirmDelete(user),
                            );
                          }).toList(),
                        ),
                    const SizedBox(height: 28),
                    AppFooter(
                      text: 'Need help?',
                      actionText: 'Contact Support',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}