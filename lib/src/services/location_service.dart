import 'package:geolocator/geolocator.dart';

class LocationPoint {
  const LocationPoint({
    required this.lat,
    required this.lng,
    required this.accuracy,
  });

  final double lat;
  final double lng;
  final double accuracy;
}

class LocationService {
  /// The current position, or null when it cannot be obtained. Never throws.
  ///
  /// The nullable return is the whole contract: every caller treats the GPS stamp as a nice-to-have
  /// on top of the real action — starting a leg, confirming a pickup, filing a proof. But
  /// [_ensurePermission] sat outside the try, and each of the plugin calls inside it can throw:
  /// permissions missing from the manifest, location services off, and above all a permission
  /// request already in flight.
  ///
  /// That last one is not an edge case here. Starting a route fires a position lookup in the
  /// background; tapping "Démarrer le trajet" a few seconds later raised
  /// PermissionRequestInProgressException, the exception escaped, and the action was abandoned
  /// before the request was ever sent — an error on screen with nothing in any server log to explain
  /// it, because nothing had reached the server.
  ///
  /// A helper that advertises "null if unavailable" must not abort its caller.
  Future<LocationPoint?> currentPosition() async {
    try {
      return await _currentPositionOrThrow();
    } catch (_) {
      return null;
    }
  }

  Future<LocationPoint?> _currentPositionOrThrow() async {
    final permission = await _ensurePermission();
    if (!permission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      return LocationPoint(
        lat: position.latitude,
        lng: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (_) {
      // GPS fix timed out or unavailable — try last known position.
      // getLastKnownPosition is unsupported on web, so catch that too.
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last == null) return null;
        return LocationPoint(
          lat: last.latitude,
          lng: last.longitude,
          accuracy: last.accuracy,
        );
      } catch (_) {
        return null;
      }
    }
  }

  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  Future<bool> _ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return permission == LocationPermission.whileInUse || permission == LocationPermission.always;
  }
}
