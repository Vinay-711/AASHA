import 'dart:io';
import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';

abstract class ARRemoteSource {
  Future<Map<String, dynamic>> scanImage(File imageFile,
      {Map<String, dynamic>? location});
}

class ARRemoteSourceImpl implements ARRemoteSource {
  final ApiClient apiClient;
  ARRemoteSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> scanImage(
    File imageFile, {
    Map<String, dynamic>? location,
  }) async {
    try {
      final result = await apiClient.uploadFile<Map<String, dynamic>>(
        '/api/v1/ar/scan',
        file: imageFile,
        additionalData:
            location != null ? {'location': location.toString()} : null,
      );
      return result;
    } catch (_) {
      throw ServerException();
    }
  }
}
