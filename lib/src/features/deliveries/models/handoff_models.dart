/// A custody-transfer (handoff) as seen by a driver — mirrors the backend
/// `HandoffResponse` returned by `GET /api/driver/handoffs`.
class HandoffSummary {
  const HandoffSummary({
    required this.id,
    required this.state,
    this.deliveryId,
    this.routeId,
    this.erpOrderId,
    this.clientName,
    this.dropoffAddress,
    this.fromDriverId,
    this.fromDriverName,
    this.toDriverId,
    this.toDriverName,
    this.requestedAt,
    this.tokenExpiresAt,
    this.confirmedAt,
    this.reason,
  });

  factory HandoffSummary.fromJson(Map<String, dynamic> json) {
    DateTime? parse(String? v) => v != null ? DateTime.tryParse(v) : null;
    return HandoffSummary(
      id: json['id'].toString(),
      state: json['state'] as String? ?? 'REQUESTED',
      deliveryId: json['deliveryId'] as String?,
      routeId: json['routeId'] as String?,
      erpOrderId: json['erpOrderId'] as String?,
      clientName: json['clientName'] as String?,
      dropoffAddress: json['dropoffAddress'] as String?,
      fromDriverId: json['fromDriverId'] as String?,
      fromDriverName: json['fromDriverName'] as String?,
      toDriverId: json['toDriverId'] as String?,
      toDriverName: json['toDriverName'] as String?,
      requestedAt: parse(json['requestedAt'] as String?),
      tokenExpiresAt: parse(json['tokenExpiresAt'] as String?),
      confirmedAt: parse(json['confirmedAt'] as String?),
      reason: json['reason'] as String?,
    );
  }

  final String id;
  final String state;
  final String? deliveryId;
  final String? routeId;
  final String? erpOrderId;
  final String? clientName;
  final String? dropoffAddress;
  final String? fromDriverId;
  final String? fromDriverName;
  final String? toDriverId;
  final String? toDriverName;
  final DateTime? requestedAt;
  final DateTime? tokenExpiresAt;
  final DateTime? confirmedAt;
  final String? reason;

  /// True when [driverId] must RECEIVE this parcel (scan the sender's QR).
  bool isIncomingFor(String? driverId) =>
      driverId != null && driverId.isNotEmpty && toDriverId == driverId;

  /// True when [driverId] must HAND OVER this parcel (show the QR to the receiver).
  bool isOutgoingFor(String? driverId) =>
      driverId != null && driverId.isNotEmpty && fromDriverId == driverId;
}
