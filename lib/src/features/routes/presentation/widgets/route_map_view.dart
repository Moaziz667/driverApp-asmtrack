import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../theme/widgets.dart';
import '../../../../theme/swipe_button.dart';
import '../../../../theme/status_colors.dart';
import '../../../../theme/tokens.dart';
import '../../../../services/locale_provider.dart';
import '../../../deliveries/models/delivery_models.dart';
import '../../models/route_models.dart';

// Default map center — Tunisia (Tunis)
const _kDefaultCenter = LatLng(36.8065, 10.1815);

class RouteMapView extends StatelessWidget {
  const RouteMapView({
    super.key,
    required this.route,
    required this.isWorking,
    required this.locale,
    required this.mapController,
    required this.sheetController,
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
  final MapController mapController;
  final DraggableScrollableController sheetController;
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
    final isDark = theme.brightness == Brightness.dark;
    
    // Build real stop coords from pinned deliveries; filter out unpinned stops
    final pinnedStops = route?.stops.where((s) => s.hasPinned).toList() ?? [];
    final stopCoords = pinnedStops.map((s) => LatLng(s.lat!, s.lng!)).toList();

    // Map center: first pinned stop, or Tunisia default
    final mapCenter = stopCoords.isNotEmpty ? stopCoords.first : _kDefaultCenter;

    // Route polyline: prefer OSRM geometry, fallback to point-to-point
    final List<LatLng> polyPoints;
    if (route?.routeGeometry != null && route!.routeGeometry!.isNotEmpty) {
      polyPoints = DriverRoute.decodePolyline(route!.routeGeometry!);
    } else {
      polyPoints = stopCoords;
    }

    // Depot marker: first point of OSRM polyline (depot is always origin of optimization)
    final LatLng? depotCoord = polyPoints.isNotEmpty ? polyPoints.first : null;

    final urlTemplate = isDark
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png';

    return Stack(
      children: [
        // ── Full-screen OSM Map ──────────────────────────────────────────────
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: stopCoords.length > 1 ? 12 : 13,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: urlTemplate,
              userAgentPackageName: 'com.asm.driverapp',
            ),
            // Route polyline
            if (polyPoints.length > 1)
              PolylineLayer(
                polylines: <Polyline>[
                  Polyline(
                    points: polyPoints,
                    strokeWidth: 4.5,
                    color: theme.colorScheme.primary,
                    borderColor: isDark ? Colors.black : Colors.white,
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),
            // Depot marker (start of OSRM polyline = depot origin)
            if (depotCoord != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: depotCoord,
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: () => mapController.move(depotCoord, 15.5),
                      child: const _DepotMarker(),
                    ),
                  ),
                ],
              ),
            // Stop markers at real coordinates
            MarkerLayer(
              markers: pinnedStops.asMap().entries.map((entry) {
                final stop = entry.value;
                final coord = stopCoords[entry.key];
                final isDone = stop.status != DriverRouteStopStatus.pending;
                final isNext = !isDone &&
                    (route?.stops.firstWhere(
                          (s) => s.status == DriverRouteStopStatus.pending,
                          orElse: () => stop,
                        ) ==
                        stop);
                return Marker(
                  point: coord,
                  width: isNext ? 75 : 42,
                  height: isNext ? 75 : 62,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      mapController.move(coord, 15.5);
                    },
                    child: _StopMarker(
                      order: stop.stopOrder,
                      isDone: isDone,
                      isNext: isNext,
                      etaAt: stop.etaAt,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // ── Top bar ─────────────────────────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MapTopBar(route: route, onRefresh: onRefresh),
              if (route?.fromCache == true) const _OfflineBanner(),
            ],
          ),
        ),

        // ── Bottom sheet ────────────────────────────────────────────────────
        DraggableScrollableSheet(
          controller: sheetController,
          initialChildSize: 0.35,
          minChildSize: 0.12,
          maxChildSize: 0.75,
          snap: true,
          snapSizes: const [0.12, 0.35, 0.75],
          builder: (context, scrollController) => _BottomSheet(
            scrollController: scrollController,
            route: route,
            isWorking: isWorking,
            locale: locale,
            onStart: onStart,
            onConfirmPickup: onConfirmPickup,
            onStartTransit: onStartTransit,
            onOpenPod: onOpenPod,
            onOpenDetails: onOpenDetails,
            onDownloadPdf: onDownloadPdf,
            onNavigate: onNavigate,
          ),
        ),
      ],
    );
  }
}

// ─── Depot Marker ─────────────────────────────────────────────────────────────
class _DepotMarker extends StatelessWidget {
  const _DepotMarker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), // Dark Slate
        shape: BoxShape.circle,
        border: Border.all(color: cs.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.warehouse_rounded,
        size: 18,
        color: cs.primary,
      ),
    );
  }
}

// ─── Stop Marker ──────────────────────────────────────────────────────────────
class _StopMarker extends StatefulWidget {
  const _StopMarker({required this.order, required this.isDone, required this.isNext, this.etaAt});
  final int order;
  final bool isDone;
  final bool isNext;
  final String? etaAt;

  @override
  State<_StopMarker> createState() => _StopMarkerState();
}

class _StopMarkerState extends State<_StopMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    if (widget.isNext) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _StopMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNext && !oldWidget.isNext) {
      _pulseController.repeat();
    } else if (!widget.isNext && oldWidget.isNext) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String? get _time {
    if (widget.etaAt == null) return null;
    try {
      final dt = DateTime.parse(widget.etaAt!).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color color;
    if (widget.isDone) {
      color = const Color(0xFF10B981); // Emerald Green
    } else if (widget.isNext) {
      color = cs.primary; // Glowing primary blue/cyan
    } else {
      color = const Color(0xFFF59E0B); // Amber
    }

    final time = _time;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing radar effect
            if (widget.isNext)
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 32 * _pulseAnimation.value,
                    height: 32 * _pulseAnimation.value,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: (1.0 - (_pulseAnimation.value - 1.0) / 1.2) * 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color.withValues(alpha: (1.0 - (_pulseAnimation.value - 1.0) / 1.2) * 0.4),
                        width: 1.5,
                      ),
                    ),
                  );
                },
              ),
            // Pin marker itself
            Container(
              width: widget.isNext ? 36 : 28,
              height: widget.isNext ? 36 : 28,
              decoration: BoxDecoration(
                color: widget.isDone
                    ? color.withValues(alpha: 0.15)
                    : color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isDone ? color : Colors.white,
                  width: widget.isNext ? 2.5 : 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: widget.isNext ? 0.5 : 0.2),
                    blurRadius: widget.isNext ? 8 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: widget.isDone
                    ? Icon(Icons.check, size: widget.isNext ? 18 : 14, color: color)
                    : Text(
                        '${widget.order}',
                        style: TextStyle(
                          fontSize: widget.isNext ? 14 : 11,
                          fontWeight: FontWeight.w700,
                          color: widget.isDone ? color : Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
        if (time != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.black,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: color.withValues(alpha: 0.4),
                width: 0.5,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Map Top Bar ──────────────────────────────────────────────────────────────
class _MapTopBar extends StatelessWidget {
  const _MapTopBar({required this.route, required this.onRefresh});
  final DriverRoute? route;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Refresh button
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant),
                  boxShadow: AppTokens.shadowSm(brightness: theme.brightness),
                ),
                child: Icon(
                  PhosphorIconsBold.arrowsClockwise,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ─── Bottom Sheet ─────────────────────────────────────────────────────────────
class _BottomSheet extends StatelessWidget {
  const _BottomSheet({
    required this.scrollController,
    required this.route,
    required this.isWorking,
    required this.locale,
    required this.onStart,
    required this.onConfirmPickup,
    required this.onStartTransit,
    required this.onOpenPod,
    required this.onOpenDetails,
    this.onDownloadPdf,
    this.onNavigate,
  });

  final ScrollController scrollController;
  final DriverRoute? route;
  final bool isWorking;
  final String locale;
  final VoidCallback? onStart;
  final ValueChanged<String>? onConfirmPickup;
  final ValueChanged<String> onStartTransit;
  final ValueChanged<String> onOpenPod;
  final ValueChanged<String> onOpenDetails;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onNavigate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final pendingStops = route?.stops
        .where((s) => s.status == DriverRouteStopStatus.pending)
        .toList() ??
      const [];
    final nextPendingStop = pendingStops.isNotEmpty ? pendingStops.first : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? const Color(0xE6121824) 
                  : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: isDark ? 0.35 : 0.7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // Frosted Drag Handle
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Container(
                      width: 38,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                ),

                if (route == null) ...[
                  // No active route panel
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLow,
                            shape: BoxShape.circle,
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Icon(LucideIcons.ban, size: 24, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune tournée assignée',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'En attente d\'instructions du dispatch',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Route summary row
                  _RouteSummaryBar(route: route!),
                  const SizedBox(height: 18),

                  // Swipe CTAs replacing primary buttons
                  if (route!.status == DriverRouteStatus.validated)
                    SwipeButton(
                      label: DriverCopy.get('route_swipe_start', locale),
                      onSwipe: isWorking ? null : () => onStart?.call(),
                      isWorking: isWorking,
                      icon: PhosphorIconsBold.play,
                      activeColor: const Color(0xFF1E40AF),
                    )
                  else if (route!.status == DriverRouteStatus.inProgress) ...[
                    if (nextPendingStop == null)
                      _InfoChip(label: DriverCopy.get('route_all_stops_done', locale), color: cs.secondary)
                    else if (nextPendingStop.isPickup)
                      SwipeButton(
                        label: DriverCopy.get('route_swipe_load', locale),
                        onSwipe: isWorking ? null : () => onConfirmPickup?.call(nextPendingStop.id),
                        isWorking: isWorking,
                        icon: PhosphorIconsBold.package,
                        activeColor: const Color(0xFF0891B2),
                      ),
                    // Delivery stop → no CTA; the driver opens it by tapping the stop on the map/list.
                  ],

                  // Secondary actions row (PDF + Maps)
                  if (route!.status == DriverRouteStatus.validated ||
                      route!.status == DriverRouteStatus.inProgress) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (route!.status == DriverRouteStatus.validated) ...[
                          Expanded(
                            child: _ActionButton(
                              label: DriverCopy.get('route_download_pdf', locale),
                              icon: LucideIcons.fileDown,
                              color: cs.secondary,
                              onTap: () => onDownloadPdf?.call(),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: _ActionButton(
                            label: DriverCopy.get('route_navigate', locale),
                            icon: LucideIcons.navigation2,
                            color: cs.primary,
                            onTap: () => onNavigate?.call(),
                          ),
                        ),
                      ],
                    ),
                  ],

                  if (route!.status == DriverRouteStatus.closed)
                    _InfoChip(label: DriverCopy.get('route_finished', locale), color: cs.onSurfaceVariant),

                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        DriverCopy.get('route_stops_log', locale),
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Divider(color: cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${route!.stops.length}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (route!.stops.isEmpty)
                    Text(
                      DriverCopy.get('route_no_stops', locale),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    )
                  else
                    ...route!.stops.map((stop) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: stop.isPickup
                              ? _PickupStopCard(
                                  stop: stop,
                                  parcelCount: route!.pickupParcelCount(stop),
                                  pickList: route!.deliveriesForDepot(stop.sourceDepotId),
                                  locale: locale,
                                )
                              : _StopListItem(
                                  stop: stop,
                                  depotPicked: route!.isDepotPicked(stop),
                                  onStartTransit: onStartTransit,
                                  onOpenPod: onOpenPod,
                                  onOpenDetails: onOpenDetails,
                                ),
                        )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteSummaryBar extends StatelessWidget {
  const _RouteSummaryBar({required this.route});
  final DriverRoute route;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final total = route.stops.length;
    final done = route.stops.where((s) => s.status != DriverRouteStopStatus.pending).length;
    final progress = total == 0 ? 0.0 : done / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(route.name, style: theme.textTheme.titleMedium),
            ),
            Text('$done / $total', style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.primary)),
          ],
        ),
        if (route.zone != null && route.zone!.isNotEmpty) ...[
          const SizedBox(height: 3),
          Row(children: [
            Icon(Icons.map_outlined, size: 12, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(route.zone!, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
          ]),
        ],
        if (route.depotName != null || route.depotAddress != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.warehouse_outlined, size: 13, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (route.depotName != null)
                        Text(route.depotName!, style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.primary)),
                      if (route.depotAddress != null)
                        Text(route.depotAddress!, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('${(progress * 100).toStringAsFixed(0)}%', style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary)),
          ],
        ),
      ],
    );
  }
}

/// Multi-depot PICKUP stop: "Charger N colis — Dépôt X" with a pick list and a confirm button.
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

  static const Color _pickup = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final done = stop.status == DriverRouteStopStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: done ? cs.outlineVariant : _pickup.withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2))],
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
                    color: _pickup.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warehouse_outlined, size: 16, color: _pickup),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DriverCopy.get('route_load_parcels', locale)
                        .replaceAll('{count}', '$parcelCount')
                        .replaceAll('{depot}', stop.sourceDepotName ?? ''),
                    style: theme.textTheme.labelLarge?.copyWith(fontSize: 13, fontWeight: FontWeight.w700, color: done ? cs.onSurfaceVariant : _pickup),
                  ),
                ),
                if (done)
                  const Icon(Icons.check_circle, size: 18, color: _pickup),
              ],
            ),
            if (pickList.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...pickList.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 5, color: cs.onSurfaceVariant),
                        const SizedBox(width: 8),
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
    required this.onStartTransit,
    required this.onOpenPod,
    required this.onOpenDetails,
    this.depotPicked = true,
  });

  final DriverRouteStop stop;
  final ValueChanged<String> onStartTransit;
  final ValueChanged<String> onOpenPod;
  final ValueChanged<String> onOpenDetails;
  /// False when this delivery's source depot hasn't been picked up yet — the row
  /// is locked until the driver confirms that depot's pickup stop.
  final bool depotPicked;

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
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text('${stop.stopOrder}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    stop.clientName ?? 'Client',
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _DeliveryStatusBadge(ds),
              ],
            ),
            if (stop.address != null || stop.city != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 12, color: colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
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
              const SizedBox(height: 4),
              Row(
                children: [
                  if (stop.orderRef != null)
                    Text(stop.orderRef!, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  if (stop.orderRef != null && stop.totalAmount != null)
                    Text('  .  ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                  if (stop.totalAmount != null)
                    Text('${stop.totalAmount!.toStringAsFixed(3)} TND', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ],
            if (stop.formattedEta != null || stop.formattedSla != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  if (stop.formattedEta != null) ...[
                    Icon(Icons.schedule_rounded, size: 11, color: colorScheme.tertiary),
                    const SizedBox(width: 3),
                    Text('ETA ${stop.formattedEta}', style: TextStyle(fontSize: 10, color: colorScheme.tertiary, fontWeight: FontWeight.w600)),
                  ],
                  if (stop.formattedEta != null && stop.formattedSla != null)
                    const Text('   '),
                  if (stop.formattedSla != null) ...[
                    Icon(Icons.flag_outlined, size: 11, color: colorScheme.secondary),
                    const SizedBox(width: 3),
                    Text('SLA ${stop.formattedSla}', style: TextStyle(fontSize: 10, color: colorScheme.secondary, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ],
            ],
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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(status.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      color: Colors.amber.shade700,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'Donnees en cache - reconnectez-vous pour actualiser',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
      );
}

class MapPlaceholderLoading extends StatelessWidget {
  const MapPlaceholderLoading({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        body: LoadingState(message: 'Chargement de la tournee...'),
      );
}

class MapError extends StatelessWidget {
  const MapError({super.key, required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: EmptyState(
          icon: PhosphorIconsRegular.cloudSlash,
          title: 'Impossible de charger la tournee',
          action: onRetry,
          actionLabel: 'Reessayer',
        ),
      );
}
