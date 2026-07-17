// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AsmTrack Driver';

  @override
  String get tabRoute => 'Tournée';

  @override
  String get tabCalendar => 'Calendrier';

  @override
  String get tabProfile => 'Profil';

  @override
  String get offlineBanner =>
      'Hors ligne — les actions seront synchronisées à la reconnexion';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'Aucune notification';

  @override
  String get statusOnline => 'En service';

  @override
  String get status_on_break => 'En pause';

  @override
  String get status_offline => 'Hors ligne';

  @override
  String get status_online_upper => 'EN SERVICE';

  @override
  String get status_on_break_upper => 'EN PAUSE';

  @override
  String get status_offline_upper => 'HORS LIGNE';

  @override
  String get action_start_shift => 'Prendre mon service';

  @override
  String get action_take_break => 'Prendre une pause';

  @override
  String get action_end_day => 'Terminer ma journée';

  @override
  String get action_resume_service => 'Reprendre le service';

  @override
  String get profile_title => 'PROFIL';

  @override
  String get driver_id => 'ID Chauffeur';

  @override
  String get phone => 'Téléphone';

  @override
  String get last_ping => 'Dernier ping';

  @override
  String get gps => 'GPS';

  @override
  String get section_availability => 'DISPONIBILITÉ';

  @override
  String get section_performance => 'PERFORMANCE';

  @override
  String get section_account => 'COMPTE';

  @override
  String get section_actions => 'ACTIONS';

  @override
  String get language_setting => 'Langue';

  @override
  String get send_location => 'Envoyer ma position';

  @override
  String get change_password => 'Changer le mot de passe';

  @override
  String get profileChangePhoto => 'Changer la photo';

  @override
  String get profileTakePhoto => 'Prendre une photo';

  @override
  String get profileChooseGallery => 'Choisir dans la galerie';

  @override
  String get profilePhotoCropTitle => 'Recadrer la photo de profil';

  @override
  String get profileSuccessRate => 'Taux de réussite';

  @override
  String get profileLoading => 'Chargement du profil…';

  @override
  String get profileUnavailable => 'Profil indisponible';

  @override
  String get profileRetry => 'Réessayer';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logout_confirm_title => 'Se déconnecter ?';

  @override
  String get logout_confirm_body =>
      'Vous devrez vous reconnecter pour accéder à vos livraisons.';

  @override
  String get cancel => 'Annuler';

  @override
  String get position_sent => 'Position envoyée au dispatch.';

  @override
  String get profileUploadFailed => 'Échec de l\'envoi, réessayez';

  @override
  String get profilePhotoRequired => 'Ajoutez votre photo';

  @override
  String get profilePhotoRequiredSub =>
      'Obligatoire pour continuer. Elle sera visible par le dispatching.';

  @override
  String get profilePhotoConfirm => 'Confirmer';

  @override
  String get metric_delivered => 'Livré';

  @override
  String get metric_failed => 'Échoué';

  @override
  String get metric_total => 'Total';

  @override
  String ws_route_assigned(Object route) {
    return 'Tournée $route assignée — consultez-la avant de partir.';
  }

  @override
  String ws_route_cancelled(Object route) {
    return 'La tournée $route a été annulée.';
  }

  @override
  String ws_route_reassigned_away(Object route) {
    return 'La tournée $route a été réaffectée à un autre chauffeur.';
  }

  @override
  String ws_route_reassigned_to_you(Object route) {
    return 'La tournée $route vous a été réaffectée !';
  }

  @override
  String ws_stop_added(Object client, Object route) {
    return '$client ajouté à $route.';
  }

  @override
  String ws_pickup_overdue(Object client, Object count) {
    return 'Chargement en retard — Dépôt $client ($count).';
  }

  @override
  String ws_stop_removed(Object client, Object ref, Object route, Object why) {
    return '$client$ref retiré de $route$why.';
  }

  @override
  String ws_route_updated(Object route) {
    return 'La tournée $route a été modifiée.';
  }

  @override
  String ws_stops_transferred_out(Object route) {
    return 'Des arrêts ont été retirés de $route.';
  }

  @override
  String ws_stops_transferred_in(Object route) {
    return 'De nouveaux arrêts ont été ajoutés à $route.';
  }

  @override
  String get ws_generic_route => 'votre tournée';

  @override
  String ws_handoff_incoming(Object name, Object ref) {
    return 'Réception requise — colis $ref de $name';
  }

  @override
  String ws_handoff_outgoing(Object name, Object ref) {
    return 'À remettre — colis $ref à $name';
  }

  @override
  String ws_handoff_confirmed(Object ref) {
    return 'Transfert confirmé — colis $ref';
  }

  @override
  String ws_handoff_cancelled(Object ref) {
    return 'Transfert annulé — colis $ref';
  }

  @override
  String get ws_handoff_other => 'un chauffeur';

  @override
  String get handoff_action_scan => 'Scanner';

  @override
  String get handoff_action_show => 'Afficher le code';

  @override
  String get handoff_inbox_title => 'Mes transferts';

  @override
  String get handoff_inbox_incoming => 'À recevoir';

  @override
  String get handoff_inbox_outgoing => 'À remettre';

  @override
  String get handoff_inbox_from => 'Reçu de';

  @override
  String get handoff_inbox_to => 'À remettre à';

  @override
  String get handoff_inbox_empty_title => 'Aucun transfert';

  @override
  String get handoff_inbox_empty_sub =>
      'Les transferts de colis apparaîtront ici.';

  @override
  String get handoff_inbox_error => 'Impossible de charger les transferts';

  @override
  String get handoff_inbox_retry => 'Réessayer';

  @override
  String get handoff_manual_action => 'Saisir le code';

  @override
  String get handoff_manual_title => 'Code de transfert';

  @override
  String get handoff_manual_hint => 'ABC123';

  @override
  String get handoff_manual_confirm => 'Confirmer';

  @override
  String get handoff_manual_success => 'Transfert confirmé';

  @override
  String get handoff_manual_error => 'Code invalide ou expiré';

  @override
  String get splash_sub => 'Pilotage logistique';

  @override
  String get splash_loading => 'Chargement…';

  @override
  String get splash_copyright => '(c) 2026 Opérations logistiques ASM';

  @override
  String get login_driver_space => 'AsmTrack Driver';

  @override
  String get login_secure_access => 'Accès sécurisé · AsmOne';

  @override
  String get login_auth_header => 'Authentification';

  @override
  String get login_auth_desc =>
      'Vous allez être redirigé vers la page de connexion sécurisée pour vous identifier.';

  @override
  String get login_action_connect => 'Se connecter';

  @override
  String get login_action_connecting => 'Connexion...';

  @override
  String get login_action_setup => 'Configurer mon compte';

  @override
  String get login_action_change_workspace => 'Changer d\'espace de travail';

  @override
  String get login_action_setup_sub =>
      'Première connexion · définir le mot de passe';

  @override
  String get login_action_change_workspace_sub =>
      'Se connecter à un autre serveur';

  @override
  String get login_secure_sso => 'Connexion sécurisée · ASM Track';

  @override
  String get login_version => 'Version';

  @override
  String get login_failed_error =>
      'Échec de l\'authentification. Vérifiez vos identifiants.';

  @override
  String get loginServerUrl => 'URL du serveur';

  @override
  String get loginServerUrlHint =>
      'http://192.168.1.10  (local)  ·  https://dev.asm…';

  @override
  String get loginServerUrlDesc =>
      'L\'authentification suit cet hôte automatiquement.';

  @override
  String get loginServerUrlInvalid => 'URL invalide (ex: http://192.168.1.10)';

  @override
  String get loginServerSave => 'Enregistrer';

  @override
  String get loginServerCancel => 'Annuler';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginPasswordLabel => 'Mot de passe';

  @override
  String get route_swipe_start => 'Glisser pour démarrer la tournée';

  @override
  String get route_swipe_load => 'Glisser pour charger';

  @override
  String get route_swipe_confirm_load => 'Glisser pour confirmer le chargement';

  @override
  String get route_all_stops_done => 'Tous les arrêts validés';

  @override
  String get route_download_pdf => 'Télécharger PDF';

  @override
  String get route_navigate => 'Naviguer';

  @override
  String get route_finished => 'Tournée terminée';

  @override
  String get route_stops_log => 'Journal des arrêts';

  @override
  String route_load_parcels(Object count, Object depot) {
    return 'Charger $count colis — Dépôt $depot';
  }

  @override
  String get route_no_stops => 'Aucun arrêt configuré.';

  @override
  String get route_empty_title => 'Aucune tournée en cours';

  @override
  String get route_empty_subtitle =>
      'Votre tournée apparaîtra ici une fois assignée par le dispatching.';

  @override
  String get routeRefresh => 'Actualiser';

  @override
  String get routeStops => 'ARRÊTS';

  @override
  String get routeStop => 'arrêt';

  @override
  String get routeStopsCount => 'arrêts';

  @override
  String get routeConfirmDelivery => 'Confirmer la livraison';

  @override
  String get routeLoading => 'Chargement de la tournée…';

  @override
  String get delivery_detail_title => 'Détails de la livraison';

  @override
  String get return_pickup_badge => 'Retour';

  @override
  String get return_pickup_title => 'Collecte retour';

  @override
  String get delivery_detail_loading => 'Chargement de la livraison…';

  @override
  String get delivery_detail_load_failed => 'Échec du chargement';

  @override
  String get delivery_detail_retry => 'Réessayer';

  @override
  String get delivery_detail_fail_report => 'Signaler un échec';

  @override
  String get delivery_detail_fail_select =>
      'Sélectionnez la raison de l\'échec de cette livraison.';

  @override
  String get delivery_detail_comment_hint =>
      'Commentaire supplémentaire (optionnel)';

  @override
  String get delivery_detail_fail_submit => 'Soumettre le rapport d\'échec';

  @override
  String get delivery_detail_pod_title => 'Preuve de livraison';

  @override
  String get delivery_detail_fail_reason => 'Raison de l\'échec';

  @override
  String get delivery_detail_cancel_reason => 'Raison de l\'annulation';

  @override
  String get delivery_detail_history_title => 'Historique des statuts';

  @override
  String get delivery_detail_articles => 'Articles';

  @override
  String get delivery_detail_scheduled => 'Planifiée';

  @override
  String get delivery_detail_content => 'Contenu du colis';

  @override
  String get delivery_detail_timeline => 'Chronologie';

  @override
  String get delivery_detail_ts_scheduled => 'Planifiée';

  @override
  String get delivery_detail_ts_picked_up => 'Ramassée';

  @override
  String get delivery_detail_ts_in_transit => 'En cours';

  @override
  String get delivery_detail_ts_delivered => 'Livrée';

  @override
  String get delivery_detail_ts_failed => 'Échouée';

  @override
  String get delivery_detail_ts_cancelled => 'Annulée';

  @override
  String get delivery_detail_ts_created => 'Créée';

  @override
  String get delivery_detail_pending_dispatch => 'En attente de dispatch';

  @override
  String get delivery_detail_pickup_package => 'Ramasser le colis';

  @override
  String get delivery_detail_navigate => 'Naviguer';

  @override
  String get delivery_detail_start_transit => 'Démarrer le trajet';

  @override
  String get delivery_detail_generate_handoff => 'Générer le code de transfert';

  @override
  String get delivery_detail_submit_pod => 'Soumettre la preuve de livraison';

  @override
  String get delivery_detail_locked => 'Clôturé';

  @override
  String get delivery_detail_offline_queue =>
      'Hors ligne — sera envoyé à la reconnexion';

  @override
  String get delivery_detail_error_prefix => 'Erreur';

  @override
  String get delivery_detail_unauthorized_link =>
      'Cette livraison ne vous est pas assignée.';

  @override
  String get deliveryItem => 'article';

  @override
  String get deliveryItems => 'articles';

  @override
  String get deliveryOpen => 'Ouvrir';

  @override
  String get deliveryOrder => 'Commande';

  @override
  String get deliveryPackageTransferred => 'Colis transféré vers vous';

  @override
  String get deliveryHandoffScanHint =>
      'À la réception, scannez le QR du chauffeur expéditeur pour confirmer. Vous pouvez continuer votre travail entre-temps.';

  @override
  String get deliveryScanSenderQr => 'Scanner le QR de l\'expéditeur';

  @override
  String get pod_title => 'Preuve de livraison';

  @override
  String get pod_pdf_open_error =>
      'Impossible d\'ouvrir le PDF. Aucune application PDF installée.';

  @override
  String get pod_pdf_download_error =>
      'Erreur lors du téléchargement du bon de livraison.';

  @override
  String get pod_step_1 =>
      '1. Imprimez le bon de livraison et faites-le signer par le client.';

  @override
  String get pod_step_2 => '2. Photographiez le bon signé.';

  @override
  String get pod_step_3 => '3. Photographiez la remise du colis.';

  @override
  String get pod_view_print_bl => 'Voir / Imprimer bon de livraison';

  @override
  String get pod_downloading => 'Téléchargement…';

  @override
  String get pod_photo_bl_title => 'Bon de livraison signé';

  @override
  String get pod_photo_bl_sub => 'Photographiez le bon signé par le client';

  @override
  String get pod_photo_pkg_title => 'Remise du colis';

  @override
  String get pod_photo_pkg_sub =>
      'Photographiez le colis au moment de la remise';

  @override
  String get pod_photo_take => 'Prendre une photo';

  @override
  String get pod_photo_retake => 'Reprendre';

  @override
  String get pod_photo_delete => 'Supprimer';

  @override
  String get pod_photo_tap_hint => 'Appuyer pour photographier';

  @override
  String get pod_photo_access_error =>
      'Impossible d\'accéder à l\'appareil photo.';

  @override
  String get pod_comments_label =>
      'Commentaires (code porte, nom personne, etc.)';

  @override
  String get pod_gps_label => 'Joindre la position GPS';

  @override
  String get pod_gps_sub =>
      'Coordonnées envoyées une seule fois à la soumission.';

  @override
  String get pod_partial_label => 'Livraison partielle';

  @override
  String get pod_partial_sub =>
      'Activez si certains articles n\'ont pas été livrés.';

  @override
  String get pod_item_outcome_header => 'Résultat par article :';

  @override
  String get pod_delivered_qty => 'Quantité livrée';

  @override
  String get pod_reason_label => 'Motif *';

  @override
  String get pod_reason_partial => 'Motif — livraison partielle *';

  @override
  String get pod_item_comment_hint => 'Commentaire sur cet article (optionnel)';

  @override
  String get pod_reason_mandatory => 'Raison obligatoire pour :';

  @override
  String get pod_photos_mandatory => 'Les 2 photos sont obligatoires.';

  @override
  String get pod_confirm_delivery => 'Confirmer la livraison';

  @override
  String get pod_success_message => 'POD transmis avec succès.';

  @override
  String get podCameraTake => 'Prendre une photo';

  @override
  String get podGalleryChoose => 'Choisir de la galerie';

  @override
  String get podComment => 'Commentaire';

  @override
  String get podCommentOptional => 'Commentaire (optionnel)';

  @override
  String get calendarRoutes => 'Tournées';

  @override
  String get calendarRoute => 'Tournée';

  @override
  String get calendarStops => 'Arrêts';

  @override
  String get calendarDelivered => 'Livrés';

  @override
  String get calendarAmount => 'Montant';

  @override
  String get calendarRouteCancelled => 'Tournée annulée';

  @override
  String get calendarItems => 'Articles';

  @override
  String get calendarLoadItemsError => 'Impossible de charger les articles';

  @override
  String get calendarNoItems => 'Aucun article';

  @override
  String get calendarOpenRoute => 'Ouvrir la tournée';

  @override
  String get handoffScannerScanSenderQr => 'Scanner le QR de l\'expéditeur';

  @override
  String get handoffScannerAlignHint =>
      'Alignez le code QR de l\'autre chauffeur dans le cadre pour confirmer le transfert de responsabilité.';

  @override
  String get handoffScannerHoldAligned => 'Maintenez le code bien aligné…';

  @override
  String get handoffScannerReading => 'Lecture en cours';

  @override
  String get handoffScannerValidating => 'Validation du transfert…';

  @override
  String get handoffScannerSuccess => 'Transfert confirmé';

  @override
  String get handoffScannerSuccessBody => 'Le colis vous a été transféré.';

  @override
  String get handoffScannerInvalidQr =>
      'Ce QR code n\'est pas un jeton de transfert valide.';

  @override
  String get handoffScannerExpired =>
      'Ce jeton a expiré. Demandez à l\'expéditeur d\'en générer un nouveau.';

  @override
  String get handoffScannerUsed =>
      'Jeton invalide ou déjà utilisé. Réessayez avec un nouveau code.';

  @override
  String get handoffScannerNotForYou => 'Ce transfert ne vous est pas destiné.';

  @override
  String get handoffScannerUpdated =>
      'Ce transfert vient d\'être mis à jour. Actualisez puis réessayez.';

  @override
  String get handoffScannerNetworkError =>
      'Connexion impossible. Vérifiez votre réseau et réessayez.';

  @override
  String get handoffScannerFailed => 'Échec du transfert. Veuillez réessayer.';

  @override
  String get handoffScannerCameraDenied => 'Accès à la caméra refusé';

  @override
  String get handoffScannerCameraUnavailable => 'Caméra indisponible';

  @override
  String get handoffScannerCameraDeniedHint =>
      'Autorisez l\'accès à la caméra dans les réglages pour scanner les transferts.';

  @override
  String get handoffScannerCameraError =>
      'Impossible de démarrer la caméra. Réessayez plus tard.';

  @override
  String get handoffTokenUnauthorized =>
      'Vous n\'êtes pas autorisé à générer un jeton pour ce colis.';

  @override
  String get handoffTokenNoPending =>
      'Aucun transfert en attente pour ce colis. Actualisez puis réessayez.';

  @override
  String get handoffTokenNetworkError =>
      'Connexion impossible. Vérifiez votre réseau et réessayez.';

  @override
  String get handoffTokenGenerateFailed =>
      'Impossible de générer le jeton. Veuillez réessayer.';

  @override
  String get handoffTokenAuthTitle => 'Authentification du transfert';

  @override
  String get handoffTokenAuthHint =>
      'Demandez à l\'autre chauffeur de scanner ce code pour confirmer le transfert de responsabilité.';

  @override
  String get handoffTokenGenerating => 'Génération du jeton sécurisé…';

  @override
  String get handoffTokenClose => 'Fermer';

  @override
  String get handoffTokenTokenLabel => 'Jeton : ';

  @override
  String get handoffTokenExpiresIn => 'Expire dans 5 minutes';

  @override
  String get handoffTokenExpiresInFormat => 'Expire dans MM:SS';

  @override
  String get handoffTokenExpired => 'Ce code a expiré.';

  @override
  String get handoffTokenGenerateNew => 'Générer un nouveau code';

  @override
  String get handoffTokenRetry => 'Réessayer';

  @override
  String get historyLoading => 'Chargement de l\'archive…';

  @override
  String get historyOfflineTitle => 'Historique hors ligne';

  @override
  String get historyRetry => 'Réessayer';

  @override
  String get historyOrder => 'Commande';

  @override
  String get historyArticles => 'Articles';

  @override
  String get timeJustNow => 'À l\'instant';

  @override
  String timeMinutesAgo(Object minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String timeHoursAgo(Object hours) {
    return 'Il y a ${hours}h';
  }

  @override
  String timeDaysAgo(Object days) {
    return 'Il y a ${days}j';
  }

  @override
  String get offlinePendingUpdates => 'modifications en attente';

  @override
  String get offlineConnectionRestored =>
      'Connexion rétablie · Synchronisation…';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle => 'Inscription chauffeur';

  @override
  String get registerFullName => 'Nom complet';

  @override
  String get registerRequired => 'Requis';

  @override
  String get registerPhoneLabel => 'Numéro de téléphone';

  @override
  String get registerPassword => 'Mot de passe';

  @override
  String get registerMinChars => 'Min 6 caractères';

  @override
  String get registerSubmitting => 'Inscription...';

  @override
  String get registerCreateAccount => 'Créer un compte';

  @override
  String get registerHasAccount => 'Vous avez déjà un compte ?';

  @override
  String get registerSignIn => 'Se connecter';

  @override
  String get setupEnterCode => 'Entrez votre code d\'activation';

  @override
  String get setupServerError =>
      'Serveur inaccessible — vérifiez votre connexion';

  @override
  String get setupCodeNotFound =>
      'Code non trouve - Contactez votre responsable';

  @override
  String get setupCodeExpired => 'Code expire - Demandez un nouveau code';

  @override
  String get setupCodeUsed => 'Ce code a déjà été utilisé';

  @override
  String get setupCodeInvalidFormat => 'Format de code invalide (UUID attendu)';

  @override
  String get setupCodeInvalid => 'Code invalide ou expiré';

  @override
  String get setupEnterPhone => 'Entrez votre numéro de téléphone';

  @override
  String get setupCodeSent => 'Un code d\'activation a été envoyé par email.';

  @override
  String get setupCodeResent =>
      'Un code d\'activation a été renvoyé par email.';

  @override
  String get setupPhoneNotFound => 'Téléphone non trouvé ou déjà activé';

  @override
  String get setupAccountActivated =>
      'Compte activé ! Connectez-vous avec votre numéro de téléphone.';

  @override
  String get setupActivationFailed =>
      'Activation échouée. Vérifiez votre code et réessayez.';

  @override
  String get setupSignIn => 'Se connecter';

  @override
  String get setupConfigureAccount => 'Configurer mon compte';

  @override
  String get setupActivationTitle => 'Activation chauffeur';

  @override
  String get setupActivationSubtitle =>
      'Entrez le code d\'activation reçu par email, puis choisissez votre mot de passe.';

  @override
  String get setupActivationCode => 'Code d\'activation';

  @override
  String get setupValidateCode => 'Valider le code';

  @override
  String get setupNoCode => 'Vous n\'avez pas reçu le code ?';

  @override
  String get setupYourPhone => 'Votre téléphone';

  @override
  String get setupResendCode => 'Renvoyer le code';

  @override
  String setupWelcome(Object name) {
    return 'Bienvenue, $name';
  }

  @override
  String get setupPassword => 'Mot de passe';

  @override
  String get setupPasswordMin => 'Minimum 6 caractères';

  @override
  String get setupConfirmPassword => 'Confirmer le mot de passe';

  @override
  String get setupConfirmPasswordHint => 'Répétez votre mot de passe';

  @override
  String get setupPasswordMismatch => 'Les mots de passe ne correspondent pas';

  @override
  String get setupActivating => 'Activation...';

  @override
  String get setupActivateAccount => 'Activer mon compte';

  @override
  String get setupNoCodeReceived => 'Vous n\'avez pas reçu le code ?';

  @override
  String get setupPhoneHint => 'Votre téléphone';

  @override
  String get monthJanuary => 'Janvier';

  @override
  String get monthFebruary => 'Février';

  @override
  String get monthMarch => 'Mars';

  @override
  String get monthApril => 'Avril';

  @override
  String get monthMay => 'Mai';

  @override
  String get monthJune => 'Juin';

  @override
  String get monthJuly => 'Juillet';

  @override
  String get monthAugust => 'Août';

  @override
  String get monthSeptember => 'Septembre';

  @override
  String get monthOctober => 'Octobre';

  @override
  String get monthNovember => 'Novembre';

  @override
  String get monthDecember => 'Décembre';

  @override
  String get dayMonday => 'Lundi';

  @override
  String get dayTuesday => 'Mardi';

  @override
  String get dayWednesday => 'Mercredi';

  @override
  String get dayThursday => 'Jeudi';

  @override
  String get dayFriday => 'Vendredi';

  @override
  String get daySaturday => 'Samedi';

  @override
  String get daySunday => 'Dimanche';

  @override
  String get calendarToday => 'Aujourd\'hui';

  @override
  String get calendarTomorrow => 'Demain';

  @override
  String get calendarClose => 'Fermer';

  @override
  String get calendarClient => 'Client';

  @override
  String get statusUnscheduled => 'Non planifié';

  @override
  String get statusScheduled => 'Planifié';

  @override
  String get statusPickedUp => 'Chargé';

  @override
  String get statusInTransit => 'En transit';

  @override
  String get statusDelivered => 'Livré';

  @override
  String get statusPartial => 'Partiel';

  @override
  String get statusFailed => 'Échec';

  @override
  String get statusCancelled => 'Annulé';

  @override
  String get statusPending => 'En attente';

  @override
  String calendarWeek(Object week) {
    return 'Semaine $week';
  }

  @override
  String get calendarRouteCancelledTitle => 'Tournée annulée';

  @override
  String calendarRouteCancelledBody(Object name) {
    return 'La tournée \"$name\" a été annulée par la dispatch.';
  }

  @override
  String get calendarNoRoutes => 'Aucune tournée';

  @override
  String get calendarLoadRoutesError => 'Impossible de charger les tournées';

  @override
  String get calendarCheckConnection =>
      'Vérifiez votre connexion et réessayez.';

  @override
  String get statusScheduledLabel => 'Planifié';

  @override
  String get statusPickedUpLabel => 'Chargé';

  @override
  String get statusInTransitLabel => 'En transit';

  @override
  String get statusAwaitingHandoff => 'En attente de transfert';

  @override
  String get statusDeliveredLabel => 'Livré';

  @override
  String get statusPartiallyDelivered => 'Livré partiel';

  @override
  String get statusFailedLabel => 'Échec';

  @override
  String get statusCancelledLabel => 'Annulé';

  @override
  String get routeStatusDraft => 'Brouillon';

  @override
  String get routeStatusValidated => 'Validée';

  @override
  String get routeStatusInProgress => 'En cours';

  @override
  String get routeStatusClosed => 'Clôturée';

  @override
  String get routeStatusCancelledR => 'Annulée';

  @override
  String get stopStatusPending => 'En attente';

  @override
  String get stopStatusArrived => 'Arrivé';

  @override
  String get stopStatusCompleted => 'Mission terminée';

  @override
  String get stopStatusFailed => 'Échec';

  @override
  String get stopStatusPartial => 'Partiel';

  @override
  String get routeDefaultName => 'Tournée';

  @override
  String get reasonClientAbsent => 'Client absent';

  @override
  String get reasonClientRefused => 'Refusé par le client';

  @override
  String get reasonWrongAddress => 'Mauvaise adresse';

  @override
  String get reasonPackageDamaged => 'Colis endommagé';

  @override
  String get reasonOther => 'Autre';

  @override
  String get podOutcomeDelivered => 'Livré';

  @override
  String get podOutcomeRefused => 'Refusé';

  @override
  String get podOutcomeDamaged => 'Endommagé';

  @override
  String get podOutcomeMissing => 'Manquant';

  @override
  String get podNotesTitle => 'Commentaire';

  @override
  String get podNotesHint => 'Commentaire (optionnel)';

  @override
  String routeTimeFrom(Object time) {
    return 'Dès $time';
  }

  @override
  String routeTimeBefore(Object time) {
    return 'Avant $time';
  }

  @override
  String routeStopCount(Object count) {
    return '$count arrêts';
  }

  @override
  String routeStopCountSingular(Object count) {
    return '$count arrêt';
  }

  @override
  String get routeSwipeStartHint => 'Glisser pour démarrer la tournée';

  @override
  String get routeSwipeLoadHint => 'Glisser pour charger';

  @override
  String get routeStopsHeader => 'ARRÊTS';

  @override
  String get routeAllStopsDone => 'Tous les arrêts validés';

  @override
  String get routeFinishedLabel => 'Tournée terminée';

  @override
  String get routeOfflineBanner => 'Mode hors ligne — Données en cache';

  @override
  String get routeConfirmPickup => 'Confirmez d\'abord le chargement au dépôt';

  @override
  String get routeLoadingRoute => 'Chargement de la tournée...';

  @override
  String get routeLoadError => 'Impossible de charger la tournée';

  @override
  String get routeRetry => 'Réessayer';

  @override
  String get routeInfoDate => 'Date';

  @override
  String get routeInfoSchedule => 'Horaire';

  @override
  String get routeInfoZone => 'Zone';

  @override
  String get routeInfoCity => 'Ville';

  @override
  String get routeInfoStops => 'Arrêts';

  @override
  String get routeInfoVehicle => 'Véhicule';

  @override
  String get routeNoStopsConfigured => 'Aucun arrêt configuré.';

  @override
  String routePickupLabel(Object depot) {
    return 'Chargement — Dépôt $depot';
  }

  @override
  String get historyOffline => 'Historique hors ligne';

  @override
  String get historyEmpty => 'Aucun enregistrement';

  @override
  String get historyEmptySubtitle =>
      'Les livraisons terminées apparaîtront ici.';

  @override
  String get historySectionTitle => 'Historique';

  @override
  String historyRecordCount(Object count) {
    return '$count enregistrements';
  }

  @override
  String get historyFilterDate => 'Filtrer par date...';

  @override
  String get historyNoAddress => 'Aucune adresse';

  @override
  String get historyItems => 'Articles';

  @override
  String get filterAll => 'Tout';

  @override
  String get filterDelivered => 'Livrée';

  @override
  String get filterFailed => 'Échouée';

  @override
  String get filterCancelled => 'Annulée';

  @override
  String get routeOfflineAction => 'Hors ligne — sera envoyé à la reconnexion';

  @override
  String routeErrorSnackbar(Object error) {
    return 'Erreur: $error';
  }

  @override
  String get routeOfflineUnavailable => 'Non disponible hors ligne';

  @override
  String get routePdfFailed => 'Échec du téléchargement du PDF';

  @override
  String get routeGenerateQr => 'Générer QR';

  @override
  String get routeScanQr => 'Scanner QR';

  @override
  String get routeScannerOffline => 'Scanner non disponible hors ligne';

  @override
  String get deliveryNoAddress => 'Aucune adresse fournie';

  @override
  String get statusHistoryDelivered => 'Livré';

  @override
  String get statusHistoryPartial => 'Partiel';

  @override
  String get statusHistoryFailed => 'Échec';

  @override
  String get statusHistoryCancelled => 'Annulé';

  @override
  String get statusHistoryInTransit => 'En transit';

  @override
  String get statusHistoryPickedUp => 'Récupéré';

  @override
  String get statusHistoryScheduled => 'Planifié';

  @override
  String get statusHistoryUnknown => 'Inconnu';

  @override
  String get handoffTransferredToYou => 'Colis transféré vers vous';

  @override
  String get handoffScanInstructions =>
      'À la réception, scannez le QR du chauffeur expéditeur pour confirmer.';

  @override
  String get handoffScanSenderQr => 'Scanner le QR de l\'expéditeur';

  @override
  String get bonLivraisonOffline => 'Non disponible hors ligne';

  @override
  String get bonLivraisonOpen => 'Ouvrir';

  @override
  String get handoffUnauthorized =>
      'Vous n\'êtes pas autorisé à générer un jeton pour ce colis.';

  @override
  String get handoffNoTransfer =>
      'Aucun transfert en attente pour ce colis. Actualisez puis réessayez.';

  @override
  String get handoffConnectionError =>
      'Connexion impossible. Vérifiez votre réseau et réessayez.';

  @override
  String get handoffGenerateFailed =>
      'Impossible de générer le jeton. Veuillez réessayer.';

  @override
  String get handoffAuthTitle => 'Authentification du transfert';

  @override
  String get handoffAuthDescription =>
      'Demandez à l\'autre chauffeur de scanner ce code pour confirmer le transfert.';

  @override
  String get handoffGeneratingToken => 'Génération du jeton sécurisé…';

  @override
  String get handoffTokenLabel => 'Jeton : ';

  @override
  String handoffExpiresIn(Object time) {
    return 'Expire dans $time';
  }

  @override
  String get handoffCodeExpired => 'Ce code a expiré.';

  @override
  String get handoffNewCode => 'Générer un nouveau code';

  @override
  String get handoffRetry => 'Réessayer';

  @override
  String get handoffScanGuidance => 'Scanner le QR de l\'expéditeur';

  @override
  String get handoffScanDescription =>
      'Alignez le code QR de l\'autre chauffeur dans le cadre pour confirmer.';

  @override
  String get handoffKeepAligned => 'Maintenez le code bien aligné…';

  @override
  String get handoffReading => 'Lecture en cours';

  @override
  String get handoffValidating => 'Validation du transfert…';

  @override
  String get handoffTransferConfirmed => 'Transfert confirmé';

  @override
  String get handoffTransferComplete => 'Le colis vous a été transféré.';

  @override
  String get handoffInvalidQr =>
      'Ce QR code n\'est pas un jeton de transfert valide.';

  @override
  String get handoffTokenExpiredDetail =>
      'Ce jeton a expiré. Demandez à l\'expéditeur d\'en générer un nouveau.';

  @override
  String get handoffTokenUsed =>
      'Jeton invalide ou déjà utilisé. Réessayez avec un nouveau code.';

  @override
  String get handoffNotForYou => 'Ce transfert ne vous est pas destiné.';

  @override
  String get handoffTransferUpdated =>
      'Ce transfert vient d\'être mis à jour. Actualisez puis réessayez.';

  @override
  String get cameraAccessDenied => 'Accès à la caméra refusé';

  @override
  String get cameraUnavailable => 'Caméra indisponible';

  @override
  String get cameraPermInstructions =>
      'Autorisez l\'accès à la caméra dans les réglages pour scanner les transferts.';

  @override
  String get cameraStartFailed =>
      'Impossible de démarrer la caméra. Réessayez plus tard.';

  @override
  String get setupEnterCodeHint => 'Entrez votre code d\'activation';

  @override
  String get setupServerInaccessible =>
      'Serveur inaccessible - Verifiez votre connexion';

  @override
  String get setupCodeAlreadyUsed => 'Ce code a deja ete utilise';

  @override
  String get setupInvalidFormat => 'Format de code invalide (UUID attendu)';

  @override
  String get setupInvalidOrExpired => 'Code invalide ou expire';

  @override
  String get setupEnterPhoneHint => 'Entrez votre numero de telephone';

  @override
  String get setupCodeSentEmail =>
      'Un code d\'activation a ete envoye par email.';

  @override
  String get setupCodeResentEmail =>
      'Un code d\'activation a ete renvoye par email.';

  @override
  String get setupPhoneNotFoundOrActive =>
      'Telephone non trouve ou deja active';

  @override
  String get setupPasswordLabel => 'Mot de passe';

  @override
  String get registerDescription =>
      'Remplissez vos informations pour commencer.';

  @override
  String get registerPhone => 'Numéro de téléphone';

  @override
  String get registerPasswordField => 'Mot de passe';

  @override
  String get registerButton => 'S\'inscrire';

  @override
  String get registerLoading => 'Inscription...';

  @override
  String get deliveryAccept => 'Accepter';

  @override
  String get deliveryNoAddressProvided => 'Aucune adresse fournie';

  @override
  String get podTakePhoto => 'Prendre une photo';

  @override
  String get podChooseGallery => 'Choisir de la galerie';

  @override
  String get podPhotosRequired => 'Les 2 photos sont obligatoires';

  @override
  String profileError(Object error) {
    return 'Erreur : $error';
  }

  @override
  String get calendarTodayButton => 'Aujourd\'hui';

  @override
  String calendarProgress(Object percent) {
    return '$percent% complété';
  }

  @override
  String calendarStopCount(Object count) {
    return '$count arrêt(s)';
  }
}
