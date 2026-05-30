import 'package:dio/dio.dart';
import 'package:smartops/core/services/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await ApiService.dio.get('/auth/me');

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );

      return Map<String, dynamic>.from(response.data);
    } on DioException catch (error) {
      throw _handleDioError(error);
    }
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/auth/reset-password',
        data: {
          'email': email,
          'newPassword': newPassword,
        },
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