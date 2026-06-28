import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Color-token guard. Structural colors must come from the theme
/// (`ColorScheme` / `AppTokens` / `status_colors.dart`), not raw `Color(0x…)`
/// hex literals. The files below are the grandfathered baseline (existing hex
/// to be cleaned up gradually); **new** files with hardcoded hex outside
/// `lib/src/theme/` fail this test. Don't add to the allowlist to silence it —
/// tokenize the color instead.
void main() {
  const baseline = <String>{
    'lib/src/features/auth/presentation/login_screen.dart',
    'lib/src/features/auth/presentation/splash_screen.dart',
    'lib/src/features/deliveries/presentation/handoff_token_sheet.dart',
    'lib/src/features/home/presentation/widgets/home_widgets.dart',
    'lib/src/features/routes/presentation/route_detail_sheet.dart',
    'lib/src/features/routes/presentation/widgets/calendar_widgets.dart',
  };

  test('no new hardcoded Color(0x…) outside lib/src/theme/', () {
    final re = RegExp(r'Color\(0x');
    final offenders = <String>[];

    for (final entity in Directory('lib/src').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final path = entity.path.replaceAll(r'\', '/');
      if (path.contains('/theme/')) continue;
      if (re.hasMatch(entity.readAsStringSync())) offenders.add(path);
    }

    final unexpected = offenders.where((p) => !baseline.contains(p)).toList()..sort();
    expect(
      unexpected,
      isEmpty,
      reason: 'Hardcoded colors found in new files — use ColorScheme/AppTokens '
          'instead of Color(0x…). Offenders: $unexpected',
    );

    // Keep the baseline honest: flag entries that no longer have hex so they can
    // be removed from the allowlist as cleanup happens.
    final stale = baseline.where((p) => !offenders.contains(p)).toList()..sort();
    expect(stale, isEmpty,
        reason: 'These baseline files no longer contain Color(0x…) — remove from allowlist: $stale');
  });
}
