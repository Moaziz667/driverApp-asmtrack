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
      final response = await _client.dio.get<Map<String, dynamic>>('/driver/routes/today');
      final data = response.data;
      if (data == null || data.isEmpty) {
        return null;
      }
      await _cache.saveRaw(data);
      return DriverRoute.fromJson(data);
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
      '/driver/routes',
      queryParameters: {'from': fromStr, 'to': toStr},
    );
    return (response.data ?? [])
        .map((e) => DriverRoute.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Queue the write and project it onto the cached route so the screen moves on.
  ///
  /// Enqueuing alone used to be the whole offline path, and it left the UI frozen on the previous
  /// state: the driver confirmed a pickup, saw "sync deferred", and the parcel stayed "to load" with
  /// no way forward. A queued action the driver cannot see the effect of is, to him, an action that
  /// did not happen.
  Future<DriverRoute> _queue(
    String path,
    String? idempotencyKey,
    String clientTimestamp,
    void Function(Map<String, dynamic> route) project,
  ) async {
    await _offlineQueue.enqueueRequest(
      path: path,
      method: 'POST',
      data: {'clientTimestamp': clientTimestamp},
      idempotencyKey: idempotencyKey,
    );
    final projected = await _cache.applyLocal(project);
    // Nothing cached to project onto (first launch offline): the caller still needs to know the write
    // was only queued, and has no route to show.
    if (projected == null) throw 'OFFLINE_QUEUED';
    return projected;
  }

  Future<DriverRoute> _mutate(
    String path, {
    String? idempotencyKey,
    required void Function(Map<String, dynamic> route) project,
  }) async {
    final clientTimestamp = DateTime.now().toUtc().toIso8601String();

    // Skip the API call entirely if offline — no timeout wait.
    final online = await _connectivity.isOnline;
    if (!online) {
      return _queue(path, idempotencyKey, clientTimestamp, project);
    }

    // See DeliveryRepository: the server reads the action time off the header, so the direct path
    // must send it too, not only the queued replay.
    final options = Options(headers: {
      if (idempotencyKey != null) 'X-Idempotency-Key': idempotencyKey,
      'X-Client-Timestamp': clientTimestamp,
    });

    try {
      final response = await _client.dio.post<Map<String, dynamic>>(
        path,
        data: {'clientTimestamp': clientTimestamp},
        options: options,
      );
      final data = response.data ?? <String, dynamic>{};
      // The server's answer is the whole route: cache it so the next drop of signal starts from the
      // freshest truth rather than from whatever was there before the action.
      if (data.isNotEmpty) await _cache.saveRaw(data);
      return DriverRoute.fromJson(data);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        return _queue(path, idempotencyKey, clientTimestamp, project);
      }
      rethrow;
    }
  }

  Future<DriverRoute> start(String routeId) async {
    return _mutate(
      '/driver/routes/$routeId/start',
      idempotencyKey: 'start-route-$routeId',
      project: (route) {
        route['status'] = 'IN_PROGRESS';
        route['startedAt'] ??= DateTime.now().toUtc().toIso8601String();
      },
    );
  }

  Future<DriverRoute> arrive(String routeId, String stopId) async {
    return _mutate(
      '/driver/routes/$routeId/stops/$stopId/arrive',
      idempotencyKey: 'arrive-$routeId-$stopId',
      project: (route) => _eachStop(route, (stop) {
        if (stop['id'] == stopId) stop['status'] = 'ARRIVED';
      }),
    );
  }

  /// Confirm a depot PICKUP stop — loads (PICKED_UP) every delivery on the route
  /// sourced from that depot and marks the pickup stop completed.
  Future<DriverRoute> confirmPickup(String routeId, String stopId) async {
    return _mutate(
      '/driver/routes/$routeId/stops/$stopId/confirm-pickup',
      idempotencyKey: 'confirm-pickup-$routeId-$stopId',
      project: (route) {
        // Mirror the server: completing a pickup also loads every delivery drawn from that depot.
        // Projecting only the stop would leave the parcels showing as "to load" — the exact symptom
        // that made the offline flow look broken.
        final depotIds = <String>{};
        _eachStop(route, (stop) {
          if (stop['id'] != stopId) return;
          stop['status'] = 'COMPLETED';
          for (final id in (stop['sourceDepotIds'] as List<dynamic>? ?? const [])) {
            depotIds.add(id.toString());
          }
          final single = stop['sourceDepotId'];
          if (single != null) depotIds.add(single.toString());
        });
        _eachStop(route, (stop) {
          if ((stop['stopType'] as String?)?.toUpperCase() == 'PICKUP') return;
          if (_stopDrawsFrom(stop, depotIds)) stop['deliveryStatus'] = 'PICKED_UP';
        });
        _recountCompleted(route);
      },
    );
  }

  /// A delivery stop is loaded at this pickup when it draws from one of its depots. A stop with no
  /// depot of its own belongs to the route's single depot, so it loads with the only pickup there is.
  static bool _stopDrawsFrom(Map<String, dynamic> stop, Set<String> depotIds) {
    if (depotIds.isEmpty) return true;
    final ids = (stop['sourceDepotIds'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    final single = stop['sourceDepotId']?.toString();
    if (single != null) ids.add(single);
    if (ids.isEmpty) return true;
    return ids.any(depotIds.contains);
  }

  static void _eachStop(
      Map<String, dynamic> route, void Function(Map<String, dynamic>) fn) {
    for (final raw in (route['stops'] as List<dynamic>? ?? const [])) {
      if (raw is Map<String, dynamic>) fn(raw);
    }
  }

  /// Keep the progress header honest while offline; the server recomputes it on the next fetch.
  static void _recountCompleted(Map<String, dynamic> route) {
    final stops = (route['stops'] as List<dynamic>? ?? const []);
    final done = stops.where((raw) =>
        raw is Map<String, dynamic> &&
        (raw['status'] as String?)?.toUpperCase() == 'COMPLETED').length;
    route['completedStops'] = done;
    if (stops.isNotEmpty) {
      route['progressPercent'] = (done / stops.length) * 100;
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
