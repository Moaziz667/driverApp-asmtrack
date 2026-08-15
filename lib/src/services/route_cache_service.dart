import 'dart:convert';

import 'package:hive/hive.dart';

import '../features/routes/models/route_models.dart';

/// Offline copy of today's route.
///
/// The payload is stored **exactly as the server sent it**, not re-serialised field by field. The
/// previous hand-written mapper silently dropped every field added since it was written — stop type,
/// source depots, pickup load, parcel counts, route geometry — so a cached route came back with its
/// depot stops unrecognisable. Keeping the raw JSON makes that class of bug impossible: a new field
/// on the API is cached the day it ships, with no code change here.
///
/// It also lets [applyLocal] project a queued offline action onto the cached route, so the driver's
/// screen advances while the write waits in the queue. That projection is deliberately optimistic and
/// short-lived: the next successful fetch overwrites it with the server's truth, which is what makes a
/// rejected action correct itself on its own.
class RouteCacheService {
  static const _key = 'cached_today_route';
  static const _atKey = 'cached_today_route_at';

  Box get _box => Hive.box('domain_cache');

  Future<void> saveRaw(Map<String, dynamic> json) async {
    try {
      await _box.put(_key, jsonEncode(json));
      await _box.put(_atKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Cache write failures are non-fatal — the app still works online.
    }
  }

  Map<String, dynamic>? loadRaw() {
    try {
      final raw = _box.get(_key) as String?;
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// When the cached route was last refreshed from the server.
  DateTime? cachedAt() {
    final raw = _box.get(_atKey) as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  DriverRoute? load() {
    final json = loadRaw();
    if (json == null) return null;
    try {
      return DriverRoute.fromJson({...json, 'fromCache': true});
    } catch (_) {
      return null;
    }
  }

  /// Rewrite the cached route through [mutate] and return the result, so a queued action is visible
  /// immediately. Returns null when there is nothing cached to project onto.
  Future<DriverRoute?> applyLocal(
      void Function(Map<String, dynamic> route) mutate) async {
    final json = loadRaw();
    if (json == null) return null;
    try {
      mutate(json);
    } catch (_) {
      return null;
    }
    // Deliberately not touching `_atKey`: this is a local projection, not fresh server data, and the
    // "offline data · HH:MM" banner must keep showing when the truth was actually last confirmed.
    try {
      await _box.put(_key, jsonEncode(json));
    } catch (_) {
      return null;
    }
    return load();
  }

  Future<void> clear() async {
    try {
      await _box.delete(_key);
      await _box.delete(_atKey);
    } catch (_) {}
  }
}
