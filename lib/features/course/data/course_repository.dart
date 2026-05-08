import 'package:dio/dio.dart';
import 'package:hlms_mobile/core/models/course.dart';
import 'package:hlms_mobile/core/models/enrollment.dart';
import 'package:hlms_mobile/core/network/api_client.dart';

class CourseRepository {
  final ApiClient _apiClient;

  CourseRepository(this._apiClient);

  Future<List<Course>> getLatestCourses() async {
    try {
      final response = await _apiClient.dio.get('public/courses', queryParameters: {
        'sort': 'latest',
        'per_page': 10,
      });

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat kursus terbaru');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan jaringan');
    }
  }

  Future<List<Enrollment>> getMyLearning() async {
    try {
      final response = await _apiClient.dio.get('mobile/student/my-learning', queryParameters: {
        '_': DateTime.now().millisecondsSinceEpoch,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> dataMap = response.data['data'];
        final List<dynamic> courses = dataMap['courses'] ?? [];
        final List<dynamic> batches = dataMap['batches'] ?? [];
        final List<dynamic> classes = dataMap['classes'] ?? [];
        
        final List<Enrollment> allLearning = [];
        allLearning.addAll(courses.map((j) => Enrollment.fromJson(j)));
        allLearning.addAll(batches.map((j) => Enrollment.fromJson(j)));
        allLearning.addAll(classes.map((j) => Enrollment.fromJson(j)));
        
        return allLearning;
      } else {
        throw Exception('Gagal memuat kursus saya');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan jaringan');
    }
  }

  Future<List<Enrollment>> getLearningHistory() async {
    try {
      final response = await _apiClient.dio.get('student/learning-history');

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => Enrollment.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat riwayat pembelajaran');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan jaringan');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('public/categories');

      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat kategori');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan jaringan');
    }
  }

  Future<Course> getCourseDetail(String slug) async {
    try {
      final response = await _apiClient.dio.get('public/courses/$slug');

      if (response.statusCode == 200) {
        return Course.fromJson(response.data['data'], response.data['meta']);
      } else {
        throw Exception('Gagal memuat detail kursus');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan jaringan');
    }
  }

  Future<Map<String, dynamic>> getLearningDetail(String slug) async {
    try {
      final response = await _apiClient.dio.get('mobile/student/courses/$slug');
      return response.data['data'];
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw Exception('Gagal memuat silabus (Status: ${e.response?.statusCode}): $msg');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Map<String, dynamic>> getLessonDetail(String slug, int lessonId) async {
    try {
      final response = await _apiClient.dio.get('mobile/student/courses/$slug/lessons/$lessonId');
      return response.data['data'];
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw Exception('Gagal memuat materi (Status: ${e.response?.statusCode}): $msg');
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<void> markLessonComplete(String slug, int lessonId) async {
    try {
      await _apiClient.dio.post('mobile/student/courses/$slug/lessons/$lessonId/complete');
    } catch (e) {
      throw Exception('Gagal memperbarui progres');
    }
  }

  Future<Map<String, dynamic>> getAssignmentDetail(int assignmentId) async {
    try {
      final response = await _apiClient.dio.get('mobile/student/assignments/$assignmentId');
      return response.data['data'];
    } catch (e) {
      throw Exception('Gagal memuat detail tugas');
    }
  }

  Future<Map<String, dynamic>> getQuizDetail(int quizId) async {
    try {
      final response = await _apiClient.dio.get('mobile/student/quizzes/$quizId');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat detail kuis');
    } catch (e) {
      throw Exception('Terjadi kesalahan saat memuat kuis');
    }
  }

  Future<Map<String, dynamic>> submitAssignment({
    required int assignmentId,
    String? content,
    Map<String, dynamic>? answers,
    String? filePath,
  }) async {
    try {
      FormData formData = FormData();
      if (content != null && content.isNotEmpty) {
        formData.fields.add(MapEntry('content', content));
      }
      if (answers != null) {
        answers.forEach((key, value) {
          formData.fields.add(MapEntry('answers[$key]', value.toString()));
        });
      }
      if (filePath != null) {
        formData.files.add(MapEntry(
          'file',
          await MultipartFile.fromFile(filePath),
        ));
      }

      final response = await _apiClient.dio.post(
        'mobile/student/assignments/$assignmentId/submit',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Return the full response so the UI can show message + meta
        return {
          'message': response.data['message'] ?? 'Tugas berhasil dikumpulkan!',
          'data': response.data['data'],
          'meta': response.data['meta'] ?? {},
        };
      } else {
        throw Exception(response.data['message'] ?? 'Gagal mengumpulkan tugas');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan saat mengumpulkan tugas');
    }
  }
  Future<Map<String, dynamic>> submitQuiz({
    required int quizId,
    required Map<String, String> answers,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        'mobile/student/quizzes/$quizId/submit',
        data: {'answers': answers},
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mengumpulkan kuis');
    }
  }

  Future<List<Map<String, dynamic>>> getAssignments() async {
    try {
      final response = await _apiClient.dio.get('mobile/student/assignments');
      if (response.statusCode == 200) {
        final List data = response.data['data']; 
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal memuat daftar tugas');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Terjadi kesalahan jaringan');
    }
  }
  Future<void> addToCart(int courseId) async {
    try {
      await _apiClient.dio.post('cart', data: {'course_id': courseId});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal menambahkan ke keranjang');
    }
  }

  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _apiClient.dio.get('cart');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat keranjang');
    }
  }

  Future<Map<String, dynamic>> processCheckout([Map<String, dynamic>? data]) async {
    try {
      final response = await _apiClient.dio.post('checkout/process', data: data);
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memproses checkout');
    }
  }

  Future<void> enrollCourse(String slug) async {
    try {
      await _apiClient.dio.post('mobile/student/courses/$slug/enroll');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal mendaftar kursus');
    }
  }

  Future<List<Course>> getRecommendations() async {
    try {
      final response = await _apiClient.dio.get('mobile/student/recommendations');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return data.map((json) => Course.fromJson(json)).toList();
      } else {
        throw Exception('Gagal memuat rekomendasi');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Gagal memuat rekomendasi');
    }
  }
}
