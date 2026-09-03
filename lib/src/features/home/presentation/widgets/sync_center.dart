import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../services/offline_queue_service.dart';
import '../../../deliveries/presentation/delivery_detail_screen.dart';
import '../../../../theme/status_colors.dart';

/// Re-arms one or all failed items, then tells the driver the truth: if we're
/// offline the retry is queued, not sent — so "Retry" never looks like success
/// when nothing actually left the device.
Future<void> _retryWithFeedback(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() retry,
) async {
  await retry();
  final online = await ref.read(connectivityServiceProvider).isOnline;
  if (!context.mounted) return;
  if (!online) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.delivery_detail_offline_queue)));
  }
}

/// Opens the Sync Center — the driver's window into pending and failed writes,
/// with manual retry. Nothing is ever dropped silently, so this is where a
/// rejected "Delivered" or a stuck POD surfaces and can be acted on.
Future<void> showSyncCenter(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _SyncCenterSheet(),
  );
}

/// Localised, human label for a queued action, derived from its REST path.
String syncActionLabel(AppLocalizations l10n, String action) {
  switch (action) {
    case 'complete':
      return l10n.syncActionComplete;
    case 'pod':
      return l10n.syncActionPod;
    case 'fail':
      return l10n.syncActionFail;
    case 'cancel':
      return l10n.syncActionCancel;
    case 'transit':
      return l10n.syncActionTransit;
    case 'pickup':
      return l10n.syncActionPickup;
    case 'accept':
      return l10n.syncActionAccept;
    case 'arrive':
      return l10n.syncActionArrive;
    case 'route_start':
      return l10n.syncActionRouteStart;
    default:
      return l10n.syncActionGeneric;
  }
}

String _twoDigits(int n) => n.toString().padLeft(2, '0');
String _hhmm(DateTime? dt) =>
    dt == null ? '' : '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';

class _SyncCenterSheet extends ConsumerWidget {
  const _SyncCenterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    // Watching the aggregate state rebuilds the list as items drain / fail.
    ref.watch(offlineQueueProvider);
    final queue = ref.read(offlineQueueProvider.notifier);
    final items = queue.items();
    final hasFailed = items.any((i) => i.status == QueueItemStatus.deadLetter);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                children: [
                  Icon(
                    PhosphorIconsBold.cloudArrowUp,
                    size: 20,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.syncCenterTitle,
                      style: GoogleFonts.inter(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (hasFailed)
                    TextButton.icon(
                      onPressed: () =>
                          _retryWithFeedback(context, ref, queue.retryAll),
                      icon: const Icon(
                        PhosphorIconsRegular.arrowClockwise,
                        size: 16,
                      ),
                      label: Text(l10n.syncRetryAll),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: items.isEmpty
                  ? _EmptyState(l10n: l10n)
                  : ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      itemBuilder: (context, i) => _QueueRow(item: items[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(PhosphorIconsRegular.checkCircle, size: 44, color: cs.primary),
          const SizedBox(height: 12),
          Text(
            l10n.syncUpToDate,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.syncEmpty,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueRow extends ConsumerWidget {
  const _QueueRow({required this.item});
  final OfflineQueueItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final queue = ref.read(offlineQueueProvider.notifier);
    final failed = item.status == QueueItemStatus.deadLetter;

    // A queued write is "on hold" and a dead-lettered one has "failed" — the same two states the
    // status palette already names, so they take its colours and follow the theme.
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final (Color badgeColor, String badgeText, IconData badgeIcon) = failed
        ? (
            statusColors.failed,
            l10n.syncStatusFailed,
            PhosphorIconsBold.warning,
          )
        : (
            statusColors.onBreak,
            l10n.syncStatusPending,
            PhosphorIconsRegular.clock,
          );

    final ref0 = item.reference;
    final title = ref0 != null
        ? '${syncActionLabel(l10n, item.action)} · $ref0'
        : syncActionLabel(l10n, item.action);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(badgeIcon, size: 16, color: badgeColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              failed
                  ? _errorText(l10n, item.lastError)
                  : l10n.syncEnqueuedAt(_hhmm(item.enqueuedAt)),
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          if (failed)
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 4),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _retryWithFeedback(
                      context,
                      ref,
                      () => queue.retryItem(item.key),
                    ),
                    icon: const Icon(
                      PhosphorIconsRegular.arrowClockwise,
                      size: 15,
                    ),
                    label: Text(l10n.syncRetry),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  if (ref0 != null && item.path.contains('/deliveries/'))
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(
                          DeliveryDetailScreen.routeName,
                          arguments: DeliveryDetailArgs(deliveryId: ref0),
                        );
                      },
                      child: Text(l10n.syncViewDelivery),
                    ),
                  const Spacer(),
                  IconButton(
                    tooltip: l10n.syncDiscard,
                    onPressed: () => queue.discardItem(item.key),
                    icon: Icon(
                      PhosphorIconsRegular.trash,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _errorText(AppLocalizations l10n, String? code) {
    if (code == null) return l10n.syncStatusFailed;
    if (code == 'TTL_EXPIRED') return l10n.syncExpired;
    if (code.startsWith('HTTP_4')) return l10n.syncRejectedByServer;
    return l10n.syncRejectedByServer;
  }
}
