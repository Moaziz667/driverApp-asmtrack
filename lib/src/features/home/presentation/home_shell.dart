import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../app_providers.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';
import '../../../services/locale_provider.dart';
import '../../../services/location_service.dart';
import '../../../services/notification_store.dart';
import '../../../services/websocket_service.dart';
import '../../../services/offline_queue_service.dart';
import '../../../theme/status_colors.dart';
import '../../deliveries/models/delivery_models.dart';
import '../../deliveries/presentation/delivery_detail_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../profile/presentation/onboarding_photo_screen.dart';
import '../../routes/models/route_models.dart';
import '../../routes/presentation/calendar_screen.dart';
import '../../routes/presentation/routes_screen.dart';
import 'widgets/home_widgets.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  static const routeName = '/home';

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  Timer? _locationTimer;
  Timer? _assignmentRefreshTimer;
  bool _isTracking = false;
  StreamSubscription<bool>? _connectivitySub;

  final _wsService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _assignmentRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _refreshAssignmentsAndNotify();
      // Retried, because the first attempt below usually comes too early: the shell mounts before
      // the driver profile has loaded, _initWebSocket finds no id and gives up — and nothing used to
      // call it again, so the socket was never opened for the whole session. connect() is
      // idempotent, so this costs nothing once the connection is up.
      _initWebSocket();
    });
    _initWebSocket();
    _initConnectivityListener();
    _initFcmHandlers();
  }

  void _initFcmHandlers() {
    final store = ref.read(notificationStoreProvider.notifier);
    ref.read(fcmServiceProvider).setHandlers(
      onReceived: (title, body, type) {
        store.add(title: title, body: body, type: type);
        // A handoff opened while the app is in the foreground usually arrives here, as FCM, and not
        // as a STOMP frame — and only the STOMP path refreshed the list. So the transfers button
        // beside the bell stayed hidden (it hides itself at zero) until the app was restarted: the
        // parcel was waiting to change hands and the driver had no way in.
        if (type.startsWith('HANDOFF_')) {
          ref.invalidate(handoffsProvider);
        }
      },
      onTap: (type, deliveryId) {
        if (type.startsWith('HANDOFF_') && deliveryId != null && deliveryId.isNotEmpty) {
          _openHandoffDelivery(deliveryId);
          return;
        }
        ref.read(homeTabIndexProvider.notifier).state = 0;
        _showNotificationPanel();
      },
    );
  }

  void _showNotificationPanel() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => const NotificationPanel(),
      );
    });
  }

  Future<void> _initWebSocket() async {
    final authState = ref.read(authControllerProvider);
    final driverId = authState.driver?.id;
    if (driverId == null || driverId.isEmpty) return;

    final config = ref.read(appConfigProvider);
    final storage = ref.read(tokenStorageProvider);
    _wsService.connect(
      wsBaseUrl: config.apiBaseUrl,
      driverId: driverId,
      tokenStorage: storage,
      onEvent: _handleWsEvent,
    );
  }

  void _handleWsEvent(RouteWsEvent event) {
    if (!mounted) return;

    // S2: an admin force-logged-out this driver — sign out instantly instead of waiting for
    // the access token to expire. The DriverApp auth listener handles navigation to login.
    if (event.event == 'session.revoked') {
      ref.read(authControllerProvider.notifier).logout();
      return;
    }

    ref.invalidate(todayRouteProvider);
    ref.invalidate(weekRoutesProvider(ref.read(calendarWeekProvider)));
    ref.invalidate(activeDeliveriesProvider);

    if (event.event.startsWith('handoff.')) {
      ref.invalidate(handoffsProvider);
      _handleHandoffWsEvent(event);
      return;
    }

    final loc = AppLocalizations.of(context);
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final routeStr = event.routeName.isNotEmpty ? '\u00ab${event.routeName}\u00bb' : loc.ws_generic_route;
    final String message;
    IconData icon;
    Color color;

    switch (event.event) {
      case 'DELIVERY_ASSIGNED':
        {
          final client = event.clientName ?? '';
          message = client.isNotEmpty
              ? loc.ws_delivery_assigned(client)
              : loc.ws_new_delivery;
          icon = PhosphorIconsRegular.package;
          color = statusColors.delivered;
        }
        break;
      case 'DELIVERY_REMOVED':
        {
          final client = event.clientName ?? '';
          message = client.isNotEmpty
              ? loc.ws_delivery_removed(client)
              : loc.ws_delivery_removed_generic;
          icon = PhosphorIconsRegular.minusCircle;
          color = statusColors.failed;
        }
        break;
      case 'ROUTE_ASSIGNED':
        message = loc.ws_route_assigned(routeStr);
        icon = PhosphorIconsRegular.checkCircle;
        color = statusColors.delivered;
        break;
      case 'ROUTE_CANCELLED':
        message = loc.ws_route_cancelled(routeStr);
        icon = PhosphorIconsRegular.xCircle;
        color = statusColors.failed;
        break;
      case 'ROUTE_REASSIGNED_AWAY':
        message = loc.ws_route_reassigned_away(routeStr);
        icon = PhosphorIconsRegular.warning;
        color = statusColors.cancelled;
        break;
      case 'ROUTE_REASSIGNED_TO_YOU':
        message = loc.ws_route_reassigned_to_you(routeStr);
        icon = PhosphorIconsRegular.checkCircle;
        color = statusColors.delivered;
        break;
      case 'STOP_ADDED':
        final addedClient = event.clientName ?? '';
        message = loc.ws_stop_added(addedClient, routeStr);
        icon = PhosphorIconsRegular.mapPin;
        color = statusColors.scheduled;
        break;
      case 'STOP_REMOVED':
        final removedClient = event.clientName ?? '';
        final refStr = event.erpOrderId != null ? ' [${event.erpOrderId}]' : '';
        final why = event.reason != null ? ' \u2014 ${event.reason}' : '';
        message = loc.ws_stop_removed(removedClient, refStr, routeStr, why);
        icon = PhosphorIconsRegular.minusCircle;
        color = statusColors.cancelled;
        break;
      case 'ROUTE_UPDATED':
        message = loc.ws_route_updated(routeStr);
        icon = PhosphorIconsRegular.info;
        color = statusColors.unscheduled;
        break;
      case 'STOPS_TRANSFERRED_OUT':
        message = loc.ws_stops_transferred_out(routeStr);
        icon = PhosphorIconsRegular.arrowsLeftRight;
        color = statusColors.cancelled;
        break;
      case 'STOPS_TRANSFERRED_IN':
        message = loc.ws_stops_transferred_in(routeStr);
        icon = PhosphorIconsRegular.listPlus;
        color = statusColors.scheduled;
        break;
      case 'pickup.overdue':
        message = loc.ws_pickup_overdue(event.clientName ?? '', event.reason ?? '');
        icon = PhosphorIconsRegular.house;
        color = statusColors.failed;
        break;
      default:
        return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _handleHandoffWsEvent(RouteWsEvent event) {
    if (!mounted) return;
    final locale = ref.read(localeProvider);
    final loc = AppLocalizations.of(context);
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    final refStr = (event.erpOrderId != null && event.erpOrderId!.isNotEmpty)
        ? '#${event.erpOrderId}'
        : (event.deliveryId != null && event.deliveryId!.length >= 8
            ? '#${event.deliveryId!.substring(0, 8)}'
            : '');
    String displayName(String? name) => (name != null && name.isNotEmpty) ? name : loc.ws_handoff_other;

    switch (event.event) {
      case 'handoff.incoming':
      case 'handoff.code_ready':
        _showHandoffBanner(
          message: loc.ws_handoff_incoming(displayName(event.fromDriverName), refStr),
          icon: PhosphorIconsRegular.qrCode,
          color: statusColors.scheduled,
          actionLabel: loc.handoff_action_scan,
          onAction: () => _openHandoffDelivery(event.deliveryId),
          locale: locale,
        );
        break;
      case 'handoff.outgoing':
        _showHandoffBanner(
          message: loc.ws_handoff_outgoing(displayName(event.toDriverName), refStr),
          icon: PhosphorIconsRegular.arrowsLeftRight,
          color: statusColors.inTransit,
          actionLabel: loc.handoff_action_show,
          onAction: () => _openHandoffDelivery(event.deliveryId),
          locale: locale,
        );
        break;
      case 'handoff.confirmed':
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        _showHandoffSnack(loc.ws_handoff_confirmed(refStr), PhosphorIconsRegular.checkCircle, statusColors.delivered);
        break;
      case 'handoff.cancelled':
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
        _showHandoffSnack(loc.ws_handoff_cancelled(refStr), PhosphorIconsRegular.xCircle, statusColors.failed);
        break;
      default:
        return;
    }
  }

  void _openHandoffDelivery(String? deliveryId) {
    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    if (deliveryId == null || deliveryId.isEmpty || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(homeTabIndexProvider.notifier).state = 0;
      Navigator.of(context).pushNamed(
        DeliveryDetailScreen.routeName,
        arguments: DeliveryDetailArgs(deliveryId: deliveryId),
      );
    });
  }

  void _showHandoffBanner({
    required String message,
    required IconData icon,
    required Color color,
    required String actionLabel,
    required VoidCallback onAction,
    required String locale,
  }) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final theme = Theme.of(context);
      messenger.hideCurrentMaterialBanner();
      messenger.showMaterialBanner(
      MaterialBanner(
        backgroundColor: theme.colorScheme.surface,
        dividerColor: theme.colorScheme.outlineVariant,
        leading: Icon(icon, color: color),
        content: Text(
          message,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => messenger.hideCurrentMaterialBanner(),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () { messenger.hideCurrentMaterialBanner(); onAction(); },
            style: TextButton.styleFrom(foregroundColor: color),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
    });
  }

  void _showHandoffSnack(String message, IconData icon, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _initConnectivityListener() {
    final connectivity = ref.read(connectivityServiceProvider);
    _connectivitySub = connectivity.onlineStream.listen((isOnline) {
      if (!mounted) return;
      if (isOnline) {
        ref.read(offlineQueueProvider.notifier).processQueue();
      }
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _assignmentRefreshTimer?.cancel();
    _connectivitySub?.cancel();
    _wsService.disconnect();
    super.dispose();
  }

  void _startTracking() {
    if (_isTracking) return;
    _isTracking = true;
    // TEMPORAIRE (demo suivi public) : 5 s au lieu de 20. A remettre a 20 avant toute mise en
    // service — quatre fois plus d'envois, c'est quatre fois plus de batterie sur une journee de
    // tournee, pour un gain qui se traite mieux en interpolant l'affichage cote carte.
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) => _pushLocation());
    _pushLocation();
  }

  void _stopTracking() {
    _isTracking = false;
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  Future<void> _pushLocation() async {
    try {
      final point = await LocationService().currentPosition();
      if (point == null) return;
      await ref.read(profileRepositoryProvider).updateLocation(point.lat, point.lng);
    } catch (_) {}
  }

  Future<void> _refreshAssignmentsAndNotify() async {
    try {
      ref.invalidate(todayRouteProvider);
      ref.invalidate(activeDeliveriesProvider);
      ref.invalidate(weekRoutesProvider(ref.read(calendarWeekProvider)));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final activeIndex = ref.watch(homeTabIndexProvider);

    ref.listen(activeDeliveriesProvider, (_, next) {
      next.whenData((list) {
        if (list.any((d) => d.status == DeliveryStatus.inTransit)) {
          _startTracking();
        } else if (!_isRouteInProgress()) {
          _stopTracking();
        }
      });
    });

    ref.listen(todayRouteProvider, (_, next) {
      next.whenData((route) {
        if (route?.status == DriverRouteStatus.inProgress) {
          _startTracking();
        } else if (!_hasInTransit()) {
          _stopTracking();
        }
      });
    });

    // First-login gate: block the home tabs until the driver has added a profile photo.
    final needsPhoto = ref.watch(driverProfileProvider).maybeWhen(
          data: (p) => p.onboardingStatus != 'COMPLETE',
          orElse: () => false,
        );
    if (needsPhoto) {
      return const OnboardingPhotoScreen();
    }

    final pages = [
      const RoutesScreen(),
      CalendarScreen(onNavigateToRoute: () => ref.read(homeTabIndexProvider.notifier).state = 0),
      const SafeArea(child: ProfileScreen()),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: colorScheme.surface,
        systemNavigationBarIconBrightness: theme.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: Column(
          children: [
            HomeTopBar(onOpenNotifications: _showNotificationPanel),
            const OfflineStatusBar(),
            Expanded(
              // Cross-fade between tabs (enterprise "fade-through") while keeping
              // every page alive so scroll position and state survive tab switches.
              child: Stack(
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedOpacity(
                      opacity: i == activeIndex ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 220),
                      curve: i == activeIndex ? Curves.easeOut : Curves.easeIn,
                      child: IgnorePointer(
                        ignoring: i != activeIndex,
                        child: TickerMode(
                          enabled: i == activeIndex,
                          child: pages[i],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: ModernBottomNav(
          selectedIndex: activeIndex,
          onTabSelected: (i) => ref.read(homeTabIndexProvider.notifier).state = i,
        ),
      ),
    );
  }

  bool _hasInTransit() {
    return ref.read(activeDeliveriesProvider).value?.any((d) => d.status == DeliveryStatus.inTransit) ?? false;
  }

  bool _isRouteInProgress() {
    return ref.read(todayRouteProvider).value?.status == DriverRouteStatus.inProgress;
  }
}

