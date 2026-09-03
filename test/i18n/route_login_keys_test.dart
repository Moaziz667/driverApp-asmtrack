import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';
import 'package:driver_app/generated/l10n/app_localizations_ar.dart';
import 'package:driver_app/generated/l10n/app_localizations_en.dart';
import 'package:driver_app/generated/l10n/app_localizations_fr.dart';

/// Proves the route-CTA and login copy keys (added/used by the route i18n pass
/// and the login redesign) exist and are actually translated in all 3 locales.
AppLocalizations _loc(String locale) {
  switch (locale) {
    case 'fr':
      return AppLocalizationsFr();
    case 'en':
      return AppLocalizationsEn();
    case 'ar':
      return AppLocalizationsAr();
    default:
      throw ArgumentError('Unknown locale: $locale');
  }
}

String _translate(String key, AppLocalizations loc) {
  switch (key) {
    case 'route_swipe_start':
      return loc.route_swipe_start;
    case 'route_swipe_load':
      return loc.route_swipe_load;
    case 'route_swipe_confirm_load':
      return loc.route_swipe_confirm_load;
    case 'route_all_stops_done':
      return loc.route_all_stops_done;
    case 'route_download_pdf':
      return loc.route_download_pdf;
    case 'route_navigate':
      return loc.route_navigate;
    case 'route_finished':
      return loc.route_finished;
    case 'route_stops_log':
      return loc.route_stops_log;
    case 'login_action_setup_sub':
      return loc.login_action_setup_sub;
    case 'login_action_change_workspace_sub':
      return loc.login_action_change_workspace_sub;
    case 'login_secure_sso':
      return loc.login_secure_sso;
    case 'login_version':
      return loc.login_version;
    case 'login_failed_error':
      return loc.login_failed_error;
    default:
      throw ArgumentError('Unknown key: $key');
  }
}

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
        final loc = _loc(locale);
        final value = _translate(key, loc);
        expect(
          value,
          isNotEmpty,
          reason: 'Empty translation for "$key" in $locale',
        );
        expect(
          value,
          isNot(key),
          reason: 'Missing $locale translation for "$key" (got the key back)',
        );
      });
    }
  }
}
