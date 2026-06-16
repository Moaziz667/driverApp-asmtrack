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
  final dbKey = await tokenStorage.getOrCreateDbKey();
  final cipher = HiveAesCipher(dbKey);

  await Hive.openBox<Map<dynamic, dynamic>>('offline_queue', encryptionCipher: cipher);
  await Hive.openBox('notifications', encryptionCipher: cipher);
  await Hive.openBox('domain_cache', encryptionCipher: cipher);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

