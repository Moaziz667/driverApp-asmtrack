import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/src/services/locale_provider.dart';

/// Proves the route-CTA and login copy keys (added/used by the route i18n pass
/// and the login redesign) exist and are actually translated in all 3 locales —
/// `DriverCopy.get` returns the key itself when a translation is missing, so a
/// returned value equal to the key = a real bug (e.g. the earlier missing
/// `login_failed_error`).
void main() {
  const keys = [
    'route_swipe_start',
    'route_swipe_load',
    'route_swipe_confirm_load',
    'route_all_stops_done',
    'route_download_pdf',
    'route_navigate',
    'route_finished',
    'route_stops_log',
    'login_action_setup_sub',
    'login_action_change_workspace_sub',
    'login_secure_sso',
    'login_version',
    'login_failed_error',
  ];

  for (final locale in ['fr', 'en', 'ar']) {
    for (final key in keys) {
      test('$key is translated in $locale', () {
        final value = DriverCopy.get(key, locale);
        expect(value, isNotEmpty);
        expect(value, isNot(key),
            reason: 'Missing $locale translation for "$key" (got the key back)');
      });
    }
  }
}
