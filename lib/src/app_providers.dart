import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/app_config.dart';
import 'features/auth/data/auth_controller.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/models/auth_models.dart';
import 'features/deliveries/data/delivery_repository.dart';
import 'features/deliveries/models/delivery_models.dart';
import 'features/deliveries/models/handoff_models.dart';
import 'features/profile/data/profile_repository.dart';
import 'features/profile/models/profile_models.dart';
import 'features/routes/data/route_repository.dart';
import 'features/routes/models/route_models.dart';
import 'services/api_client.dart';
import 'services/connectivity_service.dart';
import 'services/fcm_service.dart';
import 'services/pdf_service.dart';
import 'services/route_cache_service.dart';
import 'services/offline_queue_service.dart';
import 'services/token_storage.dart';

final appConfigProvider = StateProvider<AppConfig>((ref) => AppConfig.fromEnvironment());

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  // Reachability probe: a bare Dio (no auth interceptors, so it can never kick
  // off a token refresh) that hits the API host. Any HTTP response — even a 404
  // — proves the server is reachable; a timeout / DNS failure means "Wi-Fi but
  // no internet", which we then treat as offline.
  return ConnectivityService(reachabilityProbe: () async {
    final baseUrl = ref.read(appConfigProvider).apiBaseUrlV1;
    try {
      final res = await Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      )).get<void>(
        baseUrl,
        options: Options(validateStatus: (_) => true),
      );
      return res.statusCode != null;
    } catch (_) {
      return false;
    }
  });
});

final connectionStatusProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  // Reachability, not link state: on Wi-Fi with no internet the banner must read
  // "offline" — the same truth the write path uses — so the UI never contradicts
  // what actually happens when the driver taps an action.
  return connectivity.reachabilityStream();
});

final apiClientProvider = Provider<ApiClient>((Ref ref) {
  // Read (don't watch) the config so a workspace/server-URL change does NOT rebuild this provider.
  // Watching it would dispose the whole dependent chain — including the AuthController — mid-flight
  // (e.g. when bootstrap() sets appConfig), aborting startup and freezing the app on the splash.
  // Instead, update the base URL in place when the config changes.
  final client = ApiClient(
    config: ref.read(appConfigProvider),
    tokenStorage: ref.read(tokenStorageProvider),
  );
  ref.listen<AppConfig>(appConfigProvider, (_, next) {
    client.config = next;                          // OIDC endpoints (login) follow the new host
    client.dio.options.baseUrl = next.apiBaseUrlV1;  // REST calls follow the new host
  });
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>((Ref ref) {
  final client = ref.watch(apiClientProvider);
  return AuthRepository(client);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((Ref ref) {
  final repo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(tokenStorageProvider);
  final fcm = ref.watch(fcmServiceProvider);

  final controller = AuthController(repo, storage, fcm, ref);

  // Wire up session expiration callback to break circularity in provider definitions.
  // The reason drives the message the driver sees on the login screen.
  ref.read(apiClientProvider).onSessionExpired = controller.endSession;

  return controller;
});

final deliveryRepositoryProvider = Provider<DeliveryRepository>((Ref ref) {
  final client = ref.watch(apiClientProvider);
  final queue = ref.watch(offlineQueueProvider.notifier);
  final connectivity = ref.watch(connectivityServiceProvider);
  return DeliveryRepository(client, queue, connectivity);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfileRepository(client);
});

final routeCacheServiceProvider = Provider<RouteCacheService>((ref) => RouteCacheService());

final routeRepositoryProvider = Provider<RouteRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  final cache = ref.watch(routeCacheServiceProvider);
  final queue = ref.watch(offlineQueueProvider.notifier);
  final connectivity = ref.watch(connectivityServiceProvider);
  return RouteRepository(client, cache, queue, connectivity);
});

final pdfServiceProvider = Provider<PdfService>((ref) {
  final client = ref.watch(apiClientProvider);
  return PdfService(client);
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  final client = ref.watch(apiClientProvider);
  return FcmService(client);
});

final activeDeliveriesProvider = FutureProvider<List<DriverDelivery>>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.fetchActive();
});

/// Paginated, infinite-scroll driver history — accumulates pages + tracks whether more exist.
class HistoryState {
  const HistoryState({
    this.items = const [],
    this.hasNext = false,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });
  final List<DriverDelivery> items;
  final bool hasNext;
  final bool loading;      // first page in flight
  final bool loadingMore;  // appending a page
  final Object? error;

  HistoryState copyWith({
    List<DriverDelivery>? items,
    bool? hasNext,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) =>
      HistoryState(
        items: items ?? this.items,
        hasNext: hasNext ?? this.hasNext,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: clearError ? null : (error ?? this.error),
      );
}

class DriverHistoryNotifier extends StateNotifier<HistoryState> {
  DriverHistoryNotifier(this._repo) : super(const HistoryState()) {
    loadFirst();
  }
  final DeliveryRepository _repo;
  int _page = 0;
  static const int _size = 20;

  Future<void> loadFirst() async {
    state = const HistoryState(loading: true);
    try {
      final r = await _repo.fetchHistory(page: 0, size: _size);
      _page = 0;
      state = HistoryState(items: r.items, hasNext: r.hasNext, loading: false);
    } catch (e) {
      state = HistoryState(loading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || state.loading || !state.hasNext) return;
    state = state.copyWith(loadingMore: true);
    try {
      final r = await _repo.fetchHistory(page: _page + 1, size: _size);
      _page += 1;
      state = state.copyWith(
        items: [...state.items, ...r.items],
        hasNext: r.hasNext,
        loadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(loadingMore: false);
    }
  }
}

final driverHistoryProvider =
    StateNotifierProvider.autoDispose<DriverHistoryNotifier, HistoryState>((ref) {
  return DriverHistoryNotifier(ref.watch(deliveryRepositoryProvider));
});

final driverProfileProvider = FutureProvider<DriverProfile>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchProfile();
});

final driverStatsProvider = FutureProvider<DriverStats>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.fetchStats();
});

final todayRouteProvider = FutureProvider<DriverRoute?>((ref) async {
  final repo = ref.watch(routeRepositoryProvider);
  final route = await repo.fetchToday();
  // Warm every delivery of the round while there is still signal. Unawaited on purpose: the route
  // must render at once, and a pre-load that fails changes nothing the driver can see.
  if (route != null && !route.fromCache) {
    final ids = route.stops
        .map((s) => s.deliveryId)
        .where((id) => id.isNotEmpty)
        .toSet();
    unawaited(ref.read(deliveryRepositoryProvider).prefetchDetails(ids));
  }
  return route;
});

final deliveryDetailProvider = FutureProvider.family<DriverDelivery, String>((ref, id) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.fetchById(id);
});

// ─── Calendar providers ───────────────────────────────────────────────────────

/// Tracks the Monday of the currently displayed calendar week.
final calendarWeekProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return now.subtract(Duration(days: now.weekday - 1));
});

/// Fetches all routes for a 7-day window starting from [weekStart].
final weekRoutesProvider = FutureProvider.family<List<DriverRoute>, DateTime>((ref, weekStart) {
  final repo = ref.watch(routeRepositoryProvider);
  final weekEnd = weekStart.add(const Duration(days: 6));
  return repo.fetchRange(weekStart, weekEnd);
});

/// Open custody transfers for the signed-in driver (incoming + outgoing).
/// Invalidated by the home shell on any `handoff.*` realtime event.
final handoffsProvider = FutureProvider<List<HandoffSummary>>((ref) {
  final repo = ref.watch(deliveryRepositoryProvider);
  return repo.listHandoffs();
});

/// Global state provider to track the active bottom navigation bar tab.
final homeTabIndexProvider = StateProvider<int>((ref) => 0);
