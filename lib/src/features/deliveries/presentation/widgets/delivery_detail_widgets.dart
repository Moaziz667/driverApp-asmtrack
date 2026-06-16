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

// ─── Hero Card ───────────────────────────────────────────────────────────────
class HeroCard extends ConsumerWidget {
  const HeroCard({super.key, required this.delivery});
  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = ref.watch(localeProvider);
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    final Color statusColor = switch (delivery.status) {
      DeliveryStatus.unscheduled       => statusColors.unscheduled,
      DeliveryStatus.scheduled         => statusColors.scheduled,
      DeliveryStatus.pickedUp          => statusColors.pickedUp,
      DeliveryStatus.inTransit         => statusColors.inTransit,
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
                        delivery.status.label.toUpperCase(),
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
                const SizedBox(height: 18),
                if (delivery.clientName != null) ...[
                  Row(
                    children: [
                      Icon(PhosphorIconsRegular.user, size: 16, color: cs.primary),
                      const SizedBox(width: 8),
                      Text(
                        delivery.clientName!, 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      if (delivery.clientPhone != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => launchUrlString('tel:${delivery.clientPhone}'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(PhosphorIconsBold.phoneCall, size: 12, color: cs.primary),
                                const SizedBox(width: 4),
                                Text(
                                  delivery.clientPhone!, 
                                  style: TextStyle(fontSize: 11, color: cs.primary, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  delivery.address ?? 'Aucune adresse fournie',
                  style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                ),
                if (delivery.city != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(PhosphorIconsRegular.mapPin, size: 14, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text(
                        delivery.city!, 
                        style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Divider(color: cs.outlineVariant.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _StatBox(
                      label: DriverCopy.get('delivery_detail_articles', locale),
                      value: '${delivery.items.length}',
                    ),
                    if (delivery.scheduledAt != null) ...[
                      const SizedBox(width: 12),
                      _StatBox(
                        label: DriverCopy.get('delivery_detail_scheduled', locale),
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
              title: DriverCopy.get('delivery_detail_content', locale), 
              subtitle: countText,
            ),
            const SizedBox(height: 14),
            ...items.asMap().entries.map((e) {
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
                        child: Text(
                          e.value.name, 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: Text(
                          'x${e.value.quantity}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cs.primary),
                        ),
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

// ─── Timestamps ───────────────────────────────────────────────────────────────
class TimestampCard extends ConsumerWidget {
  const TimestampCard({super.key, required this.delivery});
  final DriverDelivery delivery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final entries = delivery.timestamps.entries
        .where((e) => e.value != null)
        .map((e) => (label: _keyLabel(e.key, locale), time: e.value!))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    if (entries.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: DriverCopy.get('delivery_detail_timeline', locale)),
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

  String _keyLabel(String key, String locale) {
    switch (key) {
      case 'scheduledAt': return DriverCopy.get('delivery_detail_ts_scheduled', locale);
      case 'pickedUpAt': return DriverCopy.get('delivery_detail_ts_picked_up', locale);
      case 'inTransitAt': return DriverCopy.get('delivery_detail_ts_in_transit', locale);
      case 'completedAt': return DriverCopy.get('delivery_detail_ts_delivered', locale);
      case 'failedAt': return DriverCopy.get('delivery_detail_ts_failed', locale);
      case 'cancelledAt': return DriverCopy.get('delivery_detail_ts_cancelled', locale);
      case 'createdAt': return DriverCopy.get('delivery_detail_ts_created', locale);
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
    final locale = ref.watch(localeProvider);

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
                    DriverCopy.get('delivery_detail_pending_dispatch', locale),
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
              label: DriverCopy.get('delivery_detail_pickup_package', locale),
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
              label: Text(DriverCopy.get('delivery_detail_fail_report', locale)),
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
                label: Text(DriverCopy.get('delivery_detail_navigate', locale)),
              ),
            ),
          );
          buttons.add(const SizedBox(height: 10));
        }
        buttons.addAll([
          SwipeButton(
            label: DriverCopy.get('delivery_detail_start_transit', locale),
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
              label: Text(DriverCopy.get('delivery_detail_fail_report', locale)),
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
                label: Text(DriverCopy.get('delivery_detail_generate_handoff', locale)),
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
                label: Text(DriverCopy.get('delivery_detail_navigate', locale)),
              ),
            ),
          );
          buttons.add(const SizedBox(height: 10));
        }
        buttons.addAll([
          SwipeButton(
            label: DriverCopy.get('delivery_detail_submit_pod', locale),
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
              label: Text(DriverCopy.get('delivery_detail_fail_report', locale)),
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
                label: Text(DriverCopy.get('delivery_detail_generate_handoff', locale)),
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
                    DriverCopy.get('delivery_detail_locked', locale),
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
    final locale = ref.read(localeProvider);
    if (_loading) return;

    final isOnline = await ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non disponible hors ligne')),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      final ok = await ref.read(pdfServiceProvider).downloadAndOpen(
        '/api/driver/deliveries/${widget.deliveryId}/bon-livraison',
        fileName: 'bon-livraison-${widget.deliveryId}.pdf',
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(DriverCopy.get('pod_pdf_open_error', locale))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(DriverCopy.get('pod_pdf_download_error', locale))),
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
                    DriverCopy.get('pod_view_print_bl', locale),
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
                  : Text(locale == 'ar' ? 'عرض' : locale == 'en' ? 'Open' : 'Ouvrir'),
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
                      locale == 'ar'
                          ? 'طرد محوّل إليك'
                          : locale == 'en'
                              ? 'Package transferred to you'
                              : 'Colis transféré vers vous',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: cs.secondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      locale == 'ar'
                          ? 'عند الاستلام، امسح رمز QR الخاص بالسائق المرسل لتأكيد الاستلام. يمكنك متابعة عملك في هذه الأثناء.'
                          : locale == 'en'
                              ? 'When you receive it, scan the sender driver\'s QR to confirm. You can keep working in the meantime.'
                              : 'À la réception, scannez le QR du chauffeur expéditeur pour confirmer. Vous pouvez continuer votre travail entre-temps.',
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
                locale == 'ar'
                    ? 'امسح رمز المرسل'
                    : locale == 'en'
                        ? 'Scan sender\'s QR'
                        : 'Scanner le QR de l\'expéditeur',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
