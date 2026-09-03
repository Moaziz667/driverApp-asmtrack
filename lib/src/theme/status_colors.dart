import 'package:flutter/material.dart';

class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.unscheduled,
    required this.scheduled,
    required this.pickedUp,
    required this.inTransit,
    required this.delivered,
    required this.partiallyDelivered,
    required this.cancelled,
    required this.failed,
    required this.online,
    required this.onBreak,
    required this.offline,
  });

  final Color unscheduled;
  final Color scheduled;
  final Color pickedUp;
  final Color inTransit;
  final Color delivered;
  final Color partiallyDelivered;
  final Color cancelled;
  final Color failed;

  // Driver online statuses
  final Color online;
  final Color onBreak;
  final Color offline;

  Color forDeliveryStatus(String status) {
    final s = status.toUpperCase();
    if (s == 'UNSCHEDULED') return unscheduled;
    if (s == 'SCHEDULED') return scheduled;
    if (s == 'PICKED_UP') return pickedUp;
    if (s == 'IN_TRANSIT') return inTransit;
    if (s == 'DELIVERED') return delivered;
    if (s == 'PARTIALLY_DELIVERED' || s == 'PARTIAL') return partiallyDelivered;
    if (s == 'CANCELLED') return cancelled;
    if (s == 'FAILED' || s == 'FAILED_ATTEMPT') return failed;
    return cancelled;
  }

  Color surfaceForDeliveryStatus(String status, {double alpha = 0.15}) {
    return forDeliveryStatus(status).withValues(alpha: alpha);
  }

  Color forDriverStatus(String status) {
    final s = status.toUpperCase();
    if (s == 'ONLINE') return online;
    if (s == 'ON_BREAK') return onBreak;
    return offline;
  }

  Color surfaceForDriverStatus(String status, {double alpha = 0.15}) {
    return forDriverStatus(status).withValues(alpha: alpha);
  }

  @override
  StatusColors copyWith({
    Color? unscheduled,
    Color? scheduled,
    Color? pickedUp,
    Color? inTransit,
    Color? delivered,
    Color? partiallyDelivered,
    Color? cancelled,
    Color? failed,
    Color? online,
    Color? onBreak,
    Color? offline,
  }) {
    return StatusColors(
      unscheduled: unscheduled ?? this.unscheduled,
      scheduled: scheduled ?? this.scheduled,
      pickedUp: pickedUp ?? this.pickedUp,
      inTransit: inTransit ?? this.inTransit,
      delivered: delivered ?? this.delivered,
      partiallyDelivered: partiallyDelivered ?? this.partiallyDelivered,
      cancelled: cancelled ?? this.cancelled,
      failed: failed ?? this.failed,
      online: online ?? this.online,
      onBreak: onBreak ?? this.onBreak,
      offline: offline ?? this.offline,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      unscheduled: Color.lerp(unscheduled, other.unscheduled, t)!,
      scheduled: Color.lerp(scheduled, other.scheduled, t)!,
      pickedUp: Color.lerp(pickedUp, other.pickedUp, t)!,
      inTransit: Color.lerp(inTransit, other.inTransit, t)!,
      delivered: Color.lerp(delivered, other.delivered, t)!,
      partiallyDelivered: Color.lerp(
        partiallyDelivered,
        other.partiallyDelivered,
        t,
      )!,
      cancelled: Color.lerp(cancelled, other.cancelled, t)!,
      failed: Color.lerp(failed, other.failed, t)!,
      online: Color.lerp(online, other.online, t)!,
      onBreak: Color.lerp(onBreak, other.onBreak, t)!,
      offline: Color.lerp(offline, other.offline, t)!,
    );
  }
}
