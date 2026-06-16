import '../../../services/api_client.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<DriverProfile> fetchProfile() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/api/driver/profile');
    return DriverProfile.fromJson(response.data ?? {});
  }

  Future<DriverStats> fetchStats() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/api/driver/stats');
    return DriverStats.fromJson(response.data ?? {});
  }

  Future<void> updateLocation(double lat, double lng) async {
    await _client.dio.post('/api/driver/location', data: {'lat': lat, 'lng': lng});
  }

  Future<String> updateAvailability(String status) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      '/api/driver/availability',
      data: {'status': status},
    );
    return response.data?['status'] as String? ?? status;
  }
}
