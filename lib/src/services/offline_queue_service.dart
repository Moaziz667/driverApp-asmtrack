import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../app_providers.dart';
import 'api_client.dart';
import 'connectivity_service.dart';

final offlineQueueProvider =
    StateNotifierProvider<OfflineQueueService, OfflineSyncState>((ref) {
      final apiClient = ref.read(apiClientProvider);
      final connectivity = ref.read(connectivityServiceProvider);
      return OfflineQueueService(apiClient, connectivity);
    });

/// Lifecycle of a queued write. An entry is only ever removed from disk once it
/// has been accepted by the server (SYNCED). Everything else stays durable so
/// nothing is lost — and, crucially, nothing is ever dropped *silently*.
enum QueueItemStatus {
  /// Waiting to be sent (or waiting for a retry after a transient error).
  pending,

  /// Given up on: a permanent rejection (4xx), too many server errors, or TTL
  /// expiry. Kept on disk and surfaced to the driver, who can retry manually.
  deadLetter,
}

/// One queued write, decoded for the UI (Sync Center).
class OfflineQueueItem {
  const OfflineQueueItem({
    required this.key,
    required this.path,
    required this.method,
    required this.idempotencyKey,
    required this.enqueuedAt,
    required this.retryCount,
    required this.status,
    this.lastError,
  });

  /// Hive key (used to target a manual retry).
  final dynamic key;
  final String path;
  final String method;
  final String idempotencyKey;
  final DateTime? enqueuedAt;
  final int retryCount;
  final QueueItemStatus status;
  final String? lastError;

  /// Human action label derived from the REST path, e.g. `/driver/deliveries/42/complete`.
  /// Returns a coarse type the UI can localise + colour.
  String get action {
    final p = path.toLowerCase();
    if (p.endsWith('/pod')) return 'pod';
    if (p.endsWith('/complete')) return 'complete';
    if (p.endsWith('/fail')) return 'fail';
    if (p.endsWith('/cancel')) return 'cancel';
    if (p.endsWith('/transit')) return 'transit';
    if (p.endsWith('/pickup') || p.contains('confirm-pickup')) return 'pickup';
    if (p.endsWith('/accept')) return 'accept';
    if (p.endsWith('/arrive')) return 'arrive';
    if (p.contains('/routes/') && p.endsWith('/start')) return 'route_start';
    return 'action';
  }

  /// Best-effort delivery / route reference pulled from the path, for display.
  String? get reference {
    final segs = path.split('/').where((s) => s.isNotEmpty).toList();
    final i = segs.indexWhere((s) => s == 'deliveries' || s == 'routes');
    if (i >= 0 && i + 1 < segs.length) return segs[i + 1];
    return null;
  }
}

/// Aggregate state the UI watches: how many writes are waiting, how many failed,
/// whether a flush is in flight, and when the queue last fully drained.
class OfflineSyncState {
  const OfflineSyncState({
    this.pending = 0,
    this.failed = 0,
    this.syncing = false,
    this.lastSuccessAt,
  });

  final int pending;
  final int failed;
  final bool syncing;
  final DateTime? lastSuccessAt;

  int get total => pending + failed;

  OfflineSyncState copyWith({
    int? pending,
    int? failed,
    bool? syncing,
    DateTime? lastSuccessAt,
  }) => OfflineSyncState(
    pending: pending ?? this.pending,
    failed: failed ?? this.failed,
    syncing: syncing ?? this.syncing,
    lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
  );
}

class OfflineQueueService extends StateNotifier<OfflineSyncState> {
  final ApiClient _apiClient;
  final ConnectivityService _connectivityService;
  static const String _boxName = 'offline_queue';
  static const int _maxRetries = 3;
  static const int _ttlHours = 24;

  StreamSubscription<bool>? _connectivitySub;
  Timer? _flushTimer;
  bool _processing = false;

  /// Safety-net cadence: even if every connectivity/resume/login trigger is
  /// missed, a foreground app with pending writes re-checks this often.
  static const Duration _safetyNetInterval = Duration(seconds: 20);

  OfflineQueueService(this._apiClient, this._connectivityService)
    : super(const OfflineSyncState()) {
    _init();
  }

  void _init() {
    _recomputeState();
    // Flush on the transition back online (connectivity_plus fires when the OS
    // reports "connected" but DNS / routing may not be ready yet, hence the delay).
    _connectivitySub = _connectivityService.onlineStream.listen((
      isOnline,
    ) async {
      if (!isOnline || _pendingKeys().isEmpty) return;
      await Future.delayed(const Duration(seconds: 2));
      if (_pendingKeys().isNotEmpty) await processQueue();
    });
    // P1-a: onConnectivityChanged does NOT emit the initial state, so a cold start
    // on an already-online network would never flush. Kick a flush now if we're up.
    scheduleMicrotask(() async {
      if (_pendingKeys().isEmpty) return;
      if (await _connectivityService.isOnline) {
        await Future.delayed(const Duration(seconds: 1));
        await processQueue();
      }
    });
    // Foreground safety net: covers a connectivity event the OS never delivered
    // (Wi-Fi that silently regains internet, flaky radios). Cheap — it only probes
    // the network when there is actually pending work to send.
    _flushTimer = Timer.periodic(_safetyNetInterval, (_) async {
      if (_processing || _pendingKeys().isEmpty) return;
      if (await _connectivityService.isOnline) await processQueue();
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _flushTimer?.cancel();
    super.dispose();
  }

  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(_boxName);

  List<dynamic> _pendingKeys() => _box.keys.where((k) {
    final e = _box.get(k);
    return e != null && _statusOf(e) == QueueItemStatus.pending;
  }).toList();

  QueueItemStatus _statusOf(Map<dynamic, dynamic> e) =>
      (e['status'] as String?) == 'DEAD_LETTER'
      ? QueueItemStatus.deadLetter
      : QueueItemStatus.pending;

  void _recomputeState({bool? syncing, DateTime? lastSuccessAt}) {
    var pending = 0;
    var failed = 0;
    for (final e in _box.values) {
      if (_statusOf(e) == QueueItemStatus.deadLetter) {
        failed++;
      } else {
        pending++;
      }
    }
    state = state.copyWith(
      pending: pending,
      failed: failed,
      syncing: syncing ?? state.syncing,
      lastSuccessAt: lastSuccessAt,
    );
  }

  /// Snapshot of everything on disk, newest first — drives the Sync Center list.
  List<OfflineQueueItem> items() {
    final list = <OfflineQueueItem>[];
    for (final key in _box.keys) {
      final e = _box.get(key);
      if (e == null) continue;
      list.add(
        OfflineQueueItem(
          key: key,
          path: (e['path'] as String?) ?? '',
          method: (e['method'] as String?) ?? 'POST',
          idempotencyKey: (e['idempotencyKey'] as String?) ?? '',
          enqueuedAt: DateTime.tryParse((e['timestamp'] as String?) ?? ''),
          retryCount: (e['retryCount'] as int?) ?? 0,
          status: _statusOf(e),
          lastError: e['lastError'] as String?,
        ),
      );
    }
    list.sort(
      (a, b) =>
          (b.enqueuedAt ?? DateTime(0)).compareTo(a.enqueuedAt ?? DateTime(0)),
    );
    return list;
  }

  Future<void> enqueueRequest({
    required String path,
    required String method,
    Map<String, dynamic>? data,
    String? idempotencyKey,
  }) async {
    final key = idempotencyKey ?? '${method.toUpperCase()}-$path';

    // Dedup: if the same idempotency key is already queued, refresh its payload
    // instead of adding a second copy (e.g. the driver changed a failure reason).
    for (final existingKey in _box.keys) {
      final existing = _box.get(existingKey);
      if (existing == null) continue;
      if ((existing['idempotencyKey'] as String?) == key) {
        final updated = Map<dynamic, dynamic>.from(existing)
          ..['data'] = data != null ? jsonEncode(data) : null
          ..['status'] = 'PENDING'
          ..['lastError'] = null;
        await _box.put(existingKey, updated);
        _recomputeState();
        return;
      }
    }

    final entry = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'path': path,
      'method': method,
      'data': data != null ? jsonEncode(data) : null,
      'timestamp': DateTime.now().toIso8601String(),
      'idempotencyKey': key,
      // P3: a single correlation id per logical operation, stable across every
      // retry, so a queued write can be traced end-to-end in the backend logs.
      'correlationId':
          'oq-${DateTime.now().millisecondsSinceEpoch}-${key.hashCode}',
      'retryCount': 0,
      'status': 'PENDING',
      'lastError': null,
    };
    await _box.add(entry);
    _recomputeState();
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'offline_queue',
        message: 'enqueued $method $path (pending=${state.pending})',
      ),
    );
  }

  /// Move a dead-lettered (or any) item back to PENDING and try again now.
  Future<void> retryItem(dynamic key) async {
    final e = _box.get(key);
    if (e == null) return;
    await _box.put(
      key,
      Map<dynamic, dynamic>.from(e)
        ..['status'] = 'PENDING'
        ..['retryCount'] = 0
        ..['lastError'] = null,
    );
    _recomputeState();
    await processQueue();
  }

  /// Retry every dead-lettered item.
  Future<void> retryAll() async {
    for (final key in _box.keys.toList()) {
      final e = _box.get(key);
      if (e == null || _statusOf(e) != QueueItemStatus.deadLetter) continue;
      await _box.put(
        key,
        Map<dynamic, dynamic>.from(e)
          ..['status'] = 'PENDING'
          ..['retryCount'] = 0
          ..['lastError'] = null,
      );
    }
    _recomputeState();
    await processQueue();
  }

  /// Permanently discard a dead-lettered item (driver acknowledged the failure).
  Future<void> discardItem(dynamic key) async {
    await _box.delete(key);
    _recomputeState();
  }

  Future<void> _markDeadLetter(
    dynamic key,
    Map<dynamic, dynamic> entry,
    String reason,
  ) async {
    await _box.put(
      key,
      Map<dynamic, dynamic>.from(entry)
        ..['status'] = 'DEAD_LETTER'
        ..['lastError'] = reason
        ..['lastAttemptAt'] = DateTime.now().toIso8601String(),
    );
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'offline_queue',
        level: SentryLevel.warning,
        message: 'dead-letter ${entry['method']} ${entry['path']}: $reason',
      ),
    );
  }

  /// The moment the driver tapped, in UTC ISO-8601. Prefers the `clientTimestamp` the repository
  /// stamped into the payload (already UTC); falls back to the queue entry's own local timestamp.
  static String _utcIso(Map<dynamic, dynamic> entry) {
    try {
      final raw = entry['data'] as String?;
      if (raw != null) {
        final decoded = jsonDecode(raw);
        final stamped = decoded is Map
            ? decoded['clientTimestamp'] as String?
            : null;
        if (stamped != null && stamped.isNotEmpty) return stamped;
      }
    } catch (_) {}
    final fallback = DateTime.tryParse((entry['timestamp'] as String?) ?? '');
    return (fallback ?? DateTime.now()).toUtc().toIso8601String();
  }

  Future<void> processQueue() async {
    if (_processing) return;
    if (_pendingKeys().isEmpty) return;
    _processing = true;
    _recomputeState(syncing: true);
    Sentry.addBreadcrumb(
      Breadcrumb(
        category: 'offline_queue',
        message: 'flush start (pending=${state.pending})',
      ),
    );
    var drainedSomething = false;
    try {
      for (final key in _box.keys.toList()) {
        final entry = _box.get(key);
        if (entry == null) continue;
        if (_statusOf(entry) == QueueItemStatus.deadLetter) continue;

        // TTL: don't silently delete — dead-letter it so the driver can see it.
        final timestampStr = entry['timestamp'] as String?;
        if (timestampStr != null) {
          final enqueuedAt = DateTime.tryParse(timestampStr);
          if (enqueuedAt != null &&
              DateTime.now().difference(enqueuedAt).inHours >= _ttlHours) {
            await _markDeadLetter(key, entry, 'TTL_EXPIRED');
            continue;
          }
        }

        final path = entry['path'] as String;
        final method = entry['method'] as String;
        final dataStr = entry['data'] as String?;
        final data = dataStr != null ? jsonDecode(dataStr) : null;
        final idempotencyKey = entry['idempotencyKey'] as String?;
        final correlationId = entry['correlationId'] as String?;
        final retryCount = (entry['retryCount'] as int?) ?? 0;

        final options = Options(
          headers: {
            if (idempotencyKey != null) 'X-Idempotency-Key': idempotencyKey,
            if (correlationId != null) 'X-Correlation-ID': correlationId,
            // When the driver actually tapped. Without it the server timestamps the replay, so a
            // parcel handed over in a basement at 14:10 was proven delivered at 17:53 in the van.
            if (entry['timestamp'] != null)
              'X-Client-Timestamp': _utcIso(entry),
          },
        );

        try {
          switch (method.toUpperCase()) {
            case 'POST':
              await _apiClient.dio.post(path, data: data, options: options);
            case 'PUT':
              await _apiClient.dio.put(path, data: data, options: options);
            case 'PATCH':
              await _apiClient.dio.patch(path, data: data, options: options);
          }
          await _box.delete(key);
          drainedSomething = true;
          _recomputeState();
        } on DioException catch (e) {
          final status = e.response?.statusCode;

          // 4xx = permanent (bad request, conflict, already-terminal…). Don't
          // retry, but keep it visible so the driver knows it was rejected.
          if (status != null && status >= 400 && status < 500) {
            await _markDeadLetter(key, entry, 'HTTP_$status');
            _recomputeState();
            continue;
          }

          // Network not ready — abort the whole batch to preserve ordering. The
          // next connectivity event / resume retries after the stabilisation delay.
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.unknown) {
            break;
          }

          // 5xx — transient server error. Retry a few times, then dead-letter.
          if (retryCount >= _maxRetries) {
            await _markDeadLetter(
              key,
              entry,
              'HTTP_${status ?? 500}_max_retries',
            );
            _recomputeState();
            continue;
          }
          await _box.put(
            key,
            Map<dynamic, dynamic>.from(entry)..['retryCount'] = retryCount + 1,
          );
          _recomputeState();
        } catch (_) {
          // Unknown error — skip this item, keep processing the rest.
        }
      }
    } finally {
      _processing = false;
      _recomputeState(
        syncing: false,
        lastSuccessAt: drainedSomething && _pendingKeys().isEmpty
            ? DateTime.now()
            : null,
      );
    }
  }
}
