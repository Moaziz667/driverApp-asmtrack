import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

import '../../../../app_providers.dart';
import '../../../../theme/status_colors.dart';
import '../../../../theme/tokens.dart';
import '../../models/route_models.dart';
import '../route_detail_sheet.dart';

List<String> _kMonths(AppLocalizations l10n) => [
  l10n.monthJanuary, l10n.monthFebruary, l10n.monthMarch, l10n.monthApril,
  l10n.monthMay, l10n.monthJune, l10n.monthJuly, l10n.monthAugust,
  l10n.monthSeptember, l10n.monthOctober, l10n.monthNovember, l10n.monthDecember,
];
const _kDayLetters = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
List<String> _kDayFull(AppLocalizations l10n) => [
  l10n.dayMonday, l10n.dayTuesday, l10n.dayWednesday, l10n.dayThursday,
  l10n.dayFriday, l10n.daySaturday, l10n.daySunday,
];

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _weekStartOf(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

int _weekNumber(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  final doy = date.difference(startOfYear).inDays + 1;
  return ((doy + startOfYear.weekday - 2) / 7).floor() + 1;
}

// ─── Header ───────────────────────────────────────────────────────────────────
class CalendarHeader extends StatelessWidget {
  const CalendarHeader({super.key, 
    required this.weekStart,
    required this.selectedDay,
    required this.onJumpToday,
  });

  final DateTime weekStart;
  final DateTime selectedDay;
  final VoidCallback onJumpToday;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final currentWeekStart = _weekStartOf(todayNorm);
    final isCurrentWeek = _sameDay(weekStart, currentWeekStart);
    final weekNum = _weekNumber(weekStart);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppTokens.space20, AppTokens.space20, AppTokens.space20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_kMonths(l10n)[selectedDay.month - 1]} ${selectedDay.year}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: AppTokens.fwBold,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppTokens.space4),
                Text(
                  l10n.calendarWeek(weekNum.toString()),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: AppTokens.fwMedium,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrentWeek)
            Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              child: InkWell(
                onTap: onJumpToday,
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.space14, vertical: AppTokens.space8),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.35),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIconsBold.calendar, size: 13, color: cs.primary),
                      const SizedBox(width: AppTokens.space6),
                      Text(
                        l10n.calendarTodayButton,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: AppTokens.fwSemiBold,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Week strip ───────────────────────────────────────────────────────────────
class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, 
    required this.weekStart,
    required this.selectedDay,
    required this.routes,
    required this.loading,
    required this.onDaySelected,
    required this.onWeekChanged,
  });

  final DateTime weekStart;
  final DateTime selectedDay;
  final List<DriverRoute> routes;
  final bool loading;
  final ValueChanged<DateTime> onDaySelected;
  final ValueChanged<DateTime> onWeekChanged;

  Map<String, List<DriverRoute>> _byDay() {
    final map = <String, List<DriverRoute>>{};
    for (final r in routes) {
      if (r.date != null) {
        final k = _dayKey(r.date!);
        map.putIfAbsent(k, () => []).add(r);
      }
    }
    return map;
  }

  static String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final byDay = _byDay();

    return GestureDetector(
      onHorizontalDragEnd: (d) {
        final v = d.primaryVelocity;
        if (v == null) return;
        if (v < -400) onWeekChanged(weekStart.add(const Duration(days: 7)));
        if (v > 400) onWeekChanged(weekStart.subtract(const Duration(days: 7)));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.space14, horizontal: AppTokens.space4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            border: Border.all(color: cs.outlineVariant),
            boxShadow: AppTokens.shadowMd(brightness: Theme.of(context).brightness),
          ),
          child: Row(
            children: [
              _NavArrow(
                icon: PhosphorIconsBold.caretLeft,
                onTap: () => onWeekChanged(weekStart.subtract(const Duration(days: 7))),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (i) {
                    final day = weekStart.add(Duration(days: i));
                    final dayRoutes = byDay[_dayKey(day)] ?? [];
                    return _DayCell(
                      day: day,
                      isToday: _sameDay(day, todayNorm),
                      isSelected: _sameDay(day, selectedDay),
                      dayRoutes: dayRoutes,
                      loading: loading,
                      onTap: () => onDaySelected(day),
                    );
                  }),
                ),
              ),
              _NavArrow(
                icon: PhosphorIconsBold.caretRight,
                onTap: () => onWeekChanged(weekStart.add(const Duration(days: 7))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 28,
        height: 64,
        child: Icon(icon, size: 13, color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.dayRoutes,
    required this.loading,
    required this.onTap,
  });

  final DateTime day;
  final bool isToday;
  final bool isSelected;
  final List<DriverRoute> dayRoutes;
  final bool loading;
  final VoidCallback onTap;

  static DriverRouteStatus? _dominant(List<DriverRoute> routes) {
    if (routes.isEmpty) return null;
    const order = [
      DriverRouteStatus.inProgress,
      DriverRouteStatus.validated,
      DriverRouteStatus.closed,
      DriverRouteStatus.cancelled,
      DriverRouteStatus.draft,
    ];
    for (final s in order) {
      if (routes.any((r) => r.status == s)) return s;
    }
    return routes.first.status;
  }

  static Color _statusColor(BuildContext context, DriverRouteStatus s) {
    final cs = Theme.of(context).colorScheme;
    switch (s) {
      case DriverRouteStatus.draft:      return cs.onSurfaceVariant;
      case DriverRouteStatus.validated:  return cs.tertiary;
      case DriverRouteStatus.inProgress: return cs.primary;
      case DriverRouteStatus.closed:     return cs.tertiary;
      case DriverRouteStatus.cancelled:  return cs.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasRoutes = dayRoutes.isNotEmpty;
    final dominant = _dominant(dayRoutes);
    final dotColor = dominant != null ? _statusColor(context, dominant) : null;
    final routeCount = dayRoutes.length;

    final Color circleBg;
    final Color circleText;
    final BoxBorder? circleBorder;

    if (isToday && isSelected) {
      circleBg = cs.primary;
      circleText = Colors.black;
      circleBorder = null;
    } else if (isToday) {
      circleBg = cs.primary.withValues(alpha: 0.85);
      circleText = Colors.black;
      circleBorder = null;
    } else if (isSelected) {
      circleBg = cs.primary.withValues(alpha: 0.15);
      circleText = cs.primary;
      circleBorder = Border.all(color: cs.primary, width: 1.5);
    } else {
      circleBg = Colors.transparent;
      circleText = hasRoutes ? cs.onSurface : cs.onSurfaceVariant;
      circleBorder = null;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 36,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _kDayLetters[day.weekday - 1],
              style: TextStyle(
                fontSize: 10,
                fontWeight: AppTokens.fwSemiBold,
                color: isSelected || isToday ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppTokens.space6),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
                border: circleBorder,
              ),
              child: Center(
                child: Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: 14,
                    fontWeight: AppTokens.fwBold,
                    color: circleText,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space6),
            if (!loading && hasRoutes && dotColor != null)
              Container(
                height: 16,
                constraints: const BoxConstraints(minWidth: 16),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                  border: Border.all(
                    color: dotColor.withValues(alpha: 0.45),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$routeCount',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: AppTokens.fwBold,
                      color: dotColor,
                      height: 1,
                    ),
                  ),
                ),
              )
            else if (loading && isSelected)
              SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
              )
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─── Day summary bar ──────────────────────────────────────────────────────────
class DaySummaryBar extends StatelessWidget {
  const DaySummaryBar({super.key, required this.routes, required this.selectedDay});
  final List<DriverRoute> routes;
  final DateTime selectedDay;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final dayRoutes = routes
        .where((r) => r.date != null && _sameDay(r.date!, selectedDay))
        .toList();

    if (dayRoutes.isEmpty) return const SizedBox.shrink();

    final totalRoutes = dayRoutes.length;
    final totalStops = dayRoutes.fold<int>(0, (s, r) => s + (r.totalStops ?? r.stops.length));
    final completedStops = dayRoutes.fold<int>(0, (s, r) => s + (r.completedStops ?? 0));
    final progress = totalStops > 0 ? completedStops / totalStops : 0.0;

    double totalMontant = 0;
    for (final route in dayRoutes) {
      for (final stop in route.stops) {
        totalMontant += stop.totalAmount ?? 0;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.space16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: AppTokens.shadowSm(brightness: theme.brightness),
        ),
        child: Column(
          children: [
            Row(
              children: [
                _SummaryItem(
                  value: '$totalRoutes',
                  label: totalRoutes > 1 ? l10n.calendarRoutes : l10n.calendarRoute,
                  icon: PhosphorIconsRegular.path,
                  color: cs.tertiary,
                ),
                const SizedBox(width: AppTokens.space16),
                _SummaryItem(
                  value: '$totalStops',
                  label: l10n.calendarStops,
                  icon: PhosphorIconsRegular.package,
                  color: cs.primary,
                ),
                const SizedBox(width: AppTokens.space16),
                _SummaryItem(
                  value: '$completedStops/$totalStops',
                  label: l10n.calendarDelivered,
                  icon: PhosphorIconsRegular.checkCircle,
                  color: const Color(0xFF4CAF82),
                ),
                const Spacer(),
                if (totalMontant > 0)
                  _SummaryItem(
                    value: '${totalMontant.toStringAsFixed(3)} TND',
                    label: l10n.calendarAmount,
                    icon: PhosphorIconsRegular.currencyCircleDollar,
                    color: const Color(0xFFC4881A),
                  ),
              ],
            ),
            const SizedBox(height: AppTokens.space12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              ),
            ),
            const SizedBox(height: AppTokens.space4),
            Text(
              l10n.calendarProgress((progress * 100).round().toString()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: AppTokens.fwMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.value, required this.label, required this.icon, required this.color});
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.7)),
        const SizedBox(height: AppTokens.space4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: AppTokens.fwBold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: AppTokens.fwMedium,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ─── Stop list view ───────────────────────────────────────────────────────────
class StopListView extends StatelessWidget {
  const StopListView({super.key, 
    required this.routes,
    required this.selectedDay,
    required this.onNavigateToRoute,
  });

  final List<DriverRoute> routes;
  final DateTime selectedDay;
  final VoidCallback onNavigateToRoute;

  String _dayLabel(AppLocalizations l10n) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);
    final tomorrow = todayNorm.add(const Duration(days: 1));
    if (_sameDay(selectedDay, todayNorm)) return l10n.calendarToday;
    if (_sameDay(selectedDay, tomorrow)) return l10n.calendarTomorrow;
    return '${_kDayFull(l10n)[selectedDay.weekday - 1]} ${selectedDay.day} ${_kMonths(l10n)[selectedDay.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final label = _dayLabel(l10n);

    if (routes.isEmpty) return _EmptyDay(label: label);

    final allStops = <_StopInfo>[];
    for (final route in routes) {
      for (final stop in route.stops) {
        allStops.add(_StopInfo(route: route, stop: stop));
      }
    }
    allStops.sort((a, b) => a.stop.stopOrder.compareTo(b.stop.stopOrder));

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppTokens.space16, 0, AppTokens.space16, AppTokens.space32),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.space14),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: AppTokens.fwBold,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppTokens.space10),
              Expanded(child: Container(height: 1, color: cs.outlineVariant)),
              const SizedBox(width: AppTokens.space10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Text(
                  '${allStops.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: AppTokens.fwBold,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...allStops.map((info) => Padding(
              padding: const EdgeInsets.only(bottom: AppTokens.space10),
              child: _StopCard(
                info: info,
                // Tap shows the command details + items (lazy-loaded) in a sheet — the
                // "Ouvrir la tournée" action inside preserves the old navigate-to-route behaviour.
                onTap: () => _showStopItemsSheet(
                  context,
                  info,
                  () => _handleTap(context, info.route, onNavigateToRoute),
                ),
              ),
            )),
      ],
    );
  }

  static void _handleTap(
    BuildContext context,
    DriverRoute route,
    VoidCallback onNavigateToRoute,
  ) {
    if (route.status == DriverRouteStatus.cancelled) {
      _showCancelledSheet(context, route);
      return;
    }
    if (route.isToday &&
        (route.status == DriverRouteStatus.validated ||
            route.status == DriverRouteStatus.inProgress)) {
      onNavigateToRoute();
      return;
    }
    RouteDetailSheet.show(context, route);
  }

  static void _showCancelledSheet(BuildContext context, DriverRoute route) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radiusXl)),
        ),
        padding: const EdgeInsets.fromLTRB(AppTokens.space24, 0, AppTokens.space24, AppTokens.space40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              ),
              child: Icon(PhosphorIconsFill.xCircle, size: 24, color: cs.error),
            ),
            const SizedBox(height: AppTokens.space14),
            Text(
              l10n.calendarRouteCancelledTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: AppTokens.fwBold,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppTokens.space6),
            Text(
              l10n.calendarRouteCancelledBody(route.name),
              style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTokens.space24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: cs.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(vertical: AppTokens.space14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                ),
                child: Text(
                  l10n.calendarClose,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: AppTokens.fwBold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopInfo {
  const _StopInfo({required this.route, required this.stop});
  final DriverRoute route;
  final DriverRouteStop stop;
}

void _showStopItemsSheet(BuildContext context, _StopInfo info, VoidCallback onOpenRoute) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _StopItemsSheet(info: info, onOpenRoute: onOpenRoute),
  );
}

/// Bottom sheet showing a stop's command details + line items. Header fields come from the
/// route stop (already loaded); the item list is lazy-loaded once via [deliveryDetailProvider].
class _StopItemsSheet extends ConsumerWidget {
  const _StopItemsSheet({required this.info, required this.onOpenRoute});
  final _StopInfo info;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final stop = info.stop;
    final detail = ref.watch(deliveryDetailProvider(stop.deliveryId));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              stop.clientName ?? l10n.calendarClient,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: AppTokens.fwBold, color: cs.onSurface),
            ),
            if (stop.orderRef != null && stop.orderRef!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(stop.orderRef!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
            if (stop.address != null && stop.address!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(PhosphorIconsRegular.mapPin, size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      [stop.address, stop.city].where((e) => e != null && e.isNotEmpty).join(', '),
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Text(
              l10n.calendarItems,
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: AppTokens.fwBold, color: cs.onSurface),
            ),
            const SizedBox(height: 8),
            detail.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 22),
                child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))),
              ),
              error: (_, __) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  l10n.calendarLoadItemsError,
                  style: theme.textTheme.bodySmall?.copyWith(color: cs.error),
                ),
              ),
              data: (d) {
                if (d.items.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(
                      l10n.calendarNoItems,
                      style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                final amount = d.totalAmount ?? stop.totalAmount ?? 0;
                return Column(
                  children: [
                    ...d.items.map((it) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${it.quantity}',
                                  style: TextStyle(fontWeight: AppTokens.fwBold, color: cs.primary, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      it.name,
                                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppTokens.fwMedium, color: cs.onSurface),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (it.sku != null && it.sku!.isNotEmpty)
                                      Text(it.sku!, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (amount > 0) ...[
                      const SizedBox(height: 10),
                      Divider(color: cs.outlineVariant, height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.calendarAmount,
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          Text('${amount.toStringAsFixed(3)} ${d.currency ?? 'TND'}',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: AppTokens.fwBold, color: cs.onSurface)),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onOpenRoute();
                },
                icon: const Icon(Icons.map_outlined, size: 16),
                label: Text(l10n.calendarOpenRoute),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.primary,
                  side: BorderSide(color: cs.outlineVariant),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StopCard extends StatelessWidget {
  const _StopCard({required this.info, required this.onTap});
  final _StopInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final stop = info.stop;
    final route = info.route;

    final deliveryStatus = stop.deliveryStatus?.toUpperCase() ?? '';
    final statusColor = statusColors.forDeliveryStatus(deliveryStatus);
    final statusLabel = _deliveryStatusLabel(deliveryStatus, l10n);

    double montant = 0;
    for (final s in route.stops) {
      if (s.id == stop.id) {
        montant = s.totalAmount ?? 0;
        break;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          border: Border.all(color: cs.outlineVariant),
          boxShadow: AppTokens.shadowSm(brightness: theme.brightness),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: stop order + status
            Container(
              padding: const EdgeInsets.fromLTRB(AppTokens.space14, AppTokens.space12, AppTokens.space14, 0),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        '${stop.stopOrder}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: AppTokens.fwBold,
                          color: cs.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.space8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(color: statusColor.withValues(alpha: 0.25), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: AppTokens.fwBold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (stop.formattedEta != null)
                    Text(
                      stop.formattedEta!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: AppTokens.fwMedium,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space10),

            // Client info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
              stop.clientName ?? l10n.calendarClient,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: AppTokens.fwBold,
                      color: cs.onSurface,
                    ),
                  ),
                  if (stop.address != null) ...[
                    const SizedBox(height: AppTokens.space4),
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.mapPin, size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppTokens.space4),
                        Expanded(
                          child: Text(
                            stop.address!,
                            style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (stop.city != null) ...[
                    const SizedBox(height: AppTokens.space2),
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.building, size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppTokens.space4),
                        Text(
                          stop.city!,
                          style: TextStyle(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (stop.formattedTimeWindow != null) ...[
                    const SizedBox(height: AppTokens.space4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      ),
                      child: Text(
                        stop.formattedTimeWindow!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: AppTokens.fwMedium,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppTokens.space10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space14),
              child: Container(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: AppTokens.space10),

            // Bottom: items + montant
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTokens.space14, 0, AppTokens.space14, AppTokens.space12),
              child: Row(
                children: [
                  Row(
                    children: [
                      Icon(PhosphorIconsRegular.package, size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: AppTokens.space4),
                      Text(
                        route.stops.length > 1 ? l10n.routeStopCount(route.stops.length.toString()) : l10n.routeStopCountSingular(route.stops.length.toString()),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: AppTokens.fwMedium,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (montant > 0)
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.currencyCircleDollar, size: 13, color: const Color(0xFFC4881A)),
                        const SizedBox(width: AppTokens.space4),
                        Text(
                          '${montant.toStringAsFixed(3)} TND',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: AppTokens.fwBold,
                            color: const Color(0xFFC4881A),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _deliveryStatusLabel(String status, AppLocalizations l10n) {
    switch (status) {
      case 'UNSCHEDULED': return l10n.statusUnscheduled;
      case 'SCHEDULED': return l10n.statusScheduled;
      case 'PICKED_UP': return l10n.statusPickedUp;
      case 'IN_TRANSIT': return l10n.statusInTransit;
      case 'DELIVERED': return l10n.statusDelivered;
      case 'PARTIALLY_DELIVERED': case 'PARTIAL': return l10n.statusPartial;
      case 'FAILED': case 'FAILED_ATTEMPT': return l10n.statusFailed;
      case 'CANCELLED': return l10n.statusCancelled;
      default: return l10n.statusPending;
    }
  }
}

// ─── Empty day ────────────────────────────────────────────────────────────────
class _EmptyDay extends StatelessWidget {
  const _EmptyDay({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(
              PhosphorIconsRegular.calendarBlank,
              size: 30,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppTokens.space18),
          Text(
            l10n.calendarNoRoutes,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: AppTokens.fwBold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ─── Error state ──────────────────────────────────────────────────────────────
class CalendarErrorState extends StatelessWidget {
  const CalendarErrorState({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsRegular.cloudSlash, size: 34, color: cs.onSurfaceVariant),
          const SizedBox(height: AppTokens.space12),
          Text(
            l10n.calendarLoadRoutesError,
            style: TextStyle(
              fontSize: 14,
              fontWeight: AppTokens.fwSemiBold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            l10n.calendarCheckConnection,
            style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
