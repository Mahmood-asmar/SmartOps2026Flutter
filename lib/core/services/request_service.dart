import 'package:dio/dio.dart';
import 'package:smartops/core/services/api_service.dart';

class RequestService {
  static Future<List<dynamic>> getProjectRequests() async {
    try {
      final response = await ApiService.dio.get('/project-requests');

      final data = response.data;

      if (data is List) return data;

      if (data is Map<String, dynamic>) {
        if (data['requests'] is List) return data['requests'];
        if (data['projectRequests'] is List) return data['projectRequests'];
        if (data['data'] is List) return data['data'];
      }

      return [];
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> approveRequest(int requestId) async {
    try {
      final response = await ApiService.dio.patch(
        '/project-requests/$requestId/approve',
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> rejectRequest({
    required int requestId,
    required String rejectionReason,
  }) async {
    try {
      final response = await ApiService.dio.patch(
        '/project-requests/$requestId/reject',
        data: {
          'rejection_reason': rejectionReason,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> deleteRequest(int requestId) async {
    try {
      final response = await ApiService.dio.delete(
        '/project-requests/$requestId',
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Exception _handleDioError(DioException error) {
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

    return Exception('Something went wrong. Please try again.');
  }
}