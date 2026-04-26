import 'package:hlms_mobile/core/network/api_client.dart';

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  Future<void> deleteAccount() async {
    try {
      final response = await _apiClient.dio.delete('/profile');
      if (response.statusCode != 200) {
        throw Exception('Gagal menghapus akun');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus akun');
    }
  }
  
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/profile');
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal memuat profil');
    }
  }
}
