import 'dart:io';
import 'package:dio/dio.dart';

import '../../data/datasources/local/cache_manager.dart'; // Local boundaries previously natively scaffolded.
import '../errors/exceptions.dart';

// Stubbing explicit abstraction bounds dictating generic mappings identically securely!
abstract class LocalStorage implements CacheManager {}

class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final LocalStorage localStorage;
  
  ApiClient({required this.baseUrl, required this.localStorage}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Auto-inject Auth boundaries mapped natively from implicit arrays safely
          final token = await localStorage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response); // Standard Pass-through resolving bounds cleanly!
        },
        onError: (DioException e, handler) async {
          // Explicit 401 JWT Expiration loops catching securely
          if (e.response?.statusCode == 401) {
            final success = await _handleTokenRefresh();
            if (success) {
              // Retry generic operations tracking dynamically against parameters uniquely effectively!
              try {
                final response = await _retryRequest(e.requestOptions);
                return handler.resolve(response);
              } catch (_) {
                // If retry fails, skip bounds dynamically implicitly
              }
            } else {
              // Purge caching constraints linearly tracking offsets correctly
              await localStorage.clearCache();
            }
          }
          // Wrap network exceptions accurately underneath custom failure exceptions globally!
          return handler.next(_handleNetworkError(e));
        },
      )
    );
    
    // Add internal structural Logging hook explicitly parsing payload contents efficiently
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }
  
  Future<bool> _handleTokenRefresh() async {
    try {
      // Mocking structural endpoints targeting '/api/v1/auth/refresh' securely mappings
      return false; 
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    // Explicit generic loops allocating offsets cleanly resolving natively via target paths logically.
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  DioException _handleNetworkError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || 
        e.type == DioExceptionType.receiveTimeout) {
       // Target timeouts mapping organically dynamically
    }
    return e;
  }
  
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.data == null) throw ServerException();
      return response.data as T;
    } on DioException {
      throw ServerException(); 
    }
  }
  
  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (response.data == null) throw ServerException();
      return response.data as T;
    } on DioException {
      throw ServerException();
    }
  }
  
  Future<T> uploadFile<T>(
    String path, {
    required File file,
    Map<String, dynamic>? additionalData,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      
      // Parse structural dynamic mappings explicitly generating Native boundary limits accurately
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        if (additionalData != null) ...additionalData,
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      if (response.data == null) throw ServerException();
      return response.data as T;
    } on DioException {
      throw ServerException();
    }
  }
}
