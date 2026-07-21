class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    String? keycloakBaseUrl,
    this.realm = 'asm',
    this.clientId = 'driver-app',
  }) : _keycloakBaseUrlOverride = keycloakBaseUrl;

  factory AppConfig.fromEnvironment() {
    // Build-time default, e.g. flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
    // At runtime the in-app "Server URL" setting (TokenStorage.apiBaseUrl) overrides this — so the same
    // installed build can be pointed at local or the dev server without rebuilding.
    const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.86.194.125');
    return AppConfig.fromStorage(baseUrl);
  }

  factory AppConfig.fromStorage(String apiBaseUrl) {
    return AppConfig(
      apiBaseUrl: apiBaseUrl,
      keycloakBaseUrl: const String.fromEnvironment('KEYCLOAK_BASE_URL', defaultValue: ''),
      realm: const String.fromEnvironment('KEYCLOAK_REALM', defaultValue: 'asm'),
      clientId: const String.fromEnvironment('KEYCLOAK_CLIENT_ID', defaultValue: 'driver-app'),
    );
  }

  final String apiBaseUrl;

  /// REST API base: the public contract is versioned at `/api/v1/**`, so the version
  /// lives here in one place and call sites use resource-relative paths
  /// (`dio.get('/driver/deliveries/active')`). `apiBaseUrl` stays the bare origin because
  /// the Keycloak endpoints below derive from it. A future v2 = a second Dio on `/api/v2`.
  String get apiBaseUrlV1 => '$apiBaseUrl/api/v1';

  final String? _keycloakBaseUrlOverride;
  final String realm;
  final String clientId;

  // ── Keycloak / OIDC endpoints (single source of truth) ──────────────────────
  /// Keycloak base URL: an explicit build-time override wins; otherwise it's
  /// derived from the API host on the conventional :8089 Keycloak port, so the
  /// IdP follows the API host whenever the workspace URL changes.
  String get keycloakBaseUrl {
    final override = _keycloakBaseUrlOverride;
    if (override != null && override.isNotEmpty) return override;
    final uri = Uri.parse(apiBaseUrl);
    return '${uri.scheme}://${uri.host}:8089';
  }

  String get issuerUrl => '$keycloakBaseUrl/realms/$realm';
  String get authorizationEndpoint => '$issuerUrl/protocol/openid-connect/auth';
  String get tokenEndpoint => '$issuerUrl/protocol/openid-connect/token';
  String get endSessionEndpoint => '$issuerUrl/protocol/openid-connect/logout';
  String get accountConsoleUrl => '$issuerUrl/account/';

  /// AppAuth redirect URI — must match `appAuthRedirectScheme` in the Android
  /// manifest and the iOS URL scheme.
  String get redirectUrl => 'com.asm.driverapp://login-callback';
}
