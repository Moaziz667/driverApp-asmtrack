import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app_providers.dart';
import '../../../theme/tokens.dart';
import '../models/route_models.dart';
import 'widgets/calendar_widgets.dart';

// ── Selected day state ────────────────────────────────────────────────────────
final selectedCalendarDayProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

DateTime _weekStartOf(DateTime d) =>
    DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));

// ─────────────────────────────────────────────────────────────────────────────
class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key, required this.onNavigateToRoute});
  final VoidCallback onNavigateToRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final weekStart = ref.watch(calendarWeekProvider);
    final selectedDay = ref.watch(selectedCalendarDayProvider);
    final routesAsync = ref.watch(weekRoutesProvider(weekStart));

    void changeWeek(DateTime newStart) {
      ref.read(calendarWeekProvider.notifier).state = newStart;
      final today = DateTime.now();
      final todayNorm = DateTime(today.year, today.month, today.day);
      final inNewWeek =
          !todayNorm.isBefore(newStart) &&
          todayNorm.isBefore(newStart.add(const Duration(days: 7)));
      ref.read(selectedCalendarDayProvider.notifier).state = inNewWeek
          ? todayNorm
          : newStart;
    }

    void jumpToToday() {
      final now = DateTime.now();
      final todayNorm = DateTime(now.year, now.month, now.day);
      ref.read(calendarWeekProvider.notifier).state = _weekStartOf(todayNorm);
      ref.read(selectedCalendarDayProvider.notifier).state = todayNorm;
    }

    final routes = routesAsync.valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────
            CalendarHeader(
              weekStart: weekStart,
              selectedDay: selectedDay,
              onJumpToday: jumpToToday,
            ),

            const SizedBox(height: AppTokens.space20),

            // ── Week strip ────────────────────────────────────────────────
            WeekStrip(
              weekStart: weekStart,
              selectedDay: selectedDay,
              routes: routes,
              loading: routesAsync.isLoading,
              onDaySelected: (d) =>
                  ref.read(selectedCalendarDayProvider.notifier).state = d,
              onWeekChanged: changeWeek,
            ),

            const SizedBox(height: AppTokens.space16),

            // ── Day summary bar ───────────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: DaySummaryBar(
                key: ValueKey('${selectedDay.day}-${selectedDay.month}'),
                routes: routes,
                selectedDay: selectedDay,
              ),
            ),

            const SizedBox(height: AppTokens.space16),

            // ── Stop list ─────────────────────────────────────────────────
            Expanded(
              child: routesAsync.when(
                data: (allRoutes) {
                  final dayRoutes =
                      allRoutes
                          .where(
                            (r) =>
                                r.date != null &&
                                _sameDay(r.date!, selectedDay),
                          )
                          .toList()
                        ..sort((a, b) {
                          const order = [
                            DriverRouteStatus.inProgress,
                            DriverRouteStatus.validated,
                            DriverRouteStatus.closed,
                            DriverRouteStatus.draft,
                            DriverRouteStatus.cancelled,
                          ];
                          return order
                              .indexOf(a.status)
                              .compareTo(order.indexOf(b.status));
                        });
                  return StopListView(
                    routes: dayRoutes,
                    selectedDay: selectedDay,
                    onNavigateToRoute: onNavigateToRoute,
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(
                    color: cs.primary,
                    strokeWidth: 2,
                  ),
                ),
                error: (e, _) => CalendarErrorState(message: e.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
