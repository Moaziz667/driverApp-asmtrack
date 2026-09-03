import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/src/models/auth_tokens.dart';

void main() {
  group('AuthTokens.fromMap', () {
    test(
      'parses access/refresh/id tokens and derives expiry from expiresIn',
      () {
        final t = AuthTokens.fromMap({
          'accessToken': 'a',
          'refreshToken': 'r',
          'idToken': 'i',
          'tokenType': 'Bearer',
          'expiresIn': 3600,
        });
        expect(t.accessToken, 'a');
        expect(t.refreshToken, 'r');
        expect(t.idToken, 'i');
        expect(t.tokenType, 'Bearer');
        expect(t.isExpired, isFalse);
        expect(t.expiresAt!.isAfter(DateTime.now()), isTrue);
      },
    );

    test('accepts the "token" alias for accessToken', () {
      final t = AuthTokens.fromMap({'token': 'a', 'refreshToken': 'r'});
      expect(t.accessToken, 'a');
    });

    test(
      'falls back to currentRefreshToken when the server omits one (KC rotation edge)',
      () {
        final t = AuthTokens.fromMap({
          'accessToken': 'a',
        }, currentRefreshToken: 'old');
        expect(t.refreshToken, 'old');
      },
    );

    test('no expiresIn => expiresAt null => not expired', () {
      final t = AuthTokens.fromMap({'accessToken': 'a', 'refreshToken': 'r'});
      expect(t.expiresAt, isNull);
      expect(t.isExpired, isFalse);
    });
  });

  test('isExpired is true once expiry is in the past', () {
    final t = AuthTokens(
      accessToken: 'a',
      refreshToken: 'r',
      expiresAt: DateTime.now().subtract(const Duration(minutes: 1)),
    );
    expect(t.isExpired, isTrue);
  });

  test('copyWith overrides only the given field', () {
    final t = const AuthTokens(
      accessToken: 'a',
      refreshToken: 'r',
    ).copyWith(accessToken: 'b');
    expect(t.accessToken, 'b');
    expect(t.refreshToken, 'r');
  });
}
