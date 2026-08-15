import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../services/api_client.dart';
import '../../../services/fcm_service.dart';
import '../../../services/offline_queue_service.dart';
import '../../../services/token_storage.dart';
import '../models/auth_models.dart';
import 'auth_repository.dart';
import '../../../app_providers.dart';
import '../../../config/app_config.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, this._tokenStorage, this._fcm, this._ref) : super(AuthState.unknown());

  final AuthRepository _repository;
  final TokenStorage _tokenStorage;
  final FcmService _fcm;
  final Ref _ref;

  Future<void> bootstrap() async {
    debugPrint('[BOOT] start');
    try {
      final apiUrl = await _tokenStorage.readApiBaseUrl();
      debugPrint('[BOOT] apiUrl read (mounted=$mounted)');
      if (!mounted) return;

      final resolvedUrl = (apiUrl == null || apiUrl.isEmpty)
          ? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.86.194.125')
          : apiUrl;

      // Set the state provider synchronously so ApiClient is updated before tokens are validated
      _ref.read(appConfigProvider.notifier).state = AppConfig.fromStorage(resolvedUrl);
      debugPrint('[BOOT] config set -> $resolvedUrl');

      final tokens = await _tokenStorage.readTokens();
      debugPrint('[BOOT] tokens read: hasToken=${tokens != null} (mounted=$mounted)');
      if (!mounted) return;
      if (tokens == null) {
        state = const AuthState(status: AuthStatus.unauthenticated);
        debugPrint('[BOOT] -> unauthenticated');
        return;
      }
      state = state.copyWith(status: AuthStatus.authenticated, isLoading: false, error: null);
      debugPrint('[BOOT] -> authenticated');
      // Defer FCM init so any overlay-driven navigation (FCM notification tap)
      // doesn't race against the Navigator's overlay being laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) => _fcm.init().ignore());
    } catch (e, stack) {
      debugPrint('[AuthController bootstrap error] $e\n$stack');
      try {
        await _tokenStorage.clear();
      } catch (_) {}
      if (mounted) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    }
  }

  Future<void> login({String? email, String? password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = await _repository.login(email: email, password: password);
      await _tokenStorage.saveTokens(payload.tokens);
      // Re-arm session handling so a future suspension/expiry is acted upon.
      _ref.read(apiClientProvider).resetSession();
      state = AuthState(status: AuthStatus.authenticated, driver: payload.driver);
      // P1-a: a driver who queued writes, was signed out (token fully expired),
      // and just signed back in should have those writes flushed now — a fresh
      // token is available and connectivity may not change again.
      _ref.read(offlineQueueProvider.notifier).processQueue();
      // Tag crash reports with the driver id only (no name/phone — PII-free).
      await Sentry.configureScope((s) => s.setUser(SentryUser(id: payload.driver.id)));
      Sentry.addBreadcrumb(Breadcrumb(category: 'auth', message: 'login success'));
      WidgetsBinding.instance.addPostFrameCallback((_) => _fcm.init().ignore());
    } on DioException catch (error) {
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        error: _loginErrorMessage(error),
      );
      rethrow;
    } catch (e) {
      final errorStr = e.toString();
      final isCancelled = errorStr.contains('user_cancelled') || errorStr.contains('User cancelled flow');
      
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.unauthenticated,
        error: isCancelled ? null : errorStr,
      );
      if (!isCancelled) rethrow;
    }
  }

  /// Builds a user-facing message from a failed login. The backend returns
  /// ready-to-display French messages for suspended/pending accounts in the
  /// `error` field — surface those instead of a generic fallback.
  String _loginErrorMessage(DioException error) {
    final response = error.response;
    if (response == null) {
      return 'Réseau indisponible. Vérifiez votre connexion et réessayez.';
    }
    final data = response.data;
    String? serverMessage;
    if (data is Map) {
      serverMessage = (data['error'] ?? data['message'])?.toString();
    }
    if (serverMessage != null &&
        serverMessage.isNotEmpty &&
        serverMessage != 'Invalid credentials') {
      return serverMessage;
    }
    return 'Numéro de téléphone ou mot de passe incorrect.';
  }

  Future<void> register(String name, String phone, String password) async {
    throw UnimplementedError('Registration is handled via invites.');
  }

  /// Ends the session in response to a server signal (token expiry or the
  /// account being suspended/removed by an admin) and surfaces an accurate,
  /// localized message on the login screen.
  Future<void> endSession(SessionEndReason reason) async {
    final notice = switch (reason) {
      SessionEndReason.accountDisabled =>
        'Votre compte a été suspendu. Contactez votre responsable pour le réactiver.',
      SessionEndReason.expired =>
        'Votre session a expiré. Veuillez vous reconnecter.',
    };
    await logout(notice: notice);
  }

  Future<void> logout({String? notice}) async {
    // Deregister FCM only while we still hold a usable token — otherwise the
    // call just produces another rejected request. Time-box it so a slow or
    // failing network can never wedge the logout.
    final token = await _tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      try {
        await _fcm.deregister().timeout(const Duration(seconds: 5));
      } catch (_) {
        // Non-fatal: backend token is overwritten on next sign-in.
      }
    }
    // Keycloak OIDC endSession
    try {
      await _repository.logout();
    } catch (_) {
      // Best effort
    }

    await _tokenStorage.clear();
    // The offline cache holds this driver's round, his customers and his profile. Leaving it behind
    // would show the next driver signing in on this handset someone else's deliveries.
    try {
      await Hive.box('domain_cache').clear();
    } catch (_) {
      // Best effort: never let a cache wipe block a sign-out.
    }
    Sentry.addBreadcrumb(Breadcrumb(category: 'auth', message: 'logout'));
    await Sentry.configureScope((s) => s.setUser(null));
    // Session handling stays disarmed until the next successful sign-in (see
    // login/register), so trailing 401s from in-flight requests can't overwrite
    // the notice or trigger another logout.
    state = AuthState(status: AuthStatus.unauthenticated, error: notice);
  }

  void setDriverFromProfile(DriverIdentity driver) {
    if (state.status == AuthStatus.authenticated) {
      state = state.copyWith(driver: driver);
    }
  }
}
