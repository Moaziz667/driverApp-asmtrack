import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../theme/widgets.dart';
import '../../../../theme/swipe_button.dart';
import '../../../../theme/status_colors.dart';
import '../../../../theme/tokens.dart';
import '../../../../services/locale_provider.dart';
import '../../../deliveries/models/delivery_models.dart';
import '../../models/route_models.dart';

class RouteListView extends StatelessWidget {
  const RouteListView({
    super.key,
    required this.route,
    required this.isWorking,
    required this.locale,
    required this.onStart,
    required this.onConfirmPickup,
    required this.onStartTransit,
    required this.onOpenPod,
    required this.onOpenDetails,
    required this.onRefresh,
    this.onDownloadPdf,
    this.onNavigate,
  });

  final DriverRoute? route;
  final bool isWorking;
  final String locale;
  final VoidCallback? onStart;
  final ValueChanged<String>? onConfirmPickup;
  final ValueChanged<String> onStartTransit;
  final ValueChanged<String> onOpenPod;
  final ValueChanged<String> onOpenDetails;
  final VoidCallback onRefresh;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColors = theme.extension<StatusColors>()!;

    // Handle empty state
    if (route == null) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    LucideIcons.ban,
                    size: 32,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  DriverCopy.get('route_empty_title', locale),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: AppTokens.fwBold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  DriverCopy.get('route_empty_subtitle', locale),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: onRefresh,
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
                  label: Text(locale == 'ar' ? 'تحديث' : locale == 'en' ? 'Refresh' : 'Actualiser'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    side: BorderSide(color: colorScheme.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final currentRoute = route!;
    final total = currentRoute.stops.length;
    
    // Find next pending stop for swipe CTAs
    final nextPending = currentRoute.stops
        .where((s) => s.status == DriverRouteStopStatus.pending)
        .firstOrNull;

    return RefreshIndicator(
      color: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerLow,
      onRefresh: () async => onRefresh(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // Offline cached indicator
          if (currentRoute.fromCache) ...[
            const _OfflineBanner(),
            const SizedBox(height: 12),
          ],

          // Route header summary card
          _RouteHeaderCard(route: currentRoute, locale: locale),
          const SizedBox(height: 16),

          // Primary Swipe CTA
          if (currentRoute.status == DriverRouteStatus.validated) ...[
            SwipeButton(
              label: locale == 'ar' ? 'اسحب لبدء الجولة' : locale == 'en' ? 'Swipe to start route' : 'Glisser pour démarrer la tournée',
              onSwipe: isWorking ? null : onStart,
              isWorking: isWorking,
              icon: LucideIcons.play,
            ),
            const SizedBox(height: 12),
          ] else if (currentRoute.status == DriverRouteStatus.inProgress) ...[
            if (nextPending == null)
              const _InfoChip(
                label: 'Tous les arrêts validés',
                color: AppTokens.successGreen,
              )
            else if (nextPending.isPickup)
              SwipeButton(
                label: locale == 'ar' ? 'اسحب للشحن' : locale == 'en' ? 'Swipe to load' : 'Glisser pour charger',
                onSwipe: isWorking ? null : () => onConfirmPickup?.call(nextPending.id),
                isWorking: isWorking,
                icon: LucideIcons.package,
                activeColor: statusColors.pickedUp,
              ),
            const SizedBox(height: 12),
          ] else if (currentRoute.status == DriverRouteStatus.closed) ...[
            const _InfoChip(
              label: 'Tournée terminée',
              color: AppTokens.successGreen,
            ),
            const SizedBox(height: 12),
          ],

          // Actions Panel (Navigate / Download PDF)
          Row(
            children: [
              if (onNavigate != null)
                Expanded(
                  child: _ActionButton(
                    label: locale == 'ar' ? 'توجيه' : locale == 'en' ? 'Navigate' : 'Naviguer',
                    icon: LucideIcons.compass,
                    color: colorScheme.primary,
                    onTap: onNavigate!,
                  ),
                ),
              if (onNavigate != null && onDownloadPdf != null && currentRoute.status == DriverRouteStatus.validated)
                const SizedBox(width: 12),
              if (onDownloadPdf != null && currentRoute.status == DriverRouteStatus.validated)
                Expanded(
                  child: _ActionButton(
                    label: locale == 'ar' ? 'تحميل PDF' : locale == 'en' ? 'PDF' : 'Télécharger PDF',
                    icon: LucideIcons.fileText,
                    color: colorScheme.primary,
                    onTap: onDownloadPdf!,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Section Header: Arrêts
          Row(
            children: [
              Icon(LucideIcons.package, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                '${locale == 'ar' ? 'الوقفات' : locale == 'en' ? 'STOPS' : 'ARRÊTS'} ($total)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: AppTokens.fwBold,
                  letterSpacing: 0.8,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Stop Cards List
          ...currentRoute.stops.map((stop) {
            if (stop.isPickup) {
              final pickList = currentRoute.deliveriesForDepot(stop.sourceDepotId);
              final parcelCount = currentRoute.pickupParcelCount(stop);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _PickupStopCard(
                  stop: stop,
                  parcelCount: parcelCount,
                  pickList: pickList,
                  locale: locale,
                ),
              );
            } else {
              final depotPicked = currentRoute.isDepotPicked(stop);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _StopListItem(
                  stop: stop,
                  depotPicked: depotPicked,
                  locale: locale,
                  onStartTransit: onStartTransit,
                  onOpenPod: onOpenPod,
                  onOpenDetails: onOpenDetails,
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}

class _RouteHeaderCard extends StatelessWidget {
  const _RouteHeaderCard({required this.route, required this.locale});
  final DriverRoute route;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = route.stops.length;
    final done = route.stops.where((s) => s.status != DriverRouteStopStatus.pending).length;
    final progress = total == 0 ? 0.0 : done / total;

    final statusColors = theme.extension<StatusColors>()!;
    final Color accentColor = switch (route.status) {
      DriverRouteStatus.validated => statusColors.scheduled,
      DriverRouteStatus.inProgress => colorScheme.primary,
      DriverRouteStatus.closed => AppTokens.successGreen,
      _ => colorScheme.onSurfaceVariant,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: theme.brightness == Brightness.dark ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            color: accentColor,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        route.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTokens.fwBold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        route.status.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTokens.space12),
                Wrap(
                  spacing: AppTokens.space6,
                  runSpacing: AppTokens.space6,
                  children: [
                    if (route.plannedStart != null || route.plannedEnd != null)
                      _HeaderMetaPill(
                        icon: LucideIcons.clock,
                        label: _fmtTimeWindow(route.plannedStart, route.plannedEnd),
                      ),
                    if (route.zone != null && route.zone!.isNotEmpty)
                      _HeaderMetaPill(icon: LucideIcons.mapPin, label: route.zone!)
                    else if (route.city != null && route.city!.isNotEmpty)
                      _HeaderMetaPill(icon: LucideIcons.mapPin, label: route.city!),
                    _HeaderMetaPill(
                      icon: LucideIcons.package,
                      label: '$total ${total > 1 ? (locale == 'en' ? 'stops' : locale == 'ar' ? 'محطات' : 'arrêts') : (locale == 'en' ? 'stop' : locale == 'ar' ? 'محطة' : 'arrêt')}',
                    ),
                  ],
                ),
                if (route.depotName != null || route.depotAddress != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(LucideIcons.warehouse, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (route.depotName != null)
                                Text(
                                  route.depotName!,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    fontWeight: AppTokens.fwBold,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              if (route.depotAddress != null)
                                Text(
                                  route.depotAddress!,
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$done/$total (${(progress * 100).toStringAsFixed(0)}%)',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: AppTokens.fwBold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PickupStopCard extends StatelessWidget {
  const _PickupStopCard({
    required this.stop,
    required this.parcelCount,
    required this.pickList,
    required this.locale,
  });

  final DriverRouteStop stop;
  final int parcelCount;
  final List<DriverRouteStop> pickList;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pickupColor = theme.extension<StatusColors>()!.pickedUp;
    final done = stop.status == DriverRouteStopStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? cs.outlineVariant : pickupColor.withValues(alpha: 0.5)),
        boxShadow: AppTokens.shadowSm(brightness: theme.brightness),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: pickupColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(LucideIcons.warehouse, size: 16, color: pickupColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DriverCopy.get('route_load_parcels', locale)
                        .replaceAll('{count}', '$parcelCount')
                        .replaceAll('{depot}', stop.sourceDepotName ?? ''),
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 13,
                      fontWeight: AppTokens.fwBold,
                      color: done ? cs.onSurfaceVariant : pickupColor,
                    ),
                  ),
                ),
                if (done)
                  Icon(LucideIcons.checkCircle2, size: 18, color: pickupColor),
              ],
            ),
            if (pickList.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...pickList.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(LucideIcons.dot, size: 14, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [d.orderRef, d.clientName].where((e) => e != null && e.isNotEmpty).join(' · '),
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }
}

class _StopListItem extends StatelessWidget {
  const _StopListItem({
    required this.stop,
    required this.depotPicked,
    required this.locale,
    required this.onStartTransit,
    required this.onOpenPod,
    required this.onOpenDetails,
  });

  final DriverRouteStop stop;
  final bool depotPicked;
  final String locale;
  final ValueChanged<String> onStartTransit;
  final ValueChanged<String> onOpenPod;
  final ValueChanged<String> onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ds = stop.parsedDeliveryStatus;

    return GestureDetector(
      onTap: depotPicked
          ? () => onOpenDetails(stop.deliveryId)
          : () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Confirmez d\'abord le chargement au dépôt')),
              ),
      behavior: HitTestBehavior.opaque,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: theme.brightness == Brightness.dark ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: depotPicked ? 0.6 : 0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Opacity(
            opacity: depotPicked ? 1.0 : 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${stop.stopOrder}',
                          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppTokens.fwBold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        stop.clientName ?? 'Client',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppTokens.fwBold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DeliveryStatusBadge(ds),
                  ],
                ),
                if (stop.address != null || stop.city != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 13, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [stop.address, stop.city].where((e) => e != null && e.isNotEmpty).join(', '),
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (stop.orderRef != null || stop.totalAmount != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (stop.orderRef != null)
                        Text(
                          stop.orderRef!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                        ),
                      if (stop.orderRef != null && stop.totalAmount != null)
                        Text('  ·  ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                      if (stop.totalAmount != null)
                        Text(
                          '${stop.totalAmount!.toStringAsFixed(3)} TND',
                          style: theme.textTheme.bodySmall?.copyWith(fontWeight: AppTokens.fwBold),
                        ),
                    ],
                  ),
                ],
                if (stop.formattedEta != null || stop.formattedSla != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (stop.formattedEta != null) ...[
                        Icon(LucideIcons.clock, size: 12, color: colorScheme.tertiary),
                        const SizedBox(width: 4),
                        Text(
                          'ETA ${stop.formattedEta}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.tertiary,
                            fontWeight: AppTokens.fwMedium,
                          ),
                        ),
                      ],
                      if (stop.formattedEta != null && stop.formattedSla != null)
                        const SizedBox(width: 16),
                      if (stop.formattedSla != null) ...[
                        Icon(LucideIcons.flag, size: 12, color: colorScheme.secondary),
                        const SizedBox(width: 4),
                        Text(
                          'SLA ${stop.formattedSla}',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.secondary,
                            fontWeight: AppTokens.fwMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                // In-transit stop gets a prominent inline CTA (Stitch "Active Route"),
                // taking the driver straight to the delivery's POD flow.
                if (depotPicked && ds == DeliveryStatus.inTransit) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => onOpenPod(stop.deliveryId),
                      icon: const Icon(LucideIcons.checkCircle2, size: 18),
                      label: Text(
                        locale == 'ar'
                            ? 'تأكيد التسليم'
                            : locale == 'en'
                                ? 'Confirm delivery'
                                : 'Confirmer la livraison',
                        style: const TextStyle(fontWeight: AppTokens.fwBold, fontSize: 14),
                      ),
                      // Own height via the style (not a SizedBox) so the label is never
                      // clipped by the theme's 56px min-height + vertical padding.
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        padding: const EdgeInsets.symmetric(vertical: AppTokens.space10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryStatusBadge extends StatelessWidget {
  const _DeliveryStatusBadge(this.status);
  final DeliveryStatus status;

  @override
  Widget build(BuildContext context) {
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final color = switch (status) {
      DeliveryStatus.unscheduled       => statusColors.unscheduled,
      DeliveryStatus.scheduled         => statusColors.scheduled,
      DeliveryStatus.pickedUp          => statusColors.pickedUp,
      DeliveryStatus.inTransit         => statusColors.inTransit,
      DeliveryStatus.delivered         => statusColors.delivered,
      DeliveryStatus.partially_delivered => statusColors.partiallyDelivered,
      DeliveryStatus.failed            => statusColors.failed,
      DeliveryStatus.cancelled         => statusColors.cancelled,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.5),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(fontSize: 8.5, fontWeight: AppTokens.fwBold, color: color),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon, required this.color, required this.onTap});
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontSize: 13, fontWeight: AppTokens.fwBold, color: color),
              ),
            ],
          ),
        ),
      );
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.cloudOff, size: 14, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Mode hors ligne — Données en cache',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.info, size: 14, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: color, fontWeight: AppTokens.fwMedium),
            ),
          ],
        ),
      );
}

String _fmtTimeWindow(String? start, String? end) {
  if (start != null && end != null) return '$start – $end';
  if (start != null) return 'Dès $start';
  if (end != null) return 'Avant $end';
  return '';
}

class _HeaderMetaPill extends StatelessWidget {
  const _HeaderMetaPill({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: AppTokens.space4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: AppTokens.space4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: AppTokens.fwMedium, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class MapPlaceholderLoading extends StatelessWidget {
  const MapPlaceholderLoading({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LoadingState(message: 'Chargement de la tournée...'),
      );
}

class MapError extends StatelessWidget {
  const MapError({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: EmptyState(
          icon: PhosphorIconsRegular.cloudSlash,
          title: 'Impossible de charger la tournée',
          action: onRetry,
          actionLabel: 'Réessayer',
        ),
      );
}
