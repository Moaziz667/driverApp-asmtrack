import 'dart:typed_data';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../theme/tokens.dart';
import '../../../deliveries/models/delivery_models.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

// ─── Outcome descriptors ────────────────────────────────────────────────────
class PodOutcome {
  const PodOutcome(this.value, this.icon, this.colorKey);
  final String value;
  final IconData icon;
  final String colorKey;

  Color resolve(ColorScheme cs) {
    switch (colorKey) {
      case 'success': return cs.primary;
      case 'danger':  return cs.error;
      case 'warning': return cs.secondary;
      case 'info':    return cs.tertiary;
      default:        return cs.onSurface;
    }
  }
}

const kPodOutcomes = [
  PodOutcome('DELIVERED', LucideIcons.checkCircle2, 'success'),
  PodOutcome('REFUSED',   LucideIcons.xCircle,      'danger'),
  PodOutcome('DAMAGED',   LucideIcons.alertTriangle, 'warning'),
  PodOutcome('MISSING',   LucideIcons.search,       'info'),
];

const kPodRequiresReason = {'REFUSED', 'DAMAGED', 'MISSING'};

/// The line dispositions a driver can pick for a shortfall. Each maps 1:1 to a failure-reason
/// `category`; reasons are filtered by category (+ item scope), not a separate context.
const kPodItemDispositions = {'REFUSED', 'DAMAGED', 'MISSING'};

String podOutcomeLabel(String outcome, String locale) {
  if (locale == 'ar') {
    switch (outcome) {
      case 'DELIVERED': return 'تم التوصيل';
      case 'REFUSED': return 'مرفوض';
      case 'DAMAGED': return 'تالف';
      case 'MISSING': return 'مفقود';
    }
  } else if (locale == 'en') {
    switch (outcome) {
      case 'DELIVERED': return 'Delivered';
      case 'REFUSED': return 'Refused';
      case 'DAMAGED': return 'Damaged';
      case 'MISSING': return 'Missing';
    }
  }
  switch (outcome) {
    case 'DELIVERED': return 'Delivered';
    case 'REFUSED': return 'Refused';
    case 'DAMAGED': return 'Damaged';
    case 'MISSING': return 'Missing';
  }
  return outcome;
}

// ─── Reusable card shell ─────────────────────────────────────────────────────
class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: AppTokens.shadowSm(brightness: Theme.of(context).brightness),
      ),
      child: Padding(padding: const EdgeInsets.all(AppTokens.space16), child: child),
    );
  }
}

// ─── Dashed Border Painter ───────────────────────────────────────────────────
class DashedRectPainter extends CustomPainter {
  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.gap = 6.0,
  });

  final Color color;
  final double strokeWidth;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(8),
      ));

    final dashPath = _buildDashPath(path, gap);
    canvas.drawPath(dashPath, paint);
  }

  Path _buildDashPath(Path source, double gap) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        final double len = draw ? gap : gap;
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + len),
            Offset.zero,
          );
        }
        distance += len;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap;
  }
}

// ─── Instructions banner ─────────────────────────────────────────────────────
class PodInstructionsCard extends StatelessWidget {
  const PodInstructionsCard({super.key, required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.space16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(LucideIcons.info, size: 20, color: cs.primary),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              '${AppLocalizations.of(context).pod_step_1}\n'
              '${AppLocalizations.of(context).pod_step_2}\n'
              '${AppLocalizations.of(context).pod_step_3}',
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withValues(alpha: 0.7),
                height: 1.6,
                fontWeight: AppTokens.fwMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── "View bon de livraison" button ──────────────────────────────────────────
class PodViewBlButton extends StatelessWidget {
  const PodViewBlButton({super.key, required this.loading, required this.onTap, required this.locale});
  final bool loading;
  final VoidCallback onTap;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
          : const Icon(LucideIcons.fileText, size: 18),
      label: Text(loading ? AppLocalizations.of(context).pod_downloading : AppLocalizations.of(context).pod_view_print_bl),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        side: BorderSide(color: cs.outlineVariant),
        foregroundColor: cs.onSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        ),
      ),
    );
  }
}

// ─── Photo capture section ───────────────────────────────────────────────────
class PodPhotoSection extends StatelessWidget {
  const PodPhotoSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bytes,
    required this.isRequired,
    required this.onCapture,
    required this.onClear,
    required this.locale,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Uint8List? bytes;
  final bool isRequired;
  final VoidCallback onCapture;
  final VoidCallback onClear;
  final String locale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final captured = bytes != null;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 20, color: cs.primary),
                        const SizedBox(width: 8),
                        Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: AppTokens.fwBold)),
                        if (isRequired) Text(' *', style: TextStyle(color: cs.error, fontWeight: AppTokens.fwBold)),
                      ],
                    ),
                    const SizedBox(height: AppTokens.space6),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (captured)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: AppTokens.space12),
          if (captured)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
              child: Image.memory(bytes!, height: 200, width: double.infinity, fit: BoxFit.cover),
            )
          else
            GestureDetector(
              onTap: onCapture,
              child: CustomPaint(
                painter: DashedRectPainter(
                  color: cs.outlineVariant,
                  strokeWidth: 1.5,
                ),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(LucideIcons.camera, size: 24, color: cs.primary),
                        ),
                        const SizedBox(height: AppTokens.space12),
                        Text(
                          AppLocalizations.of(context).pod_photo_tap_hint,
                          style: TextStyle(fontSize: 14, color: cs.primary, fontWeight: AppTokens.fwBold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: AppTokens.space12),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onCapture,
                icon: const Icon(LucideIcons.camera, size: 16),
                label: Text(captured ? AppLocalizations.of(context).pod_photo_retake : AppLocalizations.of(context).pod_photo_take),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              if (captured) ...[
                const SizedBox(width: AppTokens.space8),
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(LucideIcons.trash2, size: 16),
                  label: Text(AppLocalizations.of(context).pod_photo_delete),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.error,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Notes field ─────────────────────────────────────────────────────────────
class PodNotesField extends StatelessWidget {
  const PodNotesField({super.key, required this.controller, required this.locale});
  final TextEditingController controller;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.stickyNote, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: AppTokens.space8),
              Text(
                AppLocalizations.of(context).podNotesTitle,
                style: TextStyle(fontWeight: AppTokens.fwSemiBold, color: cs.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space10),
          TextField(
            controller: controller,
            minLines: 2,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context).podNotesHint,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Generic toggle card (location + partial) ────────────────────────────────
class PodToggleCard extends StatelessWidget {
  const PodToggleCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.expanded,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppTokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: AppTokens.fwSemiBold, color: cs.onSurface)),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Switch(value: value, onChanged: onChanged),
            ],
          ),
          if (value && expanded != null) ...[
            const Divider(height: 24),
            expanded!,
          ],
        ],
      ),
    );
  }
}

// ─── Per-item outcome row ────────────────────────────────────────────────────
/// Per-unit breakdown editor for one order line. A line of qty N is split into a *delivered* slice
/// (derived, read-only) plus up to three shortfall dispositions — missing / refused / damaged — each
/// with its own quantity stepper and motif chips. This lets a driver record a genuinely mixed
/// outcome on a single line (e.g. of 4: 2 delivered + 1 refused + 1 damaged), instead of one outcome
/// per line. The parent owns the state; this widget is purely presentational.
class PodItemOutcomeRow extends StatelessWidget {
  const PodItemOutcomeRow({
    super.key,
    required this.item,
    required this.delivered,
    required this.dispQty,
    required this.dispReason,
    this.adminReasons = const [],
    required this.locale,
    required this.onDispQty,
    required this.onDispReason,
  });

  final dynamic item;

  /// Derived delivered quantity (`planned − Σ shortfall`); read-only here.
  final int delivered;

  /// Shortfall quantities keyed by disposition (MISSING / REFUSED / DAMAGED).
  final Map<String, int> dispQty;

  /// Chosen motif code per disposition (null until picked).
  final Map<String, String?> dispReason;

  final List<FailureReasonOption> adminReasons;
  final String locale;
  final void Function(String disposition, int qty) onDispQty;
  final void Function(String disposition, String code) onDispReason;

  static const _shortfallDisps = ['MISSING', 'REFUSED', 'DAMAGED'];

  PodOutcome _descriptor(String value) =>
      kPodOutcomes.firstWhere((o) => o.value == value, orElse: () => kPodOutcomes.first);

  /// Motif chips for a disposition, from the admin referential — matched by `category` and restricted
  /// to item-scoped reasons. Empty offline / when nothing is configured (the parent then treats the
  /// motif as optional so the driver isn't blocked).
  List<({String code, String label})> _reasonChips(String disposition) {
    if (adminReasons.isNotEmpty) {
      final filtered = adminReasons.where((r) => r.coversItem && r.category == disposition).toList();
      if (filtered.isNotEmpty) {
        return filtered.map((r) => (code: r.code, label: r.label)).toList();
      }
    }
    return const <({String code, String label})>[];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final plannedQty = item.quantity as int;
    final shortfall = plannedQty - delivered;
    final hasShortfall = shortfall > 0;
    final accent = hasShortfall ? cs.secondary : cs.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.space16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: item identity + delivered/planned tally ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Icon(LucideIcons.package, size: 16, color: accent),
                ),
                const SizedBox(width: AppTokens.space10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name as String,
                          style: TextStyle(fontWeight: AppTokens.fwBold, fontSize: 14, color: cs.onSurface)),
                      if (item.sku != null && item.sku != item.name)
                        Text(item.sku as String, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Text(
                    '$delivered / $plannedQty',
                    style: TextStyle(
                      fontSize: 12, fontWeight: AppTokens.fwBold, fontFamily: 'monospace',
                      color: hasShortfall ? cs.secondary : cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space12),
          Divider(height: 1, color: cs.outlineVariant),

          // ── Delivered slice (derived, read-only) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(LucideIcons.checkCircle2, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context).pod_delivered_qty,
                    style: TextStyle(fontSize: 13, fontWeight: AppTokens.fwSemiBold, color: cs.onSurface)),
                const Spacer(),
                Text('$delivered',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: hasShortfall ? cs.secondary : cs.primary)),
                Text(' / $plannedQty', style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              ],
            ),
          ),

          // ── Shortfall dispositions: each a stepper (+ motif chips when > 0) ──
          for (final disp in _shortfallDisps) ...[
            Divider(height: 1, color: cs.outlineVariant),
            _dispositionRow(context, disp),
          ],
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _dispositionRow(BuildContext context, String disposition) {
    final cs = Theme.of(context).colorScheme;
    final color = _descriptor(disposition).resolve(cs);
    final icon = _descriptor(disposition).icon;
    final qty = dispQty[disposition] ?? 0;
    final active = qty > 0;
    // A slice can grow only while some quantity is still delivered.
    final canAdd = delivered > 0;
    final chips = _reasonChips(disposition);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 16, color: active ? color : cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                podOutcomeLabel(disposition, locale),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? AppTokens.fwSemiBold : AppTokens.fwMedium,
                  color: active ? color : cs.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              _QtyButton(
                icon: LucideIcons.minus,
                enabled: qty > 0,
                color: cs.error,
                onTap: () => onDispQty(disposition, qty - 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$qty',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: active ? color : cs.onSurfaceVariant)),
              ),
              _QtyButton(
                icon: LucideIcons.plus,
                enabled: canAdd,
                color: color,
                onTap: () => onDispQty(disposition, qty + 1),
              ),
            ],
          ),
        ),
        if (active && chips.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(40, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips.map((r) {
                final selected = dispReason[disposition] == r.code;
                return GestureDetector(
                  onTap: () => onDispReason(disposition, r.code),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? color.withValues(alpha: 0.15) : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                      border: Border.all(color: selected ? color : cs.outlineVariant, width: selected ? 1.5 : 1),
                    ),
                    child: Text(
                      r.label,
                      style: TextStyle(fontSize: 12, fontWeight: AppTokens.fwMedium, color: selected ? color : cs.onSurfaceVariant),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.enabled, required this.color, required this.onTap});
  final IconData icon;
  final bool enabled;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: enabled ? color.withValues(alpha: 0.12) : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppTokens.radiusSm),
          border: Border.all(color: enabled ? color : cs.outlineVariant),
        ),
        child: Icon(icon, size: 16, color: enabled ? color : cs.onSurfaceVariant),
      ),
    );
  }
}
