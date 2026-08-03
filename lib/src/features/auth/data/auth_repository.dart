import '../../../models/auth_tokens.dart';
import '../../../services/api_client.dart';
import '../models/auth_models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  AuthRepository(this._client);

  final ApiClient _client;
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  Future<AuthPayload> login({String? email, String? password}) async {
    // flutter_appauth has no web implementation, and the mobile redirect scheme
    // (com.asm.driverapp://) can't round-trip through a browser. On web we fall
    // back to Keycloak's Direct Access Grant (ROPC) with an email/password form.
    // DEV-ONLY: never reachable in a mobile/prod build (guarded by kIsWeb).
    if (kIsWeb) {
      return _webLogin(email ?? '', password ?? '');
    }

    final cfg = _client.config;
    final result = await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        cfg.clientId,
        cfg.redirectUrl,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: cfg.authorizationEndpoint,
          tokenEndpoint: cfg.tokenEndpoint,
          endSessionEndpoint: cfg.endSessionEndpoint,
        ),
        // `offline_access` is what keeps a driver signed in between stops.
        //
        // Without it Keycloak binds the refresh token to the SSO session, which expires on idle
        // (30 minutes by default). A driver who spends half an hour on the road without opening the
        // app — the normal case, not an edge one — comes back to a refresh token the server has
        // already forgotten, and the app signs him out mid-round. With it, Keycloak issues an
        // offline token that survives idle and app restarts, and only ends when someone revokes it.
        //
        // The DRIVER role already carries offline_access in the realm; the app simply never asked.
        scopes: const ['openid', 'profile', 'email', 'offline_access'],
        allowInsecureConnections: true,
      ),
    );

    if (result.accessToken != null) {
      final tokens = AuthTokens(
        accessToken: result.accessToken!,
        refreshToken: result.refreshToken ?? '',
        idToken: result.idToken,
      );

      // We must fetch the driver profile with this access token
      // Because AppAuth just returned the tokens, but our AuthState expects a DriverIdentity.
      final dio = Dio(BaseOptions(
        baseUrl: _client.dio.options.baseUrl,
        headers: {'Authorization': 'Bearer ${tokens.accessToken}'},
      ));

      final profileRes = await dio.get<Map<String, dynamic>>('/driver/profile');
      final driver = DriverIdentity.fromJson(profileRes.data ?? {});
      return AuthPayload(tokens: tokens, driver: driver);
    }
    throw Exception('Login failed or cancelled');
  }

  /// DEV-ONLY web sign-in via Keycloak Direct Access Grant (ROPC). Requires the
  /// `driver-app` client to have "Direct Access Grants" enabled and the web
  /// origin registered under Web Origins (CORS). Sends credentials directly to
  /// the token endpoint — acceptable only for local web dev, never for prod.
  Future<AuthPayload> _webLogin(String email, String password) async {
    final cfg = _client.config;
    final dio = Dio();
    final tokenRes = await dio.post<Map<String, dynamic>>(
      cfg.tokenEndpoint,
      options: Options(contentType: Headers.formUrlEncodedContentType),
      data: {
        'grant_type': 'password',
        'client_id': cfg.clientId,
        'username': email,
        'password': password,
        'scope': 'openid profile email offline_access',   // see the AppAuth call above
      },
    );

    final data = tokenRes.data ?? const {};
    final accessToken = data['access_token'] as String?;
    if (accessToken == null) {
      throw Exception('Login failed');
    }
    final tokens = AuthTokens(
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String? ?? '',
      idToken: data['id_token'] as String?,
    );

    final profileDio = Dio(BaseOptions(
      baseUrl: _client.dio.options.baseUrl,
      headers: {'Authorization': 'Bearer ${tokens.accessToken}'},
    ));
    final profileRes = await profileDio.get<Map<String, dynamic>>('/driver/profile');
    final driver = DriverIdentity.fromJson(profileRes.data ?? {});
    return AuthPayload(tokens: tokens, driver: driver);
  }

  Future<AuthPayload> register({required String name, required String phone, required String password}) async {
    throw UnimplementedError('Registration is handled via admin invitation.');
  }

  Future<void> logout() async {
    // Web (ROPC) has no AppAuth session to end at the IdP; token clearing is
    // handled by the controller. Skip the native endSession call.
    if (kIsWeb) return;
    final cfg = _client.config;
    try {
      final idToken = await _client.tokenStorage.readIdToken();
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: idToken != null ? cfg.redirectUrl : null,
          serviceConfiguration: AuthorizationServiceConfiguration(
            authorizationEndpoint: cfg.authorizationEndpoint,
            tokenEndpoint: cfg.tokenEndpoint,
            endSessionEndpoint: cfg.endSessionEndpoint,
          ),
          allowInsecureConnections: true,
        ),
      );
    } catch (_) {
      // Best-effort OIDC logout
    }
  }
}
