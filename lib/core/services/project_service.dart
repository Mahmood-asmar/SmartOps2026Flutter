import 'package:dio/dio.dart';
import 'package:smartops/core/services/api_service.dart';

class ProjectService {
  static Future<List<dynamic>> getProjects() async {
    try {
      final response = await ApiService.dio.get('/projects');

      final data = response.data;

      if (data is List) return data;

      if (data is Map<String, dynamic>) {
        if (data['projects'] is List) return data['projects'];
        if (data['data'] is List) return data['data'];
      }

      return [];
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> getProjectDetails(int projectId) async {
    try {
      final response = await ApiService.dio.get('/projects/$projectId');

      final data = response.data;

      if (data is Map<String, dynamic>) {
        if (data['project'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data['project']);
        }

        if (data['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data['data']);
        }

        return Map<String, dynamic>.from(data);
      }

      return {};
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> updateProject({
    required int projectId,
    String? status,
    String? priority,
  }) async {
    final payload = <String, dynamic>{};

    if (status != null) payload['status'] = status;
    if (priority != null) payload['priority'] = priority;

    try {
      final response = await ApiService.dio.patch(
        '/projects/$projectId',
        data: payload,
      );

      return _asMap(response.data);
    } on DioException catch (patchError) {
      final statusCode = patchError.response?.statusCode;

      if (statusCode == 404 || statusCode == 405) {
        try {
          final response = await ApiService.dio.put(
            '/projects/$projectId',
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

    if (statusCode == 401) {
      return Exception('Unauthorized. Please login again.');
    }

    if (statusCode == 403) {
      return Exception('You do not have permission to perform this action.');
    }

    if (statusCode == 404) {
      return Exception('Requested resource was not found.');
    }

    if (statusCode == 500) {
      return Exception('Server error. Please try again later.');
    }

    return Exception(
      'Something went wrong. Status code: ${statusCode ?? 'unknown'}',
    );
  }
}