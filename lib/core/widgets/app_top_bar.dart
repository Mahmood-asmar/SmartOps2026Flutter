import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:smartops/core/models/notification_model.dart';
import 'package:smartops/core/provider/auth_provider.dart';
import 'package:smartops/core/services/notification_service.dart';
import 'package:smartops/core/services/notification_socket_service.dart';
import 'package:smartops/features/notifications/screens/notifications_screen.dart';

class AppTopBar extends StatefulWidget {
  final VoidCallback onMenuTap;
  final String? title;

  const AppTopBar({
    super.key,
    required this.onMenuTap,
    this.title,
  });

  @override
  State<AppTopBar> createState() => _AppTopBarState();
}

class _AppTopBarState extends State<AppTopBar> {
  int unreadCount = 0;
  bool isLoadingNotifications = false;

  StreamSubscription<NotificationModel>? _notificationSubscription;
  bool _socketInitialized = false;

  @override
  void initState() {
    super.initState();
    loadUnreadCount();
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

  String _getInitial(String name) {
    if (name.trim().isEmpty) return 'U';

    return name.trim().characters.first.toUpperCase();
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
              if (!notification.isRead) {
                unreadCount++;
              }
            });
          },
        );
  }

  Future<void> loadUnreadCount() async {
    setState(() {
      isLoadingNotifications = true;
    });

    try {
      final data = await NotificationService.getNotifications();

      final notifications = data
          .map(
            (item) => NotificationModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      if (!mounted) return;

      setState(() {
        unreadCount = notifications
            .where((notification) => notification.isRead == false)
            .length;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        unreadCount = 0;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoadingNotifications = false;
        });
      }
    }
  }

  Future<void> _goToNotifications(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );

    if (!mounted) return;

    loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final userName = authProvider.userName;
    final userEmail = authProvider.userEmail;
    final userInitial = _getInitial(userName);

    return Row(
      children: [
        IconButton(
          onPressed: widget.onMenuTap,
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF0B2E59),
            size: 28,
          ),
        ),

        const SizedBox(width: 8),

        if (widget.title != null)
          Expanded(
            child: Text(
              widget.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF0B2E59),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          )
        else
          const Spacer(),

        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => _goToNotifications(context),
              icon: const Icon(
                Icons.notifications_none,
                color: Color(0xFF0B2E59),
              ),
            ),

            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: const Color(0xFFF5F7FA),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),

            if (isLoadingNotifications && unreadCount == 0)
              const Positioned(
                right: 8,
                top: 8,
                child: SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Color(0xFF0B2E59),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 4),

        Tooltip(
          message: userEmail.isNotEmpty ? userEmail : userName,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF0B2E59),
            child: Text(
              userInitial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}