// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AsmTrack Driver';

  @override
  String get tabRoute => 'Route';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabProfile => 'Profile';

  @override
  String get offlineBanner => 'Offline — actions will sync when connection is restored';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get statusOnline => 'Online';

  @override
  String get status_on_break => 'On Break';

  @override
  String get status_offline => 'Offline';

  @override
  String get status_online_upper => 'ONLINE';

  @override
  String get status_on_break_upper => 'ON BREAK';

  @override
  String get status_offline_upper => 'OFFLINE';

  @override
  String get action_start_shift => 'Start Shift';

  @override
  String get action_take_break => 'Take a Break';

  @override
  String get action_end_day => 'End Workday';

  @override
  String get action_resume_service => 'Resume Service';

  @override
  String get profile_title => 'PROFILE';

  @override
  String get driver_id => 'Driver ID';

  @override
  String get phone => 'Phone Number';

  @override
  String get last_ping => 'Last Ping';

  @override
  String get gps => 'GPS';

  @override
  String get section_availability => 'AVAILABILITY';

  @override
  String get section_performance => 'PERFORMANCE';

  @override
  String get section_account => 'ACCOUNT';

  @override
  String get section_actions => 'ACTIONS';

  @override
  String get language_setting => 'Language';

  @override
  String get send_location => 'Send my position';

  @override
  String get change_password => 'Change Password';

  @override
  String get profileChangePhoto => 'Change Photo';

  @override
  String get profileTakePhoto => 'Take Photo';

  @override
  String get profileChooseGallery => 'Choose from Gallery';

  @override
  String get profilePhotoCropTitle => 'Crop Profile Photo';

  @override
  String get profileSuccessRate => 'Success rate';

  @override
  String get profileLoading => 'Loading profile…';

  @override
  String get profileUnavailable => 'Profile unavailable';

  @override
  String get profileRetry => 'Retry';

  @override
  String get logout => 'Sign Out';

  @override
  String get logout_confirm_title => 'Sign Out?';

  @override
  String get logout_confirm_body => 'You will need to sign in again to access your deliveries.';

  @override
  String get cancel => 'Cancel';

  @override
  String get position_sent => 'Location sent to dispatcher.';

  @override
  String get profileUploadFailed => 'Upload failed, try again';

  @override
  String get profilePhotoRequired => 'Add your photo';

  @override
  String get profilePhotoRequiredSub => 'Required to continue. Visible to dispatch.';

  @override
  String get profilePhotoConfirm => 'Confirm';

  @override
  String get metric_delivered => 'Delivered';

  @override
  String get metric_failed => 'Failed';

  @override
  String get metric_total => 'Total';

  @override
  String ws_delivery_assigned(Object client) {
    return 'Delivery assigned — $client';
  }

  @override
  String get ws_new_delivery => 'New delivery assigned';

  @override
  String ws_delivery_removed(Object client) {
    return 'Delivery removed — $client';
  }

  @override
  String get ws_delivery_removed_generic => 'Delivery removed from your route';

  @override
  String ws_route_assigned(Object route) {
    return 'Route $route assigned — please review before departure.';
  }

  @override
  String ws_route_cancelled(Object route) {
    return 'Route $route has been cancelled.';
  }

  @override
  String ws_route_reassigned_away(Object route) {
    return 'Route $route has been reassigned to another driver.';
  }

  @override
  String ws_route_reassigned_to_you(Object route) {
    return 'Route $route has been reassigned to you!';
  }

  @override
  String ws_stop_added(Object client, Object route) {
    return '$client added to route $route.';
  }

  @override
  String ws_pickup_overdue(Object client, Object count) {
    return 'Pickup overdue — Depot $client ($count).';
  }

  @override
  String ws_stop_removed(Object client, Object ref, Object route, Object why) {
    return '$client$ref removed from route $route$why.';
  }

  @override
  String ws_route_updated(Object route) {
    return 'Route $route has been updated.';
  }

  @override
  String ws_stops_transferred_out(Object route) {
    return 'Stops were removed from route $route.';
  }

  @override
  String ws_stops_transferred_in(Object route) {
    return 'New stops were added to route $route.';
  }

  @override
  String get ws_generic_route => 'your route';

  @override
  String ws_handoff_incoming(Object name, Object ref) {
    return 'Pickup required — parcel $ref from $name';
  }

  @override
  String ws_handoff_outgoing(Object name, Object ref) {
    return 'To hand over — parcel $ref to $name';
  }

  @override
  String ws_handoff_confirmed(Object ref) {
    return 'Handover confirmed — parcel $ref';
  }

  @override
  String ws_handoff_cancelled(Object ref) {
    return 'Handover cancelled — parcel $ref';
  }

  @override
  String get ws_handoff_other => 'a driver';

  @override
  String get handoff_action_scan => 'Scan';

  @override
  String get handoff_action_show => 'Show code';

  @override
  String get handoff_inbox_title => 'My handoffs';

  @override
  String get handoff_inbox_incoming => 'To receive';

  @override
  String get handoff_inbox_outgoing => 'To hand over';

  @override
  String get handoff_inbox_from => 'From';

  @override
  String get handoff_inbox_to => 'Hand over to';

  @override
  String get handoff_inbox_empty_title => 'No handoffs';

  @override
  String get handoff_inbox_empty_sub => 'Parcel transfers will appear here.';

  @override
  String get handoff_inbox_error => 'Could not load handoffs';

  @override
  String get handoff_inbox_retry => 'Retry';

  @override
  String get handoff_manual_action => 'Enter code';

  @override
  String get handoff_manual_title => 'Transfer code';

  @override
  String get handoff_manual_hint => 'ABC123';

  @override
  String get handoff_manual_confirm => 'Confirm';

  @override
  String get handoff_manual_success => 'Transfer confirmed';

  @override
  String get handoff_manual_error => 'Invalid or expired code';

  @override
  String get splash_sub => 'Logistics management';

  @override
  String get splash_loading => 'Loading…';

  @override
  String get splash_copyright => '(c) 2026 ASM Logistics Operations';

  @override
  String get login_driver_space => 'AsmTrack Driver';

  @override
  String get login_secure_access => 'Secure Access · AsmOne';

  @override
  String get login_auth_header => 'Authentication';

  @override
  String get login_auth_desc => 'You will be redirected to the secure login page to authenticate.';

  @override
  String get login_action_connect => 'Sign In';

  @override
  String get login_action_connecting => 'Connecting...';

  @override
  String get login_action_setup => 'Configure my account';

  @override
  String get login_action_change_workspace => 'Change workspace';

  @override
  String get login_action_setup_sub => 'First time · set your password';

  @override
  String get login_action_change_workspace_sub => 'Connect to a different server';

  @override
  String get login_secure_sso => 'Secure sign-in · ASM Track';

  @override
  String get login_version => 'Version';

  @override
  String get login_failed_error => 'Authentication failed. Check your credentials.';

  @override
  String get loginServerUrl => 'Server URL';

  @override
  String get loginServerUrlHint => 'http://192.168.1.10  (local)  ·  https://dev.asm…';

  @override
  String get loginServerUrlDesc => 'Authentication follows this host automatically.';

  @override
  String get loginServerUrlInvalid => 'Invalid URL (e.g. http://192.168.1.10)';

  @override
  String get loginServerSave => 'Save';

  @override
  String get loginServerCancel => 'Cancel';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get route_swipe_start => 'Swipe to start the route';

  @override
  String get route_swipe_load => 'Swipe to load';

  @override
  String get route_swipe_confirm_load => 'Swipe to confirm loading';

  @override
  String get route_all_stops_done => 'All stops completed';

  @override
  String get route_download_pdf => 'Download PDF';

  @override
  String get route_navigate => 'Navigate';

  @override
  String get route_finished => 'Route completed';

  @override
  String get route_stops_log => 'Stops log';

  @override
  String route_load_parcels(Object count, Object depot) {
    return 'Load $count parcels — Depot $depot';
  }

  @override
  String get route_no_stops => 'No stops configured.';

  @override
  String get route_empty_title => 'No active route';

  @override
  String get route_empty_subtitle => 'Your route will appear here once assigned by dispatch.';

  @override
  String get routeRefresh => 'Refresh';

  @override
  String get routeStops => 'STOPS';

  @override
  String get routeStop => 'stop';

  @override
  String get routeStopsCount => 'stops';

  @override
  String get routeConfirmDelivery => 'Confirm delivery';

  @override
  String get routeLoading => 'Loading route…';

  @override
  String get delivery_detail_title => 'Delivery Details';

  @override
  String get return_pickup_badge => 'Return';

  @override
  String get return_pickup_title => 'Return collection';

  @override
  String get delivery_detail_loading => 'Loading delivery...';

  @override
  String get delivery_detail_load_failed => 'Failed to load';

  @override
  String get delivery_detail_retry => 'Retry';

  @override
  String get delivery_detail_fail_report => 'Report failure';

  @override
  String get delivery_detail_fail_select => 'Select the reason for failure.';

  @override
  String get delivery_detail_comment_hint => 'Additional comment (optional)';

  @override
  String get delivery_detail_fail_submit => 'Submit failure report';

  @override
  String get delivery_detail_pod_title => 'Proof of Delivery';

  @override
  String get delivery_detail_fail_reason => 'Failure reason';

  @override
  String get delivery_detail_cancel_reason => 'Cancellation reason';

  @override
  String get delivery_detail_history_title => 'Status History';

  @override
  String get delivery_detail_articles => 'Items';

  @override
  String get delivery_detail_scheduled => 'Scheduled';

  @override
  String get delivery_detail_content => 'Package content';

  @override
  String get delivery_detail_timeline => 'Timeline';

  @override
  String get delivery_detail_ts_scheduled => 'Scheduled';

  @override
  String get delivery_detail_ts_picked_up => 'Picked Up';

  @override
  String get delivery_detail_ts_in_transit => 'In Transit';

  @override
  String get delivery_detail_ts_delivered => 'Delivered';

  @override
  String get delivery_detail_ts_failed => 'Failed';

  @override
  String get delivery_detail_ts_cancelled => 'Cancelled';

  @override
  String get delivery_detail_ts_created => 'Created';

  @override
  String get delivery_detail_pending_dispatch => 'Waiting for dispatch';

  @override
  String get delivery_detail_pickup_package => 'Collect package';

  @override
  String get delivery_detail_navigate => 'Navigate';

  @override
  String get delivery_detail_start_transit => 'Start journey';

  @override
  String get delivery_detail_generate_handoff => 'Generate transfer code';

  @override
  String get delivery_detail_submit_pod => 'Submit proof of delivery';

  @override
  String get delivery_detail_collect_return => 'Collect parcel';

  @override
  String get delivery_detail_confirm_collection => 'Confirm collection';

  @override
  String get delivery_detail_locked => 'Completed';

  @override
  String get delivery_detail_offline_queue => 'Offline — will be sent on reconnect';

  @override
  String get delivery_detail_error_prefix => 'Error';

  @override
  String get delivery_detail_unauthorized_link => 'This delivery is not assigned to you.';

  @override
  String get deliveryItem => 'item';

  @override
  String get deliveryItems => 'items';

  @override
  String get deliveryOpen => 'Open';

  @override
  String get deliveryOrder => 'Order';

  @override
  String get deliveryPackageTransferred => 'Package transferred to you';

  @override
  String get deliveryHandoffScanHint => 'When you receive it, scan the sender driver\'s QR to confirm. You can keep working in the meantime.';

  @override
  String get deliveryScanSenderQr => 'Scan sender\'s QR';

  @override
  String get pod_title => 'Proof of Delivery';

  @override
  String get pod_pdf_open_error => 'Cannot open PDF. No PDF viewer application installed.';

  @override
  String get pod_pdf_download_error => 'Error downloading delivery note.';

  @override
  String get pod_step_1 => '1. Print the delivery note and have the customer sign it.';

  @override
  String get pod_step_2 => '2. Take a photo of the signed note.';

  @override
  String get pod_step_3 => '3. Take a photo of the package handover.';

  @override
  String get pod_view_print_bl => 'View / Print Delivery Note';

  @override
  String get pod_downloading => 'Downloading...';

  @override
  String get pod_photo_bl_title => 'Signed Delivery Note';

  @override
  String get pod_photo_bl_sub => 'Photograph the note signed by the customer';

  @override
  String get pod_photo_pkg_title => 'Package Handover';

  @override
  String get pod_photo_pkg_sub => 'Photograph the package at the moment of handover';

  @override
  String get pod_photo_take => 'Take photo';

  @override
  String get pod_photo_retake => 'Retake';

  @override
  String get pod_photo_delete => 'Delete';

  @override
  String get pod_photo_tap_hint => 'Tap to take photo';

  @override
  String get pod_photo_access_error => 'Cannot access camera.';

  @override
  String get pod_comments_label => 'Comments (door code, receiver name, etc.)';

  @override
  String get pod_gps_label => 'Attach GPS location';

  @override
  String get pod_gps_sub => 'Coordinates sent only once at submission.';

  @override
  String get pod_partial_label => 'Partial delivery';

  @override
  String get pod_partial_sub => 'Enable if some items were not delivered.';

  @override
  String get pod_item_outcome_header => 'Outcome per item:';

  @override
  String get pod_delivered_qty => 'Delivered quantity';

  @override
  String get pod_reason_label => 'Reason *';

  @override
  String get pod_reason_partial => 'Reason — partial delivery *';

  @override
  String get pod_item_comment_hint => 'Comment on this item (optional)';

  @override
  String get pod_reason_mandatory => 'Reason mandatory for:';

  @override
  String get pod_photos_mandatory => 'Both photos are mandatory.';

  @override
  String get pod_confirm_delivery => 'Confirm delivery';

  @override
  String get pod_success_message => 'POD submitted successfully.';

  @override
  String get podCameraTake => 'Take a photo';

  @override
  String get podGalleryChoose => 'Choose from gallery';

  @override
  String get podComment => 'Comment';

  @override
  String get podCommentOptional => 'Comment (optional)';

  @override
  String get calendarRoutes => 'Routes';

  @override
  String get calendarRoute => 'Route';

  @override
  String get calendarStops => 'Stops';

  @override
  String get calendarDelivered => 'Delivered';

  @override
  String get calendarAmount => 'Amount';

  @override
  String get calendarRouteCancelled => 'Route cancelled';

  @override
  String get calendarItems => 'Items';

  @override
  String get calendarLoadItemsError => 'Couldn\'t load items';

  @override
  String get calendarNoItems => 'No items';

  @override
  String get calendarOpenRoute => 'Open route';

  @override
  String get handoffScannerScanSenderQr => 'Scan sender\'s QR';

  @override
  String get handoffScannerAlignHint => 'Align the sender driver\'s QR code in the frame to confirm the transfer of responsibility.';

  @override
  String get handoffScannerHoldAligned => 'Hold the code steady…';

  @override
  String get handoffScannerReading => 'Reading';

  @override
  String get handoffScannerValidating => 'Validating transfer…';

  @override
  String get handoffScannerSuccess => 'Transfer confirmed';

  @override
  String get handoffScannerSuccessBody => 'The package has been transferred to you.';

  @override
  String get handoffScannerInvalidQr => 'This QR code is not a valid transfer token.';

  @override
  String get handoffScannerExpired => 'This token has expired. Ask the sender to generate a new one.';

  @override
  String get handoffScannerUsed => 'Invalid or already-used token. Try a new code.';

  @override
  String get handoffScannerNotForYou => 'This transfer is not addressed to you.';

  @override
  String get handoffScannerUpdated => 'This transfer was just updated. Refresh and try again.';

  @override
  String get handoffScannerNetworkError => 'No connection. Check your network and try again.';

  @override
  String get handoffScannerFailed => 'Transfer failed. Please try again.';

  @override
  String get handoffScannerCameraDenied => 'Camera access denied';

  @override
  String get handoffScannerCameraUnavailable => 'Camera unavailable';

  @override
  String get handoffScannerCameraDeniedHint => 'Allow camera access in settings to scan transfers.';

  @override
  String get handoffScannerCameraError => 'Could not start the camera. Try again later.';

  @override
  String get handoffTokenUnauthorized => 'You are not authorized to generate a token for this package.';

  @override
  String get handoffTokenNoPending => 'No pending transfer for this package. Refresh and try again.';

  @override
  String get handoffTokenNetworkError => 'No connection. Check your network and try again.';

  @override
  String get handoffTokenGenerateFailed => 'Could not generate the token. Please try again.';

  @override
  String get handoffTokenAuthTitle => 'Transfer authentication';

  @override
  String get handoffTokenAuthHint => 'Ask the other driver to scan this code to confirm the transfer of responsibility.';

  @override
  String get handoffTokenGenerating => 'Generating secure token…';

  @override
  String get handoffTokenClose => 'Close';

  @override
  String get handoffTokenTokenLabel => 'Token: ';

  @override
  String get handoffTokenExpiresIn => 'Expires in 5 minutes';

  @override
  String get handoffTokenExpiresInFormat => 'Expires in MM:SS';

  @override
  String get handoffTokenExpired => 'This code has expired.';

  @override
  String get handoffTokenGenerateNew => 'Generate a new code';

  @override
  String get handoffTokenRetry => 'Retry';

  @override
  String get historyLoading => 'Loading history…';

  @override
  String get historyOfflineTitle => 'Offline history';

  @override
  String get historyRetry => 'Retry';

  @override
  String get historyOrder => 'Order';

  @override
  String get historyArticles => 'Items';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(Object minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(Object hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(Object days) {
    return '${days}d ago';
  }

  @override
  String get offlinePendingUpdates => 'pending updates';

  @override
  String get offlineConnectionRestored => 'Connection restored · Syncing data…';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Driver registration';

  @override
  String get registerFullName => 'Full name';

  @override
  String get registerRequired => 'Required';

  @override
  String get registerPhoneLabel => 'Phone number';

  @override
  String get registerPassword => 'Password';

  @override
  String get registerMinChars => 'Min 6 characters';

  @override
  String get registerSubmitting => 'Registering...';

  @override
  String get registerCreateAccount => 'Create account';

  @override
  String get registerHasAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get setupEnterCode => 'Enter your activation code';

  @override
  String get setupServerError => 'Server unreachable — check your connection';

  @override
  String get setupCodeNotFound => 'Code not found — contact your manager';

  @override
  String get setupCodeExpired => 'Code expired — request a new code';

  @override
  String get setupCodeUsed => 'This code has already been used';

  @override
  String get setupCodeInvalidFormat => 'Invalid code format (UUID expected)';

  @override
  String get setupCodeInvalid => 'Invalid or expired code';

  @override
  String get setupEnterPhone => 'Enter your phone number';

  @override
  String get setupCodeSent => 'An activation code has been sent by email.';

  @override
  String get setupCodeResent => 'A new activation code has been sent by email.';

  @override
  String get setupPhoneNotFound => 'Phone not found or already activated';

  @override
  String get setupAccountActivated => 'Account activated! Sign in with your phone number.';

  @override
  String get setupActivationFailed => 'Activation failed. Check your code and try again.';

  @override
  String get setupSignIn => 'Sign in';

  @override
  String get setupConfigureAccount => 'Configure my account';

  @override
  String get setupActivationTitle => 'Driver activation';

  @override
  String get setupActivationSubtitle => 'Enter the activation code received by email, then choose your password.';

  @override
  String get setupActivationCode => 'Activation code';

  @override
  String get setupValidateCode => 'Validate code';

  @override
  String get setupNoCode => 'Didn\'t receive the code?';

  @override
  String get setupYourPhone => 'Your phone';

  @override
  String get setupResendCode => 'Resend code';

  @override
  String setupWelcome(Object name) {
    return 'Welcome, $name';
  }

  @override
  String get setupPassword => 'Password';

  @override
  String get setupPasswordMin => 'Minimum 6 characters';

  @override
  String get setupConfirmPassword => 'Confirm password';

  @override
  String get setupConfirmPasswordHint => 'Repeat your password';

  @override
  String get setupPasswordMismatch => 'Passwords do not match';

  @override
  String get setupActivating => 'Activating...';

  @override
  String get setupActivateAccount => 'Activate my account';

  @override
  String get setupNoCodeReceived => 'Didn\'t receive the code?';

  @override
  String get setupPhoneHint => 'Your phone';

  @override
  String get monthJanuary => 'January';

  @override
  String get monthFebruary => 'February';

  @override
  String get monthMarch => 'March';

  @override
  String get monthApril => 'April';

  @override
  String get monthMay => 'May';

  @override
  String get monthJune => 'June';

  @override
  String get monthJuly => 'July';

  @override
  String get monthAugust => 'August';

  @override
  String get monthSeptember => 'September';

  @override
  String get monthOctober => 'October';

  @override
  String get monthNovember => 'November';

  @override
  String get monthDecember => 'December';

  @override
  String get dayMonday => 'Monday';

  @override
  String get dayTuesday => 'Tuesday';

  @override
  String get dayWednesday => 'Wednesday';

  @override
  String get dayThursday => 'Thursday';

  @override
  String get dayFriday => 'Friday';

  @override
  String get daySaturday => 'Saturday';

  @override
  String get daySunday => 'Sunday';

  @override
  String get calendarToday => 'Today';

  @override
  String get calendarTomorrow => 'Tomorrow';

  @override
  String get calendarClose => 'Close';

  @override
  String get calendarClient => 'Client';

  @override
  String get statusUnscheduled => 'Unscheduled';

  @override
  String get statusScheduled => 'Scheduled';

  @override
  String get statusPickedUp => 'Picked Up';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusPartial => 'Partial';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusPending => 'Pending';

  @override
  String calendarWeek(Object week) {
    return 'Week $week';
  }

  @override
  String get calendarRouteCancelledTitle => 'Route cancelled';

  @override
  String calendarRouteCancelledBody(Object name) {
    return 'Route $name has been cancelled by dispatch.';
  }

  @override
  String get calendarNoRoutes => 'No routes';

  @override
  String get calendarLoadRoutesError => 'Couldn\'t load routes';

  @override
  String get calendarCheckConnection => 'Check your connection and try again.';

  @override
  String get statusScheduledLabel => 'Scheduled';

  @override
  String get statusPickedUpLabel => 'Picked Up';

  @override
  String get statusPickedUpReturn => 'Parcel collected';

  @override
  String get statusInTransitLabel => 'In Transit';

  @override
  String get statusAwaitingHandoff => 'Awaiting Handoff';

  @override
  String get statusDeliveredLabel => 'Delivered';

  @override
  String get statusDeliveredReturn => 'Received at depot';

  @override
  String get statusPartiallyDelivered => 'Partially delivered';

  @override
  String get statusFailedLabel => 'Failed';

  @override
  String get statusCancelledLabel => 'Cancelled';

  @override
  String get routeStatusDraft => 'Draft';

  @override
  String get routeStatusValidated => 'Validated';

  @override
  String get routeStatusInProgress => 'In Progress';

  @override
  String get routeStatusClosed => 'Closed';

  @override
  String get routeStatusCancelledR => 'Cancelled';

  @override
  String get stopStatusPending => 'Pending';

  @override
  String get stopStatusArrived => 'Arrived';

  @override
  String get stopStatusCompleted => 'Completed';

  @override
  String get stopStatusFailed => 'Failed';

  @override
  String get stopStatusPartial => 'Partial';

  @override
  String get routeDefaultName => 'Route';

  @override
  String get reasonClientAbsent => 'Client absent';

  @override
  String get reasonClientRefused => 'Refused by client';

  @override
  String get reasonWrongAddress => 'Wrong address';

  @override
  String get reasonPackageDamaged => 'Package damaged';

  @override
  String get reasonOther => 'Other';

  @override
  String get podOutcomeDelivered => 'Delivered';

  @override
  String get podOutcomeRefused => 'Refused';

  @override
  String get podOutcomeDamaged => 'Damaged';

  @override
  String get podOutcomeMissing => 'Missing';

  @override
  String get podNotesTitle => 'Comment';

  @override
  String get podNotesHint => 'Comment (optional)';

  @override
  String routeTimeFrom(Object time) {
    return 'From $time';
  }

  @override
  String routeTimeBefore(Object time) {
    return 'Before $time';
  }

  @override
  String routeStopCount(Object count) {
    return '$count stops';
  }

  @override
  String routeStopCountSingular(Object count) {
    return '$count stop';
  }

  @override
  String get routeSwipeStartHint => 'Swipe to start route';

  @override
  String get routeSwipeLoadHint => 'Swipe to load';

  @override
  String get routeStopsHeader => 'STOPS';

  @override
  String get routeAllStopsDone => 'All stops completed';

  @override
  String get routeFinishedLabel => 'Route completed';

  @override
  String get routeOfflineBanner => 'Offline mode — cached data';

  @override
  String get routeConfirmPickup => 'Confirm loading at depot first';

  @override
  String get routeLoadingRoute => 'Loading route...';

  @override
  String get routeLoadError => 'Couldn\'t load route';

  @override
  String get routeRetry => 'Retry';

  @override
  String get routeInfoDate => 'Date';

  @override
  String get routeInfoSchedule => 'Schedule';

  @override
  String get routeInfoZone => 'Zone';

  @override
  String get routeInfoCity => 'City';

  @override
  String get routeInfoStops => 'Stops';

  @override
  String get routeInfoVehicle => 'Vehicle';

  @override
  String get routeNoStopsConfigured => 'No stops configured.';

  @override
  String routePickupLabel(Object depot) {
    return 'Loading — Depot $depot';
  }

  @override
  String get historyOffline => 'History offline';

  @override
  String get historyEmpty => 'No records';

  @override
  String get historyEmptySubtitle => 'Completed deliveries will appear here.';

  @override
  String get historySectionTitle => 'History';

  @override
  String historyRecordCount(Object count) {
    return '$count records';
  }

  @override
  String get historyFilterDate => 'Filter by date...';

  @override
  String get historyNoAddress => 'No address';

  @override
  String get historyItems => 'Items';

  @override
  String get filterAll => 'All';

  @override
  String get filterDelivered => 'Delivered';

  @override
  String get filterFailed => 'Failed';

  @override
  String get filterCancelled => 'Cancelled';

  @override
  String get routeOfflineAction => 'Offline — will be sent on reconnection';

  @override
  String routeErrorSnackbar(Object error) {
    return 'Error: $error';
  }

  @override
  String get routeOfflineUnavailable => 'Not available offline';

  @override
  String get routePdfFailed => 'PDF download failed';

  @override
  String get routeGenerateQr => 'Generate QR';

  @override
  String get routeScanQr => 'Scan QR';

  @override
  String get routeScannerOffline => 'Scanner unavailable offline';

  @override
  String get deliveryNoAddress => 'No address provided';

  @override
  String get statusHistoryDelivered => 'Delivered';

  @override
  String get statusHistoryPartial => 'Partial';

  @override
  String get statusHistoryFailed => 'Failed';

  @override
  String get statusHistoryCancelled => 'Cancelled';

  @override
  String get statusHistoryInTransit => 'In Transit';

  @override
  String get statusHistoryPickedUp => 'Picked Up';

  @override
  String get statusHistoryScheduled => 'Scheduled';

  @override
  String get statusHistoryUnknown => 'Unknown';

  @override
  String get handoffTransferredToYou => 'Package transferred to you';

  @override
  String get handoffScanInstructions => 'At reception, scan the sender driver\'s QR to confirm.';

  @override
  String get handoffScanSenderQr => 'Scan sender\'s QR';

  @override
  String get bonLivraisonOffline => 'Not available offline';

  @override
  String get bonLivraisonOpen => 'Open';

  @override
  String get handoffUnauthorized => 'You are not authorized to generate a token for this package.';

  @override
  String get handoffNoTransfer => 'No pending transfer for this package. Refresh and try again.';

  @override
  String get handoffConnectionError => 'Connection failed. Check your network and try again.';

  @override
  String get handoffGenerateFailed => 'Failed to generate token. Please try again.';

  @override
  String get handoffAuthTitle => 'Transfer authentication';

  @override
  String get handoffAuthDescription => 'Ask the other driver to scan this code to confirm the transfer.';

  @override
  String get handoffGeneratingToken => 'Generating secure token…';

  @override
  String get handoffTokenLabel => 'Token: ';

  @override
  String handoffExpiresIn(Object time) {
    return 'Expires in $time';
  }

  @override
  String get handoffCodeExpired => 'This code has expired.';

  @override
  String get handoffNewCode => 'Generate new code';

  @override
  String get handoffRetry => 'Retry';

  @override
  String get handoffScanGuidance => 'Scan sender\'s QR';

  @override
  String get handoffScanDescription => 'Align the other driver\'s QR code in the frame to confirm.';

  @override
  String get handoffKeepAligned => 'Keep the code aligned…';

  @override
  String get handoffReading => 'Reading';

  @override
  String get handoffValidating => 'Validating transfer…';

  @override
  String get handoffTransferConfirmed => 'Transfer confirmed';

  @override
  String get handoffTransferComplete => 'The package has been transferred to you.';

  @override
  String get handoffInvalidQr => 'This QR code is not a valid transfer token.';

  @override
  String get handoffTokenExpiredDetail => 'This token has expired. Ask the sender to generate a new one.';

  @override
  String get handoffTokenUsed => 'Invalid or already used token. Try with a new code.';

  @override
  String get handoffNotForYou => 'This transfer is not intended for you.';

  @override
  String get handoffTransferUpdated => 'This transfer was just updated. Refresh and try again.';

  @override
  String get cameraAccessDenied => 'Camera access denied';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get cameraPermInstructions => 'Grant camera access in settings to scan transfers.';

  @override
  String get cameraStartFailed => 'Couldn\'t start camera. Try again later.';

  @override
  String get setupEnterCodeHint => 'Enter your activation code';

  @override
  String get setupServerInaccessible => 'Server unreachable — check your connection';

  @override
  String get setupCodeAlreadyUsed => 'This code has already been used';

  @override
  String get setupInvalidFormat => 'Invalid code format (UUID expected)';

  @override
  String get setupInvalidOrExpired => 'Invalid or expired code';

  @override
  String get setupEnterPhoneHint => 'Enter your phone number';

  @override
  String get setupCodeSentEmail => 'An activation code has been sent by email.';

  @override
  String get setupCodeResentEmail => 'A new activation code has been sent by email.';

  @override
  String get setupPhoneNotFoundOrActive => 'Phone not found or already activated';

  @override
  String get setupPasswordLabel => 'Password';

  @override
  String get registerDescription => 'Fill in your information to get started.';

  @override
  String get registerPhone => 'Phone number';

  @override
  String get registerPasswordField => 'Password';

  @override
  String get registerButton => 'Register';

  @override
  String get registerLoading => 'Registering...';

  @override
  String get deliveryAccept => 'Accept';

  @override
  String get deliveryNoAddressProvided => 'No address provided';

  @override
  String get podTakePhoto => 'Take a photo';

  @override
  String get podChooseGallery => 'Choose from gallery';

  @override
  String get podPhotosRequired => 'Both photos are required';

  @override
  String profileError(Object error) {
    return 'Error: $error';
  }

  @override
  String get calendarTodayButton => 'Today';

  @override
  String calendarProgress(Object percent) {
    return '$percent% completed';
  }

  @override
  String calendarStopCount(Object count) {
    return '$count stop(s)';
  }
}
