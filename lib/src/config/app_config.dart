class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.discoveryUrl,
    String? keycloakBaseUrl,
    this.realm = 'asm',
    this.clientId = 'driver-app',
  }) : _keycloakBaseUrlOverride = keycloakBaseUrl;

  factory AppConfig.fromEnvironment() {
    // PROD: pass these at build time, e.g.
    //   flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com \
    //                      --dart-define=KEYCLOAK_BASE_URL=https://id.yourdomain.com
    // Without API_BASE_URL the app connects to localhost and fails on a real device.
    const baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.86.194.125');
    const discovery = String.fromEnvironment('DISCOVERY_URL', defaultValue: 'http://10.86.194.125:8080/clients.json');
    return AppConfig(
      apiBaseUrl: baseUrl,
      discoveryUrl: discovery,
      keycloakBaseUrl: const String.fromEnvironment('KEYCLOAK_BASE_URL', defaultValue: ''),
      realm: const String.fromEnvironment('KEYCLOAK_REALM', defaultValue: 'asm'),
      clientId: const String.fromEnvironment('KEYCLOAK_CLIENT_ID', defaultValue: 'driver-app'),
    );
  }

  factory AppConfig.fromStorage(String apiBaseUrl) {
    const discovery = String.fromEnvironment('DISCOVERY_URL', defaultValue: 'http://10.86.194.125:8080/clients.json');
    return AppConfig(
      apiBaseUrl: apiBaseUrl,
      discoveryUrl: discovery,
      keycloakBaseUrl: const String.fromEnvironment('KEYCLOAK_BASE_URL', defaultValue: ''),
      realm: const String.fromEnvironment('KEYCLOAK_REALM', defaultValue: 'asm'),
      clientId: const String.fromEnvironment('KEYCLOAK_CLIENT_ID', defaultValue: 'driver-app'),
    );
  }

  final String apiBaseUrl;
  final String discoveryUrl;
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
