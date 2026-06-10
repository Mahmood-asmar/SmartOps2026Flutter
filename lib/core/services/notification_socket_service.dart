import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:smartops/core/models/notification_model.dart';

class NotificationSocketService {
  NotificationSocketService._();

  static final NotificationSocketService instance =
  NotificationSocketService._();

  io.Socket? _socket;
  bool _isConnected = false;

  final StreamController<NotificationModel> _notificationController =
  StreamController<NotificationModel>.broadcast();

  Stream<NotificationModel> get notificationStream {
    return _notificationController.stream;
  }

  bool get isConnected {
    return _isConnected;
  }

  void connect({
    required String token,
    int? userId,
  }) {
    if (_socket != null && _isConnected) return;

    _socket = io.io(
      'https://smartops2026backend.onrender.com',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({
        'token': token,
      })
          .setQuery({
        if (userId != null) 'userId': userId.toString(),
      })
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;

      if (userId != null) {
        _socket!.emit('join_user', userId);
        _socket!.emit('joinUser', userId);
        _socket!.emit('register_user', userId);
        _socket!.emit('join', 'user_$userId');
      }
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
    });

    _socket!.onConnectError((_) {
      _isConnected = false;
    });

    _socket!.onError((_) {
      _isConnected = false;
    });

    _listenForNotification('new_notification');
    _listenForNotification('notification:new');
    _listenForNotification('notification_created');
    _listenForNotification('receive_notification');
    _listenForNotification('notifications:new');
  }

  void _listenForNotification(String eventName) {
    _socket?.off(eventName);

    _socket?.on(eventName, (data) {
      try {
        if (data is Map) {
          final notification = NotificationModel.fromJson(
            Map<String, dynamic>.from(data),
          );

          _notificationController.add(notification);
          return;
        }

        if (data is List && data.isNotEmpty && data.first is Map) {
          final notification = NotificationModel.fromJson(
            Map<String, dynamic>.from(data.first),
          );

          _notificationController.add(notification);
        }
      } catch (_) {}
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }
}