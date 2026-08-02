// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'AsmTrack Driver';

  @override
  String get tabRoute => 'الرحلة';

  @override
  String get tabCalendar => 'التقويم';

  @override
  String get tabProfile => 'الملف الشخصي';

  @override
  String get offlineBanner => 'خارج الشبكة — سيتم مزامنة الإجراءات عند إعادة الاتصال';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get noNotifications => 'لا توجد إشعارات';

  @override
  String get statusOnline => 'متصل';

  @override
  String get status_on_break => 'في استراحة';

  @override
  String get status_offline => 'غير متصل';

  @override
  String get status_online_upper => 'متصل';

  @override
  String get status_on_break_upper => 'في استراحة';

  @override
  String get status_offline_upper => 'غير متصل';

  @override
  String get action_start_shift => 'بدء الخدمة';

  @override
  String get action_take_break => 'أخذ استراحة';

  @override
  String get action_end_day => 'إنهاء العمل اليومي';

  @override
  String get action_resume_service => 'استئناف الخدمة';

  @override
  String get profile_title => 'الملف الشخصي';

  @override
  String get driver_id => 'معرف السائق';

  @override
  String get phone => 'رقم الهاتف';

  @override
  String get last_ping => 'آخر اتصال';

  @override
  String get gps => 'موقع GPS';

  @override
  String get section_availability => 'الحالة';

  @override
  String get section_performance => 'الأداء';

  @override
  String get section_account => 'الحساب';

  @override
  String get section_actions => 'الإجراءات';

  @override
  String get language_setting => 'اللغة';

  @override
  String get send_location => 'إرسال موقعي';

  @override
  String get change_password => 'تغيير كلمة المرور';

  @override
  String get profileChangePhoto => 'تغيير الصورة';

  @override
  String get profileTakePhoto => 'التقاط صورة';

  @override
  String get profileChooseGallery => 'اختيار من المعرض';

  @override
  String get profilePhotoCropTitle => 'قص صورة الملف الشخصي';

  @override
  String get profileSuccessRate => 'نسبة النجاح';

  @override
  String get profileLoading => 'جاري تحميل الملف الشخصي…';

  @override
  String get profileUnavailable => 'الملف الشخصي غير متاح';

  @override
  String get profileRetry => 'إعادة المحاولة';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logout_confirm_title => 'تسجيل الخروج؟';

  @override
  String get logout_confirm_body => 'ستحتاج إلى تسجيل الدخول مرة أخرى للوصول إلى شحناتك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get position_sent => 'تم إرسال الموقع إلى المسؤول.';

  @override
  String get profileUploadFailed => 'فشل الإرسال، حاول مجددًا';

  @override
  String get profilePhotoRequired => 'أضف صورتك';

  @override
  String get profilePhotoRequiredSub => 'مطلوبة للمتابعة. ستكون مرئية للإرسال.';

  @override
  String get profilePhotoConfirm => 'تأكيد';

  @override
  String get metric_delivered => 'تم التوصيل';

  @override
  String get metric_failed => 'فشل';

  @override
  String get metric_total => 'الإجمالي';

  @override
  String ws_delivery_assigned(Object client) {
    return 'تم تعيين شحنة — $client';
  }

  @override
  String get ws_new_delivery => 'تم تعيين شحنة جديدة';

  @override
  String ws_delivery_removed(Object client) {
    return 'تم إزالة شحنة — $client';
  }

  @override
  String get ws_delivery_removed_generic => 'تم إزالة شحنة من رحلتك';

  @override
  String ws_route_assigned(Object route) {
    return 'تم تعيين الرحلة $route — يرجى مراجعتها قبل الانطلاق.';
  }

  @override
  String ws_route_cancelled(Object route) {
    return 'تم إلغاء الرحلة $route.';
  }

  @override
  String ws_route_reassigned_away(Object route) {
    return 'تم نقل الرحلة $route لسائق آخر.';
  }

  @override
  String ws_route_reassigned_to_you(Object route) {
    return 'تم إعادة تعيين الرحلة $route إليك!';
  }

  @override
  String ws_stop_added(Object client, Object route) {
    return 'تم إضافة $client إلى الرحلة $route.';
  }

  @override
  String ws_pickup_overdue(Object client, Object count) {
    return 'تأخر التحميل — مستودع $client ($count).';
  }

  @override
  String ws_stop_removed(Object client, Object ref, Object route, Object why) {
    return 'تم إزالة $client$ref من الرحلة $route$why.';
  }

  @override
  String ws_route_updated(Object route) {
    return 'تم تحديث الرحلة $route.';
  }

  @override
  String ws_stops_transferred_out(Object route) {
    return 'تم إزالة محطات من رحلتك $route.';
  }

  @override
  String ws_stops_transferred_in(Object route) {
    return 'تم إضافة محطات جديدة إلى رحلتك $route.';
  }

  @override
  String get ws_generic_route => 'رحلتك';

  @override
  String ws_handoff_incoming(Object name, Object ref) {
    return 'استلام مطلوب — الطرد $ref من $name';
  }

  @override
  String ws_handoff_outgoing(Object name, Object ref) {
    return 'للتسليم — الطرد $ref إلى $name';
  }

  @override
  String ws_handoff_confirmed(Object ref) {
    return 'تم تأكيد التسليم — الطرد $ref';
  }

  @override
  String ws_handoff_cancelled(Object ref) {
    return 'أُلغي التسليم — الطرد $ref';
  }

  @override
  String get ws_handoff_other => 'سائق';

  @override
  String get handoff_action_scan => 'مسح';

  @override
  String get handoff_action_show => 'إظهار الرمز';

  @override
  String get handoff_inbox_title => 'تحويلاتي';

  @override
  String get handoff_inbox_incoming => 'للاستلام';

  @override
  String get handoff_inbox_outgoing => 'للتسليم';

  @override
  String get handoff_inbox_from => 'من';

  @override
  String get handoff_inbox_to => 'التسليم إلى';

  @override
  String get handoff_inbox_empty_title => 'لا توجد تحويلات';

  @override
  String get handoff_inbox_empty_sub => 'ستظهر تحويلات الطرود هنا.';

  @override
  String get handoff_inbox_error => 'تعذّر تحميل التحويلات';

  @override
  String get handoff_inbox_retry => 'إعادة المحاولة';

  @override
  String get handoff_manual_action => 'إدخال الرمز';

  @override
  String get handoff_manual_title => 'رمز التحويل';

  @override
  String get handoff_manual_hint => 'ABC123';

  @override
  String get handoff_manual_confirm => 'تأكيد';

  @override
  String get handoff_manual_success => 'تم تأكيد التحويل';

  @override
  String get handoff_manual_error => 'رمز غير صالح أو منتهٍ';

  @override
  String get splash_sub => 'إدارة العمليات اللوجستية';

  @override
  String get splash_loading => 'جارٍ التحميل…';

  @override
  String get splash_copyright => '© ٢٠٢٦ العمليات اللوجستية ASM';

  @override
  String get login_driver_space => 'AsmTrack Driver';

  @override
  String get login_secure_access => 'دخول آمن · AsmOne';

  @override
  String get login_auth_header => 'المصادقة';

  @override
  String get login_auth_desc => 'سيتم إعادة توجيهك إلى صفحة تسجيل الدخول الآمن للتحقق من هويتك.';

  @override
  String get login_action_connect => 'تسجيل الدخول';

  @override
  String get login_action_connecting => 'جاري الاتصال...';

  @override
  String get login_action_setup => 'إعداد حسابي';

  @override
  String get login_action_change_workspace => 'تغيير فضاء العمل';

  @override
  String get login_action_setup_sub => 'أول تسجيل · تعيين كلمة المرور';

  @override
  String get login_action_change_workspace_sub => 'الاتصال بخادم آخر';

  @override
  String get login_secure_sso => 'دخول آمن · ASM Track';

  @override
  String get login_version => 'الإصدار';

  @override
  String get login_failed_error => 'فشلت عملية المصادقة. تحقق من بيانات الاعتماد الخاصة بك.';

  @override
  String get loginServerUrl => 'رابط الخادم';

  @override
  String get loginServerUrlHint => 'http://192.168.1.10  (محلي)  ·  https://dev.asm…';

  @override
  String get loginServerUrlDesc => 'تتبع المصادقة هذا المضيف تلقائيًا.';

  @override
  String get loginServerUrlInvalid => 'رابط غير صالح (مثال: http://192.168.1.10)';

  @override
  String get loginServerSave => 'حفظ';

  @override
  String get loginServerCancel => 'إلغاء';

  @override
  String get loginEmailLabel => 'البريد الإلكتروني';

  @override
  String get loginPasswordLabel => 'كلمة المرور';

  @override
  String get route_swipe_start => 'اسحب لبدء الجولة';

  @override
  String get route_swipe_load => 'اسحب للتحميل';

  @override
  String get route_swipe_confirm_load => 'اسحب لتأكيد التحميل';

  @override
  String get route_all_stops_done => 'تم إنجاز جميع النقاط';

  @override
  String get route_download_pdf => 'تحميل PDF';

  @override
  String get route_navigate => 'تنقّل';

  @override
  String get route_finished => 'انتهت الجولة';

  @override
  String get route_stops_log => 'سجل النقاط';

  @override
  String route_load_parcels(Object count, Object depot) {
    return 'تحميل $count طرود — مستودع $depot';
  }

  @override
  String get route_no_stops => 'لا توجد نقاط مهيأة.';

  @override
  String get route_empty_title => 'لا توجد رحلة نشطة';

  @override
  String get route_empty_subtitle => 'ستظهر رحلتك هنا بمجرد تعيينها من قِبَل التوزيع.';

  @override
  String get routeRefresh => 'تحديث';

  @override
  String get routeStops => 'الوقفات';

  @override
  String get routeStop => 'محطة';

  @override
  String get routeStopsCount => 'محطات';

  @override
  String get routeConfirmDelivery => 'تأكيد التوصيل';

  @override
  String get routeLoading => 'جاري تحميل الجولة…';

  @override
  String get delivery_detail_title => 'تفاصيل الشحنة';

  @override
  String get return_pickup_badge => 'إرجاع';

  @override
  String get return_pickup_title => 'استلام المرتجع';

  @override
  String get delivery_detail_loading => 'جاري تحميل الشحنة...';

  @override
  String get delivery_detail_load_failed => 'فشل تحميل الشحنة';

  @override
  String get delivery_detail_retry => 'إعادة المحاولة';

  @override
  String get delivery_detail_fail_report => 'الإبلاغ عن فشل';

  @override
  String get delivery_detail_fail_select => 'اختر سبب فشل التوصيل.';

  @override
  String get delivery_detail_comment_hint => 'تعليق إضافي (اختياري)';

  @override
  String get delivery_detail_fail_submit => 'تقديم تقرير الفشل';

  @override
  String get delivery_detail_pod_title => 'إثبات التسليم';

  @override
  String get delivery_detail_fail_reason => 'سبب الفشل';

  @override
  String get delivery_detail_cancel_reason => 'سبب الإلغاء';

  @override
  String get delivery_detail_history_title => 'سجل الحالات';

  @override
  String get delivery_detail_articles => 'سلع';

  @override
  String get delivery_detail_scheduled => 'مجدولة';

  @override
  String get delivery_detail_content => 'محتويات الطرد';

  @override
  String get delivery_detail_timeline => 'السجل الزمني';

  @override
  String get delivery_detail_ts_scheduled => 'مجدولة';

  @override
  String get delivery_detail_ts_picked_up => 'تم الاستلام';

  @override
  String get delivery_detail_ts_in_transit => 'في الطريق';

  @override
  String get delivery_detail_ts_delivered => 'تم التوصيل';

  @override
  String get delivery_detail_ts_failed => 'فشلت';

  @override
  String get delivery_detail_ts_cancelled => 'ملغاة';

  @override
  String get delivery_detail_ts_created => 'تم إنشاؤها';

  @override
  String get delivery_detail_pending_dispatch => 'في انتظار التوزيع';

  @override
  String get delivery_detail_pickup_package => 'استلام الطرد';

  @override
  String get delivery_detail_navigate => 'الملاحة';

  @override
  String get delivery_detail_start_transit => 'بدء الرحلة';

  @override
  String get delivery_detail_generate_handoff => 'إنشاء رمز التحويل';

  @override
  String get delivery_detail_submit_pod => 'تقديم إثبات التوصيل';

  @override
  String get delivery_detail_collect_return => 'استلام الطرد';

  @override
  String get delivery_detail_confirm_collection => 'تأكيد الاستلام';

  @override
  String get delivery_detail_locked => 'مغلق';

  @override
  String get delivery_detail_offline_queue => 'خارج الشبكة — سيتم الإرسال عند الاتصال';

  @override
  String get delivery_detail_error_prefix => 'خطأ';

  @override
  String get delivery_detail_unauthorized_link => 'هذه الشحنة غير معينة لك.';

  @override
  String get deliveryItem => 'سلعة';

  @override
  String get deliveryItems => 'عناصر';

  @override
  String get deliveryOpen => 'عرض';

  @override
  String get deliveryOrder => 'طلب';

  @override
  String get deliveryPackageTransferred => 'طرد محوّل إليك';

  @override
  String get deliveryHandoffScanHint => 'عند الاستلام، امسح رمز QR الخاص بالسائق المرسل لتأكيد الاستلام. يمكنك متابعة عملك في هذه الأثناء.';

  @override
  String get deliveryScanSenderQr => 'امسح رمز المرسل';

  @override
  String get pod_title => 'إثبات التوصيل';

  @override
  String get pod_pdf_open_error => 'لا يمكن فتح ملف الـ PDF. لم يتم تثبيت تطبيق قارئ PDF.';

  @override
  String get pod_pdf_download_error => 'حدث خطأ أثناء تحميل إذن التسليم.';

  @override
  String get pod_step_1 => '1. اطبع إذن التسليم واطلب من العميل التوقيع عليه.';

  @override
  String get pod_step_2 => '2. التقط صورة لإذن التسليم الموقع.';

  @override
  String get pod_step_3 => '3. التقط صورة لتسليم الطرد.';

  @override
  String get pod_view_print_bl => 'عرض / طباعة إذن التسليم';

  @override
  String get pod_downloading => 'جاري التحميل...';

  @override
  String get pod_photo_bl_title => 'إذن التسليم الموقع';

  @override
  String get pod_photo_bl_sub => 'التقط صورة لإذن التسليم الموقع من العميل';

  @override
  String get pod_photo_pkg_title => 'تسليم الطرد';

  @override
  String get pod_photo_pkg_sub => 'التقط صورة للطرد عند التسليم';

  @override
  String get pod_photo_take => 'التقاط صورة';

  @override
  String get pod_photo_retake => 'إعادة الالتقاط';

  @override
  String get pod_photo_delete => 'حذف';

  @override
  String get pod_photo_tap_hint => 'انقر لالتقاط صورة';

  @override
  String get pod_photo_access_error => 'لا يمكن الوصول إلى الكاميرا.';

  @override
  String get pod_comments_label => 'تعليقات (رمز الباب، اسم المستلم، إلخ.)';

  @override
  String get pod_gps_label => 'إرفاق موقع GPS';

  @override
  String get pod_gps_sub => 'يتم إرسال الإحداثيات مرة واحدة فقط عند التقديم.';

  @override
  String get pod_partial_label => 'توصيل جزئي';

  @override
  String get pod_partial_sub => 'قم بالتفعيل إذا لم يتم توصيل بعض السلع.';

  @override
  String get pod_item_outcome_header => 'النتيجة لكل سلعة:';

  @override
  String get pod_delivered_qty => 'الكمية المسلمة';

  @override
  String get pod_reason_label => 'السبب *';

  @override
  String get pod_reason_partial => 'السبب — توصيل جزئي *';

  @override
  String get pod_item_comment_hint => 'تعليق على هذه السلعة (اختياري)';

  @override
  String get pod_reason_mandatory => 'السبب إلزامي لـ:';

  @override
  String get pod_photos_mandatory => 'الصورتان إلزاميتان.';

  @override
  String get pod_confirm_delivery => 'تأكيد التوصيل';

  @override
  String get pod_success_message => 'تم تقديم إثبات التوصيل بنجاح.';

  @override
  String get podCameraTake => 'التقاط صورة الكاميرا';

  @override
  String get podGalleryChoose => 'اختيار من معرض الصور';

  @override
  String get podComment => 'تعليق';

  @override
  String get podCommentOptional => 'تعليق (اختياري)';

  @override
  String get calendarRoutes => 'جولات';

  @override
  String get calendarRoute => 'جولة';

  @override
  String get calendarStops => 'محطات';

  @override
  String get calendarDelivered => 'تم التوصيل';

  @override
  String get calendarAmount => 'المبلغ';

  @override
  String get calendarRouteCancelled => 'جولة ملغاة';

  @override
  String get calendarItems => 'عناصر';

  @override
  String get calendarLoadItemsError => 'تعذّر تحميل العناصر';

  @override
  String get calendarNoItems => 'لا توجد عناصر';

  @override
  String get calendarOpenRoute => 'فتح الجولة';

  @override
  String get handoffScannerScanSenderQr => 'امسح رمز المرسل';

  @override
  String get handoffScannerAlignHint => '_alignHint_';

  @override
  String get handoffScannerHoldAligned => 'holdAligned_';

  @override
  String get handoffScannerReading => 'reading_';

  @override
  String get handoffScannerValidating => 'validating_';

  @override
  String get handoffScannerSuccess => 'success_';

  @override
  String get handoffScannerSuccessBody => 'successBody_';

  @override
  String get handoffScannerInvalidQr => 'invalidQr_';

  @override
  String get handoffScannerExpired => 'expired_';

  @override
  String get handoffScannerUsed => 'used_';

  @override
  String get handoffScannerNotForYou => 'notForYou_';

  @override
  String get handoffScannerUpdated => 'updated_';

  @override
  String get handoffScannerNetworkError => 'networkError_';

  @override
  String get handoffScannerFailed => 'failed_';

  @override
  String get handoffScannerCameraDenied => 'cameraDenied_';

  @override
  String get handoffScannerCameraUnavailable => 'cameraUnavailable_';

  @override
  String get handoffScannerCameraDeniedHint => 'cameraDeniedHint_';

  @override
  String get handoffScannerCameraError => 'cameraError_';

  @override
  String get handoffTokenUnauthorized => 'unauthorized_';

  @override
  String get handoffTokenNoPending => 'noPending_';

  @override
  String get handoffTokenNetworkError => 'networkError_';

  @override
  String get handoffTokenGenerateFailed => 'generateFailed_';

  @override
  String get handoffTokenAuthTitle => 'authTitle_';

  @override
  String get handoffTokenAuthHint => 'authHint_';

  @override
  String get handoffTokenGenerating => 'generating_';

  @override
  String get handoffTokenClose => 'إغلاق';

  @override
  String get handoffTokenTokenLabel => 'الرمز: ';

  @override
  String get handoffTokenExpiresIn => 'ينتهي خلال 5 دقائق';

  @override
  String get handoffTokenExpiresInFormat => 'ينتهي خلال MM:SS';

  @override
  String get handoffTokenExpired => 'انتهت صلاحية هذا الرمز.';

  @override
  String get handoffTokenGenerateNew => 'إنشاء رمز جديد';

  @override
  String get handoffTokenRetry => 'إعادة المحاولة';

  @override
  String get historyLoading => 'جاري تحميل السجل...';

  @override
  String get historyOfflineTitle => 'الأرشيف غير متصل';

  @override
  String get historyRetry => 'إعادة المحاولة';

  @override
  String get historyOrder => 'طلب';

  @override
  String get historyArticles => 'عناصر';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeMinutesAgo(Object minutes) {
    return 'منذ $minutes د';
  }

  @override
  String timeHoursAgo(Object hours) {
    return 'منذ $hours س';
  }

  @override
  String timeDaysAgo(Object days) {
    return 'منذ $days ي';
  }

  @override
  String get offlinePendingUpdates => 'تعديلات معلقة';

  @override
  String get offlineConnectionRestored => 'تم استعادة الاتصال · جاري المزامنة...';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'تسجيل سائق';

  @override
  String get registerFullName => 'الاسم الكامل';

  @override
  String get registerRequired => 'مطلوب';

  @override
  String get registerPhoneLabel => 'رقم الهاتف';

  @override
  String get registerPassword => 'كلمة المرور';

  @override
  String get registerMinChars => '6 أحرف على الأقل';

  @override
  String get registerSubmitting => 'جاري التسجيل...';

  @override
  String get registerCreateAccount => 'إنشاء حساب';

  @override
  String get registerHasAccount => 'لديك حساب بالفعل؟';

  @override
  String get registerSignIn => 'تسجيل الدخول';

  @override
  String get setupEnterCode => 'أدخل رمز التنشيط';

  @override
  String get setupServerError => 'الخادم غير متاح — تحقق من اتصالك';

  @override
  String get setupCodeNotFound => 'الرمز غير موجود — تواصل مع مسؤولك';

  @override
  String get setupCodeExpired => 'انتهت صلاحية الرمز — اطلب رمزاً جديداً';

  @override
  String get setupCodeUsed => 'تم استخدام هذا الرمز بالفعل';

  @override
  String get setupCodeInvalidFormat => 'تنسيق رمز غير صالح (متوقع UUID)';

  @override
  String get setupCodeInvalid => 'رمز غير صالح أو منتهي الصلاحية';

  @override
  String get setupEnterPhone => 'أدخل رقم هاتفك';

  @override
  String get setupCodeSent => 'تم إرسال رمز التنشيط عبر البريد الإلكتروني.';

  @override
  String get setupCodeResent => 'تم إرسال رمز تنشيط جديد عبر البريد الإلكتروني.';

  @override
  String get setupPhoneNotFound => 'الهاتف غير موجود أو تم تنشيطه بالفعل';

  @override
  String get setupAccountActivated => 'تم تنشيط الحساب! سجل الدخول برقم هاتفك.';

  @override
  String get setupActivationFailed => 'فشل التنشيط. تحقق من الرمز وحاول مرة أخرى.';

  @override
  String get setupSignIn => 'تسجيل الدخول';

  @override
  String get setupConfigureAccount => 'إعداد حسابي';

  @override
  String get setupActivationTitle => 'تنشيط السائق';

  @override
  String get setupActivationSubtitle => 'أدخل رمز التنشيط المستلم عبر البريد الإلكتروني، ثم اختر كلمة المرور.';

  @override
  String get setupActivationCode => 'رمز التنشيط';

  @override
  String get setupValidateCode => 'التحقق من الرمز';

  @override
  String get setupNoCode => 'لم تتلقَ الرمز؟';

  @override
  String get setupYourPhone => 'هاتفك';

  @override
  String get setupResendCode => 'إعادة إرسال الرمز';

  @override
  String setupWelcome(Object name) {
    return 'مرحباً، $name';
  }

  @override
  String get setupPassword => 'كلمة المرور';

  @override
  String get setupPasswordMin => '6 أحرف كحد أدنى';

  @override
  String get setupConfirmPassword => 'تأكيد كلمة المرور';

  @override
  String get setupConfirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get setupPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get setupActivating => 'جاري التنشيط...';

  @override
  String get setupActivateAccount => 'تنشيط حسابي';

  @override
  String get setupNoCodeReceived => 'لم تتلقَّ الرمز؟';

  @override
  String get setupPhoneHint => 'هاتفك';

  @override
  String get monthJanuary => 'يناير';

  @override
  String get monthFebruary => 'فبراير';

  @override
  String get monthMarch => 'مارس';

  @override
  String get monthApril => 'أبريل';

  @override
  String get monthMay => 'ماي';

  @override
  String get monthJune => 'جوان';

  @override
  String get monthJuly => 'جويلية';

  @override
  String get monthAugust => 'أوت';

  @override
  String get monthSeptember => 'سبتمبر';

  @override
  String get monthOctober => 'أكتوبر';

  @override
  String get monthNovember => 'نوفمبر';

  @override
  String get monthDecember => 'ديسمبر';

  @override
  String get dayMonday => 'الإثنين';

  @override
  String get dayTuesday => 'الثلاثاء';

  @override
  String get dayWednesday => 'الأربعاء';

  @override
  String get dayThursday => 'الخميس';

  @override
  String get dayFriday => 'الجمعة';

  @override
  String get daySaturday => 'السبت';

  @override
  String get daySunday => 'الأحد';

  @override
  String get calendarToday => 'اليوم';

  @override
  String get calendarTomorrow => 'غداً';

  @override
  String get calendarClose => 'إغلاق';

  @override
  String get calendarClient => 'العميل';

  @override
  String get statusUnscheduled => 'غير مجدول';

  @override
  String get statusScheduled => 'مجدول';

  @override
  String get statusPickedUp => 'تم التحميل';

  @override
  String get statusInTransit => 'في الطريق';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusPartial => 'جزئي';

  @override
  String get statusFailed => 'فشل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String calendarWeek(Object week) {
    return 'الأسبوع $week';
  }

  @override
  String get calendarRouteCancelledTitle => 'تم إلغاء الجولة';

  @override
  String calendarRouteCancelledBody(Object name) {
    return 'تم إلغاء الجولة \"$name\" من قبل الموزع.';
  }

  @override
  String get calendarNoRoutes => 'لا توجد جولات';

  @override
  String get calendarLoadRoutesError => 'تعذّر تحميل الجولات';

  @override
  String get calendarCheckConnection => 'تحقق من اتصالك وحاول مرة أخرى.';

  @override
  String get statusScheduledLabel => 'مجدول';

  @override
  String get statusPickedUpLabel => 'تم التحميل';

  @override
  String get statusPickedUpReturn => 'تم استلام الطرد';

  @override
  String get statusInTransitLabel => 'في الطريق';

  @override
  String get statusAwaitingHandoff => 'في انتظار التسليم اليدوي';

  @override
  String get statusDeliveredLabel => 'تم التوصيل';

  @override
  String get statusDeliveredReturn => 'تم الاستلام في المستودع';

  @override
  String get statusPartiallyDelivered => 'تم التوصيل جزئياً';

  @override
  String get statusFailedLabel => 'فشل';

  @override
  String get statusCancelledLabel => 'ملغي';

  @override
  String get routeStatusDraft => 'مسودة';

  @override
  String get routeStatusValidated => 'موثقة';

  @override
  String get routeStatusInProgress => 'قيد التنفيذ';

  @override
  String get routeStatusClosed => 'مغلقة';

  @override
  String get routeStatusCancelledR => 'ملغاة';

  @override
  String get stopStatusPending => 'قيد الانتظار';

  @override
  String get stopStatusArrived => 'وصل';

  @override
  String get stopStatusCompleted => 'مهمة مكتملة';

  @override
  String get stopStatusFailed => 'فشل';

  @override
  String get stopStatusPartial => 'جزئي';

  @override
  String get routeDefaultName => 'جولة';

  @override
  String get reasonClientAbsent => 'العميل غائب';

  @override
  String get reasonClientRefused => 'رفض العميل';

  @override
  String get reasonWrongAddress => 'عنوان خاطئ';

  @override
  String get reasonPackageDamaged => 'تالف';

  @override
  String get reasonOther => 'آخر';

  @override
  String get podOutcomeDelivered => 'تم التوصيل';

  @override
  String get podOutcomeRefused => 'مرفوض';

  @override
  String get podOutcomeDamaged => 'تالف';

  @override
  String get podOutcomeMissing => 'مفقود';

  @override
  String get podNotesTitle => 'تعليق';

  @override
  String get podNotesHint => 'تعليق (اختياري)';

  @override
  String routeTimeFrom(Object time) {
    return 'من $time';
  }

  @override
  String routeTimeBefore(Object time) {
    return 'قبل $time';
  }

  @override
  String routeStopCount(Object count) {
    return '$count محطات';
  }

  @override
  String routeStopCountSingular(Object count) {
    return '$count محطة';
  }

  @override
  String get routeSwipeStartHint => 'اسحب لبدء الجولة';

  @override
  String get routeSwipeLoadHint => 'اسحب للتحميل';

  @override
  String get routeStopsHeader => 'الوقفات';

  @override
  String get routeAllStopsDone => 'جميع المحطات مكتملة';

  @override
  String get routeFinishedLabel => 'الجولة مكتملة';

  @override
  String get routeOfflineBanner => 'وضع عدم الاتصال — بيانات مؤقتة';

  @override
  String get routeConfirmPickup => 'أكّد التحميل من المستودع أولاً';

  @override
  String get routeLoadingRoute => 'جاري تحميل الجولة...';

  @override
  String get routeLoadError => 'تعذّر تحميل الجولة';

  @override
  String get routeRetry => 'إعادة المحاولة';

  @override
  String get routeInfoDate => 'التاريخ';

  @override
  String get routeInfoSchedule => 'الجدول';

  @override
  String get routeInfoZone => 'المنطقة';

  @override
  String get routeInfoCity => 'المدينة';

  @override
  String get routeInfoStops => 'المحطات';

  @override
  String get routeInfoVehicle => 'المركبة';

  @override
  String get routeNoStopsConfigured => 'لا توجد محطات.';

  @override
  String routePickupLabel(Object depot) {
    return 'التحميل — المستودع $depot';
  }

  @override
  String get historyOffline => 'السجل غير متصل';

  @override
  String get historyEmpty => 'لا توجد سجلات';

  @override
  String get historyEmptySubtitle => 'ستظهر التوصيلات المكتملة هنا.';

  @override
  String get historySectionTitle => 'السجل';

  @override
  String historyRecordCount(Object count) {
    return '$count سجلات';
  }

  @override
  String get historyFilterDate => 'تصفية حسب التاريخ...';

  @override
  String get historyNoAddress => 'بدون عنوان';

  @override
  String get historyItems => 'عناصر';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterDelivered => 'تم التوصيل';

  @override
  String get filterFailed => 'فشل';

  @override
  String get filterCancelled => 'ملغي';

  @override
  String get routeOfflineAction => 'غير متصل — سيتم الإرسال عند إعادة الاتصال';

  @override
  String routeErrorSnackbar(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get routeOfflineUnavailable => 'غير متصل';

  @override
  String get routePdfFailed => 'فشل تحميل PDF';

  @override
  String get routeGenerateQr => 'إنشاء رمز';

  @override
  String get routeScanQr => 'مسح الرمز';

  @override
  String get routeScannerOffline => 'الماسح غير متاح في وضع عدم الاتصال';

  @override
  String get deliveryNoAddress => 'بدون عنوان';

  @override
  String get statusHistoryDelivered => 'تم التوصيل';

  @override
  String get statusHistoryPartial => 'جزئي';

  @override
  String get statusHistoryFailed => 'فشل';

  @override
  String get statusHistoryCancelled => 'ملغي';

  @override
  String get statusHistoryInTransit => 'في الطريق';

  @override
  String get statusHistoryPickedUp => 'تم الاستلام';

  @override
  String get statusHistoryScheduled => 'مجدول';

  @override
  String get statusHistoryUnknown => 'غير معروف';

  @override
  String get handoffTransferredToYou => 'تم تحويل الطرد إليك';

  @override
  String get handoffScanInstructions => 'عند الاستلام، امسح رمز QR للسائق المرسل للتأكيد.';

  @override
  String get handoffScanSenderQr => 'مسح رمز QR للمرسل';

  @override
  String get bonLivraisonOffline => 'غير متاح في وضع عدم الاتصال';

  @override
  String get bonLivraisonOpen => 'فتح';

  @override
  String get handoffUnauthorized => 'لست مخولاً لإنشاء رمز لهذا الطرد.';

  @override
  String get handoffNoTransfer => 'لا يوجد تحويل معلق لهذا الطرد. حدّث وأعد المحاولة.';

  @override
  String get handoffConnectionError => 'فشل الاتصال. تحقق من شبكتك وأعد المحاولة.';

  @override
  String get handoffGenerateFailed => 'فشل إنشاء الرمز. يرجى إعادة المحاولة.';

  @override
  String get handoffAuthTitle => 'مصادقة التحويل';

  @override
  String get handoffAuthDescription => 'اطلب من السائق الآخر مسح هذا الرمز لتأكيد التحويل.';

  @override
  String get handoffGeneratingToken => 'جاري إنشاء الرمز الآمن...';

  @override
  String get handoffTokenLabel => 'الرمز: ';

  @override
  String handoffExpiresIn(Object time) {
    return 'ينتهي خلال $time';
  }

  @override
  String get handoffCodeExpired => 'انتهت صلاحية هذا الرمز.';

  @override
  String get handoffNewCode => 'إنشاء رمز جديد';

  @override
  String get handoffRetry => 'إعادة المحاولة';

  @override
  String get handoffScanGuidance => 'مسح رمز QR للمرسل';

  @override
  String get handoffScanDescription => 'ضع رمز QR للسائق الآخر في الإطار لتأكيد التحويل.';

  @override
  String get handoffKeepAligned => 'أبقِ الرمز مصطفاً...';

  @override
  String get handoffReading => 'جاري القراءة';

  @override
  String get handoffValidating => 'جاري التحقق من التحويل...';

  @override
  String get handoffTransferConfirmed => 'تم تأكيد التحويل';

  @override
  String get handoffTransferComplete => 'تم تحويل الطرد إليك.';

  @override
  String get handoffInvalidQr => 'هذا الرمز ليس رمز تحويل صالح.';

  @override
  String get handoffTokenExpiredDetail => 'انتهت صلاحية الرمز. اطلب من المرسل إنشاء رمز جديد.';

  @override
  String get handoffTokenUsed => 'رمز غير صالح أو مستخدم بالفعل. أعد المحاولة برمز جديد.';

  @override
  String get handoffNotForYou => 'هذا التحويل ليس لك.';

  @override
  String get handoffTransferUpdated => 'تم تحديث هذا التحويل للتو. حدّث وأعد المحاولة.';

  @override
  String get cameraAccessDenied => 'تم رفض الوصول إلى الكاميرا';

  @override
  String get cameraUnavailable => 'الكاميرا غير متاحة';

  @override
  String get cameraPermInstructions => 'امنح صلاحية الكاميرا في الإعدادات لمسح التحويلات.';

  @override
  String get cameraStartFailed => 'تعذّر تشغيل الكاميرا. أعد المحاولة لاحقاً.';

  @override
  String get setupEnterCodeHint => 'أدخل رمز التنشيط';

  @override
  String get setupServerInaccessible => 'الخادم غير متاح — تحقق من اتصالك';

  @override
  String get setupCodeAlreadyUsed => 'هذا الرمز مستخدم بالفعل';

  @override
  String get setupInvalidFormat => 'صيغة الرمز غير صالحة (مطلوب UUID)';

  @override
  String get setupInvalidOrExpired => 'رمز غير صالح أو منتهي الصلاحية';

  @override
  String get setupEnterPhoneHint => 'أدخل رقم هاتفك';

  @override
  String get setupCodeSentEmail => 'تم إرسال رمز التنشيط بالبريد الإلكتروني.';

  @override
  String get setupCodeResentEmail => 'تم إرسال رمز تنشيط جديد بالبريد الإلكتروني.';

  @override
  String get setupPhoneNotFoundOrActive => 'الهاتف غير موجود أو مُنشّط بالفعل';

  @override
  String get setupPasswordLabel => 'كلمة المرور';

  @override
  String get registerDescription => 'أكمل معلوماتك للبدء.';

  @override
  String get registerPhone => 'رقم الهاتف';

  @override
  String get registerPasswordField => 'كلمة المرور';

  @override
  String get registerButton => 'تسجيل';

  @override
  String get registerLoading => 'جاري التسجيل...';

  @override
  String get deliveryAccept => 'قبول';

  @override
  String get deliveryNoAddressProvided => 'بدون عنوان';

  @override
  String get podTakePhoto => 'التقط صورة';

  @override
  String get podChooseGallery => 'اختر من المعرض';

  @override
  String get podPhotosRequired => 'الصورتان مطلوبتان';

  @override
  String profileError(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get calendarTodayButton => 'اليوم';

  @override
  String calendarProgress(Object percent) {
    return '$percent% مكتمل';
  }

  @override
  String calendarStopCount(Object count) {
    return '$count محطة (ות)';
  }
}
