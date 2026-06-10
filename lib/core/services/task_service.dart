import 'package:dio/dio.dart';
import 'package:smartops/core/services/api_service.dart';

class TaskService {
  static Future<List<dynamic>> getTasks() async {
    try {
      final response = await ApiService.dio.get('/tasks');

      final data = response.data;

      if (data is List) return data;

      if (data is Map<String, dynamic>) {
        if (data['tasks'] is List) return data['tasks'];
        if (data['data'] is List) return data['data'];
      }

      return [];
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> updateTask({
    required int taskId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? deadline,
    int? assignedUser,
    int? projectId,
  }) async {
    final payload = <String, dynamic>{};

    if (title != null) payload['title'] = title;
    if (description != null) payload['description'] = description;
    if (status != null) payload['status'] = status;
    if (priority != null) payload['priority'] = priority;
    if (deadline != null) payload['deadline'] = deadline;
    if (assignedUser != null) payload['assigned_user'] = assignedUser;
    if (projectId != null) payload['project_id'] = projectId;

    try {
      final response = await ApiService.dio.patch(
        '/tasks/$taskId',
        data: payload,
      );

      return _asMap(response.data);
    } on DioException catch (patchError) {
      final statusCode = patchError.response?.statusCode;

      if (statusCode == 404 || statusCode == 405) {
        try {
          final response = await ApiService.dio.put(
            '/tasks/$taskId',
            data: payload,
          );

          return _asMap(response.data);
        } on DioException catch (putError) {
          throw _handleDioError(putError);
        }
      }

      throw _handleDioError(patchError);
    }
  }

  static Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required int assignedUser,
    required int projectId,
    required String deadline,
    required String priority,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/tasks',
        data: {
          'title': title,
          'description': description,
          'assigned_user': assignedUser,
          'project_id': projectId,
          'deadline': deadline,
          'priority': priority,
          'status': 'pending',
        },
      );

      return _asMap(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    return {
      'message': 'Success',
      'data': data,
    };
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
    }

    if (statusCode == 400) {
      return Exception('Invalid task data. Please check the fields.');
    }

    if (statusCode == 401) {
      return Exception('Unauthorized. Please login again.');
    }

    if (statusCode == 403) {
      return Exception('You do not have permission to perform this action.');
    }

    if (statusCode == 404) {
      return Exception('Requested task was not found.');
    }

    if (statusCode == 500) {
      return Exception('Server error. Please try again later.');
    }

    return Exception(
      'Something went wrong. Status code: ${statusCode ?? 'unknown'}',
    );
  }
}