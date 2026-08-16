import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../app_providers.dart';
import '../../../services/location_service.dart';
import '../../../theme/widgets.dart';
import '../../pod/presentation/pod_form_screen.dart';
import '../models/delivery_models.dart';
import '../models/status_labels.dart';
import 'handoff_scanner_screen.dart';
import 'widgets/delivery_detail_widgets.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

class DeliveryDetailArgs {
  const DeliveryDetailArgs({required this.deliveryId});
  final String deliveryId;
}

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  const DeliveryDetailScreen({super.key, required this.args});

  static const routeName = '/delivery/detail';
  final DeliveryDetailArgs args;

  @override
  ConsumerState<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  bool _isWorking = false;
  final _locationService = LocationService();

  Future<void> _refresh() async {
    ref.invalidate(deliveryDetailProvider(widget.args.deliveryId));
    ref.invalidate(activeDeliveriesProvider);
  }

  Future<void> _perform(Future<DriverDelivery> Function() task) async {
    setState(() => _isWorking = true);
    try {
      await task();
      await _refresh();
      // Offline actions now go through: they are queued and applied to the cached delivery, so the
      // screen advances. The notice therefore has to be raised on success, not on a failure.
      if (mounted && !await ref.read(connectivityServiceProvider).isOnline) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).delivery_detail_offline_queue)),
          );
        }
      }
    } catch (e) {
      if (e == 'OFFLINE_QUEUED') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).delivery_detail_offline_queue)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context).delivery_detail_error_prefix}: $e')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final asyncDetail = ref.watch(deliveryDetailProvider(widget.args.deliveryId));
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        leading: IconButton(
          icon: const Icon(PhosphorIconsBold.caretLeft, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppLocalizations.of(context).delivery_detail_title),
      ),
      body: asyncDetail.when(
        data: (delivery) => RefreshIndicator(
          color: cs.primary,
          backgroundColor: cs.surfaceContainerLow,
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            children: [
              if (!(ref.watch(connectionStatusProvider).value ?? true))
                _OfflineDataBanner(
                  cachedAt: ref
                      .read(deliveryRepositoryProvider)
                      .detailCachedAt(delivery.id),
                ),
              HeroCard(delivery: delivery),
              const SizedBox(height: 16),
              if (delivery.instructions != null && delivery.instructions!.isNotEmpty) ...[
                InstructionsCard(text: delivery.instructions!),
                const SizedBox(height: 16),
              ],
              if (delivery.items.isNotEmpty) ...[
                ItemsCard(items: delivery.items),
                const SizedBox(height: 16),
              ],
              FailureReasonCard(delivery: delivery),
              if (delivery.proofOfDelivery != null) ...[
                const SizedBox(height: 16),
                PodImagesCard(pod: delivery.proofOfDelivery!),
              ],
              const SizedBox(height: 16),
              TimestampCard(delivery: delivery),
              const SizedBox(height: 16),
              StatusHistoryCard(delivery: delivery),
              const SizedBox(height: 16),
              BonLivraisonCard(deliveryId: delivery.id),
              const SizedBox(height: 24),
              ActionPanel(
                delivery: delivery,
                isWorking: _isWorking,
                currentDriverId: ref.watch(driverProfileProvider).value?.id,
                onScanHandoff: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const HandoffScannerScreen()),
                  );
                  if (result == true) await _refresh();
                },
                onPickup: () => _perform(() => ref.read(deliveryRepositoryProvider).pickup(delivery.id)),
                onTransit: () => _perform(() async {
                  final point = await _locationService.currentPosition();
                  return ref.read(deliveryRepositoryProvider).startTransit(
                        delivery.id,
                        lat: point?.lat,
                        lng: point?.lng,
                      );
                }),
                onFail: () async {
                  final reasons = await ref.read(deliveryRepositoryProvider).fetchFailureReasons();
                  if (!context.mounted) return;
                  // Full-visit failure: only motifs usable at the delivery scope (DELIVERY / BOTH).
                  final base = reasons.where((r) => r.coversDelivery).toList();
                  // ADR-033 — a return collection fails for a short, distinct set of reasons (client absent /
                  // refuses to hand it back / not ready → OTHER); the delivery catalog (wrong address, damaged…)
                  // doesn't fit. Fall back to the bundled list filtered the same way when the API is empty.
                  const returnCats = ['CLIENT_ABSENT', 'REFUSED', 'OTHER'];
                  List<FailureReasonOption> failureReasons = base;
                  if (delivery.isReturnPickup) {
                    final filtered = base.where((r) => returnCats.contains(r.category)).toList();
                    failureReasons = filtered.isNotEmpty
                        ? filtered
                        : FailureReasonOption.fallback.where((r) => returnCats.contains(r.category)).toList();
                  }
                  final reason = await _showFailSheet(context, failureReasons);
                  if (reason == null) return;
                  await _perform(() => ref.read(deliveryRepositoryProvider).fail(
                        delivery.id,
                        reasonCode: reason.$1,
                        comment: reason.$2,
                      ));
                },
                onPod: () async {
                  final result = await Navigator.of(context).pushNamed(
                    PodFormScreen.routeName,
                    arguments: PodFormArgs(delivery: delivery),
                  );
                  if (result == true) await _refresh();
                },
              ),
            ],
          ),
        ),
        loading: () => LoadingState(message: AppLocalizations.of(context).delivery_detail_loading),
        error: (error, _) {
          final isUnauthorized = error.toString().contains('403') || error.toString().contains('unauthorized');
          return EmptyState(
            icon: PhosphorIconsRegular.warningCircle,
            title: isUnauthorized 
                ? AppLocalizations.of(context).delivery_detail_unauthorized_link
                : AppLocalizations.of(context).delivery_detail_load_failed,
            action: _refresh,
            actionLabel: AppLocalizations.of(context).delivery_detail_retry,
          );
        },
      ),
    );
  }

  Future<(String, String?)?> _showFailSheet(BuildContext context, List<FailureReasonOption> reasons) async {
    final cs = Theme.of(context).colorScheme;
    final options = reasons.isNotEmpty ? reasons : FailureReasonOption.fallback;
    FailureReasonOption selected = options.first;
    final commentCtrl = TextEditingController();
    
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: cs.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                  const SizedBox(height: 20),
                  Text(
                    AppLocalizations.of(context).delivery_detail_fail_report, 
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700, 
                          color: cs.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context).delivery_detail_fail_select, 
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.35,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final reason = options[i];
                        final isSelected = reason.code == selected.code;
                        return Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => setModal(() => selected = reason),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: isSelected ? cs.errorContainer : cs.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? cs.error.withValues(alpha: 0.4) : cs.outlineVariant,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? PhosphorIconsFill.radioButton : PhosphorIconsRegular.circle,
                                    color: isSelected ? cs.error : cs.onSurfaceVariant,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      reason.label,
                                      style: TextStyle(
                                        color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: commentCtrl,
                    style: TextStyle(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context).delivery_detail_comment_hint,
                      prefixIcon: const Icon(PhosphorIconsRegular.notePencil, size: 18),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(PhosphorIconsBold.flagPennant),
                      label: Text(
                        AppLocalizations.of(context).delivery_detail_fail_submit,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (confirmed == true) {
      return (selected.code, commentCtrl.text.trim().isEmpty ? null : commentCtrl.text.trim());
    }
    return null;
  }
}


/// Small banner shown when the driver is viewing a delivery offline, so a cached
/// (possibly stale) fiche is never mistaken for live data. Shows when the cache
/// was last refreshed.
class _OfflineDataBanner extends StatelessWidget {
  const _OfflineDataBanner({this.cachedAt});
  final DateTime? cachedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final time = cachedAt != null
        ? '${cachedAt!.hour.toString().padLeft(2, '0')}:${cachedAt!.minute.toString().padLeft(2, '0')}'
        : '—';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.cloudSlash, size: 15, color: Color(0xFFB45309)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.offlineDataAsOf(time),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFB45309),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
