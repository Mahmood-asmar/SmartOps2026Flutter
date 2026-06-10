import 'package:dio/dio.dart';
import 'package:smartops/core/services/api_service.dart';

class UserService {
  static Future<List<dynamic>> getUsers() async {
    try {
      final response = await ApiService.dio.get('/users');

      final data = response.data;

      if (data is List) return data;

      if (data is Map<String, dynamic>) {
        if (data['users'] is List) return data['users'];
        if (data['data'] is List) return data['data'];
      }

      return [];
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/users',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );

      return _asMap(response.data);
    } on DioException catch (firstError) {
      final statusCode = firstError.response?.statusCode;

      if (statusCode == 404 || statusCode == 405) {
        try {
          final response = await ApiService.dio.post(
            '/users/create',
            data: {
              'name': name,
              'email': email,
              'password': password,
              'role': role,
            },
          );

          return _asMap(response.data);
        } on DioException catch (secondError) {
          throw _handleDioError(secondError);
        }
      }

      throw _handleDioError(firstError);
    }
  }

  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await ApiService.dio.delete('/users/$userId');

      return _asMap(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;

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

      if (data['error'] != null) {
        return Exception(data['error'].toString());
      }
    }

    if (statusCode == 400) {
      return Exception('Invalid user data. Please check the fields.');
    }

    if (statusCode == 401) {
      return Exception('Unauthorized. Please login again.');
    }

    if (statusCode == 403) {
      return Exception('Admin access required.');
    }

    if (statusCode == 404) {
      return Exception('Users endpoint was not found.');
    }

    if (statusCode == 409) {
      return Exception('Email already exists.');
    }

    if (statusCode == 500) {
      return Exception('Server error. Please try again later.');
    }

    return Exception(
      'Something went wrong. Status code: ${statusCode ?? 'unknown'}',
    );
  }
}