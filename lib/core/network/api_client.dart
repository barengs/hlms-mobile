import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'token_interceptor.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://molang.umediatama.com/api/v1/', // Production API URL
      // baseUrl: 'http://10.0.2.2:8000/api/v1/', // Local API URL for Android Emulator
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    
    _dio.interceptors.add(TokenInterceptor(_dio));
  }

  Dio get dio => _dio;
}
