import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'status_colors.dart';
import 'tokens.dart';

/// Branded page transition: a fade combined with a short upward slide — the
/// "fade-through" motion used across enterprise apps. Applied to every platform
/// so push/pop feels identical and intentional rather than the stock platform default.
class _FadeThroughPageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeThroughPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );
    final slide = Tween<Offset>(begin: const Offset(0, 0.035), end: Offset.zero).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

const PageTransitionsTheme _appPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _FadeThroughPageTransitionsBuilder(),
    TargetPlatform.iOS: _FadeThroughPageTransitionsBuilder(),
    TargetPlatform.fuchsia: _FadeThroughPageTransitionsBuilder(),
    TargetPlatform.linux: _FadeThroughPageTransitionsBuilder(),
    TargetPlatform.macOS: _FadeThroughPageTransitionsBuilder(),
    TargetPlatform.windows: _FadeThroughPageTransitionsBuilder(),
  },
);

ThemeData buildLightTheme() {
  // Brand-aligned with the admin app (Control Tower light): ASM blue #0972D3, white surfaces.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF0972D3),
    secondary: const Color(0xFF10B981),
    brightness: Brightness.light,
    primary: const Color(0xFF0972D3),
    surface: const Color(0xFFFFFFFF),
    onSurface: const Color(0xFF0F141A),
    surfaceContainerLow: const Color(0xFFFFFFFF),
    outlineVariant: const Color(0xFFE9EBED),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    pageTransitionsTheme: _appPageTransitions,
    scaffoldBackgroundColor: const Color(0xFFFCFCFC), // admin --app-bg (canvas slightly off-white)
    textTheme: GoogleFonts.openSansTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: AppTokens.fwBold,
        color: colorScheme.onSurface,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.space18, vertical: AppTokens.space16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: const TextStyle(fontWeight: AppTokens.fwMedium),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space16, horizontal: AppTokens.space24),
        textStyle: const TextStyle(fontWeight: AppTokens.fwBold, fontSize: 15, letterSpacing: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space16, horizontal: AppTokens.space24),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        textStyle: const TextStyle(fontWeight: AppTokens.fwBold, fontSize: 15, letterSpacing: 0.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space12, horizontal: AppTokens.space24),
        textStyle: const TextStyle(fontWeight: AppTokens.fwSemiBold, fontSize: 14),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radius2xl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
    ),
    extensions: const [
      StatusColors(
        unscheduled:         Color(0xFFC4881A),
        scheduled:           Color(0xFF5E6AD2),
        pickedUp:            Color(0xFF2594B8),
        inTransit:           Color(0xFFD4772C),
        delivered:           Color(0xFF4CAF82),
        partiallyDelivered:  Color(0xFF7B6FCC),
        cancelled:           Color(0xFF8A8F98),
        failed:              Color(0xFFC7372F),
        online:              Color(0xFF10B981),
        onBreak:             Color(0xFFF59E0B),
        offline:             Color(0xFF8A8F98),
      ),
    ],
  );
}

ThemeData buildDarkTheme() {
  // Brand-aligned with the admin app (Control Tower dark): Signal Blue #539FE5 on graphite navy
  // (canvas #0F1B2A, cards #1B2530), so the driver app reads as the same product as the dashboard.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF539FE5),
    secondary: const Color(0xFF10B981),
    brightness: Brightness.dark,
    primary: const Color(0xFF539FE5),
    surface: const Color(0xFF1B2530),
    onSurface: const Color(0xFFE9EBED),
    surfaceContainerLow: const Color(0xFF232F3E),
    outlineVariant: const Color(0xFF2B3640),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    pageTransitionsTheme: _appPageTransitions,
    scaffoldBackgroundColor: const Color(0xFF0F1B2A), // admin --app-bg (canvas darker than cards)
    textTheme: GoogleFonts.openSansTextTheme().apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: colorScheme.onSurface),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: AppTokens.fwBold,
        color: colorScheme.onSurface,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.0),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.space18, vertical: AppTokens.space16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      labelStyle: const TextStyle(fontWeight: AppTokens.fwMedium),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space16, horizontal: AppTokens.space24),
        textStyle: const TextStyle(fontWeight: AppTokens.fwBold, fontSize: 15, letterSpacing: 0.5),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusLg)),
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space16, horizontal: AppTokens.space24),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1.5),
        textStyle: const TextStyle(fontWeight: AppTokens.fwBold, fontSize: 15, letterSpacing: 0.5),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
        padding: const EdgeInsets.symmetric(vertical: AppTokens.space12, horizontal: AppTokens.space24),
        textStyle: const TextStyle(fontWeight: AppTokens.fwSemiBold, fontSize: 14),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerLow,
      elevation: 0,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radius2xl)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: colorScheme.inverseSurface,
      contentTextStyle: TextStyle(color: colorScheme.onInverseSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
    ),
    extensions: const [
      StatusColors(
        unscheduled:         Color(0xFFD4A030),
        scheduled:           Color(0xFF7B8AE0),
        pickedUp:            Color(0xFF3DB8D0),
        inTransit:           Color(0xFFE89040),
        delivered:           Color(0xFF6BC49A),
        partiallyDelivered:  Color(0xFF9588D8),
        cancelled:           Color(0xFFA0A5B0),
        failed:              Color(0xFFE05045),
        online:              Color(0xFF34D399),
        onBreak:             Color(0xFFFB923C),
        offline:             Color(0xFF9CA3AF),
      ),
    ],
  );
}
