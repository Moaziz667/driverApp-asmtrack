import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'status_colors.dart';
import 'tokens.dart';

ThemeData buildLightTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5E6AD2),
    secondary: const Color(0xFF10B981),
    brightness: Brightness.light,
    primary: const Color(0xFF5E6AD2),
    surface: const Color(0xFFF8FAFC),
    onSurface: const Color(0xFF0F172A),
    surfaceContainerLow: Colors.white,
    outlineVariant: const Color(0xFFE2E8F0),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: GoogleFonts.outfitTextTheme().apply(
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
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.05),
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
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF5E6AD2),
    secondary: const Color(0xFF10B981),
    brightness: Brightness.dark,
    primary: const Color(0xFF5E6AD2),
    surface: const Color(0xFF0A0B10),
    onSurface: const Color(0xFFF8FAFC),
    surfaceContainerLow: const Color(0xFF121824),
    outlineVariant: const Color(0xFF1E293B),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: GoogleFonts.outfitTextTheme().apply(
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
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
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
