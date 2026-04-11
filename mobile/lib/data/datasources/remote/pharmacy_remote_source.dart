import 'dart:io';
import '../../../core/network/api_client.dart';
import '../../../core/errors/exceptions.dart';

abstract class PharmacyRemoteSource {
  Future<List<Map<String, dynamic>>> searchMedicine({
    required String medicineName,
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    bool inStockOnly = false,
  });
}

class PharmacyRemoteSourceImpl implements PharmacyRemoteSource {
  final ApiClient apiClient;
  PharmacyRemoteSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> searchMedicine({
    required String medicineName,
    required double lat,
    required double lng,
    double radiusKm = 5.0,
    bool inStockOnly = false,
  }) async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/pharmacy/search',
        queryParameters: {
          'medicine_name': medicineName,
          'lat': lat,
          'lng': lng,
          'radius_km': radiusKm,
          'in_stock_only': inStockOnly,
        },
      );
      final responseData = result as Map<String, dynamic>;
      final pharmacies = responseData['pharmacies'] as List<dynamic>;
      return pharmacies.cast<Map<String, dynamic>>();
    } catch (_) {
      throw ServerException();
    }
  }
}
