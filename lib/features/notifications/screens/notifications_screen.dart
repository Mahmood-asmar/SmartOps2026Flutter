import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/notification_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/notification_service.dart';
import 'package:smartops/core/services/notification_socket_service.dart';
import 'package:smartops/core/widgets/app_drawer.dart';
import 'package:smartops/core/widgets/app_footer.dart';
import 'package:smartops/core/widgets/app_top_bar.dart';
import 'package:smartops/features/notifications/widgets/notifications_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> notifications = [];

  bool isLoading = true;
  bool isActionLoading = false;
  bool _socketInitialized = false;

  String errorMessage = '';
  String selectedFilter = 'all';

  StreamSubscription<NotificationModel>? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initSocket();
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  int? _extractUserId(AuthProvider authProvider) {
    try {
      final dynamic user = authProvider.user;

      if (user == null) return null;

      if (user is Map<String, dynamic>) {
        final value = user['user_id'] ?? user['id'];

        if (value is int) return value;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value);
      }

      final dynamic value = user.userId ?? user.id;

      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
    } catch (_) {}

    return null;
  }

  void _initSocket() {
    if (_socketInitialized) return;

    final authProvider = context.read<AuthProvider>();

    final token = authProvider.token;

    if (token == null || token.isEmpty) return;

    _socketInitialized = true;

    NotificationSocketService.instance.connect(
      token: token,
      userId: _extractUserId(authProvider),
    );

    _notificationSubscription =
        NotificationSocketService.instance.notificationStream.listen(
              (notification) {
            if (!mounted) return;

            setState(() {
              final exists = notifications.any(
                    (item) => item.notificationId == notification.notificationId,
              );

              if (!exists) {
                notifications = [notification, ...notifications];
              }
            });
          },
        );
  }

  Future<void> loadNotifications() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final data = await NotificationService.getNotifications();

      final loadedNotifications = data
          .map(
            (item) => NotificationModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      loadedNotifications.sort((a, b) {
        final aDate = DateTime.tryParse(a.createdAt ?? '');
        final bDate = DateTime.tryParse(b.createdAt ?? '');

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      setState(() {
        notifications = loadedNotifications;
      });
    } catch (error) {
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

  List<NotificationModel> get filteredNotifications {
    if (selectedFilter == 'unread') {
      return notifications.where((item) => !item.isRead).toList();
    }

    if (selectedFilter == 'read') {
      return notifications.where((item) => item.isRead).toList();
    }

    return notifications;
  }

  int get totalCount {
    return notifications.length;
  }

  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  int get readCount {
    return notifications.where((item) => item.isRead).length;
  }

  double get readProgress {
    if (totalCount == 0) return 0;

    return readCount / totalCount;
  }

  Future<void> _markOneAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    setState(() {
      isActionLoading = true;
    });

    try {
      await NotificationService.markAsRead(notification.notificationId);

      setState(() {
        notifications = notifications.map((item) {
          if (item.notificationId == notification.notificationId) {
            return item.copyWith(isRead: true);
          }

          return item;
        }).toList();
      });
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
          isActionLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    if (unreadCount == 0) return;

    setState(() {
      isActionLoading = true;
    });

    try {
      await NotificationService.markAllAsRead();

      setState(() {
        notifications = notifications
            .map(
              (item) => item.copyWith(isRead: true),
        )
            .toList();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All notifications marked as read.'),
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
          isActionLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    setState(() {
      isActionLoading = true;
    });

    try {
      await NotificationService.deleteNotification(notification.notificationId);

      setState(() {
        notifications = notifications
            .where(
              (item) => item.notificationId != notification.notificationId,
        )
            .toList();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification deleted.'),
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
          isActionLoading = false;
        });
      }
    }
  }

  Widget _buildFilterChip({
    required String value,
    required String label,
    required int count,
  }) {
    final isSelected = selectedFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = value;
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
            onPressed: loadNotifications,
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
      child: Column(
        children: [
          const Icon(
            Icons.notifications_off_outlined,
            color: Color(0xFF98A2B3),
            size: 46,
          ),
          const SizedBox(height: 12),
          const Text(
            'No notifications found',
            style: TextStyle(
              color: Color(0xFF0B2E59),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            selectedFilter == 'all'
                ? 'You do not have notifications yet.'
                : 'No $selectedFilter notifications available.',
            textAlign: TextAlign.center,
            style: const TextStyle(
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
    final items = filteredNotifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      drawer: const AppDrawer(activePage: 'notifications'),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return RefreshIndicator(
              color: const Color(0xFF0B2E59),
              onRefresh: loadNotifications,
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
                      title: 'Notifications',
                      onMenuTap: () => _openDrawer(context),
                    ),

                    const SizedBox(height: 22),

                    const Text(
                      'Notifications',
                      style: TextStyle(
                        color: Color(0xFF0B2E59),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Communication center for project updates, tasks, and system activity.',
                      style: TextStyle(
                        color: Color(0xFF667085),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isActionLoading || unreadCount == 0
                                ? null
                                : _markAllAsRead,
                            icon: const Icon(Icons.done_all, size: 18),
                            label: Text(
                              isActionLoading
                                  ? 'Processing...'
                                  : 'Mark all read',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B2E59),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF98A2B3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: loadNotifications,
                            icon: const Icon(Icons.refresh, size: 18),
                            label: const Text('Refresh'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF0B2E59),
                              side: const BorderSide(
                                color: Color(0xFF0B2E59),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        _buildFilterChip(
                          value: 'all',
                          label: 'ALL',
                          count: totalCount,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          value: 'unread',
                          label: 'UNREAD',
                          count: unreadCount,
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          value: 'read',
                          label: 'READ',
                          count: readCount,
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
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
                            'OVERVIEW',
                            style: TextStyle(
                              color: Color(0xFFBFD4EA),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Unread notifications',
                            style: TextStyle(
                              color: Color(0xFFD8E3F0),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 14),
                          LinearProgressIndicator(
                            value: readProgress,
                            minHeight: 6,
                            backgroundColor: const Color(0xFF385274),
                            color: Colors.green.shade400,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    if (isLoading)
                      _buildLoading()
                    else if (errorMessage.isNotEmpty)
                      _buildError()
                    else if (items.isEmpty)
                        _buildEmpty()
                      else
                        Column(
                          children: items.map((notification) {
                            return NotificationCard(
                              notification: notification,
                              onMarkAsRead: () => _markOneAsRead(notification),
                              onDelete: () => _deleteNotification(notification),
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