import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards FR/EN/AR translation parity — a missing key silently falls back to
/// French at runtime, so this catches drift before it ships.
/// Reads the ARB JSON files directly and compares their key sets.
void main() {
  final fr = _loadArbKeys('fr');
  final en = _loadArbKeys('en');
  final ar = _loadArbKeys('ar');

  test('EN has every FR key', () {
    final missing = fr.difference(en);
    expect(missing, isEmpty, reason: 'Keys in FR missing from EN: $missing');
  });

  test('AR has every FR key', () {
    final missing = fr.difference(ar);
    expect(missing, isEmpty, reason: 'Keys in FR missing from AR: $missing');
  });

  test('no EN-only keys', () {
    final extra = en.difference(fr);
    expect(extra, isEmpty, reason: 'Keys in EN missing from FR: $extra');
  });

  test('no AR-only keys', () {
    final extra = ar.difference(fr);
    expect(extra, isEmpty, reason: 'Keys in AR missing from FR: $extra');
  });
}

Set<String> _loadArbKeys(String locale) {
  final file = File('lib/l10n/app_$locale.arb');
  final content = file.readAsStringSync();
  final Map<String, dynamic> json = jsonDecode(content);
  // Skip metadata keys that start with '@' or '@@'.
  return json.keys.where((k) => !k.startsWith('@')).toSet();
}
