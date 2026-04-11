import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';

abstract class MedicationRemoteSource {
  Future<List<Map<String, dynamic>>> getMedications();
  Future<Map<String, dynamic>> addMedication(Map<String, dynamic> data);
  Future<void> logAdherence(String medicationId, String status,
      String scheduledFor,
      {String? notes});
  Future<List<Map<String, dynamic>>> getMedicationLogs(String medicationId);
}

class MedicationRemoteSourceImpl implements MedicationRemoteSource {
  final ApiClient apiClient;
  MedicationRemoteSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getMedications() async {
    try {
      final result =
          await apiClient.get<List<dynamic>>('/api/v1/medications/');
      return result.cast<Map<String, dynamic>>();
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>> addMedication(
      Map<String, dynamic> data) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/medications/',
        data: data,
      );
      return result;
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<void> logAdherence(String medicationId, String status,
      String scheduledFor,
      {String? notes}) async {
    try {
      await apiClient.post<Map<String, dynamic>>(
        '/api/v1/medications/$medicationId/log',
        data: {
          'status': status,
          'scheduled_for': scheduledFor,
          if (notes != null) 'notes': notes,
        },
      );
    } catch (_) {
      throw ServerException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMedicationLogs(
      String medicationId) async {
    try {
      final result = await apiClient
          .get<List<dynamic>>('/api/v1/medications/$medicationId/logs');
      return result.cast<Map<String, dynamic>>();
    } catch (_) {
      throw ServerException();
    }
  }
}
