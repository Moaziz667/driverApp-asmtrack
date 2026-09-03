import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_tokens.dart';

class TokenStorage {
  static const FlutterSecureStorage _sharedSecureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  TokenStorage() : _secureStorage = _sharedSecureStorage;

  final FlutterSecureStorage _secureStorage;
  AuthTokens? _cached;

  static const _kAccessTokenKey = 'access_token';
  static const _kRefreshTokenKey = 'refresh_token';
  static const _kIdTokenKey = 'id_token';
  static const _kTokenTypeKey = 'token_type';
  static const _kExpiresAtKey = 'expires_at';
  static const _kApiBaseUrlKey = 'api_base_url';
  static const _kDbEncryptionKey = 'db_encryption_key';

  Future<String?> _readSafe(String key) async {
    try {
      return await _secureStorage
          .read(key: key)
          .timeout(const Duration(seconds: 3));
    } catch (e, stack) {
      debugPrint('[TokenStorage] Error reading key $key: $e\n$stack');
      return null;
    }
  }

  Future<void> _writeSafe(String key, String value) async {
    try {
      await _secureStorage
          .write(key: key, value: value)
          .timeout(const Duration(seconds: 3));
    } catch (e, stack) {
      debugPrint('[TokenStorage] Error writing key $key: $e\n$stack');
    }
  }

  Future<void> _deleteSafe(String key) async {
    try {
      await _secureStorage.delete(key: key).timeout(const Duration(seconds: 3));
    } catch (e, stack) {
      debugPrint('[TokenStorage] Error deleting key $key: $e\n$stack');
    }
  }

  Future<AuthTokens?> readTokens() async {
    if (_cached != null) {
      return _cached;
    }
    final access = await _readSafe(_kAccessTokenKey);
    final refresh = await _readSafe(_kRefreshTokenKey);
    if (access == null || refresh == null) {
      return null;
    }
    final idToken = await _readSafe(_kIdTokenKey);
    final tokenType = await _readSafe(_kTokenTypeKey) ?? 'Bearer';
    final expiresIso = await _readSafe(_kExpiresAtKey);
    final expiresAt = expiresIso != null ? DateTime.tryParse(expiresIso) : null;
    _cached = AuthTokens(
      accessToken: access,
      refreshToken: refresh,
      idToken: idToken,
      tokenType: tokenType,
      expiresAt: expiresAt,
    );
    return _cached;
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    _cached = tokens;
    await _writeSafe(_kAccessTokenKey, tokens.accessToken);
    await _writeSafe(_kRefreshTokenKey, tokens.refreshToken);
    await _writeSafe(_kIdTokenKey, tokens.idToken ?? '');
    await _writeSafe(_kTokenTypeKey, tokens.tokenType);
    await _writeSafe(_kExpiresAtKey, tokens.expiresAt?.toIso8601String() ?? '');
  }

  Future<void> clear() async {
    _cached = null;
    await _deleteSafe(_kAccessTokenKey);
    await _deleteSafe(_kRefreshTokenKey);
    await _deleteSafe(_kIdTokenKey);
    await _deleteSafe(_kTokenTypeKey);
    await _deleteSafe(_kExpiresAtKey);
  }

  Future<String?> readAccessToken() async => (await readTokens())?.accessToken;
  Future<String?> readRefreshToken() async =>
      (await readTokens())?.refreshToken;
  Future<String?> readIdToken() async => (await readTokens())?.idToken;

  Future<String?> readApiBaseUrl() async {
    return await _readSafe(_kApiBaseUrlKey);
  }

  Future<void> saveApiBaseUrl(String url) async {
    await _writeSafe(_kApiBaseUrlKey, url);
  }

  Future<List<int>> getOrCreateDbKey() async {
    final base64Key = await _readSafe(_kDbEncryptionKey);
    if (base64Key != null && base64Key.isNotEmpty) {
      try {
        final decoded = base64Decode(base64Key);
        if (decoded.length == 32) {
          return decoded;
        } else if (decoded.length > 32) {
          return decoded.sublist(0, 32);
        }
      } catch (_) {
        // Fall through and generate fresh key
      }
    }
    final random = Random.secure();
    final freshKey = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    await _writeSafe(_kDbEncryptionKey, base64Encode(freshKey));
    return freshKey;
  }
}
