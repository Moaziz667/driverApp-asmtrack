import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:driver_app/src/theme/app_theme.dart';

/// Pumps a leaf widget inside the app's light theme. Disables GoogleFonts
/// runtime fetching so tests never hit the network and render deterministically
/// (important for golden stability).
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  Size? surfaceSize,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  // Tight, phone-ish surface bounds both axes — the POD cards are full-width
  // widgets that need a bounded width, and a tall height avoids overflow.
  await tester.binding.setSurfaceSize(surfaceSize ?? const Size(390, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}
