import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_providers.dart';
import '../../../services/location_service.dart';
import '../../../services/locale_provider.dart';
import '../../deliveries/presentation/delivery_detail_screen.dart';
import '../../deliveries/presentation/handoff_scanner_screen.dart';
import '../../deliveries/presentation/handoff_token_sheet.dart';
import '../models/route_models.dart';
import 'widgets/route_list_view.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

class RoutesScreen extends ConsumerStatefulWidget {
  const RoutesScreen({super.key});

  @override
  ConsumerState<RoutesScreen> createState() => _RoutesScreenState();
}

class _RoutesScreenState extends ConsumerState<RoutesScreen> {
  bool _isWorking = false;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(todayRouteProvider);
    ref.invalidate(activeDeliveriesProvider);
    ref.invalidate(deliveryDetailProvider);
  }

  Future<void> _doAction(Future<void> Function() fn) async {
    if (_isWorking) return;
    setState(() => _isWorking = true);
    try {
      await fn();
      await _refresh();
    } catch (e) {
      if (e == 'OFFLINE_QUEUED') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).routeOfflineAction)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).routeErrorSnackbar(e.toString()))),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _downloadPdf(String routeId) => _doAction(() async {
        // Offline check
        final isOnline = await ref.read(connectivityServiceProvider).isOnline;
        if (!isOnline) {
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).routeOfflineUnavailable)),
              );
          }
          return;
        }
        final ok = await ref.read(pdfServiceProvider).downloadAndOpen(
          '/api/driver/routes/$routeId/pdf',
          fileName: 'route-$routeId.pdf',
        );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).routePdfFailed)),
          );
        }
      });

  Future<void> _openMaps(List<DriverRouteStop> stops) async {
    final pinned = stops.where((s) => s.hasPinned).toList();
    if (pinned.isEmpty) return;
    final dest = pinned.last;
    final waypoints = pinned.length > 1
        ? pinned.sublist(0, pinned.length - 1).map((s) => '${s.lat},${s.lng}').join('|')
        : null;
    final buffer = StringBuffer(
      'https://www.google.com/maps/dir/?api=1&travelmode=driving'
      '&destination=${dest.lat},${dest.lng}',
    );
    if (waypoints != null) buffer.write('&waypoints=$waypoints');
    final uri = Uri.parse(buffer.toString());
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback to geo: URI for devices without Google Maps
      final geoUri = Uri.parse('geo:${dest.lat},${dest.lng}?q=${dest.lat},${dest.lng}');
      try {
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> _startRoute(String id) => _doAction(() async {
        // A route can't run while the driver is offline — auto-pass "En service".
        final status = ref.read(driverProfileProvider).valueOrNull?.onlineStatus;
        if (status != 'ONLINE') {
          try {
            await ref.read(profileRepositoryProvider).updateAvailability('ONLINE');
            ref.invalidate(driverProfileProvider);
          } catch (_) {
            // Non-fatal: still start the route even if the status flip failed.
          }
        }

        // Start immediately — never block the swipe on a GPS fix (getCurrentPosition can take
        // up to 10s indoors, which makes the button feel dead). The location stamp is non-essential
        // here and background tracking refreshes it anyway, so do it best-effort after the start.
        await ref.read(routeRepositoryProvider).start(id);

        unawaited(() async {
          try {
            final pt = await LocationService().currentPosition();
            if (pt != null) {
              await ref.read(profileRepositoryProvider).updateLocation(pt.lat, pt.lng);
            }
          } catch (_) {
            // Best-effort: a missing/slow location must never affect the started route.
          }
        }());
      });

  Future<void> _confirmPickup(String routeId, String stopId) => _doAction(() async {
        final pt = await LocationService().currentPosition();
        if (pt != null) {
          await ref.read(profileRepositoryProvider).updateLocation(pt.lat, pt.lng);
        }

        await ref.read(routeRepositoryProvider).confirmPickup(routeId, stopId);
      });

  Future<void> _startTransit(String deliveryId) => _doAction(() async {
        final pt = await LocationService().currentPosition();

        await ref.read(deliveryRepositoryProvider).startTransit(
          deliveryId,
          lat: pt?.lat,
          lng: pt?.lng,
        );
      });

  void _openPod(BuildContext context, String deliveryId) {
    Navigator.of(context).pushNamed(
      DeliveryDetailScreen.routeName,
      arguments: DeliveryDetailArgs(deliveryId: deliveryId),
    );
  }

  void _openDetails(BuildContext context, String deliveryId) {
    Navigator.of(context).pushNamed(
      DeliveryDetailScreen.routeName,
      arguments: DeliveryDetailArgs(deliveryId: deliveryId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeAsync = ref.watch(todayRouteProvider);
    final deliveries = ref.watch(activeDeliveriesProvider).value ?? [];
    final currentDriverId = ref.watch(driverProfileProvider).value?.id;
    final locale = ref.watch(localeProvider);

    final pendingHandoffs = deliveries
        .where((d) => d.requiresHandoff && d.handoffConfirmedAt == null)
        .toList();

    // Determine this driver's role in the pending handoff
    final senderDelivery = currentDriverId != null
        ? pendingHandoffs.where((d) => d.handoffFromDriverId == currentDriverId).firstOrNull
        : null;
    final isReceiver = currentDriverId != null &&
        pendingHandoffs.any((d) => d.handoffToDriverId == currentDriverId);

    Widget? fab;
    if (senderDelivery != null) {
      // Driver 1 (sender): show QR code for Driver 2 to scan
      fab = FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (_) => HandoffTokenSheet(deliveryId: senderDelivery.id),
          );
          _refresh();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        icon: const Icon(LucideIcons.qrCode, size: 20),
        label: Text(AppLocalizations.of(context).routeGenerateQr, style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 13)),
      );
    } else if (isReceiver) {
      // Driver 2 (receiver): scan Driver 1's QR
      fab = FloatingActionButton.extended(
        onPressed: () async {
          final isOnline = await ref.read(connectivityServiceProvider).isOnline;
          if (!isOnline) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context).routeScannerOffline)),
              );
            }
            return;
          }
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const HandoffScannerScreen()),
          );
          if (result == true) _refresh();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        icon: const Icon(LucideIcons.qrCode, size: 20),
        label: Text(AppLocalizations.of(context).routeScanQr, style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.5, fontSize: 13)),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: routeAsync.when(
        data: (route) => RouteListView(
          route: route,
          isWorking: _isWorking,
          locale: locale,
          onStart: route == null ? null : () => _startRoute(route.id),
          onConfirmPickup: route == null ? null : (stopId) => _confirmPickup(route.id, stopId),
          onStartTransit: _startTransit,
          onOpenPod: (deliveryId) => _openPod(context, deliveryId),
          onOpenDetails: (deliveryId) => _openDetails(context, deliveryId),
          onRefresh: _refresh,
          onDownloadPdf: route == null ? null : () => _downloadPdf(route.id),
          onNavigate: route == null ? null : () => _openMaps(route.stops),
        ),
        loading: () => const MapPlaceholderLoading(),
        error: (_, __) => MapError(onRetry: _refresh),
      ),
      floatingActionButton: fab,
    );
  }
}

