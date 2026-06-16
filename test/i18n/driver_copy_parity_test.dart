import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/src/services/locale_provider.dart';

/// Guards FR/EN/AR translation parity — a missing key silently falls back to
/// French at runtime, so this catches drift before it ships.
void main() {
  final fr = DriverCopy.dict['fr']!.keys.toSet();
  final en = DriverCopy.dict['en']!.keys.toSet();
  final ar = DriverCopy.dict['ar']!.keys.toSet();

  test('EN has every FR key', () {
    expect(fr.difference(en), isEmpty, reason: 'Keys in FR missing from EN: ${fr.difference(en)}');
  });
  test('AR has every FR key', () {
    expect(fr.difference(ar), isEmpty, reason: 'Keys in FR missing from AR: ${fr.difference(ar)}');
  });
  test('no EN-only keys', () {
    expect(en.difference(fr), isEmpty, reason: 'Keys in EN missing from FR: ${en.difference(fr)}');
  });
  test('no AR-only keys', () {
    expect(ar.difference(fr), isEmpty, reason: 'Keys in AR missing from FR: ${ar.difference(fr)}');
  });
}
