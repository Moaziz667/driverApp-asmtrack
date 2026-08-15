import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AsmTrack Driver'**
  String get appTitle;

  /// No description provided for @tabRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get tabRoute;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @offlineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline — actions will sync when connection is restored'**
  String get offlineBanner;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @statusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get statusOnline;

  /// No description provided for @status_on_break.
  ///
  /// In en, this message translates to:
  /// **'On Break'**
  String get status_on_break;

  /// No description provided for @status_offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get status_offline;

  /// No description provided for @status_online_upper.
  ///
  /// In en, this message translates to:
  /// **'ONLINE'**
  String get status_online_upper;

  /// No description provided for @status_on_break_upper.
  ///
  /// In en, this message translates to:
  /// **'ON BREAK'**
  String get status_on_break_upper;

  /// No description provided for @status_offline_upper.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE'**
  String get status_offline_upper;

  /// No description provided for @action_start_shift.
  ///
  /// In en, this message translates to:
  /// **'Start Shift'**
  String get action_start_shift;

  /// No description provided for @action_take_break.
  ///
  /// In en, this message translates to:
  /// **'Take a Break'**
  String get action_take_break;

  /// No description provided for @action_end_day.
  ///
  /// In en, this message translates to:
  /// **'End Workday'**
  String get action_end_day;

  /// No description provided for @action_resume_service.
  ///
  /// In en, this message translates to:
  /// **'Resume Service'**
  String get action_resume_service;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profile_title;

  /// No description provided for @driver_id.
  ///
  /// In en, this message translates to:
  /// **'Driver ID'**
  String get driver_id;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phone;

  /// No description provided for @last_ping.
  ///
  /// In en, this message translates to:
  /// **'Last Ping'**
  String get last_ping;

  /// No description provided for @gps.
  ///
  /// In en, this message translates to:
  /// **'GPS'**
  String get gps;

  /// No description provided for @section_availability.
  ///
  /// In en, this message translates to:
  /// **'AVAILABILITY'**
  String get section_availability;

  /// No description provided for @section_performance.
  ///
  /// In en, this message translates to:
  /// **'PERFORMANCE'**
  String get section_performance;

  /// No description provided for @section_account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get section_account;

  /// No description provided for @section_actions.
  ///
  /// In en, this message translates to:
  /// **'ACTIONS'**
  String get section_actions;

  /// No description provided for @language_setting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_setting;

  /// No description provided for @send_location.
  ///
  /// In en, this message translates to:
  /// **'Send my position'**
  String get send_location;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @profileChangePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get profileChangePhoto;

  /// No description provided for @profileTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get profileTakePhoto;

  /// No description provided for @profileChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get profileChooseGallery;

  /// No description provided for @profilePhotoCropTitle.
  ///
  /// In en, this message translates to:
  /// **'Crop Profile Photo'**
  String get profilePhotoCropTitle;

  /// No description provided for @profileSuccessRate.
  ///
  /// In en, this message translates to:
  /// **'Success rate'**
  String get profileSuccessRate;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile…'**
  String get profileLoading;

  /// No description provided for @profileUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable'**
  String get profileUnavailable;

  /// No description provided for @profileRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get profileRetry;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logout;

  /// No description provided for @logout_confirm_title.
  ///
  /// In en, this message translates to:
  /// **'Sign Out?'**
  String get logout_confirm_title;

  /// No description provided for @logout_confirm_body.
  ///
  /// In en, this message translates to:
  /// **'You will need to sign in again to access your deliveries.'**
  String get logout_confirm_body;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @position_sent.
  ///
  /// In en, this message translates to:
  /// **'Location sent to dispatcher.'**
  String get position_sent;

  /// No description provided for @profileUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Upload failed, try again'**
  String get profileUploadFailed;

  /// No description provided for @profilePhotoRequired.
  ///
  /// In en, this message translates to:
  /// **'Add your photo'**
  String get profilePhotoRequired;

  /// No description provided for @profilePhotoRequiredSub.
  ///
  /// In en, this message translates to:
  /// **'Required to continue. Visible to dispatch.'**
  String get profilePhotoRequiredSub;

  /// No description provided for @profilePhotoConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get profilePhotoConfirm;

  /// No description provided for @metric_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get metric_delivered;

  /// No description provided for @metric_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get metric_failed;

  /// No description provided for @metric_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get metric_total;

  /// No description provided for @ws_delivery_assigned.
  ///
  /// In en, this message translates to:
  /// **'Delivery assigned — {client}'**
  String ws_delivery_assigned(Object client);

  /// No description provided for @ws_new_delivery.
  ///
  /// In en, this message translates to:
  /// **'New delivery assigned'**
  String get ws_new_delivery;

  /// No description provided for @ws_delivery_removed.
  ///
  /// In en, this message translates to:
  /// **'Delivery removed — {client}'**
  String ws_delivery_removed(Object client);

  /// No description provided for @ws_delivery_removed_generic.
  ///
  /// In en, this message translates to:
  /// **'Delivery removed from your route'**
  String get ws_delivery_removed_generic;

  /// No description provided for @ws_route_assigned.
  ///
  /// In en, this message translates to:
  /// **'Route {route} assigned — please review before departure.'**
  String ws_route_assigned(Object route);

  /// No description provided for @ws_route_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Route {route} has been cancelled.'**
  String ws_route_cancelled(Object route);

  /// No description provided for @ws_route_reassigned_away.
  ///
  /// In en, this message translates to:
  /// **'Route {route} has been reassigned to another driver.'**
  String ws_route_reassigned_away(Object route);

  /// No description provided for @ws_route_reassigned_to_you.
  ///
  /// In en, this message translates to:
  /// **'Route {route} has been reassigned to you!'**
  String ws_route_reassigned_to_you(Object route);

  /// No description provided for @ws_stop_added.
  ///
  /// In en, this message translates to:
  /// **'{client} added to route {route}.'**
  String ws_stop_added(Object client, Object route);

  /// No description provided for @ws_pickup_overdue.
  ///
  /// In en, this message translates to:
  /// **'Pickup overdue — Depot {client} ({count}).'**
  String ws_pickup_overdue(Object client, Object count);

  /// No description provided for @ws_stop_removed.
  ///
  /// In en, this message translates to:
  /// **'{client}{ref} removed from route {route}{why}.'**
  String ws_stop_removed(Object client, Object ref, Object route, Object why);

  /// No description provided for @ws_route_updated.
  ///
  /// In en, this message translates to:
  /// **'Route {route} has been updated.'**
  String ws_route_updated(Object route);

  /// No description provided for @ws_stops_transferred_out.
  ///
  /// In en, this message translates to:
  /// **'Stops were removed from route {route}.'**
  String ws_stops_transferred_out(Object route);

  /// No description provided for @ws_stops_transferred_in.
  ///
  /// In en, this message translates to:
  /// **'New stops were added to route {route}.'**
  String ws_stops_transferred_in(Object route);

  /// No description provided for @ws_generic_route.
  ///
  /// In en, this message translates to:
  /// **'your route'**
  String get ws_generic_route;

  /// No description provided for @ws_handoff_incoming.
  ///
  /// In en, this message translates to:
  /// **'Pickup required — parcel {ref} from {name}'**
  String ws_handoff_incoming(Object name, Object ref);

  /// No description provided for @ws_handoff_outgoing.
  ///
  /// In en, this message translates to:
  /// **'To hand over — parcel {ref} to {name}'**
  String ws_handoff_outgoing(Object name, Object ref);

  /// No description provided for @ws_handoff_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Handover confirmed — parcel {ref}'**
  String ws_handoff_confirmed(Object ref);

  /// No description provided for @ws_handoff_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Handover cancelled — parcel {ref}'**
  String ws_handoff_cancelled(Object ref);

  /// No description provided for @ws_handoff_other.
  ///
  /// In en, this message translates to:
  /// **'a driver'**
  String get ws_handoff_other;

  /// No description provided for @handoff_action_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get handoff_action_scan;

  /// No description provided for @handoff_action_show.
  ///
  /// In en, this message translates to:
  /// **'Show code'**
  String get handoff_action_show;

  /// No description provided for @handoff_inbox_title.
  ///
  /// In en, this message translates to:
  /// **'My handoffs'**
  String get handoff_inbox_title;

  /// No description provided for @handoff_inbox_incoming.
  ///
  /// In en, this message translates to:
  /// **'To receive'**
  String get handoff_inbox_incoming;

  /// No description provided for @handoff_inbox_outgoing.
  ///
  /// In en, this message translates to:
  /// **'To hand over'**
  String get handoff_inbox_outgoing;

  /// No description provided for @handoff_inbox_from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get handoff_inbox_from;

  /// No description provided for @handoff_inbox_to.
  ///
  /// In en, this message translates to:
  /// **'Hand over to'**
  String get handoff_inbox_to;

  /// No description provided for @handoff_inbox_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No handoffs'**
  String get handoff_inbox_empty_title;

  /// No description provided for @handoff_inbox_empty_sub.
  ///
  /// In en, this message translates to:
  /// **'Parcel transfers will appear here.'**
  String get handoff_inbox_empty_sub;

  /// No description provided for @handoff_inbox_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load handoffs'**
  String get handoff_inbox_error;

  /// No description provided for @handoff_inbox_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get handoff_inbox_retry;

  /// No description provided for @handoff_manual_action.
  ///
  /// In en, this message translates to:
  /// **'Enter code'**
  String get handoff_manual_action;

  /// No description provided for @handoff_manual_title.
  ///
  /// In en, this message translates to:
  /// **'Transfer code'**
  String get handoff_manual_title;

  /// No description provided for @handoff_manual_hint.
  ///
  /// In en, this message translates to:
  /// **'ABC123'**
  String get handoff_manual_hint;

  /// No description provided for @handoff_manual_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get handoff_manual_confirm;

  /// No description provided for @handoff_manual_success.
  ///
  /// In en, this message translates to:
  /// **'Transfer confirmed'**
  String get handoff_manual_success;

  /// No description provided for @handoff_manual_error.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code'**
  String get handoff_manual_error;

  /// No description provided for @splash_sub.
  ///
  /// In en, this message translates to:
  /// **'Logistics management'**
  String get splash_sub;

  /// No description provided for @splash_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get splash_loading;

  /// No description provided for @splash_copyright.
  ///
  /// In en, this message translates to:
  /// **'(c) 2026 ASM Logistics Operations'**
  String get splash_copyright;

  /// No description provided for @login_driver_space.
  ///
  /// In en, this message translates to:
  /// **'AsmTrack Driver'**
  String get login_driver_space;

  /// No description provided for @login_secure_access.
  ///
  /// In en, this message translates to:
  /// **'Secure Access'**
  String get login_secure_access;

  /// No description provided for @login_auth_header.
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get login_auth_header;

  /// No description provided for @login_auth_desc.
  ///
  /// In en, this message translates to:
  /// **'You will be redirected to the secure login page to authenticate.'**
  String get login_auth_desc;

  /// No description provided for @login_action_connect.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login_action_connect;

  /// No description provided for @login_action_connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get login_action_connecting;

  /// No description provided for @login_action_setup.
  ///
  /// In en, this message translates to:
  /// **'Configure my account'**
  String get login_action_setup;

  /// No description provided for @login_action_change_workspace.
  ///
  /// In en, this message translates to:
  /// **'Change workspace'**
  String get login_action_change_workspace;

  /// No description provided for @login_action_setup_sub.
  ///
  /// In en, this message translates to:
  /// **'First time · set your password'**
  String get login_action_setup_sub;

  /// No description provided for @login_action_change_workspace_sub.
  ///
  /// In en, this message translates to:
  /// **'Connect to a different server'**
  String get login_action_change_workspace_sub;

  /// No description provided for @login_secure_sso.
  ///
  /// In en, this message translates to:
  /// **'Secure sign-in · ASM Track'**
  String get login_secure_sso;

  /// No description provided for @login_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get login_version;

  /// No description provided for @login_failed_error.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Check your credentials.'**
  String get login_failed_error;

  /// No description provided for @loginServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get loginServerUrl;

  /// No description provided for @loginServerUrlHint.
  ///
  /// In en, this message translates to:
  /// **'http://192.168.1.10  (local)  ·  https://dev.asm…'**
  String get loginServerUrlHint;

  /// No description provided for @loginServerUrlDesc.
  ///
  /// In en, this message translates to:
  /// **'Authentication follows this host automatically.'**
  String get loginServerUrlDesc;

  /// No description provided for @loginServerUrlInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL (e.g. http://192.168.1.10)'**
  String get loginServerUrlInvalid;

  /// No description provided for @loginServerSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get loginServerSave;

  /// No description provided for @loginServerCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get loginServerCancel;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @route_swipe_start.
  ///
  /// In en, this message translates to:
  /// **'Swipe to start the route'**
  String get route_swipe_start;

  /// No description provided for @route_swipe_load.
  ///
  /// In en, this message translates to:
  /// **'Swipe to load'**
  String get route_swipe_load;

  /// No description provided for @route_swipe_confirm_load.
  ///
  /// In en, this message translates to:
  /// **'Swipe to confirm loading'**
  String get route_swipe_confirm_load;

  /// No description provided for @route_all_stops_done.
  ///
  /// In en, this message translates to:
  /// **'All stops completed'**
  String get route_all_stops_done;

  /// No description provided for @route_download_pdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get route_download_pdf;

  /// No description provided for @route_navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get route_navigate;

  /// No description provided for @route_finished.
  ///
  /// In en, this message translates to:
  /// **'Route completed'**
  String get route_finished;

  /// No description provided for @route_stops_log.
  ///
  /// In en, this message translates to:
  /// **'Stops log'**
  String get route_stops_log;

  /// No description provided for @route_load_parcels.
  ///
  /// In en, this message translates to:
  /// **'Load {count} parcels — Depot {depot}'**
  String route_load_parcels(Object count, Object depot);

  /// No description provided for @route_no_stops.
  ///
  /// In en, this message translates to:
  /// **'No stops configured.'**
  String get route_no_stops;

  /// No description provided for @route_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No active route'**
  String get route_empty_title;

  /// No description provided for @route_empty_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Your route will appear here once assigned by dispatch.'**
  String get route_empty_subtitle;

  /// No description provided for @routeRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get routeRefresh;

  /// No description provided for @routeStops.
  ///
  /// In en, this message translates to:
  /// **'STOPS'**
  String get routeStops;

  /// No description provided for @routeStop.
  ///
  /// In en, this message translates to:
  /// **'stop'**
  String get routeStop;

  /// No description provided for @routeStopsCount.
  ///
  /// In en, this message translates to:
  /// **'stops'**
  String get routeStopsCount;

  /// No description provided for @routeConfirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery'**
  String get routeConfirmDelivery;

  /// No description provided for @routeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading route…'**
  String get routeLoading;

  /// No description provided for @delivery_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get delivery_detail_title;

  /// No description provided for @return_pickup_badge.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get return_pickup_badge;

  /// No description provided for @return_pickup_title.
  ///
  /// In en, this message translates to:
  /// **'Return collection'**
  String get return_pickup_title;

  /// No description provided for @delivery_detail_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading delivery...'**
  String get delivery_detail_loading;

  /// No description provided for @delivery_detail_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get delivery_detail_load_failed;

  /// No description provided for @delivery_detail_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get delivery_detail_retry;

  /// No description provided for @delivery_detail_fail_report.
  ///
  /// In en, this message translates to:
  /// **'Report failure'**
  String get delivery_detail_fail_report;

  /// No description provided for @delivery_detail_fail_select.
  ///
  /// In en, this message translates to:
  /// **'Select the reason for failure.'**
  String get delivery_detail_fail_select;

  /// No description provided for @delivery_detail_comment_hint.
  ///
  /// In en, this message translates to:
  /// **'Additional comment (optional)'**
  String get delivery_detail_comment_hint;

  /// No description provided for @delivery_detail_fail_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit failure report'**
  String get delivery_detail_fail_submit;

  /// No description provided for @delivery_detail_pod_title.
  ///
  /// In en, this message translates to:
  /// **'Proof of Delivery'**
  String get delivery_detail_pod_title;

  /// No description provided for @delivery_detail_fail_reason.
  ///
  /// In en, this message translates to:
  /// **'Failure reason'**
  String get delivery_detail_fail_reason;

  /// No description provided for @delivery_detail_cancel_reason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get delivery_detail_cancel_reason;

  /// No description provided for @delivery_detail_history_title.
  ///
  /// In en, this message translates to:
  /// **'Status History'**
  String get delivery_detail_history_title;

  /// No description provided for @delivery_detail_articles.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get delivery_detail_articles;

  /// No description provided for @delivery_detail_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get delivery_detail_scheduled;

  /// No description provided for @delivery_detail_content.
  ///
  /// In en, this message translates to:
  /// **'Package content'**
  String get delivery_detail_content;

  /// No description provided for @delivery_detail_timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get delivery_detail_timeline;

  /// No description provided for @delivery_detail_ts_scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get delivery_detail_ts_scheduled;

  /// No description provided for @delivery_detail_ts_picked_up.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get delivery_detail_ts_picked_up;

  /// No description provided for @delivery_detail_ts_in_transit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get delivery_detail_ts_in_transit;

  /// No description provided for @delivery_detail_ts_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivery_detail_ts_delivered;

  /// No description provided for @delivery_detail_ts_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get delivery_detail_ts_failed;

  /// No description provided for @delivery_detail_ts_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get delivery_detail_ts_cancelled;

  /// No description provided for @delivery_detail_ts_created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get delivery_detail_ts_created;

  /// No description provided for @delivery_detail_pending_dispatch.
  ///
  /// In en, this message translates to:
  /// **'Waiting for dispatch'**
  String get delivery_detail_pending_dispatch;

  /// No description provided for @delivery_detail_pickup_package.
  ///
  /// In en, this message translates to:
  /// **'Collect package'**
  String get delivery_detail_pickup_package;

  /// No description provided for @delivery_detail_navigate.
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get delivery_detail_navigate;

  /// No description provided for @delivery_detail_start_transit.
  ///
  /// In en, this message translates to:
  /// **'Start journey'**
  String get delivery_detail_start_transit;

  /// No description provided for @delivery_detail_generate_handoff.
  ///
  /// In en, this message translates to:
  /// **'Generate transfer code'**
  String get delivery_detail_generate_handoff;

  /// No description provided for @delivery_detail_submit_pod.
  ///
  /// In en, this message translates to:
  /// **'Submit proof of delivery'**
  String get delivery_detail_submit_pod;

  /// No description provided for @delivery_detail_collect_return.
  ///
  /// In en, this message translates to:
  /// **'Collect parcel'**
  String get delivery_detail_collect_return;

  /// No description provided for @delivery_detail_confirm_collection.
  ///
  /// In en, this message translates to:
  /// **'Confirm collection'**
  String get delivery_detail_confirm_collection;

  /// No description provided for @delivery_detail_locked.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get delivery_detail_locked;

  /// No description provided for @delivery_detail_offline_queue.
  ///
  /// In en, this message translates to:
  /// **'Offline — will be sent on reconnect'**
  String get delivery_detail_offline_queue;

  /// No description provided for @delivery_detail_error_prefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get delivery_detail_error_prefix;

  /// No description provided for @delivery_detail_unauthorized_link.
  ///
  /// In en, this message translates to:
  /// **'This delivery is not assigned to you.'**
  String get delivery_detail_unauthorized_link;

  /// No description provided for @deliveryItem.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get deliveryItem;

  /// No description provided for @deliveryItems.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get deliveryItems;

  /// No description provided for @deliveryOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get deliveryOpen;

  /// No description provided for @deliveryOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get deliveryOrder;

  /// No description provided for @deliveryPackageTransferred.
  ///
  /// In en, this message translates to:
  /// **'Package transferred to you'**
  String get deliveryPackageTransferred;

  /// No description provided for @deliveryHandoffScanHint.
  ///
  /// In en, this message translates to:
  /// **'When you receive it, scan the sender driver\'s QR to confirm. You can keep working in the meantime.'**
  String get deliveryHandoffScanHint;

  /// No description provided for @deliveryScanSenderQr.
  ///
  /// In en, this message translates to:
  /// **'Scan sender\'s QR'**
  String get deliveryScanSenderQr;

  /// No description provided for @pod_title.
  ///
  /// In en, this message translates to:
  /// **'Proof of Delivery'**
  String get pod_title;

  /// No description provided for @pod_pdf_open_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot open PDF. No PDF viewer application installed.'**
  String get pod_pdf_open_error;

  /// No description provided for @pod_pdf_download_error.
  ///
  /// In en, this message translates to:
  /// **'Error downloading delivery note.'**
  String get pod_pdf_download_error;

  /// No description provided for @pod_step_1.
  ///
  /// In en, this message translates to:
  /// **'1. Print the delivery note and have the customer sign it.'**
  String get pod_step_1;

  /// No description provided for @pod_step_2.
  ///
  /// In en, this message translates to:
  /// **'2. Take a photo of the signed note.'**
  String get pod_step_2;

  /// No description provided for @pod_step_3.
  ///
  /// In en, this message translates to:
  /// **'3. Take a photo of the package handover.'**
  String get pod_step_3;

  /// No description provided for @pod_view_print_bl.
  ///
  /// In en, this message translates to:
  /// **'View / Print Delivery Note'**
  String get pod_view_print_bl;

  /// No description provided for @pod_downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading...'**
  String get pod_downloading;

  /// No description provided for @pod_photo_bl_title.
  ///
  /// In en, this message translates to:
  /// **'Signed Delivery Note'**
  String get pod_photo_bl_title;

  /// No description provided for @pod_photo_bl_sub.
  ///
  /// In en, this message translates to:
  /// **'Photograph the note signed by the customer'**
  String get pod_photo_bl_sub;

  /// No description provided for @pod_amend_note_title.
  ///
  /// In en, this message translates to:
  /// **'Amend the note before photographing'**
  String get pod_amend_note_title;

  /// No description provided for @pod_amend_note_body.
  ///
  /// In en, this message translates to:
  /// **'The note was printed with the ordered quantities. Strike them through, write the quantities actually handed over, and have the customer sign the correction.'**
  String get pod_amend_note_body;

  /// No description provided for @pod_photo_pkg_title.
  ///
  /// In en, this message translates to:
  /// **'Package Handover'**
  String get pod_photo_pkg_title;

  /// No description provided for @pod_photo_pkg_sub.
  ///
  /// In en, this message translates to:
  /// **'Photograph the package at the moment of handover'**
  String get pod_photo_pkg_sub;

  /// No description provided for @pod_photo_take.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get pod_photo_take;

  /// No description provided for @pod_photo_retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get pod_photo_retake;

  /// No description provided for @pod_photo_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get pod_photo_delete;

  /// No description provided for @pod_photo_tap_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap to take photo'**
  String get pod_photo_tap_hint;

  /// No description provided for @pod_photo_access_error.
  ///
  /// In en, this message translates to:
  /// **'Cannot access camera.'**
  String get pod_photo_access_error;

  /// No description provided for @pod_comments_label.
  ///
  /// In en, this message translates to:
  /// **'Comments (door code, receiver name, etc.)'**
  String get pod_comments_label;

  /// No description provided for @pod_gps_label.
  ///
  /// In en, this message translates to:
  /// **'Attach GPS location'**
  String get pod_gps_label;

  /// No description provided for @pod_gps_sub.
  ///
  /// In en, this message translates to:
  /// **'Coordinates sent only once at submission.'**
  String get pod_gps_sub;

  /// No description provided for @pod_partial_label.
  ///
  /// In en, this message translates to:
  /// **'Partial delivery'**
  String get pod_partial_label;

  /// No description provided for @pod_partial_sub.
  ///
  /// In en, this message translates to:
  /// **'Enable if some items were not delivered.'**
  String get pod_partial_sub;

  /// No description provided for @pod_partial_bl_cleared.
  ///
  /// In en, this message translates to:
  /// **'Delivery-note photo removed: take it again with the corrected quantities.'**
  String get pod_partial_bl_cleared;

  /// No description provided for @pod_item_outcome_header.
  ///
  /// In en, this message translates to:
  /// **'Outcome per item:'**
  String get pod_item_outcome_header;

  /// No description provided for @pod_delivered_qty.
  ///
  /// In en, this message translates to:
  /// **'Delivered quantity'**
  String get pod_delivered_qty;

  /// No description provided for @pod_reason_label.
  ///
  /// In en, this message translates to:
  /// **'Reason *'**
  String get pod_reason_label;

  /// No description provided for @pod_reason_partial.
  ///
  /// In en, this message translates to:
  /// **'Reason — partial delivery *'**
  String get pod_reason_partial;

  /// No description provided for @pod_item_comment_hint.
  ///
  /// In en, this message translates to:
  /// **'Comment on this item (optional)'**
  String get pod_item_comment_hint;

  /// No description provided for @pod_reason_mandatory.
  ///
  /// In en, this message translates to:
  /// **'Reason mandatory for:'**
  String get pod_reason_mandatory;

  /// No description provided for @pod_photos_mandatory.
  ///
  /// In en, this message translates to:
  /// **'Both photos are mandatory.'**
  String get pod_photos_mandatory;

  /// No description provided for @pod_confirm_delivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm delivery'**
  String get pod_confirm_delivery;

  /// No description provided for @pod_success_message.
  ///
  /// In en, this message translates to:
  /// **'POD submitted successfully.'**
  String get pod_success_message;

  /// No description provided for @podCameraTake.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get podCameraTake;

  /// No description provided for @podGalleryChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get podGalleryChoose;

  /// No description provided for @podComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get podComment;

  /// No description provided for @podCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get podCommentOptional;

  /// No description provided for @calendarRoutes.
  ///
  /// In en, this message translates to:
  /// **'Routes'**
  String get calendarRoutes;

  /// No description provided for @calendarRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get calendarRoute;

  /// No description provided for @calendarStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get calendarStops;

  /// No description provided for @calendarDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get calendarDelivered;

  /// No description provided for @calendarAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get calendarAmount;

  /// No description provided for @calendarRouteCancelled.
  ///
  /// In en, this message translates to:
  /// **'Route cancelled'**
  String get calendarRouteCancelled;

  /// No description provided for @calendarItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get calendarItems;

  /// No description provided for @calendarLoadItemsError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load items'**
  String get calendarLoadItemsError;

  /// No description provided for @calendarNoItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get calendarNoItems;

  /// No description provided for @calendarOpenRoute.
  ///
  /// In en, this message translates to:
  /// **'Open route'**
  String get calendarOpenRoute;

  /// No description provided for @handoffScannerScanSenderQr.
  ///
  /// In en, this message translates to:
  /// **'Scan sender\'s QR'**
  String get handoffScannerScanSenderQr;

  /// No description provided for @handoffScannerAlignHint.
  ///
  /// In en, this message translates to:
  /// **'Align the sender driver\'s QR code in the frame to confirm the transfer of responsibility.'**
  String get handoffScannerAlignHint;

  /// No description provided for @handoffScannerHoldAligned.
  ///
  /// In en, this message translates to:
  /// **'Hold the code steady…'**
  String get handoffScannerHoldAligned;

  /// No description provided for @handoffScannerReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get handoffScannerReading;

  /// No description provided for @handoffScannerValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating transfer…'**
  String get handoffScannerValidating;

  /// No description provided for @handoffScannerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer confirmed'**
  String get handoffScannerSuccess;

  /// No description provided for @handoffScannerSuccessBody.
  ///
  /// In en, this message translates to:
  /// **'The package has been transferred to you.'**
  String get handoffScannerSuccessBody;

  /// No description provided for @handoffScannerInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a valid transfer token.'**
  String get handoffScannerInvalidQr;

  /// No description provided for @handoffScannerExpired.
  ///
  /// In en, this message translates to:
  /// **'This token has expired. Ask the sender to generate a new one.'**
  String get handoffScannerExpired;

  /// No description provided for @handoffScannerUsed.
  ///
  /// In en, this message translates to:
  /// **'Invalid or already-used token. Try a new code.'**
  String get handoffScannerUsed;

  /// No description provided for @handoffScannerNotForYou.
  ///
  /// In en, this message translates to:
  /// **'This transfer is not addressed to you.'**
  String get handoffScannerNotForYou;

  /// No description provided for @handoffScannerUpdated.
  ///
  /// In en, this message translates to:
  /// **'This transfer was just updated. Refresh and try again.'**
  String get handoffScannerUpdated;

  /// No description provided for @handoffScannerNetworkError.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get handoffScannerNetworkError;

  /// No description provided for @handoffScannerFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed. Please try again.'**
  String get handoffScannerFailed;

  /// No description provided for @handoffScannerCameraDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access denied'**
  String get handoffScannerCameraDenied;

  /// No description provided for @handoffScannerCameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get handoffScannerCameraUnavailable;

  /// No description provided for @handoffScannerCameraDeniedHint.
  ///
  /// In en, this message translates to:
  /// **'Allow camera access in settings to scan transfers.'**
  String get handoffScannerCameraDeniedHint;

  /// No description provided for @handoffScannerCameraError.
  ///
  /// In en, this message translates to:
  /// **'Could not start the camera. Try again later.'**
  String get handoffScannerCameraError;

  /// No description provided for @handoffTokenUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to generate a token for this package.'**
  String get handoffTokenUnauthorized;

  /// No description provided for @handoffTokenNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending transfer for this package. Refresh and try again.'**
  String get handoffTokenNoPending;

  /// No description provided for @handoffTokenNetworkError.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get handoffTokenNetworkError;

  /// No description provided for @handoffTokenGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not generate the token. Please try again.'**
  String get handoffTokenGenerateFailed;

  /// No description provided for @handoffTokenAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer authentication'**
  String get handoffTokenAuthTitle;

  /// No description provided for @handoffTokenAuthHint.
  ///
  /// In en, this message translates to:
  /// **'Ask the other driver to scan this code to confirm the transfer of responsibility.'**
  String get handoffTokenAuthHint;

  /// No description provided for @handoffTokenGenerating.
  ///
  /// In en, this message translates to:
  /// **'Generating secure token…'**
  String get handoffTokenGenerating;

  /// No description provided for @handoffTokenClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get handoffTokenClose;

  /// No description provided for @handoffTokenTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Token: '**
  String get handoffTokenTokenLabel;

  /// No description provided for @handoffTokenExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in 5 minutes'**
  String get handoffTokenExpiresIn;

  /// No description provided for @handoffTokenExpiresInFormat.
  ///
  /// In en, this message translates to:
  /// **'Expires in MM:SS'**
  String get handoffTokenExpiresInFormat;

  /// No description provided for @handoffTokenExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired.'**
  String get handoffTokenExpired;

  /// No description provided for @handoffTokenGenerateNew.
  ///
  /// In en, this message translates to:
  /// **'Generate a new code'**
  String get handoffTokenGenerateNew;

  /// No description provided for @handoffTokenRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get handoffTokenRetry;

  /// No description provided for @historyLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading history…'**
  String get historyLoading;

  /// No description provided for @historyOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline history'**
  String get historyOfflineTitle;

  /// No description provided for @historyRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get historyRetry;

  /// No description provided for @historyOrder.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get historyOrder;

  /// No description provided for @historyArticles.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get historyArticles;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(Object minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(Object hours);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(Object days);

  /// No description provided for @offlinePendingUpdates.
  ///
  /// In en, this message translates to:
  /// **'pending updates'**
  String get offlinePendingUpdates;

  /// No description provided for @offlineConnectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Connection restored · Syncing data…'**
  String get offlineConnectionRestored;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Driver registration'**
  String get registerSubtitle;

  /// No description provided for @registerFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get registerFullName;

  /// No description provided for @registerRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get registerRequired;

  /// No description provided for @registerPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get registerPhoneLabel;

  /// No description provided for @registerPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPassword;

  /// No description provided for @registerMinChars.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get registerMinChars;

  /// No description provided for @registerSubmitting.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registerSubmitting;

  /// No description provided for @registerCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccount;

  /// No description provided for @registerHasAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHasAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignIn;

  /// No description provided for @setupEnterCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your activation code'**
  String get setupEnterCode;

  /// No description provided for @setupServerError.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable — check your connection'**
  String get setupServerError;

  /// No description provided for @setupCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Code not found — contact your manager'**
  String get setupCodeNotFound;

  /// No description provided for @setupCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'Code expired — request a new code'**
  String get setupCodeExpired;

  /// No description provided for @setupCodeUsed.
  ///
  /// In en, this message translates to:
  /// **'This code has already been used'**
  String get setupCodeUsed;

  /// No description provided for @setupCodeInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid code format (UUID expected)'**
  String get setupCodeInvalidFormat;

  /// No description provided for @setupCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code'**
  String get setupCodeInvalid;

  /// No description provided for @setupEnterPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get setupEnterPhone;

  /// No description provided for @setupCodeSent.
  ///
  /// In en, this message translates to:
  /// **'An activation code has been sent by email.'**
  String get setupCodeSent;

  /// No description provided for @setupCodeResent.
  ///
  /// In en, this message translates to:
  /// **'A new activation code has been sent by email.'**
  String get setupCodeResent;

  /// No description provided for @setupPhoneNotFound.
  ///
  /// In en, this message translates to:
  /// **'Phone not found or already activated'**
  String get setupPhoneNotFound;

  /// No description provided for @setupAccountActivated.
  ///
  /// In en, this message translates to:
  /// **'Account activated! Sign in with your phone number.'**
  String get setupAccountActivated;

  /// No description provided for @setupActivationFailed.
  ///
  /// In en, this message translates to:
  /// **'Activation failed. Check your code and try again.'**
  String get setupActivationFailed;

  /// No description provided for @setupSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get setupSignIn;

  /// No description provided for @setupConfigureAccount.
  ///
  /// In en, this message translates to:
  /// **'Configure my account'**
  String get setupConfigureAccount;

  /// No description provided for @setupActivationTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver activation'**
  String get setupActivationTitle;

  /// No description provided for @setupActivationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the activation code received by email, then choose your password.'**
  String get setupActivationSubtitle;

  /// No description provided for @setupActivationCode.
  ///
  /// In en, this message translates to:
  /// **'Activation code'**
  String get setupActivationCode;

  /// No description provided for @setupValidateCode.
  ///
  /// In en, this message translates to:
  /// **'Validate code'**
  String get setupValidateCode;

  /// No description provided for @setupNoCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get setupNoCode;

  /// No description provided for @setupYourPhone.
  ///
  /// In en, this message translates to:
  /// **'Your phone'**
  String get setupYourPhone;

  /// No description provided for @setupResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get setupResendCode;

  /// No description provided for @setupWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String setupWelcome(Object name);

  /// No description provided for @setupPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get setupPassword;

  /// No description provided for @setupPasswordMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get setupPasswordMin;

  /// No description provided for @setupConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get setupConfirmPassword;

  /// No description provided for @setupConfirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat your password'**
  String get setupConfirmPasswordHint;

  /// No description provided for @setupPasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get setupPasswordMismatch;

  /// No description provided for @setupActivating.
  ///
  /// In en, this message translates to:
  /// **'Activating...'**
  String get setupActivating;

  /// No description provided for @setupActivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Activate my account'**
  String get setupActivateAccount;

  /// No description provided for @setupNoCodeReceived.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get setupNoCodeReceived;

  /// No description provided for @setupPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Your phone'**
  String get setupPhoneHint;

  /// No description provided for @monthJanuary.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get monthJanuary;

  /// No description provided for @monthFebruary.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get monthFebruary;

  /// No description provided for @monthMarch.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get monthMarch;

  /// No description provided for @monthApril.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get monthApril;

  /// No description provided for @monthMay.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get monthMay;

  /// No description provided for @monthJune.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get monthJune;

  /// No description provided for @monthJuly.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get monthJuly;

  /// No description provided for @monthAugust.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get monthAugust;

  /// No description provided for @monthSeptember.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get monthSeptember;

  /// No description provided for @monthOctober.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get monthOctober;

  /// No description provided for @monthNovember.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get monthNovember;

  /// No description provided for @monthDecember.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get monthDecember;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get daySunday;

  /// No description provided for @calendarToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarToday;

  /// No description provided for @calendarTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get calendarTomorrow;

  /// No description provided for @calendarClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get calendarClose;

  /// No description provided for @calendarClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get calendarClient;

  /// No description provided for @statusUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get statusUnscheduled;

  /// No description provided for @statusScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduled;

  /// No description provided for @statusPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get statusPickedUp;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get statusPartial;

  /// No description provided for @statusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailed;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @calendarWeek.
  ///
  /// In en, this message translates to:
  /// **'Week {week}'**
  String calendarWeek(Object week);

  /// No description provided for @calendarRouteCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Route cancelled'**
  String get calendarRouteCancelledTitle;

  /// No description provided for @calendarRouteCancelledBody.
  ///
  /// In en, this message translates to:
  /// **'Route {name} has been cancelled by dispatch.'**
  String calendarRouteCancelledBody(Object name);

  /// No description provided for @calendarNoRoutes.
  ///
  /// In en, this message translates to:
  /// **'No routes'**
  String get calendarNoRoutes;

  /// No description provided for @calendarLoadRoutesError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load routes'**
  String get calendarLoadRoutesError;

  /// No description provided for @calendarCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again.'**
  String get calendarCheckConnection;

  /// No description provided for @statusScheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusScheduledLabel;

  /// No description provided for @statusPickedUpLabel.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get statusPickedUpLabel;

  /// No description provided for @statusPickedUpReturn.
  ///
  /// In en, this message translates to:
  /// **'Parcel collected'**
  String get statusPickedUpReturn;

  /// No description provided for @statusInTransitLabel.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransitLabel;

  /// No description provided for @statusAwaitingHandoff.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Handoff'**
  String get statusAwaitingHandoff;

  /// No description provided for @statusDeliveredLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDeliveredLabel;

  /// No description provided for @statusDeliveredReturn.
  ///
  /// In en, this message translates to:
  /// **'Received at depot'**
  String get statusDeliveredReturn;

  /// No description provided for @statusPartiallyDelivered.
  ///
  /// In en, this message translates to:
  /// **'Partially delivered'**
  String get statusPartiallyDelivered;

  /// No description provided for @statusFailedLabel.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusFailedLabel;

  /// No description provided for @statusCancelledLabel.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelledLabel;

  /// No description provided for @routeStatusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get routeStatusDraft;

  /// No description provided for @routeStatusValidated.
  ///
  /// In en, this message translates to:
  /// **'Validated'**
  String get routeStatusValidated;

  /// No description provided for @routeStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get routeStatusInProgress;

  /// No description provided for @routeStatusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get routeStatusClosed;

  /// No description provided for @routeStatusCancelledR.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get routeStatusCancelledR;

  /// No description provided for @stopStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get stopStatusPending;

  /// No description provided for @stopStatusArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived'**
  String get stopStatusArrived;

  /// No description provided for @stopStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get stopStatusCompleted;

  /// No description provided for @stopStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get stopStatusFailed;

  /// No description provided for @stopStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get stopStatusPartial;

  /// No description provided for @routeDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get routeDefaultName;

  /// No description provided for @reasonClientAbsent.
  ///
  /// In en, this message translates to:
  /// **'Client absent'**
  String get reasonClientAbsent;

  /// No description provided for @reasonClientRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused by client'**
  String get reasonClientRefused;

  /// No description provided for @reasonWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong address'**
  String get reasonWrongAddress;

  /// No description provided for @reasonPackageDamaged.
  ///
  /// In en, this message translates to:
  /// **'Package damaged'**
  String get reasonPackageDamaged;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reasonOther;

  /// No description provided for @podOutcomeDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get podOutcomeDelivered;

  /// No description provided for @podOutcomeRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get podOutcomeRefused;

  /// No description provided for @podOutcomeDamaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get podOutcomeDamaged;

  /// No description provided for @podOutcomeMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get podOutcomeMissing;

  /// No description provided for @podNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get podNotesTitle;

  /// No description provided for @podNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get podNotesHint;

  /// No description provided for @routeTimeFrom.
  ///
  /// In en, this message translates to:
  /// **'From {time}'**
  String routeTimeFrom(Object time);

  /// No description provided for @routeTimeBefore.
  ///
  /// In en, this message translates to:
  /// **'Before {time}'**
  String routeTimeBefore(Object time);

  /// No description provided for @routeStopCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stops'**
  String routeStopCount(Object count);

  /// No description provided for @routeStopCountSingular.
  ///
  /// In en, this message translates to:
  /// **'{count} stop'**
  String routeStopCountSingular(Object count);

  /// No description provided for @routeSwipeStartHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to start route'**
  String get routeSwipeStartHint;

  /// No description provided for @routeSwipeLoadHint.
  ///
  /// In en, this message translates to:
  /// **'Swipe to load'**
  String get routeSwipeLoadHint;

  /// No description provided for @routeStopsHeader.
  ///
  /// In en, this message translates to:
  /// **'STOPS'**
  String get routeStopsHeader;

  /// No description provided for @routeAllStopsDone.
  ///
  /// In en, this message translates to:
  /// **'All stops completed'**
  String get routeAllStopsDone;

  /// No description provided for @routeFinishedLabel.
  ///
  /// In en, this message translates to:
  /// **'Route completed'**
  String get routeFinishedLabel;

  /// No description provided for @routeOfflineBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline mode — cached data'**
  String get routeOfflineBanner;

  /// No description provided for @routeConfirmPickup.
  ///
  /// In en, this message translates to:
  /// **'Confirm loading at depot first'**
  String get routeConfirmPickup;

  /// No description provided for @routeLoadingRoute.
  ///
  /// In en, this message translates to:
  /// **'Loading route...'**
  String get routeLoadingRoute;

  /// No description provided for @routeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load route'**
  String get routeLoadError;

  /// No description provided for @routeRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get routeRetry;

  /// No description provided for @routeInfoDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get routeInfoDate;

  /// No description provided for @routeInfoSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get routeInfoSchedule;

  /// No description provided for @routeInfoZone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get routeInfoZone;

  /// No description provided for @routeInfoCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get routeInfoCity;

  /// No description provided for @routeInfoStops.
  ///
  /// In en, this message translates to:
  /// **'Stops'**
  String get routeInfoStops;

  /// No description provided for @routeInfoVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get routeInfoVehicle;

  /// No description provided for @routeNoStopsConfigured.
  ///
  /// In en, this message translates to:
  /// **'No stops configured.'**
  String get routeNoStopsConfigured;

  /// No description provided for @routePickupLabel.
  ///
  /// In en, this message translates to:
  /// **'Loading — Depot {depot}'**
  String routePickupLabel(Object depot);

  /// No description provided for @historyOffline.
  ///
  /// In en, this message translates to:
  /// **'History offline'**
  String get historyOffline;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get historyEmpty;

  /// No description provided for @historyEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Completed deliveries will appear here.'**
  String get historyEmptySubtitle;

  /// No description provided for @historySectionTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historySectionTitle;

  /// No description provided for @historyRecordCount.
  ///
  /// In en, this message translates to:
  /// **'{count} records'**
  String historyRecordCount(Object count);

  /// No description provided for @historyFilterDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date...'**
  String get historyFilterDate;

  /// No description provided for @historyNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address'**
  String get historyNoAddress;

  /// No description provided for @historyItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get historyItems;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get filterDelivered;

  /// No description provided for @filterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get filterFailed;

  /// No description provided for @filterCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get filterCancelled;

  /// No description provided for @routeOfflineAction.
  ///
  /// In en, this message translates to:
  /// **'Offline — will be sent on reconnection'**
  String get routeOfflineAction;

  /// No description provided for @routeErrorSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String routeErrorSnackbar(Object error);

  /// No description provided for @routeOfflineUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available offline'**
  String get routeOfflineUnavailable;

  /// No description provided for @routePdfFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF download failed'**
  String get routePdfFailed;

  /// No description provided for @routeGenerateQr.
  ///
  /// In en, this message translates to:
  /// **'Generate QR'**
  String get routeGenerateQr;

  /// No description provided for @routeScanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get routeScanQr;

  /// No description provided for @routeScannerOffline.
  ///
  /// In en, this message translates to:
  /// **'Scanner unavailable offline'**
  String get routeScannerOffline;

  /// No description provided for @deliveryNoAddress.
  ///
  /// In en, this message translates to:
  /// **'No address provided'**
  String get deliveryNoAddress;

  /// No description provided for @statusHistoryDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusHistoryDelivered;

  /// No description provided for @statusHistoryPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get statusHistoryPartial;

  /// No description provided for @statusHistoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get statusHistoryFailed;

  /// No description provided for @statusHistoryCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusHistoryCancelled;

  /// No description provided for @statusHistoryInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusHistoryInTransit;

  /// No description provided for @statusHistoryPickedUp.
  ///
  /// In en, this message translates to:
  /// **'Picked Up'**
  String get statusHistoryPickedUp;

  /// No description provided for @statusHistoryScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get statusHistoryScheduled;

  /// No description provided for @statusHistoryUnscheduled.
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get statusHistoryUnscheduled;

  /// No description provided for @statusHistoryAwaitingHandoff.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Handoff'**
  String get statusHistoryAwaitingHandoff;

  /// No description provided for @statusHistoryUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusHistoryUnknown;

  /// No description provided for @handoffTransferredToYou.
  ///
  /// In en, this message translates to:
  /// **'Package transferred to you'**
  String get handoffTransferredToYou;

  /// No description provided for @handoffScanInstructions.
  ///
  /// In en, this message translates to:
  /// **'At reception, scan the sender driver\'s QR to confirm.'**
  String get handoffScanInstructions;

  /// No description provided for @handoffScanSenderQr.
  ///
  /// In en, this message translates to:
  /// **'Scan sender\'s QR'**
  String get handoffScanSenderQr;

  /// No description provided for @bonLivraisonOffline.
  ///
  /// In en, this message translates to:
  /// **'Not available offline'**
  String get bonLivraisonOffline;

  /// No description provided for @bonLivraisonOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get bonLivraisonOpen;

  /// No description provided for @handoffUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'You are not authorized to generate a token for this package.'**
  String get handoffUnauthorized;

  /// No description provided for @handoffNoTransfer.
  ///
  /// In en, this message translates to:
  /// **'No pending transfer for this package. Refresh and try again.'**
  String get handoffNoTransfer;

  /// No description provided for @handoffConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection failed. Check your network and try again.'**
  String get handoffConnectionError;

  /// No description provided for @handoffGenerateFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate token. Please try again.'**
  String get handoffGenerateFailed;

  /// No description provided for @handoffAuthTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer authentication'**
  String get handoffAuthTitle;

  /// No description provided for @handoffAuthDescription.
  ///
  /// In en, this message translates to:
  /// **'Ask the other driver to scan this code to confirm the transfer.'**
  String get handoffAuthDescription;

  /// No description provided for @handoffGeneratingToken.
  ///
  /// In en, this message translates to:
  /// **'Generating secure token…'**
  String get handoffGeneratingToken;

  /// No description provided for @handoffTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'Token: '**
  String get handoffTokenLabel;

  /// No description provided for @handoffExpiresIn.
  ///
  /// In en, this message translates to:
  /// **'Expires in {time}'**
  String handoffExpiresIn(Object time);

  /// No description provided for @handoffCodeExpired.
  ///
  /// In en, this message translates to:
  /// **'This code has expired.'**
  String get handoffCodeExpired;

  /// No description provided for @handoffNewCode.
  ///
  /// In en, this message translates to:
  /// **'Generate new code'**
  String get handoffNewCode;

  /// No description provided for @handoffRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get handoffRetry;

  /// No description provided for @handoffScanGuidance.
  ///
  /// In en, this message translates to:
  /// **'Scan sender\'s QR'**
  String get handoffScanGuidance;

  /// No description provided for @handoffScanDescription.
  ///
  /// In en, this message translates to:
  /// **'Align the other driver\'s QR code in the frame to confirm.'**
  String get handoffScanDescription;

  /// No description provided for @handoffKeepAligned.
  ///
  /// In en, this message translates to:
  /// **'Keep the code aligned…'**
  String get handoffKeepAligned;

  /// No description provided for @handoffReading.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get handoffReading;

  /// No description provided for @handoffValidating.
  ///
  /// In en, this message translates to:
  /// **'Validating transfer…'**
  String get handoffValidating;

  /// No description provided for @handoffTransferConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Transfer confirmed'**
  String get handoffTransferConfirmed;

  /// No description provided for @handoffTransferComplete.
  ///
  /// In en, this message translates to:
  /// **'The package has been transferred to you.'**
  String get handoffTransferComplete;

  /// No description provided for @handoffInvalidQr.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a valid transfer token.'**
  String get handoffInvalidQr;

  /// No description provided for @handoffTokenExpiredDetail.
  ///
  /// In en, this message translates to:
  /// **'This token has expired. Ask the sender to generate a new one.'**
  String get handoffTokenExpiredDetail;

  /// No description provided for @handoffTokenUsed.
  ///
  /// In en, this message translates to:
  /// **'Invalid or already used token. Try with a new code.'**
  String get handoffTokenUsed;

  /// No description provided for @handoffNotForYou.
  ///
  /// In en, this message translates to:
  /// **'This transfer is not intended for you.'**
  String get handoffNotForYou;

  /// No description provided for @handoffTransferUpdated.
  ///
  /// In en, this message translates to:
  /// **'This transfer was just updated. Refresh and try again.'**
  String get handoffTransferUpdated;

  /// No description provided for @cameraAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera access denied'**
  String get cameraAccessDenied;

  /// No description provided for @cameraUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Camera unavailable'**
  String get cameraUnavailable;

  /// No description provided for @cameraPermInstructions.
  ///
  /// In en, this message translates to:
  /// **'Grant camera access in settings to scan transfers.'**
  String get cameraPermInstructions;

  /// No description provided for @cameraStartFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t start camera. Try again later.'**
  String get cameraStartFailed;

  /// No description provided for @setupEnterCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your activation code'**
  String get setupEnterCodeHint;

  /// No description provided for @setupServerInaccessible.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable — check your connection'**
  String get setupServerInaccessible;

  /// No description provided for @setupCodeAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This code has already been used'**
  String get setupCodeAlreadyUsed;

  /// No description provided for @setupInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid code format (UUID expected)'**
  String get setupInvalidFormat;

  /// No description provided for @setupInvalidOrExpired.
  ///
  /// In en, this message translates to:
  /// **'Invalid or expired code'**
  String get setupInvalidOrExpired;

  /// No description provided for @setupEnterPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get setupEnterPhoneHint;

  /// No description provided for @setupCodeSentEmail.
  ///
  /// In en, this message translates to:
  /// **'An activation code has been sent by email.'**
  String get setupCodeSentEmail;

  /// No description provided for @setupCodeResentEmail.
  ///
  /// In en, this message translates to:
  /// **'A new activation code has been sent by email.'**
  String get setupCodeResentEmail;

  /// No description provided for @setupPhoneNotFoundOrActive.
  ///
  /// In en, this message translates to:
  /// **'Phone not found or already activated'**
  String get setupPhoneNotFoundOrActive;

  /// No description provided for @setupPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get setupPasswordLabel;

  /// No description provided for @registerDescription.
  ///
  /// In en, this message translates to:
  /// **'Fill in your information to get started.'**
  String get registerDescription;

  /// No description provided for @registerPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get registerPhone;

  /// No description provided for @registerPasswordField.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordField;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerLoading.
  ///
  /// In en, this message translates to:
  /// **'Registering...'**
  String get registerLoading;

  /// No description provided for @deliveryAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get deliveryAccept;

  /// No description provided for @deliveryNoAddressProvided.
  ///
  /// In en, this message translates to:
  /// **'No address provided'**
  String get deliveryNoAddressProvided;

  /// No description provided for @podTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get podTakePhoto;

  /// No description provided for @podChooseGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get podChooseGallery;

  /// No description provided for @podPhotosRequired.
  ///
  /// In en, this message translates to:
  /// **'Both photos are required'**
  String get podPhotosRequired;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String profileError(Object error);

  /// No description provided for @calendarTodayButton.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get calendarTodayButton;

  /// No description provided for @calendarProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% completed'**
  String calendarProgress(Object percent);

  /// No description provided for @calendarStopCount.
  ///
  /// In en, this message translates to:
  /// **'{count} stop(s)'**
  String calendarStopCount(Object count);

  /// No description provided for @syncCenterTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncCenterTitle;

  /// No description provided for @syncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Everything is up to date'**
  String get syncUpToDate;

  /// No description provided for @syncSyncing.
  ///
  /// In en, this message translates to:
  /// **'Sending… {count} left'**
  String syncSyncing(Object count);

  /// No description provided for @syncPendingBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline · {count} pending'**
  String syncPendingBanner(Object count);

  /// No description provided for @syncFailedBanner.
  ///
  /// In en, this message translates to:
  /// **'{count} action(s) to review'**
  String syncFailedBanner(Object count);

  /// No description provided for @syncRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get syncRetry;

  /// No description provided for @syncRetryAll.
  ///
  /// In en, this message translates to:
  /// **'Retry all'**
  String get syncRetryAll;

  /// No description provided for @syncDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get syncDiscard;

  /// No description provided for @syncViewDelivery.
  ///
  /// In en, this message translates to:
  /// **'View delivery'**
  String get syncViewDelivery;

  /// No description provided for @syncEmpty.
  ///
  /// In en, this message translates to:
  /// **'No pending actions'**
  String get syncEmpty;

  /// No description provided for @syncStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get syncStatusPending;

  /// No description provided for @syncStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get syncStatusFailed;

  /// No description provided for @syncStatusSending.
  ///
  /// In en, this message translates to:
  /// **'Sending…'**
  String get syncStatusSending;

  /// No description provided for @syncRejectedByServer.
  ///
  /// In en, this message translates to:
  /// **'Rejected by the server'**
  String get syncRejectedByServer;

  /// No description provided for @syncExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired (too old)'**
  String get syncExpired;

  /// No description provided for @syncEnqueuedAt.
  ///
  /// In en, this message translates to:
  /// **'Saved at {time}'**
  String syncEnqueuedAt(Object time);

  /// No description provided for @offlineDataAsOf.
  ///
  /// In en, this message translates to:
  /// **'Offline data · {time}'**
  String offlineDataAsOf(Object time);

  /// No description provided for @syncActionComplete.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get syncActionComplete;

  /// No description provided for @syncActionPod.
  ///
  /// In en, this message translates to:
  /// **'Proof of delivery'**
  String get syncActionPod;

  /// No description provided for @syncActionFail.
  ///
  /// In en, this message translates to:
  /// **'Delivery failed'**
  String get syncActionFail;

  /// No description provided for @syncActionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancellation'**
  String get syncActionCancel;

  /// No description provided for @syncActionTransit.
  ///
  /// In en, this message translates to:
  /// **'In transit'**
  String get syncActionTransit;

  /// No description provided for @syncActionPickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get syncActionPickup;

  /// No description provided for @syncActionAccept.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get syncActionAccept;

  /// No description provided for @syncActionArrive.
  ///
  /// In en, this message translates to:
  /// **'Arrival'**
  String get syncActionArrive;

  /// No description provided for @syncActionRouteStart.
  ///
  /// In en, this message translates to:
  /// **'Route start'**
  String get syncActionRouteStart;

  /// No description provided for @syncActionGeneric.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get syncActionGeneric;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
