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
import 'widgets/cash_collection_card.dart';
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

  /// Null until the cash card reports; stays null for a delivery with no collection instruction.
  CashFormState? _cash;

  /// Mirrors the card's own validity so the submit button can stay honest about why it is disabled.
  bool _cashValid = true;

  /// Per-item state — this State is the single source of truth; the widgets are
  /// purely presentational and report changes through callbacks.
  ///
  /// Per-unit breakdown (WMS): a line of qty N splits into a delivered slice plus up to three
  /// *shortfall* dispositions (missing / refused / damaged), each with its own quantity and motif.
  /// The delivered quantity is derived (`N − Σ shortfall`), never stored, so the invariant
  /// `delivered + Σ shortfall = N` can't drift. Keyed by list index (two lines can share a SKU).
  late Map<int, Map<String, int>> _dispQty;
  late Map<int, Map<String, String?>> _dispReason;

  /// Shortfall dispositions, in display order. Each maps 1:1 to a failure-reason `category`.
  static const _kShortfallDisps = ['MISSING', 'REFUSED', 'DAMAGED'];

  /// Admin-configured failure reasons (same referential as the full-failure sheet).
  /// Empty until loaded / when offline → the per-item cards fall back to the built-in list.
  List<FailureReasonOption> _adminReasons = const [];

  @override
  void initState() {
    super.initState();
    _dispQty = {};
    _dispReason = {};
    // Key per-item state by list index, never sku/name: two lines can share a SKU (or both have a
    // null SKU), and a shared map key made one line's outcome/qty bleed into the other.
    final items = widget.args.delivery.items;
    for (var i = 0; i < items.length; i++) {
      _dispQty[i] = {for (final d in _kShortfallDisps) d: 0};
      _dispReason[i] = {for (final d in _kShortfallDisps) d: null};
    }
    _loadReasons();
  }

  Future<void> _loadReasons() async {
    try {
      final reasons = await ref
          .read(deliveryRepositoryProvider)
          .fetchFailureReasons();
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

  /// A shortfall disposition needs a motif only when the admin referential actually offers one for
  /// it (item-scoped, matching category). Offline / unconfigured → no chips to pick, so we don't
  /// dead-lock the driver: the backend accepts a null reason.
  /// Mirrors the card's own rules, so the submit button and the card agree on why it is blocked.
  ///
  /// Duplicated rather than read off the card's State: a driver who cannot submit and cannot see
  /// which field is wrong is stuck at a customer's door, and the card is the only thing that can
  /// point at the field.
  bool _cashCardValid(CashFormState s) {
    if (s.method == CashMethod.cheque &&
        (s.chequeNumber == null || s.chequeNumber!.isEmpty)) {
      return false;
    }
    final expected = widget.args.delivery.codAmount ?? 0;
    final short = s.method == CashMethod.none || s.amount < expected;
    final reasonAvailable = _adminReasons.any((r) => r.coversDelivery);
    if (short &&
        reasonAvailable &&
        (s.reasonCode == null || s.reasonCode!.isEmpty)) {
      return false;
    }
    return true;
  }

  bool _requiresReason(String disposition) =>
      _adminReasons.any((r) => r.coversItem && r.category == disposition);

  bool get _canSubmit {
    // ADR-033 — a return collection has no bon de livraison; only the collected-parcel photo is required.
    final isReturn = widget.args.delivery.isReturnPickup;
    if (_packageBytes == null) return false;
    if (!isReturn && _bonLivraisonBytes == null) return false;
    // A cheque with no number, or a shortfall with no motif, is refused here rather than by the
    // server: the driver is standing in front of the customer and can still fix it.
    if (!_cashValid) return false;
    if (!_isPartial) return true;
    return _missingReasonItem == null;
  }

  /// First item with a chosen shortfall still missing its motif — drives the hint message.
  String? get _missingReasonItem {
    if (!_isPartial) return null;
    final items = widget.args.delivery.items;
    for (var i = 0; i < items.length; i++) {
      final qtys = _dispQty[i]!;
      for (final disp in _kShortfallDisps) {
        if ((qtys[disp] ?? 0) > 0 &&
            _requiresReason(disp) &&
            _dispReason[i]![disp] == null) {
          return items[i].name;
        }
      }
    }
    return null;
  }

  Future<void> _openBonLivraison() async {
    if (_openingBl) return;
    setState(() => _openingBl = true);
    try {
      final deliveryId = widget.args.delivery.id;
      final ok = await ref
          .read(pdfServiceProvider)
          .downloadAndOpen(
            '/driver/deliveries/$deliveryId/bon-livraison',
            fileName: 'bon-livraison-$deliveryId.pdf',
          );
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pod_pdf_open_error),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pod_pdf_download_error),
          ),
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusLg),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(LucideIcons.camera, color: cs.primary),
                title: Text(
                  locale == 'ar'
                      ? 'التقاط صورة الكاميرا'
                      : AppLocalizations.of(context).podTakePhoto,
                  style: TextStyle(
                    fontWeight: AppTokens.fwMedium,
                    color: cs.onSurface,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: Icon(LucideIcons.image, color: cs.primary),
                title: Text(
                  locale == 'ar'
                      ? 'اختيار من معرض الصور'
                      : AppLocalizations.of(context).podChooseGallery,
                  style: TextStyle(
                    fontWeight: AppTokens.fwMedium,
                    color: cs.onSurface,
                  ),
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
        SnackBar(
          content: Text(AppLocalizations.of(context).pod_photo_access_error),
        ),
      );
    }
  }

  Widget _itemRow(int index, dynamic item, String locale) {
    final plannedQty = item.quantity as int;
    final qtys = _dispQty[index]!;
    final shortfall = qtys.values.fold<int>(0, (s, v) => s + v);
    return PodItemOutcomeRow(
      key: ValueKey(index),
      item: item,
      delivered: plannedQty - shortfall,
      dispQty: qtys,
      dispReason: _dispReason[index]!,
      adminReasons: _adminReasons,
      locale: locale,
      onDispQty: (disp, qty) => setState(() {
        // A shortfall slice can grow only into the delivered pool: clamp to N − (the other slices).
        final others = _kShortfallDisps
            .where((d) => d != disp)
            .fold<int>(0, (s, d) => s + (qtys[d] ?? 0));
        final clamped = qty.clamp(0, plannedQty - others);
        qtys[disp] = clamped;
        if (clamped == 0) _dispReason[index]![disp] = null;
      }),
      onDispReason: (disp, code) =>
          setState(() => _dispReason[index]![disp] = code),
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
        itemsArray = List.generate(items.length, (i) {
          final item = items[i];
          final int planned = item.quantity;
          final qtys = _dispQty[i]!;
          final reasons = _dispReason[i]!;
          final delivered = planned - qtys.values.fold<int>(0, (s, v) => s + v);

          // Per-unit breakdown: the delivered slice + one slice per non-zero shortfall disposition,
          // each with its own motif. Summing to `planned` is guaranteed by construction.
          final segments = <ItemSegment>[];
          if (delivered > 0) {
            segments.add(
              ItemSegment(disposition: 'DELIVERED', quantity: delivered),
            );
          }
          for (final disp in _kShortfallDisps) {
            final q = qtys[disp] ?? 0;
            if (q > 0) {
              segments.add(
                ItemSegment(
                  disposition: disp,
                  quantity: q,
                  reasonCode: reasons[disp],
                ),
              );
            }
          }

          // Denormalized single-outcome fields for the offline queue + legacy consumers (the backend
          // recomputes these from the segments when present). Dominant = the largest shortfall slice.
          String outcome = 'DELIVERED';
          String? reason;
          var dominant = 0;
          for (final disp in _kShortfallDisps) {
            final q = qtys[disp] ?? 0;
            if (q > dominant) {
              dominant = q;
              outcome = disp;
              reason = reasons[disp];
            }
          }

          // Submit the real SKU (falling back to name) so the backend can match the line; the index is
          // UI-only.
          return PartialDeliveryItem(
            sku: item.sku ?? item.name,
            quantityDone: delivered,
            outcome: outcome,
            reason: reason,
            comment: null,
            segments: segments.isNotEmpty ? segments : null,
          );
        });
      }

      try {
        // POD via the base64 JSON endpoint (transactional end-to-end on the backend);
        // the repo handles the online POST and the offline-queue fallback.
        await ref
            .read(deliveryRepositoryProvider)
            .submitPodPhotos(
              widget.args.delivery.id,
              bonLivraisonBytes: _bonLivraisonBytes,
              packageBytes: _packageBytes!,
              comment: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              lat: lat,
              lng: lng,
              isPartial: _isPartial,
              itemsDone: itemsArray,
              cash: _cash?.toEntry(),
            );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pod_success_message),
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        if (e == 'OFFLINE_QUEUED') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context).delivery_detail_offline_queue,
              ),
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          rethrow;
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context).delivery_detail_error_prefix}: $error',
          ),
        ),
      );
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
            // ADR-033 — a return collection has no delivery note: skip the bon-de-livraison viewer + photo.
            if (!widget.args.delivery.isReturnPickup) ...[
              PodViewBlButton(
                loading: _openingBl,
                onTap: _openBonLivraison,
                locale: locale,
              ),
              const SizedBox(height: AppTokens.space20),
              // The one instruction the app cannot enforce, so it is placed where it can still be
              // acted on: above the camera, not below it. The note is on the counter and the customer
              // is still there; a page further down neither would be.
              if (_isPartial) ...[
                const PodAmendNoteWarning(locale: ''),
                const SizedBox(height: AppTokens.space16),
              ],
              PodPhotoSection(
                title: AppLocalizations.of(context).pod_photo_bl_title,
                subtitle: AppLocalizations.of(context).pod_photo_bl_sub,
                bytes: _bonLivraisonBytes,
                isRequired: true,
                onCapture: () => _pickPhoto(
                  (b) => setState(() => _bonLivraisonBytes = b),
                  locale,
                ),
                onClear: () => setState(() => _bonLivraisonBytes = null),
                locale: locale,
                icon: LucideIcons.fileText,
              ),
              const SizedBox(height: AppTokens.space16),
            ],
            PodPhotoSection(
              title: AppLocalizations.of(context).pod_photo_pkg_title,
              subtitle: AppLocalizations.of(context).pod_photo_pkg_sub,
              bytes: _packageBytes,
              isRequired: true,
              onCapture: () =>
                  _pickPhoto((b) => setState(() => _packageBytes = b), locale),
              onClear: () => setState(() => _packageBytes = null),
              locale: locale,
              icon: LucideIcons.package,
            ),
            const SizedBox(height: AppTokens.space20),

            // Money, placed above the free-text note and below the photos: the driver has just
            // proved what he handed over, and the next thing that happens at the door is payment.
            if (widget.args.delivery.codRequired) ...[
              CashCollectionCard(
                expected: widget.args.delivery.codAmount ?? 0,
                currency: widget.args.delivery.currency ?? 'TND',
                reasons: _adminReasons,
                locale: locale,
                onChanged: (state) => setState(() {
                  _cash = state;
                  _cashValid = _cashCardValid(state);
                }),
              ),
              const SizedBox(height: AppTokens.space20),
            ],

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

            // ADR-033 — a return collection is all-or-nothing: no partial. Discrepancies (client returned
            // fewer/wrong items) are caught at depot inspection, not by the driver.
            if (!widget.args.delivery.isReturnPickup) ...[
              PodToggleCard(
                icon: LucideIcons.packageCheck,
                iconColor: cs.secondary,
                title: AppLocalizations.of(context).pod_partial_label,
                subtitle: AppLocalizations.of(context).pod_partial_sub,
                value: _isPartial,
                onChanged: (v) {
                  // A note photographed before this switch shows the printed quantities, so it is
                  // dropped: keeping it would file, as proof of a partial delivery, an image of the
                  // full one. It used to vanish in silence — the driver saw his photo disappear and
                  // the submit button grey out with nothing said, and read it as the app losing his
                  // work. Removing it is right; not saying so was not.
                  final hadPhoto = _bonLivraisonBytes != null;
                  setState(() {
                    _isPartial = v;
                    if (v) _bonLivraisonBytes = null;
                  });
                  if (v && hadPhoto) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context).pod_partial_bl_cleared,
                        ),
                      ),
                    );
                  }
                },
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).pod_item_outcome_header,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppTokens.space12),
                    ...widget.args.delivery.items.asMap().entries.map(
                      (e) => _itemRow(e.key, e.value, locale),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTokens.space8),
            ],
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
            AppTokens.space20,
            AppTokens.space12,
            AppTokens.space20,
            AppTokens.space12,
          ),
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
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: (_submitting || !_canSubmit) ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.checkCircle, size: 20),
                  label: Text(
                    AppLocalizations.of(context).pod_confirm_delivery,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
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
