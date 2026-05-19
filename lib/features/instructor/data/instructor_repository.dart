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

  Future<List<dynamic>> getStudents() async {
    try {
      final response = await _apiClient.dio.get('instructor/students');
      if (response.statusCode == 200) {
        if (response.data is Map && response.data['data'] != null) {
          return response.data['data'] as List<dynamic>;
        } else if (response.data is List) {
          return response.data as List<dynamic>;
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat daftar siswa');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<List<dynamic>> getSubmissions({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) {
        queryParams['status'] = status;
      }
      final response = await _apiClient.dio.get('instructor/submissions', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map) {
          if (data['data'] is List) {
            return data['data'] as List<dynamic>;
          }
        } else if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat pengumpulan tugas');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<void> gradeSubmission({
    required int submissionId,
    required double pointsAwarded,
    String? feedback,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'instructor/submissions/$submissionId/grade',
        data: {
          'points_awarded': pointsAwarded,
          'instructor_feedback': feedback,
        },
      );
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Gagal menilai tugas');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> aiGradeSubmission(int submissionId) async {
    try {
      final response = await _apiClient.dio.post('instructor/submissions/$submissionId/ai-grade');
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memicu penilaian AI');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<List<dynamic>> getDiscussions() async {
    try {
      final response = await _apiClient.dio.get('discussions');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] is List) {
          return data['data'] as List<dynamic>;
        } else if (data is List) {
          return data;
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal memuat diskusi');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }

  Future<void> replyToDiscussion({
    required int parentId,
    required String content,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'discussions',
        data: {
          'parent_id': parentId,
          'content': content,
          'type': 'discussion',
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Gagal mengirim balasan');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan jaringan';
      throw Exception(message);
    }
  }
}

