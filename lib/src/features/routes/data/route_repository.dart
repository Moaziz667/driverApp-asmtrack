import 'package:dio/dio.dart';

import '../../../services/api_client.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/route_cache_service.dart';
import '../models/route_models.dart';

import '../../../services/offline_queue_service.dart';

class RouteRepository {
  RouteRepository(this._client, this._cache, this._offlineQueue, this._connectivity);

  final ApiClient _client;
  final RouteCacheService _cache;
  final OfflineQueueService _offlineQueue;
  final ConnectivityService _connectivity;

  Future<DriverRoute?> fetchToday() async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/api/driver/routes/today');
      final data = response.data;
      if (data == null || data.isEmpty) {
        return null;
      }
      final route = DriverRoute.fromJson(data);
      await _cache.save(route);
      return route;
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      // Network error — try cache fallback
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.unknown) {
        return _cache.load();
      }
      rethrow;
    }
  }

  Future<List<DriverRoute>> fetchRange(DateTime from, DateTime to) async {
    final fromStr = _fmt(from);
    final toStr = _fmt(to);
    final response = await _client.dio.get<List<dynamic>>(
      '/api/driver/routes',
      queryParameters: {'from': fromStr, 'to': toStr},
    );
    return (response.data ?? [])
        .map((e) => DriverRoute.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DriverRoute> _mutate(String path, {String? idempotencyKey}) async {
    final clientTimestamp = DateTime.now().toUtc().toIso8601String();

    // Skip the API call entirely if offline — no timeout wait.
    final online = await _connectivity.isOnline;
    if (!online) {
      await _offlineQueue.enqueueRequest(
        path: path,
        method: 'POST',
        data: {'clientTimestamp': clientTimestamp},
        idempotencyKey: idempotencyKey,
      );
      throw 'OFFLINE_QUEUED';
    }

    final options = idempotencyKey != null
        ? Options(headers: {'X-Idempotency-Key': idempotencyKey})
        : null;

    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        path,
        data: {'clientTimestamp': clientTimestamp},
        options: options,
      );
      return DriverRoute.fromJson(response.data ?? <String, dynamic>{});
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        await _offlineQueue.enqueueRequest(
          path: path,
          method: 'POST',
          data: {'clientTimestamp': clientTimestamp},
          idempotencyKey: idempotencyKey,
        );
        throw 'OFFLINE_QUEUED';
      }
      rethrow;
    }
  }

  Future<DriverRoute> start(String routeId) async {
    return _mutate(
      '/api/driver/routes/$routeId/start',
      idempotencyKey: 'start-route-$routeId',
    );
  }

  Future<DriverRoute> arrive(String routeId, String stopId) async {
    return _mutate(
      '/api/driver/routes/$routeId/stops/$stopId/arrive',
      idempotencyKey: 'arrive-$routeId-$stopId',
    );
  }

  /// Confirm a depot PICKUP stop — loads (PICKED_UP) every delivery on the route
  /// sourced from that depot and marks the pickup stop completed.
  Future<DriverRoute> confirmPickup(String routeId, String stopId) async {
    return _mutate(
      '/api/driver/routes/$routeId/stops/$stopId/confirm-pickup',
      idempotencyKey: 'confirm-pickup-$routeId-$stopId',
    );
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
