import 'package:dio/dio.dart';
import 'package:smartops/core/services/api_service.dart';

class TemplateService {
  static Future<List<dynamic>> getTemplates() async {
    try {
      final response = await ApiService.dio.get('/project-templates');

      final data = response.data;

      if (data is List) return data;

      if (data is Map<String, dynamic>) {
        if (data['templates'] is List) return data['templates'];
        if (data['projectTemplates'] is List) return data['projectTemplates'];
        if (data['data'] is List) return data['data'];
      }

      return [];
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> createTemplate({
    required String name,
    required String description,
    required String category,
    required int estimatedDuration,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/project-templates',
        data: {
          'name': name,
          'description': description,
          'category': category,
          'estimated_duration': estimatedDuration,
        },
      );

      return _asMap(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> updateTemplate({
    required int templateId,
    required String name,
    required String description,
    required String category,
    required int estimatedDuration,
  }) async {
    try {
      final response = await ApiService.dio.put(
        '/project-templates/$templateId',
        data: {
          'name': name,
          'description': description,
          'category': category,
          'estimated_duration': estimatedDuration,
        },
      );

      return _asMap(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> deleteTemplate(int templateId) async {
    try {
      final response = await ApiService.dio.delete(
        '/project-templates/$templateId',
      );

      return _asMap(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> requestFromTemplate({
    required int templateId,
    required String name,
    required String description,
    required String category,
    required int estimatedDuration,
  }) async {
    try {
      final now = DateTime.now();
      final deadlineDate = now.add(Duration(days: estimatedDuration));

      final deadline =
          '${deadlineDate.year.toString().padLeft(4, '0')}-'
          '${deadlineDate.month.toString().padLeft(2, '0')}-'
          '${deadlineDate.day.toString().padLeft(2, '0')}';

      final response = await ApiService.dio.post(
        '/project-requests',
        data: {
          'project_name': name,
          'description': description,
          'category': category,
          'deadline': deadline,

          // Keep it if your backend stores the selected template.
          // If backend rejects template_id, remove this line only.
          'template_id': templateId,
        },
      );

      return _asMap(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> createCustomProjectRequest({
    required String projectName,
    required String description,
    required String category,
    required String deadline,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/project-requests',
        data: {
          'project_name': projectName,
          'description': description,
          'category': category,
          'deadline': deadline,
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
      return Exception('Invalid request data. Please check the fields.');
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