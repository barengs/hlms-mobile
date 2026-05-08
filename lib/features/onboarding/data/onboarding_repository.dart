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

  Future<void> submitOnboarding(List<Map<String, dynamic>> answers) async {
    try {
      final response = await _apiClient.dio.post('mobile/student/onboarding/submit', data: {
        'answers': answers,
      });
      if (response.statusCode != 200) {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan minat');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengirim survey');
    }
  }
}
