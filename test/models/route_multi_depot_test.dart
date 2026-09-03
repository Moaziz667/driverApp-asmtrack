import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/src/features/routes/models/route_models.dart';

/// A delivery whose lines sit in two warehouses must belong to both pickups.
///
/// The phone used to compare a delivery's single `sourceDepotId` against each pickup's. For an order
/// headed "Tunis" with a line waiting in Sousse that matched nothing, so the Sousse depot showed
/// nothing to load and — the part that mattered — `isDepotPicked` fell through to its home-depot
/// branch and declared the delivery already loaded.
void main() {
  const tunis = 'depot-tunis';
  const sousse = 'depot-sousse';

  DriverRouteStop pickup(String depotId, DriverRouteStopStatus status) =>
      DriverRouteStop(
        id: 'pickup-$depotId',
        deliveryId: '',
        stopOrder: 1,
        status: status,
        stopType: 'PICKUP',
        sourceDepotId: depotId,
        sourceDepotIds: [depotId],
      );

  DriverRouteStop delivery({required List<String> from, String? header}) =>
      DriverRouteStop(
        id: 'delivery-1',
        deliveryId: 'delivery-1',
        stopOrder: 2,
        status: DriverRouteStopStatus.pending,
        sourceDepotId: header ?? (from.isEmpty ? null : from.first),
        sourceDepotIds: from,
      );

  DriverRoute route(List<DriverRouteStop> stops) => DriverRoute(
    id: 'r',
    name: 'R001',
    status: DriverRouteStatus.inProgress,
    stops: stops,
  );

  group('multi-depot', () {
    test('a two-warehouse delivery counts at both depots', () {
      final sousseStop = pickup(sousse, DriverRouteStopStatus.pending);
      final tunisStop = pickup(tunis, DriverRouteStopStatus.pending);
      final r = route([
        tunisStop,
        sousseStop,
        delivery(from: [tunis, sousse], header: tunis),
      ]);

      expect(r.pickupParcelCount(sousseStop), 1);
      expect(r.pickupParcelCount(tunisStop), 1);
    });

    test('it is not loaded until the second depot is confirmed', () {
      final r = route([
        pickup(tunis, DriverRouteStopStatus.completed),
        pickup(sousse, DriverRouteStopStatus.pending),
        delivery(from: [tunis, sousse], header: tunis),
      ]);

      expect(r.isDepotPicked(r.stops.last), isFalse);
    });

    test('it is loaded once every depot is confirmed', () {
      final r = route([
        pickup(tunis, DriverRouteStopStatus.completed),
        pickup(sousse, DriverRouteStopStatus.completed),
        delivery(from: [tunis, sousse], header: tunis),
      ]);

      expect(r.isDepotPicked(r.stops.last), isTrue);
    });

    test('an older payload without sourceDepotIds behaves as before', () {
      final sousseStop = pickup(sousse, DriverRouteStopStatus.pending);
      final r = route([sousseStop, delivery(from: const [], header: sousse)]);

      expect(r.pickupParcelCount(sousseStop), 1);
      expect(r.isDepotPicked(r.stops.last), isFalse);
    });

    test('a home-depot delivery needs no pickup', () {
      final r = route([
        delivery(from: [tunis], header: tunis),
      ]);

      expect(r.isDepotPicked(r.stops.last), isTrue);
    });
  });
}
