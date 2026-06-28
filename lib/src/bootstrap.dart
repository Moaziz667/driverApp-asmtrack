import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../firebase_options.dart';

import 'app.dart';
import 'services/token_storage.dart';

// Observability config — injected at build time, e.g.
//   flutter build apk --dart-define=SENTRY_DSN=https://…  \
//                      --dart-define=SENTRY_ENVIRONMENT=production
// An empty DSN disables Sentry entirely, so the app runs normally in dev.
const _sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
const _sentryEnv = String.fromEnvironment('SENTRY_ENVIRONMENT', defaultValue: 'development');
const _sentryRelease = String.fromEnvironment('SENTRY_RELEASE', defaultValue: '');

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  final tokenStorage = TokenStorage();
  final dbKey = await tokenStorage.getOrCreateDbKey().timeout(
    const Duration(seconds: 3),
    onTimeout: () {
      debugPrint('[bootstrap] getOrCreateDbKey timed out, using fallback');
      return List<int>.generate(32, (i) => i);
    },
  );
  final cipher = HiveAesCipher(dbKey);

  await _openSafeBox<Map<dynamic, dynamic>>('offline_queue', cipher);
  await _openSafeBox('notifications', cipher);
  await _openSafeBox('domain_cache', cipher);

  // Firebase init must never block app launch — time it out so a slow/absent Play Services
  // (or a flaky network) can't freeze the splash. FCM re-initialises lazily afterwards.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('[bootstrap] Firebase.initializeApp failed/timed out: $e');
  }

  // An empty DSN means Sentry is disabled (dev). Initialising the native Sentry SDK anyway pulls in
  // a per-frame metrics collector + integration probing that janks the main thread on startup — so
  // when there's no DSN, skip Sentry entirely and just run the app.
  if (_sentryDsn.isEmpty) {
    runApp(const ProviderScope(child: DriverApp()));
    return;
  }

  // SentryFlutter.init owns the error zone (FlutterError.onError +
  // PlatformDispatcher.onError) and runs the app inside it.
  await SentryFlutter.init(
    (options) {
      options.dsn = _sentryDsn;
      options.environment = _sentryEnv;
      if (_sentryRelease.isNotEmpty) options.release = _sentryRelease;
      options.tracesSampleRate = 0.2;
      options.attachStacktrace = true;
      options.sendDefaultPii = false; // never attach tokens / phone / IP
    },
    appRunner: () => runApp(const ProviderScope(child: DriverApp())),
  );
}

Future<Box<T>> _openSafeBox<T>(String name, HiveCipher? cipher) async {
  try {
    return await Hive.openBox<T>(name, encryptionCipher: cipher);
  } catch (e, stack) {
    debugPrint('[Hive openBox error] Failed to open box $name: $e\n$stack');
    try {
      await Hive.deleteBoxFromDisk(name);
      return await Hive.openBox<T>(name, encryptionCipher: cipher);
    } catch (retryError, retryStack) {
      debugPrint('[Hive openBox error] Critical: retry failed for box $name: $retryError\n$retryStack');
      try {
        return await Hive.openBox<T>(name);
      } catch (_) {
        rethrow;
      }
    }
  }
}

