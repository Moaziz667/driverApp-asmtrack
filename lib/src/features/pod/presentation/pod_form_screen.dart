import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app_providers.dart';
import '../../../services/locale_provider.dart';
import '../../../services/location_service.dart';
import '../../../theme/tokens.dart';
import '../../deliveries/models/delivery_models.dart';
import 'widgets/pod_widgets.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

class PodFormArgs {
  const PodFormArgs({required this.delivery});
  final DriverDelivery delivery;
}

class PodFormScreen extends ConsumerStatefulWidget {
  const PodFormScreen({super.key, required this.args});

  static const routeName = '/delivery/pod';
  final PodFormArgs args;

  @override
  ConsumerState<PodFormScreen> createState() => _PodFormScreenState();
}

class _PodFormScreenState extends ConsumerState<PodFormScreen> {
  final _notesController = TextEditingController();
  final _picker = ImagePicker();
  final _locationService = LocationService();

  Uint8List? _bonLivraisonBytes;
  Uint8List? _packageBytes;
  bool _submitting = false;
  bool _attachLocation = true;
  bool _isPartial = false;
  bool _openingBl = false;

  /// Per-item state — this State is the single source of truth; the widgets are
  /// purely presentational and report changes through callbacks.
  late Map<int, int> _itemsDone;
  late Map<int, String> _itemOutcomes;
  late Map<int, String?> _itemReasons;

  /// Admin-configured failure reasons (same referential as the full-failure sheet).
  /// Empty until loaded / when offline → the per-item cards fall back to the built-in list.
  List<FailureReasonOption> _adminReasons = const [];

  @override
  void initState() {
    super.initState();
    _itemsDone = {};
    _itemOutcomes = {};
    _itemReasons = {};
    // Key per-item state by list index, never sku/name: two lines can share a SKU (or both have a
    // null SKU), and a shared map key made one line's outcome/qty bleed into the other.
    final items = widget.args.delivery.items;
    for (var i = 0; i < items.length; i++) {
      _itemsDone[i] = items[i].quantity;
      _itemOutcomes[i] = 'DELIVERED';
      _itemReasons[i] = null;
    }
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    try {
      final reasons = await ref.read(deliveryRepositoryProvider).fetchFailureReasons();
      if (mounted) setState(() => _adminReasons = reasons);
    } catch (_) {
      // Keep empty → cards fall back to the built-in reason list.
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    if (_bonLivraisonBytes == null || _packageBytes == null) return false;
    if (!_isPartial) return true;
    final items = widget.args.delivery.items;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final outcome = _itemOutcomes[i] ?? 'DELIVERED';
      final isPartialQty = outcome == 'DELIVERED' && (_itemsDone[i] ?? item.quantity) < item.quantity;
      if ((kPodRequiresReason.contains(outcome) || isPartialQty) && _itemReasons[i] == null) {
        return false;
      }
    }
    return true;
  }

  /// First item still missing a reason — drives the hint message.
  String? get _missingReasonItem {
    if (!_isPartial) return null;
    final items = widget.args.delivery.items;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final outcome = _itemOutcomes[i] ?? 'DELIVERED';
      final isPartialQty = outcome == 'DELIVERED' && (_itemsDone[i] ?? item.quantity) < item.quantity;
      if ((kPodRequiresReason.contains(outcome) || isPartialQty) && _itemReasons[i] == null) {
        return item.name;
      }
    }
    return null;
  }

  Future<void> _openBonLivraison() async {
    if (_openingBl) return;
    setState(() => _openingBl = true);
    try {
      final deliveryId = widget.args.delivery.id;
      final ok = await ref.read(pdfServiceProvider).downloadAndOpen(
        '/api/driver/deliveries/$deliveryId/bon-livraison',
        fileName: 'bon-livraison-$deliveryId.pdf',
      );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).pod_pdf_open_error)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).pod_pdf_download_error)),
        );
      }
    } finally {
      if (mounted) setState(() => _openingBl = false);
    }
  }

  Future<void> _pickPhoto(ValueChanged<Uint8List> onDone, String locale) async {
    final cs = Theme.of(context).colorScheme;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: cs.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.camera, color: cs.primary),
                title: Text(
                  locale == 'ar' ? 'التقاط صورة الكاميرا' : AppLocalizations.of(context).podTakePhoto,
                  style: TextStyle(fontWeight: AppTokens.fwMedium, color: cs.onSurface),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(LucideIcons.image, color: cs.primary),
                title: Text(
                  locale == 'ar' ? 'اختيار من معرض الصور' : AppLocalizations.of(context).podChooseGallery,
                  style: TextStyle(fontWeight: AppTokens.fwMedium, color: cs.onSurface),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 70,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      onDone(bytes);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pod_photo_access_error)),
      );
    }
  }

  Widget _itemRow(int index, dynamic item, String locale) {
    final plannedQty = item.quantity as int;
    return PodItemOutcomeRow(
      key: ValueKey(index),
      item: item,
      currentQty: _itemsDone[index] ?? plannedQty,
      outcome: _itemOutcomes[index] ?? 'DELIVERED',
      reason: _itemReasons[index],
      adminReasons: _adminReasons,
      locale: locale,
      onOutcome: (v) => setState(() {
        _itemOutcomes[index] = v;
        _itemReasons[index] = null;
        _itemsDone[index] = v == 'DELIVERED' ? plannedQty : 0;
      }),
      onQty: (q) => setState(() {
        _itemsDone[index] = q;
        if (q < plannedQty && _itemOutcomes[index] == 'DELIVERED') {
          _itemOutcomes[index] = 'REFUSED';
          _itemReasons[index] = null;
        }
      }),
      onReason: (r) => setState(() => _itemReasons[index] = r),
    );
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    try {
      double? lat;
      double? lng;
      if (_attachLocation) {
        final point = await _locationService.currentPosition();
        if (point != null) {
          lat = point.lat;
          lng = point.lng;
        }
      }

      List<PartialDeliveryItem>? itemsArray;
      if (_isPartial) {
        final items = widget.args.delivery.items;
        itemsArray = _itemsDone.entries.map((e) {
          final item = items[e.key];
          final outcome = _itemOutcomes[e.key] ?? 'DELIVERED';
          final reason = _itemReasons[e.key];
          final isPartialQty = outcome == 'DELIVERED' && e.value < item.quantity;
          final sendReason = kPodRequiresReason.contains(outcome) || isPartialQty;
          // Per-item free-text removed — the motif (reason) carries the per-line detail; the single
          // optional POD note ([_notesController]) covers any general remark. Submit the real SKU
          // (falling back to name) so the backend can still match the line; the index is UI-only.
          return PartialDeliveryItem(
            sku: item.sku ?? item.name,
            quantityDone: e.value,
            outcome: outcome,
            reason: sendReason ? reason : null,
            comment: null,
          );
        }).toList();
      }

      try {
        // POD via the base64 JSON endpoint (transactional end-to-end on the backend);
        // the repo handles the online POST and the offline-queue fallback.
        await ref.read(deliveryRepositoryProvider).submitPodPhotos(
              widget.args.delivery.id,
              bonLivraisonBytes: _bonLivraisonBytes!,
              packageBytes: _packageBytes!,
              comment: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
              lat: lat,
              lng: lng,
              isPartial: _isPartial,
              itemsDone: itemsArray,
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).pod_success_message)));
        Navigator.of(context).pop(true);
      } catch (e) {
        if (e == 'OFFLINE_QUEUED') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).delivery_detail_offline_queue)),
          );
          Navigator.of(context).pop(true);
        } else {
          rethrow;
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).delivery_detail_error_prefix}: $error')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).pod_title),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppTokens.space20),
          children: [
            PodInstructionsCard(locale: locale),
            const SizedBox(height: AppTokens.space16),
            PodViewBlButton(loading: _openingBl, onTap: _openBonLivraison, locale: locale),
            const SizedBox(height: AppTokens.space20),

            PodPhotoSection(
              title: AppLocalizations.of(context).pod_photo_bl_title,
              subtitle: AppLocalizations.of(context).pod_photo_bl_sub,
              bytes: _bonLivraisonBytes,
              isRequired: true,
              onCapture: () => _pickPhoto((b) => setState(() => _bonLivraisonBytes = b), locale),
              onClear: () => setState(() => _bonLivraisonBytes = null),
              locale: locale,
              icon: LucideIcons.fileText,
            ),
            const SizedBox(height: AppTokens.space16),
            PodPhotoSection(
              title: AppLocalizations.of(context).pod_photo_pkg_title,
              subtitle: AppLocalizations.of(context).pod_photo_pkg_sub,
              bytes: _packageBytes,
              isRequired: true,
              onCapture: () => _pickPhoto((b) => setState(() => _packageBytes = b), locale),
              onClear: () => setState(() => _packageBytes = null),
              locale: locale,
              icon: LucideIcons.package,
            ),
            const SizedBox(height: AppTokens.space20),

            PodNotesField(controller: _notesController, locale: locale),
            const SizedBox(height: AppTokens.space16),

            PodToggleCard(
              icon: LucideIcons.mapPin,
              iconColor: cs.tertiary,
              title: AppLocalizations.of(context).pod_gps_label,
              subtitle: AppLocalizations.of(context).pod_gps_sub,
              value: _attachLocation,
              onChanged: (v) => setState(() => _attachLocation = v),
            ),
            const SizedBox(height: AppTokens.space16),

            PodToggleCard(
              icon: LucideIcons.packageCheck,
              iconColor: cs.secondary,
              title: AppLocalizations.of(context).pod_partial_label,
              subtitle: AppLocalizations.of(context).pod_partial_sub,
              value: _isPartial,
              onChanged: (v) => setState(() => _isPartial = v),
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context).pod_item_outcome_header, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppTokens.space12),
                  ...widget.args.delivery.items.asMap().entries.map((e) => _itemRow(e.key, e.value, locale)),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space8),
          ],
        ),
      ),
      // Primary action pinned to the bottom (Stitch "Fixed Button & Refined Layout")
      // so "Confirmer la livraison" stays reachable without scrolling the form.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(
            AppTokens.space20, AppTokens.space12, AppTokens.space20, AppTokens.space12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_canSubmit)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppTokens.space8),
                  child: Text(
                    _missingReasonItem != null
                        ? '${AppLocalizations.of(context).pod_reason_mandatory} $_missingReasonItem'
                        : (locale == 'ar'
                            ? 'الصورتان إلزاميتان'
                            : AppLocalizations.of(context).podPhotosRequired),
                    style: TextStyle(fontSize: 13, color: cs.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: (_submitting || !_canSubmit) ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(LucideIcons.checkCircle, size: 20),
                  label: Text(
                    AppLocalizations.of(context).pod_confirm_delivery,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
