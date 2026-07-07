enum DeliveryStatus {
  unscheduled,
  scheduled,
  pickedUp,
  inTransit,
  awaitingHandoff,
  delivered,
  partially_delivered,
  failed,
  cancelled,
}

extension DeliveryStatusX on DeliveryStatus {
  static DeliveryStatus fromApi(String? value) {
    switch (value) {
      case 'SCHEDULED':
        return DeliveryStatus.scheduled;
      case 'UNSCHEDULED':
        return DeliveryStatus.unscheduled;
      case 'PICKED_UP':
        return DeliveryStatus.pickedUp;
      case 'IN_TRANSIT':
        return DeliveryStatus.inTransit;
      case 'AWAITING_HANDOFF':
        return DeliveryStatus.awaitingHandoff;
      case 'DELIVERED':
        return DeliveryStatus.delivered;
      case 'PARTIALLY_DELIVERED':
        return DeliveryStatus.partially_delivered;
      case 'FAILED':
        return DeliveryStatus.failed;
      case 'CANCELLED':
        return DeliveryStatus.cancelled;
      default:
        return DeliveryStatus.unscheduled;
    }
  }
}

enum FailureReason { clientAbsent, refused, wrongAddress, damaged, other }

extension FailureReasonX on FailureReason {
  FailureCode get apiCode {
    switch (this) {
      case FailureReason.clientAbsent:
        return FailureCode('CLIENT_ABSENT');
      case FailureReason.refused:
        return FailureCode('REFUSED');
      case FailureReason.wrongAddress:
        return FailureCode('WRONG_ADDRESS');
      case FailureReason.damaged:
        return FailureCode('DAMAGED');
      case FailureReason.other:
        return FailureCode('OTHER');
    }
  }

}

class FailureCode {
  const FailureCode(this.value);
  final String value;
}

/// Configurable failure reason fetched from the backend referential.
/// Falls back to the static [FailureReason] enum when offline.
class FailureReasonOption {
  const FailureReasonOption({required this.code, required this.label, this.category, this.scope = 'DELIVERY'});
  final String code;
  final String label;

  /// Analytics category = the disposition this reason belongs to: REFUSED | DAMAGED | MISSING (item)
  /// or CLIENT_ABSENT | WRONG_ADDRESS | OTHER (delivery-only).
  final String? category;

  /// Where this motif is usable: DELIVERY | ITEM | BOTH. The disposition comes from [category].
  final String scope;

  bool get coversItem => scope == 'ITEM' || scope == 'BOTH';
  bool get coversDelivery => scope == 'DELIVERY' || scope == 'BOTH';

  factory FailureReasonOption.fromJson(Map<String, dynamic> json) => FailureReasonOption(
        code: json['code'] as String? ?? 'OTHER',
        label: json['label'] as String? ?? (json['code'] as String? ?? 'Autre'),
        category: json['category'] as String?,
        scope: (json['scope'] as String?)?.toUpperCase() ?? 'DELIVERY',
      );

  /// Static fallback derived from the legacy enum (used when the API is unreachable).
  static List<FailureReasonOption> get fallback => FailureReason.values
      .map((r) => FailureReasonOption(code: r.apiCode.value, label: r.apiCode.value, category: r.apiCode.value, scope: 'DELIVERY'))
      .toList();
}

/// One disposition of a per-unit line breakdown (WMS): DELIVERED / REFUSED / DAMAGED / MISSING.
class ItemSegment {
  const ItemSegment({required this.disposition, required this.quantity, this.reasonCode, this.reasonLabel, this.comment});
  final String disposition;
  final int quantity;
  final String? reasonCode;
  final String? reasonLabel;
  final String? comment;

  factory ItemSegment.fromJson(Map<String, dynamic> json) => ItemSegment(
        disposition: (json['disposition'] as String? ?? 'DELIVERED').toUpperCase(),
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        reasonCode: json['reasonCode'] as String?,
        reasonLabel: json['reasonLabel'] as String?,
        comment: json['comment'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'disposition': disposition,
        'quantity': quantity,
        if (reasonCode != null) 'reasonCode': reasonCode,
        if (comment != null) 'comment': comment,
      };
}

class OrderItemModel {
  const OrderItemModel({
    required this.name,
    required this.quantity,
    this.sku,
    this.quantityDone,
    this.outcome,
    this.reason,
    this.reasonLabel,
    this.comment,
    this.segments,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] as String? ?? 'Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      sku: json['sku'] as String?,
      quantityDone: (json['quantityDone'] as num?)?.toInt(),
      outcome: json['outcome'] as String?,
      reason: json['reason'] as String?,
      reasonLabel: json['reasonLabel'] as String?,
      comment: json['comment'] as String?,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => ItemSegment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String name;
  final int quantity;
  final String? sku;
  final int? quantityDone;
  final String? outcome;
  final String? reason;
  final String? reasonLabel;
  final String? comment;

  /// Per-unit disposition breakdown (WMS). Null/empty for a clean full delivery.
  final List<ItemSegment>? segments;

  /// The non-delivered segments (refused / damaged / missing), for display.
  List<ItemSegment> get shortSegments =>
      (segments ?? const []).where((s) => s.disposition != 'DELIVERED' && s.quantity > 0).toList();

  bool get hasOutcome => outcome != null && outcome!.isNotEmpty;
  bool get isFullyDelivered => quantityDone != null && quantityDone == quantity;
  bool get isPartial => quantityDone != null && quantityDone! < quantity;
}

class DriverDelivery {
  const DriverDelivery({
    required this.id,
    required this.status,
    this.orderId,
    this.orderRef,
    this.clientName,
    this.clientPhone,
    this.address,
    this.city,
    this.instructions,
    this.totalAmount,
    this.currency,
    this.items = const [],
    this.priority,
    this.scheduledAt,
    this.routeGeometry,
    this.routeDistanceKm,
    this.routeDurationMinutes,
    this.transitSlaMinutesComputed,
    this.routeEtaAt,
    this.routeProvider,
    this.lat,
    this.lng,
    this.requiresHandoff = false,
    this.handoffConfirmedAt,
    this.handoffToDriverId,
    this.handoffFromDriverId,
    this.failReason,
    this.cancelReason,
    this.proofOfDelivery,
    this.statusHistory = const [],
    this.timestamps = const {},
  });

  factory DriverDelivery.fromJson(Map<String, dynamic> json) {
    final timestamps = <String, DateTime?>{};
    for (final key in [
      'scheduledAt',
      'pickedUpAt',
      'inTransitAt',
      'completedAt',
      'failedAt',
      'cancelledAt',
      'createdAt',
    ]) {
      timestamps[key] = json[key] != null ? DateTime.tryParse(json[key] as String) : null;
    }
    return DriverDelivery(
      id: (json['deliveryId'] ?? json['id']).toString(),
      orderId: (json['orderId'])?.toString(),
      orderRef: json['orderRef'] as String?,
      clientName: json['clientName'] as String?,
      clientPhone: json['clientPhone'] as String?,
      status: DeliveryStatusX.fromApi(json['status'] as String?),
      address: json['dropoffAddress'] as String?,
      city: json['dropoffCity'] as String?,
      instructions: json['deliveryInstructions'] as String?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      priority: json['priority'] as String?,
      scheduledAt: json['scheduledAt'] != null ? DateTime.tryParse(json['scheduledAt'] as String) : null,
      routeGeometry: json['routeGeometry'] as String?,
      routeDistanceKm: (json['routeDistanceKm'] as num?)?.toDouble(),
      routeDurationMinutes: (json['routeDurationMinutes'] as num?)?.toInt(),
      transitSlaMinutesComputed: (json['transitSlaMinutesComputed'] as num?)?.toInt(),
      routeEtaAt: json['routeEtaAt'] != null ? DateTime.tryParse(json['routeEtaAt'] as String) : null,
      routeProvider: json['routeProvider'] as String?,
      lat: (json['dropoffLat'] as num?)?.toDouble() ?? (json['lat'] as num?)?.toDouble(),
      lng: (json['dropoffLng'] as num?)?.toDouble() ?? (json['lng'] as num?)?.toDouble(),
      requiresHandoff: json['requiresHandoff'] as bool? ?? false,
      handoffConfirmedAt: json['handoffConfirmedAt'] != null ? DateTime.tryParse(json['handoffConfirmedAt'] as String) : null,
      handoffToDriverId: json['handoffToDriverId'] as String?,
      handoffFromDriverId: json['handoffFromDriverId'] as String?,
      failReason: json['failReason'] as String?,
      cancelReason: json['cancelReason'] as String?,
      proofOfDelivery: json['proofOfDelivery'] != null
          ? ProofOfDeliveryModel.fromJson(json['proofOfDelivery'] as Map<String, dynamic>)
          : null,
      statusHistory: (json['statusHistory'] as List<dynamic>? ?? [])
          .map((h) => StatusHistoryItemModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      timestamps: timestamps,
    );
  }

  final String id;
  final String? orderId;
  final String? orderRef;
  final String? clientName;
  final String? clientPhone;
  final DeliveryStatus status;
  final String? address;
  final String? city;
  final String? instructions;
  final double? totalAmount;
  final String? currency;
  final List<OrderItemModel> items;
  final String? priority;
  final DateTime? scheduledAt;
  final String? routeGeometry;
  final double? routeDistanceKm;
  final int? routeDurationMinutes;
  final int? transitSlaMinutesComputed;
  final DateTime? routeEtaAt;
  final String? routeProvider;
  final double? lat;
  final double? lng;
  final bool requiresHandoff;
  final DateTime? handoffConfirmedAt;
  final String? handoffToDriverId;
  final String? handoffFromDriverId;
  final String? failReason;
  final String? cancelReason;
  final ProofOfDeliveryModel? proofOfDelivery;
  final List<StatusHistoryItemModel> statusHistory;
  final Map<String, DateTime?> timestamps;

  bool get isTerminal => status == DeliveryStatus.delivered || status == DeliveryStatus.failed || status == DeliveryStatus.cancelled;
}

class ProofOfDeliveryModel {
  const ProofOfDeliveryModel({
    this.photoUrl,
    this.signatureUrl,
    this.bonLivraisonPhotoUrl,
    this.comment,
    this.collectedAt,
    this.lat,
    this.lng,
  });

  factory ProofOfDeliveryModel.fromJson(Map<String, dynamic> json) {
    return ProofOfDeliveryModel(
      photoUrl: json['photoUrl'] as String?,
      signatureUrl: json['signatureUrl'] as String?,
      bonLivraisonPhotoUrl: json['bonLivraisonPhotoUrl'] as String?,
      comment: json['comment'] as String?,
      collectedAt: json['collectedAt'] != null ? DateTime.tryParse(json['collectedAt'] as String) : null,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  final String? photoUrl;
  final String? signatureUrl;
  final String? bonLivraisonPhotoUrl;
  final String? comment;
  final DateTime? collectedAt;
  final double? lat;
  final double? lng;

  List<String> get imageUrls {
    final urls = <String>[];
    if (photoUrl != null && photoUrl!.isNotEmpty) urls.add(photoUrl!);
    if (bonLivraisonPhotoUrl != null && bonLivraisonPhotoUrl!.isNotEmpty) urls.add(bonLivraisonPhotoUrl!);
    if (signatureUrl != null && signatureUrl!.isNotEmpty) urls.add(signatureUrl!);
    return urls;
  }
}

class StatusHistoryItemModel {
  const StatusHistoryItemModel({
    this.status,
    this.eventKey,
    this.eventParams,
    this.changedAt,
    this.changedBy,
  });

  factory StatusHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return StatusHistoryItemModel(
      status: json['status'] as String?,
      eventKey: json['eventKey'] as String?,
      eventParams: json['eventParams'] as Map<String, dynamic>?,
      changedAt: json['changedAt'] != null ? DateTime.tryParse(json['changedAt'] as String) : null,
      changedBy: json['changedBy'] as String?,
    );
  }

  final String? status;
  final String? eventKey;
  final Map<String, dynamic>? eventParams;
  final DateTime? changedAt;
  final String? changedBy;
}

class PartialDeliveryItem {
  PartialDeliveryItem({
    required this.sku,
    required this.quantityDone,
    this.outcome,
    this.reason,
    this.comment,
    this.segments,
  });

  final String sku;
  final int quantityDone;

  /// DELIVERED, REFUSED, or DAMAGED — explicit per-item outcome (legacy single-disposition path).
  final String? outcome;

  /// Reason code when outcome is REFUSED or DAMAGED.
  final String? reason;

  /// Optional per-item comment from the driver.
  final String? comment;

  /// Per-unit breakdown (WMS). When set, the backend derives quantityDone/outcome/reason from it.
  final List<ItemSegment>? segments;

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'quantityDone': quantityDone,
      if (outcome != null) 'outcome': outcome,
      if (reason != null) 'reason': reason,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      if (segments != null && segments!.isNotEmpty)
        'segments': segments!.map((s) => s.toJson()).toList(),
    };
  }
}

class PodPayload {
  PodPayload({
    required this.bonLivraisonPhotoBase64,
    required this.packagePhotoBase64,
    this.comment,
    this.lat,
    this.lng,
    this.isPartial = false,
    this.itemsDone,
  });

  final String bonLivraisonPhotoBase64;
  final String packagePhotoBase64;
  final String? comment;
  final double? lat;
  final double? lng;
  final bool isPartial;
  final List<PartialDeliveryItem>? itemsDone;

  Map<String, dynamic> toJson() {
    return {
      'bonLivraisonPhotoBase64': bonLivraisonPhotoBase64,
      'packagePhotoBase64': packagePhotoBase64,
      'comment': comment,
      'lat': lat,
      'lng': lng,
      'isPartial': isPartial,
      'itemsDone': itemsDone?.map((e) => e.toJson()).toList(),
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));
  }
}

/// A freshly generated one-time handoff code plus its server-authoritative expiry,
/// so the sender's sheet can show a live countdown and lock the code at expiry.
class HandoffTokenInfo {
  const HandoffTokenInfo({required this.token, this.expiresAt});

  final String token;
  final DateTime? expiresAt;
}

