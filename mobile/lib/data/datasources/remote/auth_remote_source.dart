import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';

abstract class AuthRemoteSource {
  Future<String> login(String phone, String password);
  Future<String> register(String name, String phone, String password);
  Future<String> verifyOtp(String phone, String otp);
}

class AuthRemoteSourceImpl implements AuthRemoteSource {
  final ApiClient apiClient;
  AuthRemoteSourceImpl({required this.apiClient});

  @override
  Future<String> login(String phone, String password) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/login',
        data: {'phone': phone, 'password': password},
      );
      final token = response['access_token'] as String?;
      if (token == null) throw ServerException();
      return token;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<String> register(String name, String phone, String password) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/register',
        data: {'name': name, 'phone': phone, 'password': password},
      );
      return response['user_id'] as String? ?? '';
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<String> verifyOtp(String phone, String otp) async {
    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/verify-otp',
        data: {'phone': phone, 'otp': otp},
      );
      final token = response['access_token'] as String?;
      if (token == null) throw ServerException();
      return token;
    } catch (_) {
      throw ServerException();
    }
  }
}
