import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Connectivity that distinguishes "an interface is up" from "the server is
/// actually reachable".
///
/// `connectivity_plus` only reports link state, so a Wi-Fi captive portal or a
/// hotel network with no real internet is reported as *online* — the app then
/// fires a request and waits for the full timeout. When a [reachabilityProbe]
/// is supplied, [isOnline] additionally confirms the API answers, with a short
/// cache so we don't probe on every call.
class ConnectivityService {
  ConnectivityService({Future<bool> Function()? reachabilityProbe})
    : _probe = reachabilityProbe;

  final _conn = Connectivity();
  final Future<bool> Function()? _probe;

  static const _cacheTtl = Duration(seconds: 5);
  bool? _cachedReachable;
  DateTime? _cachedAt;

  /// Emits on every link-state change. Coarse (interface-level) by design — the
  /// stream is a *trigger* to re-check, not the source of truth for reachability.
  /// Used to *kick* a queue flush when the radio comes back.
  Stream<bool> get onlineStream => _conn.onConnectivityChanged.map(
    (list) => list.any((r) => r != ConnectivityResult.none),
  );

  /// The stream the UI should trust: reachability, not link state. Emits the real
  /// [isOnline] (probe-backed) on startup, on every interface change, and on a
  /// periodic tick — so "Wi-Fi connected but no internet" reads as offline, and a
  /// silent return of internet on the same interface is picked up too. Values are
  /// de-duplicated so the banner only reacts to genuine transitions.
  Stream<bool> reachabilityStream({
    Duration pollInterval = const Duration(seconds: 30),
  }) async* {
    bool last = await isOnline;
    yield last;

    final trigger = StreamController<void>();
    final sub = _conn.onConnectivityChanged.listen((_) => trigger.add(null));
    final timer = Timer.periodic(pollInterval, (_) => trigger.add(null));
    try {
      await for (final _ in trigger.stream) {
        final now = await isOnline;
        if (now != last) {
          last = now;
          yield now;
        }
      }
    } finally {
      await sub.cancel();
      timer.cancel();
      await trigger.close();
    }
  }

  Future<bool> get isOnline async {
    final linkUp = (await _conn.checkConnectivity()).any(
      (r) => r != ConnectivityResult.none,
    );
    if (!linkUp) return false;
    if (_probe == null) return true;
    return _reachable();
  }

  Future<bool> _reachable() async {
    final now = DateTime.now();
    if (_cachedReachable != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!) < _cacheTtl) {
      return _cachedReachable!;
    }
    bool ok;
    try {
      ok = await _probe!().timeout(const Duration(seconds: 3));
    } catch (_) {
      ok = false;
    }
    _cachedReachable = ok;
    _cachedAt = now;
    return ok;
  }
}
