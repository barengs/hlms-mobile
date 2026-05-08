import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenInterceptor extends Interceptor {
  final Dio dio;

  TokenInterceptor(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('auth_token'); // In JWT, the token itself is often used for refresh

      if (refreshToken != null) {
        try {
          // Avoid infinite loops if refresh fails
          if (err.requestOptions.path.contains('auth/refresh')) {
            return super.onError(err, handler);
          }

          // Attempt to refresh the token
          final response = await dio.post('auth/refresh');
          
          if (response.statusCode == 200) {
            final newToken = response.data['data']['token'];
            final expiresAt = response.data['data']['expires_at'];
            
            // Save new token
            await prefs.setString('auth_token', newToken);
            if (expiresAt != null) {
              await prefs.setString('auth_token_expires_at', expiresAt);
            }

            // Retry the original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            final cloneReq = await dio.request(
              err.requestOptions.path,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
            );
            
            return handler.resolve(cloneReq);
          }
        } catch (e) {
          // Refresh failed, clear session and redirect to login
          await prefs.remove('auth_token');
          await prefs.remove('hlms_user');
          // Navigate to login (need context or a navigation service)
        }
      }
    }
    return super.onError(err, handler);
  }
}
