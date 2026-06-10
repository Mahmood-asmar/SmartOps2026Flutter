import 'package:dio/dio.dart';
import 'package:smartops/core/services/api_service.dart';

class NotificationService {
  static Future<List<dynamic>> getNotifications() async {
    try {
      final response = await ApiService.dio.get('/notifications');

      final data = response.data;

      if (data is List) return data;

      if (data is Map<String, dynamic>) {
        if (data['notifications'] is List) return data['notifications'];
        if (data['data'] is List) return data['data'];
        if (data['items'] is List) return data['items'];
      }

      return [];
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<void> markAsRead(int notificationId) async {
    try {
      try {
        await ApiService.dio.patch('/notifications/$notificationId/read');
        return;
      } on DioException catch (firstError) {
        if (firstError.response?.statusCode != 404) rethrow;
      }

      try {
        await ApiService.dio.put('/notifications/$notificationId/read');
        return;
      } on DioException catch (secondError) {
        if (secondError.response?.statusCode != 404) rethrow;
      }

      await ApiService.dio.patch(
        '/notifications/$notificationId',
        data: {
          'is_read': true,
        },
      );
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      try {
        await ApiService.dio.patch('/notifications/read-all');
        return;
      } on DioException catch (firstError) {
        if (firstError.response?.statusCode != 404) rethrow;
      }

      try {
        await ApiService.dio.put('/notifications/read-all');
        return;
      } on DioException catch (secondError) {
        if (secondError.response?.statusCode != 404) rethrow;
      }

      await ApiService.dio.patch('/notifications/mark-all-read');
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<void> deleteNotification(int notificationId) async {
    try {
      await ApiService.dio.delete('/notifications/$notificationId');
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Exception _handleDioError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
        final messages = (data['errors'] as List)
            .map((item) => item['message'].toString())
            .join('\n');

        return Exception(messages);
      }

      if (data['message'] != null) {
        return Exception(data['message'].toString());
      }

      if (data['error'] != null) {
        return Exception(data['error'].toString());
      }
    }

    if (statusCode == 401) {
      return Exception('Unauthorized. Please login again.');
    }

    if (statusCode == 403) {
      return Exception('You do not have permission to view notifications.');
    }

    if (statusCode == 404) {
      return Exception('Notifications endpoint was not found.');
    }

    if (statusCode == 500) {
      return Exception('Server error. Please try again later.');
    }

    return Exception(
      'Something went wrong. Status code: ${statusCode ?? 'unknown'}',
    );
  }
}