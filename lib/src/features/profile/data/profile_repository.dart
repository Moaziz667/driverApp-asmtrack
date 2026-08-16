import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../../services/api_client.dart';
import '../models/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final ApiClient _client;

  static const _profileKey = 'cached_driver_profile';
  static const _statsKey = 'cached_driver_stats';

  Box get _box => Hive.box('domain_cache');

  /// Cached alongside the route and the deliveries, and for the same reason: this is what identifies
  /// the driver. Without it a cold start with no signal left the app authenticated but faceless —
  /// tokens read from disk, then an empty shell, because the very first call it makes needs network.
  /// The profile changes rarely, so a stale copy is far better than none.
  Future<DriverProfile> fetchProfile() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/driver/profile');
      final body = response.data ?? <String, dynamic>{};
      try {
        await _box.put(_profileKey, jsonEncode(body));
      } catch (_) {}
      return DriverProfile.fromJson(body);
    } on DioException catch (e) {
      // No HTTP response at all = network-level (offline, DNS, timeout).
      if (e.response == null) {
        final cached = _cached(_profileKey);
        if (cached != null) return DriverProfile.fromJson(cached);
      }
      rethrow;
    }
  }

  Future<DriverStats> fetchStats() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/driver/stats');
      final body = response.data ?? <String, dynamic>{};
      try {
        await _box.put(_statsKey, jsonEncode(body));
      } catch (_) {}
      return DriverStats.fromJson(body);
    } on DioException catch (e) {
      if (e.response == null) {
        final cached = _cached(_statsKey);
        if (cached != null) return DriverStats.fromJson(cached);
      }
      rethrow;
    }
  }

  Map<String, dynamic>? _cached(String key) {
    try {
      final raw = _box.get(key) as String?;
      return raw != null ? jsonDecode(raw) as Map<String, dynamic> : null;
    } catch (_) {
      return null;
    }
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
