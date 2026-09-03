import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app_providers.dart';
import '../../../theme/widgets.dart';
import '../../../theme/status_colors.dart';
import '../models/delivery_models.dart';
import '../models/status_labels.dart';
import 'delivery_detail_screen.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

class HistoryTab extends ConsumerStatefulWidget {
  const HistoryTab({super.key});

  @override
  ConsumerState<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<HistoryTab> {
  _HistoryFilter _filter = _HistoryFilter.all;
  DateTimeRange? _dateRange;

  void _selectDateRange() async {
    final cs = Theme.of(context).colorScheme;
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: cs.primary,
              onPrimary: Colors.black,
              surface: cs.surfaceContainerLow,
              onSurface: cs.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(driverHistoryProvider);
    final notifier = ref.read(driverHistoryProvider.notifier);

    return RefreshIndicator(
      color: cs.primary,
      backgroundColor: cs.surfaceContainerLow,
      onRefresh: () => notifier.loadFirst(),
      child: Builder(
        builder: (context) {
          // First page in flight (nothing loaded yet).
          if (state.loading && state.items.isEmpty) {
            return LoadingState(
              message: AppLocalizations.of(context).historyLoading,
            );
          }
          // Failed before any page loaded → offline/retry state.
          if (state.error != null && state.items.isEmpty) {
            return EmptyState(
              icon: PhosphorIconsRegular.cloudSlash,
              title: AppLocalizations.of(context).historyOffline,
              action: () => notifier.loadFirst(),
              actionLabel: AppLocalizations.of(context).routeRetry,
            );
          }

          // Client-side narrowing over the loaded pages (status/date) — infinite scroll loads more.
          final filtered = state.items.where((d) {
            final matchesStatus = _filter.matches(d.status);
            if (!matchesStatus) return false;
            if (_dateRange != null) {
              final timestamp =
                  d.timestamps['completedAt'] ??
                  d.timestamps['failedAt'] ??
                  d.timestamps['cancelledAt'] ??
                  d.timestamps['createdAt'];
              if (timestamp == null) return false;
              return timestamp.isAfter(_dateRange!.start) &&
                  timestamp.isBefore(
                    _dateRange!.end.add(const Duration(days: 1)),
                  );
            }
            return true;
          }).toList();

          return NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 240 &&
                  state.hasNext &&
                  !state.loadingMore) {
                notifier.loadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
              itemCount: filtered.isEmpty
                  ? 2
                  : (filtered.length + 1 + (state.loadingMore ? 1 : 0)),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ArchiveHeader(
                    total: filtered.length,
                    filter: _filter,
                    dateRange: _dateRange,
                    onFilterChanged: (v) => setState(() => _filter = v),
                    onDateRangeTap: _selectDateRange,
                    onClearDates: () => setState(() => _dateRange = null),
                  );
                }
                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: PhosphorIconsRegular.package,
                    title: AppLocalizations.of(context).historyEmpty,
                    subtitle: AppLocalizations.of(context).historyEmptySubtitle,
                  );
                }
                // Trailing loader while the next page is being appended.
                if (state.loadingMore && index == filtered.length + 1) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final delivery = filtered[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _HistoryTile(delivery: delivery),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ArchiveHeader extends StatelessWidget {
  const _ArchiveHeader({
    required this.total,
    required this.filter,
    required this.onFilterChanged,
    this.dateRange,
    required this.onDateRangeTap,
    required this.onClearDates,
  });

  final int total;
  final _HistoryFilter filter;
  final DateTimeRange? dateRange;
  final ValueChanged<_HistoryFilter> onFilterChanged;
  final VoidCallback onDateRangeTap;
  final VoidCallback onClearDates;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Text(
              AppLocalizations.of(context).historySectionTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
                fontSize: 22,
              ),
            ),
          ),
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Text(
                  AppLocalizations.of(
                    context,
                  ).historyRecordCount(total.toString()),
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onDateRangeTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: dateRange != null
                            ? cs.primary
                            : cs.outlineVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 14,
                          color: dateRange != null
                              ? cs.primary
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          dateRange == null
                              ? AppLocalizations.of(context).historyFilterDate
                              : '${DateFormat('MMM d').format(dateRange!.start)} - ${DateFormat('MMM d').format(dateRange!.end)}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: dateRange != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (dateRange != null) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClearDates,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Icon(
                      LucideIcons.x,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _HistoryFilter.values.map((f) {
                final isSelected = f == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onFilterChanged(f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? cs.primary : cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? cs.primary : cs.outlineVariant,
                        ),
                      ),
                      child: Text(
                        f.label(context),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  _HistoryTile({required this.delivery}) : _fmt = DateFormat('MMM d · HH:mm');

  final DriverDelivery delivery;
  final DateFormat _fmt;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final Color statusColor = switch (delivery.status) {
      DeliveryStatus.unscheduled => statusColors.unscheduled,
      DeliveryStatus.scheduled => statusColors.scheduled,
      DeliveryStatus.pickedUp => statusColors.pickedUp,
      DeliveryStatus.inTransit => statusColors.inTransit,
      DeliveryStatus.awaitingHandoff => statusColors.pickedUp,
      DeliveryStatus.delivered => statusColors.delivered,
      DeliveryStatus.partially_delivered => statusColors.partiallyDelivered,
      DeliveryStatus.failed => statusColors.failed,
      DeliveryStatus.cancelled => statusColors.cancelled,
    };
    final timestamp =
        delivery.timestamps['completedAt'] ??
        delivery.timestamps['failedAt'] ??
        delivery.timestamps['cancelledAt'] ??
        delivery.timestamps['createdAt'];

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(
        DeliveryDetailScreen.routeName,
        arguments: DeliveryDetailArgs(deliveryId: delivery.id),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        deliveryStatusLabel(
                          delivery.status,
                          AppLocalizations.of(context),
                          isReturn: delivery.isReturnPickup,
                        ),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (timestamp != null)
                  Text(
                    _fmt.format(timestamp),
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              delivery.address ?? AppLocalizations.of(context).historyNoAddress,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            if (delivery.city != null) ...[
              const SizedBox(height: 2),
              Text(
                delivery.city!,
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _HistoryStat(
                  label: AppLocalizations.of(context).historyOrder,
                  value: delivery.orderId ?? delivery.id.substring(0, 8),
                ),
                _HistoryStat(
                  label: AppLocalizations.of(context).historyItems,
                  value: '${delivery.items.length}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

enum _HistoryFilter { all, delivered, failed, cancelled }

extension on _HistoryFilter {
  String label(BuildContext context) {
    switch (this) {
      case _HistoryFilter.all:
        return AppLocalizations.of(context).filterAll;
      case _HistoryFilter.delivered:
        return AppLocalizations.of(context).filterDelivered;
      case _HistoryFilter.failed:
        return AppLocalizations.of(context).filterFailed;
      case _HistoryFilter.cancelled:
        return AppLocalizations.of(context).filterCancelled;
    }
  }

  bool matches(DeliveryStatus status) {
    switch (this) {
      case _HistoryFilter.all:
        return true;
      case _HistoryFilter.delivered:
        return status == DeliveryStatus.delivered;
      case _HistoryFilter.failed:
        return status == DeliveryStatus.failed;
      case _HistoryFilter.cancelled:
        return status == DeliveryStatus.cancelled;
    }
  }
}
