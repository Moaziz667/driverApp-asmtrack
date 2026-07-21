import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../../../app_providers.dart';
import '../../../../services/locale_provider.dart';
import '../../../../theme/status_colors.dart';
import '../../../../theme/swipe_button.dart';
import '../../models/delivery_models.dart';
import '../handoff_token_sheet.dart';
import '../../models/status_labels.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

// ─── Hero Card ───────────────────────────────────────────────────────────────
class HeroCard extends ConsumerWidget {
  const HeroCard({super.key, required this.delivery});
  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    final Color statusColor = switch (delivery.status) {
      DeliveryStatus.unscheduled       => statusColors.unscheduled,
      DeliveryStatus.scheduled         => statusColors.scheduled,
      DeliveryStatus.pickedUp          => statusColors.pickedUp,
      DeliveryStatus.inTransit         => statusColors.inTransit,
      DeliveryStatus.awaitingHandoff   => statusColors.pickedUp,
      DeliveryStatus.delivered         => statusColors.delivered,
      DeliveryStatus.partially_delivered => statusColors.partiallyDelivered,
      DeliveryStatus.failed            => statusColors.failed,
      DeliveryStatus.cancelled         => statusColors.cancelled,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: theme.brightness == Brightness.dark ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            color: statusColor,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1.0),
                      ),
                      child: Text(
                        deliveryStatusLabel(delivery.status, AppLocalizations.of(context), isReturn: delivery.isReturnPickup).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (delivery.orderRef != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text(
                          delivery.orderRef!,
                          style: theme.textTheme.labelLarge?.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ),
                  ],
                ),
                // ADR-033 — make the reverse sense explicit: this is a collection (client→depot), not a delivery.
                if (delivery.isReturnPickup) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(PhosphorIconsRegular.arrowUUpLeft, size: 14, color: cs.tertiary),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context).return_pickup_title,
                        style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.tertiary,
                            ),
                      ),
                      if (delivery.rmaNumber != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          delivery.rmaNumber!,
                          style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                if (delivery.clientName != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          PhosphorIconsFill.user, 
                          size: 20, 
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              delivery.clientName!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (delivery.city != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    PhosphorIconsRegular.mapPin, 
                                    size: 14, 
                                    color: cs.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    delivery.city!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (delivery.clientPhone != null)
                        Material(
                          color: cs.primary,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            onTap: () => launchUrlString('tel:${delivery.clientPhone}'),
                            customBorder: const CircleBorder(),
                            child: const SizedBox(
                              width: 40,
                              height: 40,
                              child: Icon(
                                PhosphorIconsFill.phone, 
                                size: 20, 
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Text(
                  delivery.address ?? AppLocalizations.of(context).deliveryNoAddress,
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 18),
                Divider(color: cs.outlineVariant.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _StatBox(
                      label: AppLocalizations.of(context).delivery_detail_articles,
                      value: '${delivery.items.length}',
                    ),
                    if (delivery.scheduledAt != null) ...[
                      const SizedBox(width: 12),
                      _StatBox(
                        label: AppLocalizations.of(context).delivery_detail_scheduled,
                        value: _fmtDate(delivery.scheduledAt!),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(), 
              style: TextStyle(fontSize: 9, color: cs.onSurfaceVariant, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              value, 
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: cs.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Instructions ────────────────────────────────────────────────────────────
class InstructionsCard extends StatelessWidget {
  const InstructionsCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsRegular.info, color: cs.tertiary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text, 
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Items ───────────────────────────────────────────────────────────────────
class ItemsCard extends ConsumerWidget {
  const ItemsCard({super.key, required this.items});
  final List<OrderItemModel> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final countText = '${items.length} ${locale == 'ar' ? 'سلعة' : locale == 'en' ? 'item${items.length != 1 ? 's' : ''}' : 'article${items.length != 1 ? 's' : ''}'}';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: AppLocalizations.of(context).delivery_detail_content, 
              subtitle: countText,
            ),
            const SizedBox(height: 14),
            ...items.asMap().entries.map((e) {
              final item = e.value;
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Icon(PhosphorIconsRegular.package, size: 14, color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name, 
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                            ),
                            // Per-unit breakdown (WMS): one row per non-delivered disposition, so a
                            // mixed line (e.g. refused 1 + damaged 1) is shown in full, not collapsed.
                            if (item.shortSegments.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              ...item.shortSegments.map((seg) => Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        _OutcomeBadge(outcome: seg.disposition),
                                        const SizedBox(width: 6),
                                        Text('×${seg.quantity}',
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant)),
                                        if (seg.reasonLabel != null && seg.reasonLabel!.isNotEmpty) ...[
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              seg.reasonLabel!,
                                              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  )),
                            ] else if (item.hasOutcome && item.outcome!.toUpperCase() != 'DELIVERED') ...[
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  _OutcomeBadge(outcome: item.outcome!),
                                  if (item.reasonLabel != null && item.reasonLabel!.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        item.reasonLabel!,
                                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ] else if (item.isPartial && item.reasonLabel != null && item.reasonLabel!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                item.reasonLabel!,
                                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (item.hasOutcome && item.quantityDone != null)
                            Text(
                              '${item.quantityDone}/${item.quantity}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: item.isPartial ? Colors.orange : cs.primary,
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
                              ),
                              child: Text(
                                'x${item.quantity}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: cs.primary),
                              ),
                            ),
                          if (item.comment != null && item.comment!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.comment!,
                              style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  if (!isLast) ...[
                    const SizedBox(height: 10),
                    Divider(color: cs.outlineVariant, height: 1),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _OutcomeBadge extends StatelessWidget {
  const _OutcomeBadge({required this.outcome});
  final String outcome;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color) = switch (outcome.toUpperCase()) {
      'DELIVERED' => (AppLocalizations.of(context).statusHistoryDelivered, Colors.green),
      'REFUSED'   => (AppLocalizations.of(context).podOutcomeRefused, cs.error),
      'DAMAGED'   => (AppLocalizations.of(context).podOutcomeDamaged, Colors.orange),
      'MISSING'   => (AppLocalizations.of(context).podOutcomeMissing, Colors.orange),
      _           => (outcome, cs.onSurfaceVariant),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

// ─── Timestamps ───────────────────────────────────────────────────────────────
class TimestampCard extends ConsumerWidget {
  const TimestampCard({super.key, required this.delivery});
  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final entries = delivery.timestamps.entries
        .where((e) => e.value != null)
        .map((e) => (label: _keyLabel(e.key, context), time: e.value!))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    if (entries.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: AppLocalizations.of(context).delivery_detail_timeline),
            const SizedBox(height: 18),
            ...entries.asMap().entries.map((entry) {
              final idx = entry.key;
              final e = entry.value;
              final isLast = idx == entries.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: cs.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: cs.primary.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1),
                          ],
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 28,
                          color: cs.outlineVariant,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            e.label, 
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          Text(
                            _fmtTs(e.time),
                            style: TextStyle(
                              fontSize: 11, 
                              color: cs.onSurfaceVariant, 
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _keyLabel(String key, BuildContext context) {
    switch (key) {
      case 'scheduledAt': return AppLocalizations.of(context).delivery_detail_ts_scheduled;
      case 'pickedUpAt': return AppLocalizations.of(context).delivery_detail_ts_picked_up;
      case 'inTransitAt': return AppLocalizations.of(context).delivery_detail_ts_in_transit;
      case 'completedAt': return AppLocalizations.of(context).delivery_detail_ts_delivered;
      case 'failedAt': return AppLocalizations.of(context).delivery_detail_ts_failed;
      case 'cancelledAt': return AppLocalizations.of(context).delivery_detail_ts_cancelled;
      case 'createdAt': return AppLocalizations.of(context).delivery_detail_ts_created;
      default: return key;
    }
  }

  String _fmtTs(DateTime dt) {
    final d = dt.toLocal();
    return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}

// ─── Action Panel ─────────────────────────────────────────────────────────────
class ActionPanel extends ConsumerWidget {
  const ActionPanel({super.key, 
    required this.delivery,
    required this.isWorking,
    required this.onPickup,
    required this.onTransit,
    required this.onFail,
    required this.onPod,
    this.currentDriverId,
    this.onScanHandoff,
  });

  final DriverDelivery delivery;
  final bool isWorking;
  final Future<void> Function() onPickup;
  final Future<void> Function() onTransit;
  final Future<void> Function() onFail;
  final Future<void> Function() onPod;
  final String? currentDriverId;
  final Future<void> Function()? onScanHandoff;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Handoff: the receiver (handoffToDriverId) is invited to scan the sender's QR,
    // but this is non-blocking — they can keep working their current stop. We surface
    // it as a banner above the normal actions instead of replacing them.
    final bool showHandoffBanner = delivery.requiresHandoff &&
        delivery.handoffConfirmedAt == null &&
        currentDriverId != null &&
        delivery.handoffToDriverId == currentDriverId;

    final buttons = <Widget>[];

    Future<void> launchNav() async {
      final lat = delivery.lat;
      final lng = delivery.lng;
      if (lat == null || lng == null) return;
      final googleUrl = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
      try {
        await launchUrlString(googleUrl, mode: LaunchMode.externalApplication);
      } catch (_) {
        final geoUrl = 'geo:$lat,$lng?q=$lat,$lng';
        try {
          await launchUrlString(geoUrl, mode: LaunchMode.externalApplication);
        } catch (_) {}
      }
    }

    final hasGeo = delivery.lat != null && delivery.lng != null;

    switch (delivery.status) {
      case DeliveryStatus.awaitingHandoff:
        // Custody transfer pending: the receiver confirms via the incoming-handoff flow on the
        // route list ("À recevoir" + scanner), so the delivery detail shows no action here.
        break;
      case DeliveryStatus.unscheduled:
        buttons.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIconsRegular.info, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).delivery_detail_pending_dispatch,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        );
        break;
      case DeliveryStatus.scheduled:
        // In-field reassignment: the parcel is physically held by the previous driver,
        // so custody must be taken by SCANNING the sender's QR (the handoff banner above),
        // NOT a normal depot pickup. Suppress the pickup swipe for the receiving driver —
        // otherwise they could bypass the custody scan (the bug seen after a reassign).
        if (!showHandoffBanner) {
          buttons.add(
            SwipeButton(
              label: delivery.isReturnPickup
                  ? AppLocalizations.of(context).delivery_detail_collect_return
                  : AppLocalizations.of(context).delivery_detail_pickup_package,
              onSwipe: isWorking ? null : onPickup,
              isWorking: isWorking,
              icon: PhosphorIconsBold.package,
            ),
          );
          buttons.add(const SizedBox(height: 10));
        }
        buttons.add(
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isWorking ? null : onFail,
              icon: const Icon(PhosphorIconsBold.flagPennant),
              label: Text(AppLocalizations.of(context).delivery_detail_fail_report),
            ),
          ),
        );
        break;
      case DeliveryStatus.pickedUp:
        if (hasGeo) {
          buttons.add(
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: launchNav,
                icon: const Icon(PhosphorIconsBold.navigationArrow),
                label: Text(AppLocalizations.of(context).delivery_detail_navigate),
              ),
            ),
          );
          buttons.add(const SizedBox(height: 10));
        }
        buttons.addAll([
          SwipeButton(
            label: AppLocalizations.of(context).delivery_detail_start_transit,
            onSwipe: isWorking ? null : onTransit,
            isWorking: isWorking,
            icon: PhosphorIconsBold.steeringWheel,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isWorking ? null : onFail,
              icon: const Icon(PhosphorIconsBold.flagPennant),
              label: Text(AppLocalizations.of(context).delivery_detail_fail_report),
            ),
          ),
          if (delivery.requiresHandoff && delivery.handoffConfirmedAt == null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => HandoffTokenSheet(deliveryId: delivery.id),
                ),
                icon: const Icon(PhosphorIconsBold.qrCode),
                label: Text(AppLocalizations.of(context).delivery_detail_generate_handoff),
              ),
            ),
          ],
        ]);
        break;
      case DeliveryStatus.inTransit:
        if (hasGeo) {
          buttons.add(
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: launchNav,
                icon: const Icon(PhosphorIconsBold.navigationArrow),
                label: Text(AppLocalizations.of(context).delivery_detail_navigate),
              ),
            ),
          );
          buttons.add(const SizedBox(height: 10));
        }
        buttons.addAll([
          SwipeButton(
            label: delivery.isReturnPickup
                ? AppLocalizations.of(context).delivery_detail_confirm_collection
                : AppLocalizations.of(context).delivery_detail_submit_pod,
            onSwipe: isWorking ? null : onPod,
            isWorking: isWorking,
            icon: PhosphorIconsBold.sealCheck,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: isWorking ? null : onFail,
              icon: const Icon(PhosphorIconsBold.flagPennant),
              label: Text(AppLocalizations.of(context).delivery_detail_fail_report),
              style: TextButton.styleFrom(foregroundColor: cs.error),
            ),
          ),
          if (delivery.requiresHandoff && delivery.handoffConfirmedAt == null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => HandoffTokenSheet(deliveryId: delivery.id),
                ),
                icon: const Icon(PhosphorIconsBold.qrCode),
                label: Text(AppLocalizations.of(context).delivery_detail_generate_handoff),
              ),
            ),
          ],
        ]);
        break;
      case DeliveryStatus.delivered:
      case DeliveryStatus.partially_delivered:
      case DeliveryStatus.failed:
      case DeliveryStatus.cancelled:
        buttons.add(
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(PhosphorIconsFill.lock, size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).delivery_detail_locked,
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                ],
              ),
            ),
          )
        );
        break;
    }

    if (buttons.isEmpty && !showHandoffBanner) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showHandoffBanner) ...[
          _HandoffBanner(onScan: onScanHandoff),
          const SizedBox(height: 12),
        ],
        ...buttons,
      ],
    );
  }
}

// ─── Bon de Livraison Card ────────────────────────────────────────────────────
class BonLivraisonCard extends ConsumerStatefulWidget {
  const BonLivraisonCard({super.key, required this.deliveryId});
  final String deliveryId;

  @override
  ConsumerState<BonLivraisonCard> createState() => _BonLivraisonCardState();
}

class _BonLivraisonCardState extends ConsumerState<BonLivraisonCard> {
  bool _loading = false;

  Future<void> _open() async {
    if (_loading) return;

    final isOnline = await ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).bonLivraisonOffline)),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final ok = await ref.read(pdfServiceProvider).downloadAndOpen(
        '/driver/deliveries/${widget.deliveryId}/bon-livraison',
        fileName: 'bon-livraison-${widget.deliveryId}.pdf',
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).pod_pdf_open_error)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).pod_pdf_download_error)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(PhosphorIconsRegular.filePdf, color: cs.tertiary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).pod_view_print_bl,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _loading ? null : _open,
              child: _loading
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(AppLocalizations.of(context).bonLivraisonOpen),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: cs.onSurface, fontWeight: FontWeight.bold)),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(subtitle!, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
        ],
      ],
    );
  }
}

// ─── Handoff Banner (non-blocking) ────────────────────────────────────────────
// Informs the receiving driver that a package was transferred to them and offers
// a "scan QR" action — but does NOT block the rest of the stop's actions.
class _HandoffBanner extends ConsumerWidget {
  const _HandoffBanner({this.onScan});
  final Future<void> Function()? onScan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(PhosphorIconsRegular.package, color: cs.secondary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).handoffTransferredToYou,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: cs.secondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).handoffScanInstructions,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onScan,
              icon: const Icon(PhosphorIconsBold.qrCode, size: 18),
              label: Text(
                AppLocalizations.of(context).handoffScanSenderQr,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── POD Images Card ─────────────────────────────────────────────────────────
class PodImagesCard extends StatelessWidget {
  const PodImagesCard({super.key, required this.pod});
  final ProofOfDeliveryModel pod;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final urls = pod.imageUrls;
    if (urls.isEmpty && (pod.comment == null || pod.comment!.isEmpty)) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: AppLocalizations.of(context).delivery_detail_pod_title,
              subtitle: pod.collectedAt != null
                  ? '${pod.collectedAt!.day}/${pod.collectedAt!.month}/${pod.collectedAt!.year} ${pod.collectedAt!.hour.toString().padLeft(2, '0')}:${pod.collectedAt!.minute.toString().padLeft(2, '0')}'
                  : null,
            ),
            if (pod.comment != null && pod.comment!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pod.comment!,
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
                ),
              ),
            ],
            if (urls.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: urls.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _openFullScreen(context, urls, i),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        urls[i],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          height: 120,
                          color: cs.surfaceContainerHighest,
                          child: Icon(PhosphorIconsRegular.image, color: cs.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openFullScreen(BuildContext context, List<String> urls, int initialIndex) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _FullScreenGallery(urls: urls, initialIndex: initialIndex),
    ));
  }
}

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({required this.urls, required this.initialIndex});
  final List<String> urls;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1}/${widget.urls.length}', style: const TextStyle(fontSize: 16)),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (_, i) => InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Center(
            child: Image.network(
              widget.urls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(PhosphorIconsRegular.image, color: cs.onSurfaceVariant, size: 48),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Failure Reason Card ─────────────────────────────────────────────────────
class FailureReasonCard extends StatelessWidget {
  const FailureReasonCard({super.key, required this.delivery});
  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reason = delivery.status == DeliveryStatus.failed
        ? delivery.failReason
        : delivery.status == DeliveryStatus.cancelled
            ? delivery.cancelReason
            : null;
    if (reason == null || reason.isEmpty) return const SizedBox.shrink();

    final isFailed = delivery.status == DeliveryStatus.failed;
    final color = isFailed ? cs.error : cs.onSurfaceVariant;
    final label = isFailed
        ? AppLocalizations.of(context).delivery_detail_fail_reason
        : AppLocalizations.of(context).delivery_detail_cancel_reason;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isFailed ? PhosphorIconsRegular.warningCircle : PhosphorIconsRegular.xCircle,
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reason,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status History Card ─────────────────────────────────────────────────────
class StatusHistoryCard extends StatelessWidget {
  const StatusHistoryCard({super.key, required this.delivery});
  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final history = delivery.statusHistory;
    if (history.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: AppLocalizations.of(context).delivery_detail_history_title),
            const SizedBox(height: 12),
            ...history.asMap().entries.map((entry) {
              final item = entry.value;
              final isLast = entry.key == history.length - 1;
              final color = _statusColor(cs, item.status);

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
                        ),
                      ),
                      if (!isLast)
                        Container(width: 1, height: 28, color: cs.outlineVariant.withValues(alpha: 0.5)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _statusLabel(item.status, context),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                        ),
                        if (item.changedAt != null)
                          Text(
                            '${item.changedAt!.day.toString().padLeft(2, '0')}/${item.changedAt!.month.toString().padLeft(2, '0')} ${item.changedAt!.hour.toString().padLeft(2, '0')}:${item.changedAt!.minute.toString().padLeft(2, '0')}',
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  static Color _statusColor(ColorScheme cs, String? status) {
    return switch (status) {
      'DELIVERED'            => Colors.green,
      'PARTIALLY_DELIVERED'  => Colors.orange,
      'FAILED'               => cs.error,
      'CANCELLED'            => cs.onSurfaceVariant,
      'IN_TRANSIT'           => cs.primary,
      'PICKED_UP'            => cs.tertiary,
      _                      => cs.outline,
    };
  }

  static String _statusLabel(String? status, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (status) {
      'DELIVERED'            => l10n.statusHistoryDelivered,
      'PARTIALLY_DELIVERED'  => l10n.statusHistoryPartial,
      'FAILED'               => l10n.statusHistoryFailed,
      'CANCELLED'            => l10n.statusHistoryCancelled,
      'IN_TRANSIT'           => l10n.statusHistoryInTransit,
      'PICKED_UP'            => l10n.statusHistoryPickedUp,
      'SCHEDULED'            => l10n.statusHistoryScheduled,
      _                      => l10n.statusHistoryUnknown,
    };
  }
}
