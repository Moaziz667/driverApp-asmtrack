import 'package:flutter/material.dart';

class AppTokens {
  const AppTokens._();

  // ── Spacing scale (4px base unit) ──────────────────────────────────────────
  static const double space0  = 0.0;
  static const double space2  = 2.0;
  static const double space4  = 4.0;
  static const double space6  = 6.0;
  static const double space8  = 8.0;
  static const double space10 = 10.0;
  static const double space12 = 12.0;
  static const double space14 = 14.0;
  static const double space16 = 16.0;
  static const double space18 = 18.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space44 = 44.0;
  static const double space48 = 48.0;
  static const double space56 = 56.0;

  // ── Radius scale ── aligned with the admin app (Control Tower) so cards/inputs/sheets share the
  //    same roundness as the dashboard: xs2 / sm4 / md8 / lg8 / xl12 / 2xl16.
  static const double radiusSm   = 4.0;
  static const double radiusMd   = 8.0;
  static const double radiusLg   = 8.0;
  static const double radiusXl   = 12.0;
  static const double radius2xl  = 16.0;
  static const double radiusFull = 9999.0;

  // ── Semantic colors ────────────────────────────────────────────────────────
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color infoBlue     = Color(0xFF3E6AE1);
  static const Color dangerRed    = Color(0xFFC7372F);

  // ── Elevation (shadows) ────────────────────────────────────────────────────
  static List<BoxShadow> shadowSm({Brightness brightness = Brightness.light}) {
    final alpha = brightness == Brightness.dark ? 0.3 : 0.06;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: alpha),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  static List<BoxShadow> shadowMd({Brightness brightness = Brightness.light}) {
    final alpha = brightness == Brightness.dark ? 0.4 : 0.1;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: alpha),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static List<BoxShadow> shadowLg({Brightness brightness = Brightness.light}) {
    final alpha = brightness == Brightness.dark ? 0.5 : 0.14;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: alpha),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // ── Font weights (capped at w700 for readability) ─────────────────────────
  static const FontWeight fwNormal   = FontWeight.w400;
  static const FontWeight fwMedium   = FontWeight.w500;
  static const FontWeight fwSemiBold = FontWeight.w600;
  static const FontWeight fwBold     = FontWeight.w700;
}
