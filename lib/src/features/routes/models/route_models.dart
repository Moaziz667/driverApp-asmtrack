import '../../../features/deliveries/models/delivery_models.dart';

enum DriverRouteStatus { draft, validated, inProgress, closed, cancelled }

extension DriverRouteStatusX on DriverRouteStatus {
  static DriverRouteStatus fromApi(String? value) {
    switch (value) {
      case 'DRAFT':
        return DriverRouteStatus.draft;
      case 'IN_PROGRESS':
        return DriverRouteStatus.inProgress;
      case 'CLOSED':
        return DriverRouteStatus.closed;
      case 'CANCELLED':
        return DriverRouteStatus.cancelled;
      case 'VALIDATED':
      default:
        return DriverRouteStatus.validated;
    }
  }
}

enum DriverRouteStopStatus { pending, arrived, completed, failed, partial }

extension DriverRouteStopStatusX on DriverRouteStopStatus {
  static DriverRouteStopStatus fromApi(String? value) {
    switch (value) {
      case 'ARRIVED':
        return DriverRouteStopStatus.arrived;
      case 'COMPLETED':
        return DriverRouteStopStatus.completed;
      case 'FAILED':
        return DriverRouteStopStatus.failed;
      case 'PARTIAL':
        return DriverRouteStopStatus.partial;
      case 'PENDING':
      default:
        return DriverRouteStopStatus.pending;
    }
  }
}

/// One line to carry out of a depot at a pickup stop.
class PickupLoadLine {
  const PickupLoadLine({
    this.orderRef,
    this.clientName,
    this.sku,
    this.name,
    this.quantity,
  });

  factory PickupLoadLine.fromJson(Map<String, dynamic> json) => PickupLoadLine(
    orderRef: json['orderRef'] as String?,
    clientName: json['clientName'] as String?,
    sku: json['sku'] as String?,
    name: json['name'] as String?,
    quantity: (json['quantity'] as num?)?.toInt(),
  );

  final String? orderRef;
  final String? clientName;
  final String? sku;
  final String? name;
  final int? quantity;

  /// What the article is, falling back to its code when the ERP sent no label.
  String get label => name?.isNotEmpty == true ? name! : (sku ?? '');
}

class DriverRouteStop {
  const DriverRouteStop({
    required this.id,
    required this.deliveryId,
    required this.stopOrder,
    required this.status,
    this.lat,
    this.lng,
    this.address,
    this.city,
    this.deliveryStatus,
    this.clientName,
    this.clientPhone,
    this.totalAmount,
    this.orderRef,
    this.etaAt,
    this.slaDeadline,
    this.stopType = 'DELIVERY',
    this.sourceDepotId,
    this.sourceDepotIds = const [],
    this.pickupLoad = const [],
    this.sourceDepotName,
    this.sourceDepotLat,
    this.sourceDepotLng,
    this.startTimeWindow,
    this.endTimeWindow,
  });

  factory DriverRouteStop.fromJson(Map<String, dynamic> json) {
    return DriverRouteStop(
      id: (json['id'] ?? '').toString(),
      deliveryId: (json['deliveryId'] ?? '').toString(),
      stopOrder: (json['stopOrder'] as num?)?.toInt() ?? 0,
      status: DriverRouteStopStatusX.fromApi(json['status'] as String?),
      lat: (json['dropoffLat'] as num?)?.toDouble(),
      lng: (json['dropoffLng'] as num?)?.toDouble(),
      address: json['deliveryAddress'] as String?,
      city: json['deliveryCity'] as String?,
      deliveryStatus: json['deliveryStatus'] as String?,
      clientName: json['clientName'] as String?,
      clientPhone: json['clientPhone'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      orderRef: json['orderRef'] as String?,
      etaAt: json['etaAt'] as String?,
      slaDeadline: json['slaDeadline'] as String?,
      stopType: (json['stopType'] as String?) ?? 'DELIVERY',
      sourceDepotId: json['sourceDepotId'] as String?,
      sourceDepotIds:
          (json['sourceDepotIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      pickupLoad:
          (json['pickupLoad'] as List<dynamic>?)
              ?.map((e) => PickupLoadLine.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      sourceDepotName: json['sourceDepotName'] as String?,
      sourceDepotLat: (json['sourceDepotLat'] as num?)?.toDouble(),
      sourceDepotLng: (json['sourceDepotLng'] as num?)?.toDouble(),
      startTimeWindow: json['startTimeWindow'] as String?,
      endTimeWindow: json['endTimeWindow'] as String?,
    );
  }

  final String id;
  final String deliveryId;
  final int stopOrder;
  final DriverRouteStopStatus status;
  final double? lat;
  final double? lng;
  final String? address;
  final String? city;
  final String? deliveryStatus;
  final String? clientName;
  final String? clientPhone;
  final double? totalAmount;
  final String? orderRef;
  final String? etaAt;
  final String? slaDeadline;

  // Multi-depot (slice 6)
  final String stopType;
  final String? sourceDepotId;

  /// Every depot this stop's goods are loaded from.
  ///
  /// [sourceDepotId] names one, which is all an ERP issuing a note per warehouse ever needs. One
  /// that puts the warehouse on the line can send half an order from elsewhere, and matching on the
  /// single field then hid the second load: the depot said it held nothing, and worse,
  /// [isDepotPicked] found no pickup for it and answered "already loaded".
  final List<String> sourceDepotIds;

  /// For a PICKUP: what to physically carry out of the depot.
  ///
  /// An order reference is not a loading instruction, and it misleads once an order is split
  /// across warehouses — at Sousse one collects the water of order 127, its dates stay in Tunis.
  final List<PickupLoadLine> pickupLoad;

  /// The depots to match on — falls back to the single field for an older payload.
  List<String> get loadedFrom => sourceDepotIds.isNotEmpty
      ? sourceDepotIds
      : (sourceDepotId != null ? [sourceDepotId!] : const []);

  final String? sourceDepotName;
  final double? sourceDepotLat;
  final double? sourceDepotLng;
  final String? startTimeWindow;
  final String? endTimeWindow;

  bool get isPickup => stopType == 'PICKUP';

  bool get hasPinned => lat != null && lng != null;

  /// Where this stop actually is, whichever kind it is.
  ///
  /// A PICKUP stop has no delivery, so [lat]/[lng] — which come from the order's dropoff — are
  /// null on it. Navigation filtered on those alone and so dropped every depot from the
  /// itinerary: the map sent the driver from wherever he stood straight to the first customer,
  /// past the warehouse holding the parcels. On a single-depot round he knows the way and nobody
  /// notices; on a multi-depot one he misses the second load entirely.
  ///
  /// The depot's coordinates were already in the payload and on this model, simply never used.
  double? get navLat => isPickup ? sourceDepotLat : lat;
  double? get navLng => isPickup ? sourceDepotLng : lng;

  bool get hasNavPoint => navLat != null && navLng != null;

  DeliveryStatus get parsedDeliveryStatus =>
      DeliveryStatusX.fromApi(deliveryStatus);

  String? get formattedEta => _formatTime(etaAt);
  String? get formattedSla => _formatTime(slaDeadline);

  String? get formattedTimeWindow {
    if (startTimeWindow == null || endTimeWindow == null) return null;
    return '$startTimeWindow – $endTimeWindow';
  }

  static String? _formatTime(String? iso) {
    if (iso == null) return null;
    final dt = DateTime.tryParse(iso)?.toLocal();
    if (dt == null) return null;
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class DriverRoute {
  const DriverRoute({
    required this.id,
    required this.name,
    required this.status,
    required this.stops,
    this.zone,
    this.startedAt,
    this.date,
    this.city,
    this.totalStops,
    this.completedStops,
    this.progressPercent,
    this.plannedStart,
    this.plannedEnd,
    this.routeGeometry,
    this.depotName,
    this.depotAddress,
    this.vehicleName,
    this.vehiclePlate,
    this.fromCache = false,
  });

  factory DriverRoute.fromJson(Map<String, dynamic> json) {
    final stops =
        (json['stops'] as List<dynamic>? ?? [])
            .map((e) => DriverRouteStop.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    return DriverRoute(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'Tournée',
      status: DriverRouteStatusX.fromApi(json['status'] as String?),
      zone: json['detectedZoneLabel'] as String? ?? json['zone'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'] as String)
          : null,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      city: json['city'] as String?,
      totalStops: (json['totalStops'] as num?)?.toInt() ?? stops.length,
      completedStops: (json['completedStops'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      plannedStart: json['plannedStartTime'] as String?,
      plannedEnd: json['plannedEndTime'] as String?,
      routeGeometry: json['routeGeometry'] as String?,
      depotName: json['depotName'] as String?,
      depotAddress: json['depotAddress'] as String?,
      vehicleName: json['vehicleName'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
      // Set by RouteCacheService when the payload comes off disk rather than the wire.
      fromCache: json['fromCache'] == true,
      stops: stops,
    );
  }

  final String id;
  final String name;
  final DriverRouteStatus status;
  final String? zone;
  final DateTime? startedAt;
  final List<DriverRouteStop> stops;

  // Scheduling & calendar fields
  final DateTime? date;
  final String? city;
  final int? totalStops;
  final int? completedStops;
  final double? progressPercent;
  final String? plannedStart;
  final String? plannedEnd;
  final String? routeGeometry;
  final String? depotName;
  final String? depotAddress;
  final String? vehicleName;
  final String? vehiclePlate;

  /// True when this route was loaded from the local SharedPreferences cache
  /// because the network was unavailable.
  final bool fromCache;

  bool get isToday {
    if (date == null) return false;
    final now = DateTime.now();
    return date!.year == now.year &&
        date!.month == now.month &&
        date!.day == now.day;
  }

  // ── Multi-depot helpers (slice 6) ──────────────────────────────────────────

  /// Delivery stops loaded from the given source depot.
  ///
  /// A delivery drawn from two warehouses appears under both, which is why this asks
  /// [DriverRouteStop.loadedFrom] rather than comparing the single depot field.
  List<DriverRouteStop> deliveriesForDepot(String? depotId) => depotId == null
      ? const []
      : stops
            .where((s) => !s.isPickup && s.loadedFrom.contains(depotId))
            .toList();

  /// Number of parcels (delivery stops) a pickup stop loads.
  int pickupParcelCount(DriverRouteStop pickup) =>
      deliveriesForDepot(pickup.sourceDepotId).length;

  /// True when every depot this delivery draws from has been collected (or none needs collecting —
  /// a home-depot delivery has no PICKUP stop, it was loaded before departure).
  ///
  /// This used to look for a pickup whose depot equalled the delivery's own, so a delivery headed
  /// "Tunis" with a line waiting in Sousse matched nothing, fell into the home-depot branch and
  /// reported itself loaded. The driver could complete it without ever stopping in Sousse — the
  /// precedence rule the backend enforces, silently bypassed on the phone.
  bool isDepotPicked(DriverRouteStop deliveryStop) {
    final pickups = stops
        .where(
          (s) =>
              s.isPickup && deliveryStop.loadedFrom.contains(s.sourceDepotId),
        )
        .toList();
    if (pickups.isEmpty) return true; // home depot — loaded at start
    return pickups.every((p) => p.status == DriverRouteStopStatus.completed);
  }
}
