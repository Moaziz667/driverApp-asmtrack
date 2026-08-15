import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../../../services/api_client.dart';
import '../../../services/connectivity_service.dart';
import '../../../services/offline_queue_service.dart';
import '../models/delivery_models.dart';
import '../models/handoff_models.dart';

class DeliveryRepository {
  DeliveryRepository(this._client, this._offlineQueue, this._connectivity);

  final ApiClient _client;
  final OfflineQueueService _offlineQueue;
  final ConnectivityService _connectivity;

  static const _cacheKey = 'cached_active_deliveries';
  static const _detailCachePrefix = 'cached_delivery_';

  Box get _box => Hive.box('domain_cache');

  /// When the detail cache for [id] (or the active-list cache it falls back to)
  /// was last refreshed from the server — drives the "offline data · HH:MM"
  /// banner so the driver knows how fresh what he's looking at is.
  DateTime? detailCachedAt(String id) {
    final raw = (_box.get('${_detailCachePrefix}${id}_at') as String?) ??
        (_box.get('${_cacheKey}_at') as String?);
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  /// Fetch active deliveries with cache fallback for offline.
  Future<List<DriverDelivery>> fetchActive() async {
    try {
      final response = await _client.dio.get<List<dynamic>>('/driver/deliveries/active');
      final list = response.data ?? [];
      final deliveries = list.map((e) => DriverDelivery.fromJson(e as Map<String, dynamic>)).toList();
      // Save to cache
      try {
        await _box.put(_cacheKey, jsonEncode(list));
        await _box.put('${_cacheKey}_at', DateTime.now().toIso8601String());
      } catch (_) {
        // Cache write failures are non-fatal
      }
      return deliveries;
    } on DioException catch (e) {
      // Network-level failure (no HTTP response): offline, DNS lookup failure, timeout.
      if (e.response == null) {
        // Offline fallback: load from cache
        try {
          final raw = _box.get(_cacheKey) as String?;
          if (raw != null) {
            final list = jsonDecode(raw) as List<dynamic>;
            return list.map((e) => DriverDelivery.fromJson(e as Map<String, dynamic>)).toList();
          }
        } catch (_) {}
      }
      rethrow;
    }
  }

  /// Paginated driver history. The endpoint returns `{ items: [...], hasNext }` (server-side paged,
  /// Slice-based). Returns the page's items plus whether more pages exist (drives infinite scroll).
  Future<({List<DriverDelivery> items, bool hasNext})> fetchHistory({int page = 0, int size = 20}) async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/driver/history',
      queryParameters: {'page': page, 'size': size},
    );
    final data = response.data ?? <String, dynamic>{};
    final list = (data['items'] as List<dynamic>? ?? const []);
    final items = list.map((e) => DriverDelivery.fromJson(e as Map<String, dynamic>)).toList();
    return (items: items, hasNext: data['hasNext'] as bool? ?? false);
  }

  /// Warm the detail cache for a whole route, so any delivery opens offline — not only the ones the
  /// driver happened to tap while he still had signal. That was the practical failure: losing signal
  /// meant every unopened delivery was a dead end, and the driver had to guess in advance which ones
  /// he would need.
  ///
  /// Fire-and-forget and best-effort: silent on failure, and it skips anything cached in the last
  /// [freshFor]. Runs a few requests at a time rather than one by one — a driver who opens the app
  /// and closes it again a few seconds later must still leave with a usable copy, and twenty
  /// sequential round-trips did not finish in that window.
  static const _prefetchConcurrency = 4;

  Future<void> prefetchDetails(
    Iterable<String> ids, {
    Duration freshFor = const Duration(minutes: 30),
  }) async {
    if (!await _connectivity.isOnline) return;
    final now = DateTime.now();
    final pending = ids.toSet().where((id) {
      if (id.isEmpty) return false;
      // Strictly this delivery's own timestamp — NOT detailCachedAt, which falls back to the active
      // list's timestamp to drive the "offline data · HH:MM" banner. That fallback is right for the
      // banner and wrong here: the list is refreshed on every launch, so every delivery looked fresh
      // and nothing was ever pre-loaded.
      final at = _detailOnlyCachedAt(id);
      return at == null || now.difference(at) >= freshFor;
    }).toList();
    if (pending.isEmpty) return;

    var next = 0;
    Future<void> worker() async {
      while (true) {
        final i = next++;
        if (i >= pending.length) return;
        final id = pending[i];
        try {
          final response =
              await _client.dio.get<Map<String, dynamic>>('/driver/deliveries/$id');
          if (response.data == null) continue;
          await _box.put('$_detailCachePrefix$id', jsonEncode(response.data));
          await _box.put(
              '${_detailCachePrefix}${id}_at', DateTime.now().toIso8601String());
        } catch (_) {
          // A delivery we cannot pre-load is not an error the driver should see; the detail screen
          // still falls back to the cached list.
        }
      }
    }

    await Future.wait(
        List.generate(pending.length.clamp(0, _prefetchConcurrency), (_) => worker()));
  }

  /// When this delivery's own detail was cached — no list fallback. See [prefetchDetails].
  DateTime? _detailOnlyCachedAt(String id) {
    final raw = _box.get('${_detailCachePrefix}${id}_at') as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  Future<DriverDelivery> fetchById(String id) async {
    try {
      final response = await _client.dio.get<Map<String, dynamic>>('/driver/deliveries/$id');
      final delivery = DriverDelivery.fromJson(response.data ?? {});
      try {
        await _box.put('$_detailCachePrefix$id', jsonEncode(response.data));
        await _box.put('${_detailCachePrefix}${id}_at', DateTime.now().toIso8601String());
      } catch (_) {}
      return delivery;
    } on DioException catch (e) {
      // Any failure where we never got an HTTP response = network-level: offline,
      // DNS lookup failure (surfaced as `unknown`), timeouts. Serve cache in all
      // of them — gating on specific DioExceptionTypes missed "Wi-Fi off" (DNS).
      if (e.response == null) {
        // 1) Per-delivery cache (populated when this fiche was opened online).
        try {
          final raw = _box.get('$_detailCachePrefix$id') as String?;
          if (raw != null) {
            return DriverDelivery.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          }
        } catch (_) {}
        // 2) P2-e fallback: the fiche was never opened online, but it's in the
        // cached active-deliveries list the driver is looking at. Serve that so
        // the detail screen opens offline instead of failing with a network error.
        try {
          final rawList = _box.get(_cacheKey) as String?;
          if (rawList != null) {
            final list = jsonDecode(rawList) as List<dynamic>;
            final match = list.cast<Map<String, dynamic>>().firstWhere(
                  (e) => e['id']?.toString() == id,
                  orElse: () => const <String, dynamic>{},
                );
            if (match.isNotEmpty) return DriverDelivery.fromJson(match);
          }
        } catch (_) {}
      }
      rethrow;
    }
  }


  // `localStatus` is the status the server would set — the same transition, applied to the cached
  // copy so an offline driver keeps moving through his round instead of stalling on the last screen.
  Future<DriverDelivery> accept(String id) => _mutate('/driver/deliveries/$id/accept',
      idempotencyKey: 'acc-$id', localStatus: 'SCHEDULED');
  Future<DriverDelivery> pickup(String id) => _mutate('/driver/deliveries/$id/pickup',
      idempotencyKey: 'pkp-$id', localStatus: 'PICKED_UP');

  Future<DriverDelivery> startTransit(String id, {double? lat, double? lng}) {
    return _mutate(
      '/driver/deliveries/$id/transit',
      data: lat != null && lng != null ? {'lat': lat, 'lng': lng} : null,
      idempotencyKey: 'trns-$id',
      localStatus: 'IN_TRANSIT',
    );
  }

  Future<DriverDelivery> complete(String id) => _mutate('/driver/deliveries/$id/complete',
      idempotencyKey: 'cmp-$id', localStatus: 'DELIVERED');

  Future<DriverDelivery> fail(String id, {required String reasonCode, String? comment}) {
    return _mutate(
      '/driver/deliveries/$id/fail',
      localStatus: 'FAILED',
      data: {
        'failureReasonCode': reasonCode,
        if (comment != null && comment.isNotEmpty) 'failureComment': comment,
      },
      // Key on the delivery only (not the reason): a driver who changes the
      // failure reason before reconnecting should replace the queued entry, not
      // queue a second, contradictory FAIL for the same delivery.
      idempotencyKey: 'fail-$id',
    );
  }

  /// Configurable failure reasons; falls back to the static enum list on error.
  Future<List<FailureReasonOption>> fetchFailureReasons() async {
    try {
      final res = await _client.dio.get('/driver/deliveries/failure-reasons');
      final data = res.data;
      if (data is List && data.isNotEmpty) {
        return data
            .map((e) => FailureReasonOption.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {
      // offline / unreachable — use the bundled fallback
    }
    return FailureReasonOption.fallback;
  }

  Future<DriverDelivery> cancel(String id, {String? reason}) {
    return _mutate('/driver/deliveries/$id/cancel',
      data: reason != null ? {'reason': reason} : null,
      idempotencyKey: 'can-$id',
      localStatus: 'CANCELLED',
    );
  }

  Future<DriverDelivery> submitPod(String id, PodPayload payload) {
    return _mutate('/driver/deliveries/$id/pod',
      data: payload.toJson(),
      idempotencyKey: 'pod-$id',
      // Proof of delivery is what completes the delivery, so the local projection must say DELIVERED
      // — otherwise the driver signs, sees nothing move, and signs again.
      localStatus: 'DELIVERED',
    );
  }

  /// POD upload via the base64 JSON endpoint (`submitPod`). We use this rather than the multipart
  /// endpoint because the JSON path is transactional end-to-end on the backend (POD + completion +
  /// ERP sync in one transaction). `_mutate`/`submitPod` handle the online POST and the offline-queue
  /// fallback, so a queued POD is never lost.
  Future<DriverDelivery> submitPodPhotos(
    String id, {
    Uint8List? bonLivraisonBytes,
    required Uint8List packageBytes,
    String? comment,
    double? lat,
    double? lng,
    bool isPartial = false,
    List<PartialDeliveryItem>? itemsDone,
    CashEntry? cash,
  }) {
    return _buildAndSubmitPodBase64(
        id, bonLivraisonBytes, packageBytes, comment, lat, lng, isPartial, itemsDone, cash);
  }

  Future<DriverDelivery> _buildAndSubmitPodBase64(
    String id,
    Uint8List? bonLivraisonBytes,
    Uint8List packageBytes,
    String? comment,
    double? lat,
    double? lng,
    bool isPartial,
    List<PartialDeliveryItem>? itemsDone,
    CashEntry? cash,
  ) {
    final payload = PodPayload(
      // ADR-033 — null for a return collection (no delivery note).
      bonLivraisonPhotoBase64: bonLivraisonBytes != null ? base64Encode(bonLivraisonBytes) : null,
      packagePhotoBase64: base64Encode(packageBytes),
      comment: (comment != null && comment.isNotEmpty) ? comment : null,
      lat: lat,
      lng: lng,
      isPartial: isPartial,
      itemsDone: itemsDone,
      cash: cash,
    );
    return submitPod(id, payload);
  }

  /// How much cash this driver is currently holding — collected and not yet handed over.
  Future<double> cashOutstanding() async {
    final res = await _client.dio.get('/driver/deliveries/cash/outstanding');
    final data = res.data;
    if (data is Map && data['amount'] != null) {
      return (data['amount'] as num).toDouble();
    }
    return 0;
  }

  /// Declare the cash being handed over at the depot.
  ///
  /// Deliberately not queued offline like a proof of delivery. A POD describes something that has
  /// already happened and only needs to reach the server eventually; a handover is a live
  /// transaction with a person standing opposite, who is about to count. Queuing it would tell the
  /// driver he had handed over money that nobody has received.
  Future<void> declareCash(double declaredTotal) async {
    await _client.dio.post('/driver/deliveries/cash/declare',
        data: {'declaredTotal': declaredTotal});
  }

  Future<void> updateLocation(double lat, double lng) async {
    await _client.dio.post('/driver/location', data: {'lat': lat, 'lng': lng});
  }

  Future<void> report(String id, {required String reportType, String? description}) async {
    await _client.dio.post('/driver/deliveries/$id/report', data: {
      'reportType': reportType,
      if (description != null) 'description': description,
    });
  }

  Future<HandoffTokenInfo> getHandoffToken(String id) async {
    final response = await _client.dio.get<Map<String, dynamic>>('/driver/deliveries/$id/handoff-token');
    final data = response.data ?? const {};
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('Empty handoff token from server');
    }
    final expiresRaw = data['expiresAt'] as String?;
    return HandoffTokenInfo(
      token: token,
      expiresAt: expiresRaw != null ? DateTime.tryParse(expiresRaw) : null,
    );
  }

  Future<void> confirmHandoff(String id, String token, {double? lat, double? lng}) async {
    await _client.dio.post('/driver/deliveries/$id/handoff', data: {
      'token': token,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }

  /// My open custody transfers (incoming to receive + outgoing to hand over).
  Future<List<HandoffSummary>> listHandoffs() async {
    final response = await _client.dio.get<List<dynamic>>('/driver/handoffs');
    final list = response.data ?? const [];
    return list.map((e) => HandoffSummary.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> reportIncident({
    required String reportType,
    required String description,
    required List<String> photosBase64,
    String? deliveryId,
    double? lat,
    double? lng,
  }) async {
    await _client.dio.post('/driver/deliveries/report-incident', data: {
      'reportType': reportType,
      'description': description,
      'photosBase64': photosBase64,
      if (deliveryId != null) 'deliveryId': deliveryId,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
  }

  /// Project a queued write onto the cached delivery (and the cached active list) so the screen
  /// advances while the request waits for signal. Without this the driver saw "sync deferred" and a
  /// delivery frozen on its previous status — an action he could not see the effect of.
  ///
  /// Optimistic and short-lived by design: the next successful fetch overwrites it with the server's
  /// truth, so a write the server ends up rejecting corrects itself without any reconciliation code.
  Future<DriverDelivery?> _applyLocalStatus(String id, String status) async {
    try {
      final raw = _box.get('$_detailCachePrefix$id') as String?;
      Map<String, dynamic>? detail =
          raw != null ? jsonDecode(raw) as Map<String, dynamic> : null;

      // Fall back to the entry inside the cached active list — the driver may have seen the delivery
      // in the list without ever opening its detail screen.
      if (detail == null) {
        final listRaw = _box.get(_cacheKey) as String?;
        if (listRaw != null) {
          final list = jsonDecode(listRaw) as List<dynamic>;
          for (final e in list) {
            if (e is Map<String, dynamic> && e['id']?.toString() == id) {
              detail = Map<String, dynamic>.from(e);
              break;
            }
          }
        }
      }
      if (detail == null) return null;

      detail['status'] = status;
      await _box.put('$_detailCachePrefix$id', jsonEncode(detail));

      // Keep the list consistent too, otherwise going back shows the old status.
      final listRaw = _box.get(_cacheKey) as String?;
      if (listRaw != null) {
        final list = jsonDecode(listRaw) as List<dynamic>;
        for (final e in list) {
          if (e is Map<String, dynamic> && e['id']?.toString() == id) {
            e['status'] = status;
          }
        }
        await _box.put(_cacheKey, jsonEncode(list));
      }
      return DriverDelivery.fromJson(detail);
    } catch (_) {
      return null;
    }
  }

  Future<DriverDelivery> _mutate(String path,
      {Map<String, dynamic>? data, String? idempotencyKey, String? localStatus}) async {
    // Capture the action time NOW — before any network attempt.
    // The backend uses clientTimestamp when present so offline actions are
    // recorded at the moment the driver tapped, not when connectivity returned.
    final stamped = {
      ...?data,
      'clientTimestamp': DateTime.now().toUtc().toIso8601String(),
    };

    // Skip the API call entirely if offline — no 15-second timeout wait.
    final online = await _connectivity.isOnline;
    if (!online) {
      await _offlineQueue.enqueueRequest(
        path: path,
        method: 'POST',
        data: stamped,
        idempotencyKey: idempotencyKey,
      );
      final projected = localStatus != null
          ? await _applyLocalStatus(_deliveryIdOf(path), localStatus)
          : null;
      if (projected == null) throw 'OFFLINE_QUEUED';
      return projected;
    }

    final options = idempotencyKey != null
        ? Options(headers: {'X-Idempotency-Key': idempotencyKey})
        : null;

    try {
      final response = await _client.dio.post<Map<String, dynamic>>(path, data: stamped, options: options);
      final body = response.data ?? <String, dynamic>{};
      // Refresh the detail cache from the server's answer: if signal drops right after, the driver
      // resumes from the state the server actually acknowledged.
      if (body['id'] != null) {
        try {
          await _box.put('$_detailCachePrefix${body['id']}', jsonEncode(body));
          await _box.put('${_detailCachePrefix}${body['id']}_at',
              DateTime.now().toIso8601String());
        } catch (_) {}
      }
      return DriverDelivery.fromJson(body);
    } on DioException catch (e) {
      // Network dropped mid-request — enqueue for later
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        await _offlineQueue.enqueueRequest(
          path: path,
          method: 'POST',
          data: stamped,
          idempotencyKey: idempotencyKey,
        );
        final projected = localStatus != null
            ? await _applyLocalStatus(_deliveryIdOf(path), localStatus)
            : null;
        if (projected == null) throw 'OFFLINE_QUEUED';
        return projected;
      }
      rethrow;
    }
  }

  /// `/driver/deliveries/{id}/complete` → `{id}`.
  static String _deliveryIdOf(String path) {
    final segs = path.split('/').where((s) => s.isNotEmpty).toList();
    final i = segs.indexOf('deliveries');
    return (i >= 0 && i + 1 < segs.length) ? segs[i + 1] : '';
  }
}
