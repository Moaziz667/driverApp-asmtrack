import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_providers.dart';
import 'features/auth/models/auth_models.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/auth/presentation/setup_account_screen.dart';
import 'features/auth/presentation/splash_screen.dart';
import 'features/deliveries/presentation/delivery_detail_screen.dart';
import 'features/deliveries/presentation/handoff_inbox_screen.dart';
import 'features/home/presentation/home_shell.dart';
import 'features/pod/presentation/pod_form_screen.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';
import 'services/locale_provider.dart';
import 'theme/app_theme.dart';

class DriverApp extends ConsumerStatefulWidget {
  const DriverApp({super.key});

  @override
  ConsumerState<DriverApp> createState() => _DriverAppState();
}

/// Single navigator for the whole app so auth-driven routing works from any
/// screen — including a forced sign-out triggered deep inside the app.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class _DriverAppState extends ConsumerState<DriverApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authControllerProvider.notifier).bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    // Centralized auth-driven routing: whenever the auth status changes — login,
    // logout, token expiry, or an admin suspending the account — route to the
    // right screen from a single place instead of each screen doing it ad hoc.
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      debugPrint('[ROUTE] status ${prev?.status} -> ${next.status} (loading=${next.isLoading})');
      if (prev?.status == next.status || next.isLoading) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[NAV] navigateToHome ctx=${rootNavigatorKey.currentContext != null} status=${next.status}');
        navigateToHome(rootNavigatorKey.currentContext, next.status);
      });
    });

    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'AsmTrack Driver',
      navigatorKey: rootNavigatorKey,
      debugShowCheckedModeBanner: false,
      locale: Locale(locale),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        SetupAccountScreen.routeName: (_) => const SetupAccountScreen(),
        HomeShell.routeName: (_) => const HomeShell(),
        HandoffInboxScreen.routeName: (_) => const HandoffInboxScreen(),
      },
      initialRoute: SplashScreen.routeName,
      onGenerateRoute: (settings) {
        if (settings.name == DeliveryDetailScreen.routeName) {
          final args = settings.arguments as DeliveryDetailArgs;
          return MaterialPageRoute(
            builder: (_) => DeliveryDetailScreen(args: args),
            settings: settings,
          );
        }
        if (settings.name == PodFormScreen.routeName) {
          final args = settings.arguments as PodFormArgs;
          return MaterialPageRoute(
            builder: (_) => PodFormScreen(args: args),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

void navigateToHome(BuildContext? context, AuthStatus status) {
  if (context == null) return;
  if (status == AuthStatus.authenticated) {
    Navigator.of(context).pushNamedAndRemoveUntil(HomeShell.routeName, (route) => false);
  } else {
    Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
  }
}
