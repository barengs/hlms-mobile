import 'package:dio/dio.dart';
import 'package:hlms_mobile/core/network/api_client.dart';

class InstructorRepository {
  final ApiClient _apiClient;

  InstructorRepository(this._apiClient);

  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      // The API endpoint is likely /instructor/dashboard based on standard conventions 
      // but let's check what the mobile API route actually is if needed, 
      // usually it's just 'instructor/dashboard' based on the api.php
      final response = await _apiClient.dio.get('instructor/dashboard');
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat dashboard');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<List<dynamic>> getCourses() async {
    try {
      final response = await _apiClient.dio.get('instructor/courses');
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['data'] != null) {
          return response.data['data'] as List<dynamic>;
        } else if (response.data is List) {
          return response.data as List<dynamic>;
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar kelas');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<List<dynamic>> getPayouts() async {
    try {
      final response = await _apiClient.dio.get('instructor/payouts');
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['data'] != null) {
          return response.data['data'] as List<dynamic>;
        } else if (response.data is List) {
          return response.data as List<dynamic>;
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar redeem');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<void> requestPayout({
    required double amount,
    required String method,
    required String accountInfo,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'instructor/payouts',
        data: {
          'amount': amount,
          'method': method,
          'account_info': accountInfo,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Gagal memproses penarikan');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }
}
