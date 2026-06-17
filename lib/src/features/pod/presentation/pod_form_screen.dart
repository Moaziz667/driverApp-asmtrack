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
  late Map<String, int> _itemsDone;
  late Map<String, String> _itemOutcomes;
  late Map<String, String?> _itemReasons;
  late Map<String, TextEditingController> _itemCommentControllers;

  /// Admin-configured failure reasons (same referential as the full-failure sheet).
  /// Empty until loaded / when offline → the per-item cards fall back to the built-in list.
  List<FailureReasonOption> _adminReasons = const [];

  @override
  void initState() {
    super.initState();
    _itemsDone = {};
    _itemOutcomes = {};
    _itemReasons = {};
    _itemCommentControllers = {};
    for (final item in widget.args.delivery.items) {
      final key = item.sku ?? item.name;
      _itemsDone[key] = item.quantity;
      _itemOutcomes[key] = 'DELIVERED';
      _itemReasons[key] = null;
      _itemCommentControllers[key] = TextEditingController();
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
    for (final ctrl in _itemCommentControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  bool get _canSubmit {
    if (_bonLivraisonBytes == null || _packageBytes == null) return false;
    if (!_isPartial) return true;
    for (final item in widget.args.delivery.items) {
      final key = item.sku ?? item.name;
      final outcome = _itemOutcomes[key] ?? 'DELIVERED';
      final isPartialQty = outcome == 'DELIVERED' && (_itemsDone[key] ?? item.quantity) < item.quantity;
      if ((kPodRequiresReason.contains(outcome) || isPartialQty) && _itemReasons[key] == null) {
        return false;
      }
    }
    return true;
  }

  /// First item still missing a reason — drives the hint message.
  String? get _missingReasonItem {
    if (!_isPartial) return null;
    for (final item in widget.args.delivery.items) {
      final key = item.sku ?? item.name;
      final outcome = _itemOutcomes[key] ?? 'DELIVERED';
      final isPartialQty = outcome == 'DELIVERED' && (_itemsDone[key] ?? item.quantity) < item.quantity;
      if ((kPodRequiresReason.contains(outcome) || isPartialQty) && _itemReasons[key] == null) {
        return item.name;
      }
    }
    return null;
  }

  Future<void> _openBonLivraison() async {
    final locale = ref.read(localeProvider);
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
          SnackBar(content: Text(DriverCopy.get('pod_pdf_open_error', locale))),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(DriverCopy.get('pod_pdf_download_error', locale))),
        );
      }
    } finally {
      if (mounted) setState(() => _openingBl = false);
    }
  }

  Future<void> _pickPhoto(ValueChanged<Uint8List> onDone, String locale) async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.camera,
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
        SnackBar(content: Text(DriverCopy.get('pod_photo_access_error', locale))),
      );
    }
  }

  Widget _itemRow(dynamic item, String locale) {
    final key = (item.sku ?? item.name) as String;
    final plannedQty = item.quantity as int;
    return PodItemOutcomeRow(
      item: item,
      currentQty: _itemsDone[key] ?? plannedQty,
      outcome: _itemOutcomes[key] ?? 'DELIVERED',
      reason: _itemReasons[key],
      adminReasons: _adminReasons,
      commentController: _itemCommentControllers[key]!,
      locale: locale,
      onOutcome: (v) => setState(() {
        _itemOutcomes[key] = v;
        _itemReasons[key] = null;
        _itemsDone[key] = v == 'DELIVERED' ? plannedQty : 0;
      }),
      onQty: (q) => setState(() => _itemsDone[key] = q),
      onReason: (r) => setState(() => _itemReasons[key] = r),
    );
  }

  Future<void> _submit() async {
    final locale = ref.read(localeProvider);
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
        itemsArray = _itemsDone.entries.map((e) {
          final outcome = _itemOutcomes[e.key] ?? 'DELIVERED';
          final reason = _itemReasons[e.key];
          final comment = _itemCommentControllers[e.key]?.text.trim();
          final plannedQty = widget.args.delivery.items
              .firstWhere((i) => (i.sku ?? i.name) == e.key, orElse: () => widget.args.delivery.items.first)
              .quantity;
          final isPartialQty = outcome == 'DELIVERED' && e.value < plannedQty;
          final sendReason = kPodRequiresReason.contains(outcome) || isPartialQty;
          return PartialDeliveryItem(
            sku: e.key,
            quantityDone: e.value,
            outcome: outcome,
            reason: sendReason ? reason : null,
            comment: comment?.isNotEmpty == true ? comment : null,
          );
        }).toList();
      }

      try {
        // Online → multipart binary upload; offline / network drop → the repo
        // falls back to the base64 endpoint via the offline queue.
        await ref.read(deliveryRepositoryProvider).submitPodMultipart(
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(DriverCopy.get('pod_success_message', locale))));
        Navigator.of(context).pop(true);
      } catch (e) {
        if (e == 'OFFLINE_QUEUED') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(DriverCopy.get('delivery_detail_offline_queue', locale))),
          );
          Navigator.of(context).pop(true);
        } else {
          rethrow;
        }
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${DriverCopy.get('delivery_detail_error_prefix', locale)}: $error')));
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
        title: Text(DriverCopy.get('pod_title', locale)),
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
              title: DriverCopy.get('pod_photo_bl_title', locale),
              subtitle: DriverCopy.get('pod_photo_bl_sub', locale),
              bytes: _bonLivraisonBytes,
              isRequired: true,
              onCapture: () => _pickPhoto((b) => setState(() => _bonLivraisonBytes = b), locale),
              onClear: () => setState(() => _bonLivraisonBytes = null),
              locale: locale,
            ),
            const SizedBox(height: AppTokens.space16),
            PodPhotoSection(
              title: DriverCopy.get('pod_photo_pkg_title', locale),
              subtitle: DriverCopy.get('pod_photo_pkg_sub', locale),
              bytes: _packageBytes,
              isRequired: true,
              onCapture: () => _pickPhoto((b) => setState(() => _packageBytes = b), locale),
              onClear: () => setState(() => _packageBytes = null),
              locale: locale,
            ),
            const SizedBox(height: AppTokens.space20),

            PodNotesField(controller: _notesController, locale: locale),
            const SizedBox(height: AppTokens.space16),

            PodToggleCard(
              icon: LucideIcons.mapPin,
              iconColor: cs.tertiary,
              title: DriverCopy.get('pod_gps_label', locale),
              subtitle: DriverCopy.get('pod_gps_sub', locale),
              value: _attachLocation,
              onChanged: (v) => setState(() => _attachLocation = v),
            ),
            const SizedBox(height: AppTokens.space16),

            PodToggleCard(
              icon: LucideIcons.packageCheck,
              iconColor: cs.secondary,
              title: DriverCopy.get('pod_partial_label', locale),
              subtitle: DriverCopy.get('pod_partial_sub', locale),
              value: _isPartial,
              onChanged: (v) => setState(() => _isPartial = v),
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(DriverCopy.get('pod_item_outcome_header', locale), style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: AppTokens.space12),
                  ...widget.args.delivery.items.map((item) => _itemRow(item, locale)),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            if (!_canSubmit)
              Padding(
                padding: const EdgeInsets.only(bottom: AppTokens.space8),
                child: Text(
                  _missingReasonItem != null
                      ? '${DriverCopy.get('pod_reason_mandatory', locale)} $_missingReasonItem'
                      : DriverCopy.get('pod_photos_mandatory', locale),
                  style: TextStyle(fontSize: 12, color: cs.error.withValues(alpha: 0.8)),
                  textAlign: TextAlign.center,
                ),
              ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: (_submitting || !_canSubmit) ? null : _submit,
                icon: _submitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(LucideIcons.check, size: 20),
                label: Text(DriverCopy.get('pod_confirm_delivery', locale)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
