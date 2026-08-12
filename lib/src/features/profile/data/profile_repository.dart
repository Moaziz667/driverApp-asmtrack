import 'package:dio/dio.dart';

import '../../../services/api_client.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  Future<DriverProfile> fetchProfile() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/driver/profile');
    return DriverProfile.fromJson(response.data ?? {});
  }

  Future<DriverStats> fetchStats() async {
    final response = await _client.dio.get<Map<String, dynamic>>('/driver/stats');
    return DriverStats.fromJson(response.data ?? {});
  }

  /// Reports the driver's position — to DeliveryService, not DriverService.
  ///
  /// Both expose a `/location` endpoint and only one of them broadcasts. DriverService writes the
  /// coordinates to the driver row and stops there; DeliveryService also records a tracking point
  /// and publishes the realtime events the admin map and the customer's public tracking page
  /// subscribe to — then forwards the position to DriverService anyway, so the row is still updated.
  ///
  /// Posting to the silent one is why the customer's map only moved when the page was reloaded: the
  /// data was right, nobody was told about it.
  Future<void> updateLocation(double lat, double lng) async {
    await _client.dio.post('/driver/deliveries/location', data: {'lat': lat, 'lng': lng});
  }

  /// Uploads the driver's profile photo (multipart). The backend re-encodes + stores it.
  Future<void> uploadPhoto(String filePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
    });
    await _client.dio.post('/driver/me/photo', data: form);
  }

  Future<String> updateAvailability(String status) async {
    final response = await _client.dio.patch<Map<String, dynamic>>(
      '/driver/availability',
      data: {'status': status},
    );
    return response.data?['status'] as String? ?? status;
  }
}
