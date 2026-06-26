import 'package:hlms_mobile/core/network/api_client.dart';
import 'package:dio/dio.dart';

class OnboardingRepository {
  final ApiClient _apiClient;

  OnboardingRepository(this._apiClient);

  Future<List<dynamic>> getQuestions() async {
    try {
      final response = await _apiClient.dio.get('mobile/student/onboarding/questions');
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal memuat pertanyaan onboarding');
    }
  }

  Future<List<dynamic>> submitOnboarding(List<Map<String, dynamic>> answers) async {
    try {
      final response = await _apiClient.dio.post('mobile/student/onboarding/submit', data: {
        'answers': answers,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data != null && data['courses'] is List) {
           return data['courses'] as List<dynamic>;
        }
        return [];
      } else {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan minat');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengirim survey');
    }
  }
}
