import 'package:driver_app/generated/l10n/app_localizations.dart';
import 'delivery_models.dart';
import '../../routes/models/route_models.dart';

String deliveryStatusLabel(
  DeliveryStatus status,
  AppLocalizations l10n, {
  bool isReturn = false,
}) {
  switch (status) {
    case DeliveryStatus.unscheduled:
      return l10n.statusUnscheduled;
    case DeliveryStatus.scheduled:
      return l10n.statusScheduledLabel;
    // ADR-033 — a return collection: "picked up" = parcel collected at client, "delivered" = received at depot.
    case DeliveryStatus.pickedUp:
      return isReturn ? l10n.statusPickedUpReturn : l10n.statusPickedUpLabel;
    case DeliveryStatus.inTransit:
      return l10n.statusInTransitLabel;
    case DeliveryStatus.awaitingHandoff:
      return l10n.statusAwaitingHandoff;
    case DeliveryStatus.delivered:
      return isReturn ? l10n.statusDeliveredReturn : l10n.statusDeliveredLabel;
    case DeliveryStatus.partially_delivered:
      return l10n.statusPartiallyDelivered;
    case DeliveryStatus.failed:
      return l10n.statusFailedLabel;
    case DeliveryStatus.cancelled:
      return l10n.statusCancelledLabel;
  }
}

String failureReasonLabel(FailureReason reason, AppLocalizations l10n) {
  switch (reason) {
    case FailureReason.clientAbsent:
      return l10n.reasonClientAbsent;
    case FailureReason.refused:
      return l10n.reasonClientRefused;
    case FailureReason.wrongAddress:
      return l10n.reasonWrongAddress;
    case FailureReason.damaged:
      return l10n.reasonPackageDamaged;
    case FailureReason.other:
      return l10n.reasonOther;
  }
}

String routeStatusLabel(DriverRouteStatus status, AppLocalizations l10n) {
  switch (status) {
    case DriverRouteStatus.draft:
      return l10n.routeStatusDraft;
    case DriverRouteStatus.validated:
      return l10n.routeStatusValidated;
    case DriverRouteStatus.inProgress:
      return l10n.routeStatusInProgress;
    case DriverRouteStatus.closed:
      return l10n.routeStatusClosed;
    case DriverRouteStatus.cancelled:
      return l10n.routeStatusCancelledR;
  }
}

String routeStopStatusLabel(
  DriverRouteStopStatus status,
  AppLocalizations l10n,
) {
  switch (status) {
    case DriverRouteStopStatus.pending:
      return l10n.stopStatusPending;
    case DriverRouteStopStatus.arrived:
      return l10n.stopStatusArrived;
    case DriverRouteStopStatus.completed:
      return l10n.stopStatusCompleted;
    case DriverRouteStopStatus.failed:
      return l10n.stopStatusFailed;
    case DriverRouteStopStatus.partial:
      return l10n.stopStatusPartial;
  }
}
