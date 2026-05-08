import 'package:hlms_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';

class ClassroomRepository {
  final ApiClient _apiClient;

  ClassroomRepository(this._apiClient);

  Future<Map<String, dynamic>> getClassDetail(int classId) async {
    try {
      final response = await _apiClient.dio.get('classes/$classId');
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal memuat detail kelas');
    }
  }

  Future<List<dynamic>> getClassStream(int classId) async {
    try {
      final response = await _apiClient.dio.get('classes/$classId/stream');
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal memuat stream kelas');
    }
  }

  Future<List<dynamic>> getClassWork(int classId) async {
    try {
      final response = await _apiClient.dio.get('classes/$classId/work');
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal memuat tugas kelas');
    }
  }

  Future<Map<String, dynamic>> getClassPeople(int classId) async {
    try {
      final response = await _apiClient.dio.get('classes/$classId/people');
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal memuat daftar anggota kelas');
    }
  }

  Future<void> joinClass(String classCode) async {
    try {
      final response = await _apiClient.dio.post('mobile/student/batches/join', data: {
        'class_code': classCode,
      });
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Gagal bergabung');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal bergabung dengan kelas');
    }
  }

  Future<bool> toggleActivityComplete(int activityId) async {
    try {
      final response = await _apiClient.dio.post('classes/activities/$activityId/toggle-complete');
      return response.data['data']['completed'] == true;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memperbarui status');
    }
  }
}
