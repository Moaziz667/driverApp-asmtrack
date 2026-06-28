import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../services/locale_provider.dart';
import '../../../../theme/tokens.dart';
import '../../models/route_models.dart';

class RouteCard extends ConsumerWidget {
  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  final DriverRoute route;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = ref.watch(localeProvider);

    final total = route.totalStops ?? route.stops.length;
    final done = route.completedStops ?? 0;
    final progress = total == 0 ? 0.0 : done / total;
    final showProgress = route.status == DriverRouteStatus.inProgress ||
        route.status == DriverRouteStatus.closed;

    final routeStatusColor = _routeStatusColor(cs, route.status);
    final routeStatusIcon = _routeStatusIcon(route.status);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(
            color: route.status == DriverRouteStatus.cancelled
                ? cs.error.withValues(alpha: 0.3)
                : cs.outlineVariant.withValues(alpha: 0.6),
            width: 1,
          ),
          boxShadow: AppTokens.shadowSm(brightness: theme.brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top accent bar
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: routeStatusColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTokens.radiusLg),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppTokens.space14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: icon + name + status
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: routeStatusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        ),
                        child: Icon(routeStatusIcon, size: 18, color: routeStatusColor),
                      ),
                      const SizedBox(width: AppTokens.space10),
                      Expanded(
                        child: Text(
                          route.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: AppTokens.fwBold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppTokens.space8),
                      _StatusBadge(status: route.status, color: routeStatusColor),
                    ],
                  ),

                  const SizedBox(height: AppTokens.space12),

                  // Row 2: meta pills
                  Wrap(
                    spacing: AppTokens.space6,
                    runSpacing: AppTokens.space6,
                    children: [
                      if (route.plannedStart != null || route.plannedEnd != null)
                        _MetaPill(
                          icon: PhosphorIconsRegular.clock,
                          label: _formatTimeWindow(route.plannedStart, route.plannedEnd),
                        ),
                      if (route.zone != null && route.zone!.isNotEmpty)
                        _MetaPill(
                          icon: PhosphorIconsRegular.mapPin,
                          label: route.zone!,
                        )
                      else if (route.city != null && route.city!.isNotEmpty)
                        _MetaPill(
                          icon: PhosphorIconsRegular.mapPin,
                          label: route.city!,
                        ),
                      _MetaPill(
                        icon: PhosphorIconsRegular.package,
                        label: '$total ${total > 1 ? (locale == 'en' ? 'stops' : 'arrêts') : (locale == 'en' ? 'stop' : 'arrêt')}',
                      ),
                    ],
                  ),

                  // Progress bar
                  if (showProgress) ...[
                    const SizedBox(height: AppTokens.space12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 4,
                              backgroundColor: cs.surfaceContainerHighest,
                              valueColor: AlwaysStoppedAnimation(routeStatusColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTokens.space10),
                        Text(
                          '$done/$total',
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            fontWeight: AppTokens.fwBold,
                            color: routeStatusColor,
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Depot info (multi-depot)
                  if (route.depotName != null && route.depotName!.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.space8),
                    Row(
                      children: [
                        Icon(
                          PhosphorIconsRegular.building,
                          size: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppTokens.space4),
                        Text(
                          route.depotName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTimeWindow(String? start, String? end) {
    if (start != null && end != null) return '$start – $end';
    if (start != null) return 'Dès $start';
    if (end != null) return 'Avant $end';
    return '';
  }

  static Color _routeStatusColor(ColorScheme cs, DriverRouteStatus s) {
    switch (s) {
      case DriverRouteStatus.draft:       return cs.onSurfaceVariant;
      case DriverRouteStatus.validated:   return cs.tertiary;
      case DriverRouteStatus.inProgress:  return cs.primary;
      case DriverRouteStatus.closed:      return cs.tertiary;
      case DriverRouteStatus.cancelled:   return cs.error;
    }
  }

  static IconData _routeStatusIcon(DriverRouteStatus s) {
    switch (s) {
      case DriverRouteStatus.draft:       return PhosphorIconsRegular.pencilSimple;
      case DriverRouteStatus.validated:   return PhosphorIconsRegular.checkCircle;
      case DriverRouteStatus.inProgress:  return PhosphorIconsFill.path;
      case DriverRouteStatus.closed:      return PhosphorIconsFill.checkCircle;
      case DriverRouteStatus.cancelled:   return PhosphorIconsRegular.xCircle;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});
  final DriverRouteStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: AppTokens.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: AppTokens.fwBold,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});
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
          Icon(icon, size: 11, color: cs.onSurfaceVariant),
          const SizedBox(width: AppTokens.space4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: AppTokens.fwMedium,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip(this.status, {super.key});
  final DriverRouteStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color color;
    switch (status) {
      case DriverRouteStatus.draft:       color = cs.onSurfaceVariant; break;
      case DriverRouteStatus.validated:   color = cs.tertiary; break;
      case DriverRouteStatus.inProgress:  color = cs.primary; break;
      case DriverRouteStatus.closed:      color = cs.tertiary; break;
      case DriverRouteStatus.cancelled:   color = cs.error; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: AppTokens.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.5),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: AppTokens.fwBold,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
