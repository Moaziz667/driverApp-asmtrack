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

/// Per-item outcome → admin applicability context. The reason chips for each outcome come from the
/// admin failure-reason referential, filtered by the motif's `appliesTo` context (set by the admin —
/// not hardcoded here). Short-quantity DELIVERED lines map to ITEM_MISSING (a stock shortfall).
const kPodOutcomeContexts = {
  'REFUSED': 'ITEM_REFUSED',
  'DAMAGED': 'ITEM_DAMAGED',
  'MISSING': 'ITEM_MISSING',
};

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
class PodItemOutcomeRow extends StatelessWidget {
  const PodItemOutcomeRow({
    super.key,
    required this.item,
    required this.currentQty,
    required this.outcome,
    required this.reason,
    this.adminReasons = const [],
    required this.locale,
    required this.onOutcome,
    required this.onQty,
    required this.onReason,
  });

  final dynamic item;
  final int currentQty;
  final String outcome;
  final String? reason;
  final List<FailureReasonOption> adminReasons;
  final String locale;
  final ValueChanged<String> onOutcome;
  final ValueChanged<int> onQty;
  final ValueChanged<String> onReason;

  /// Resolves the reason chips for the current outcome from the admin referential, filtered by the
  /// motif's `appliesTo` context. Short-quantity DELIVERED lines use the ITEM_MISSING context.
  /// Returns empty when offline (no admin referential loaded).
  List<({String code, String label})> _reasonChips() {
    final plannedQty = item.quantity as int;
    final isPartialQty = outcome == 'DELIVERED' && currentQty < plannedQty;
    final context = isPartialQty ? 'ITEM_MISSING' : kPodOutcomeContexts[outcome];
    if (context != null && adminReasons.isNotEmpty) {
      final filtered = adminReasons.where((r) => r.appliesTo.contains(context)).toList();
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
    final opt = kPodOutcomes.firstWhere((o) => o.value == outcome, orElse: () => kPodOutcomes.first);
    final optColor = opt.resolve(cs);
    final isPartialQty = outcome == 'DELIVERED' && currentQty < plannedQty;
    final needsExtra = kPodRequiresReason.contains(outcome) || isPartialQty;
    final borderColor = isPartialQty ? cs.secondary : optColor;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.space16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: borderColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                  ),
                  child: Icon(opt.icon, size: 16, color: borderColor),
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
                    outcome == 'DELIVERED' ? '$currentQty / $plannedQty' : '0 / $plannedQty',
                    style: TextStyle(
                      fontSize: 12, fontWeight: AppTokens.fwBold, fontFamily: 'monospace',
                      color: isPartialQty ? cs.secondary : outcome != 'DELIVERED' ? cs.error : cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.space12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.8,
              children: kPodOutcomes.map((o) {
                final oColor = o.resolve(cs);
                final selected = outcome == o.value;
                return GestureDetector(
                  onTap: () => onOutcome(o.value),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: selected ? oColor.withValues(alpha: 0.18) : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                      border: Border.all(color: selected ? oColor : cs.outlineVariant, width: selected ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(o.icon, size: 15, color: selected ? oColor : cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          podOutcomeLabel(o.value, locale),
                          style: TextStyle(fontSize: 12, fontWeight: AppTokens.fwSemiBold, color: selected ? oColor : cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (outcome == 'DELIVERED') ...[
            const SizedBox(height: AppTokens.space12),
            Divider(height: 1, color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(AppLocalizations.of(context).pod_delivered_qty, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
                  const Spacer(),
                  _QtyButton(
                    icon: LucideIcons.minus,
                    enabled: currentQty > 0,
                    color: cs.error,
                    onTap: () => onQty(currentQty - 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('$currentQty',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: isPartialQty ? cs.secondary : cs.onSurface)),
                  ),
                  _QtyButton(
                    icon: LucideIcons.plus,
                    enabled: currentQty < plannedQty,
                    color: cs.primary,
                    onTap: () => onQty(currentQty + 1),
                  ),
                ],
              ),
            ),
          ],
          if (needsExtra) ...[
            Divider(height: 1, color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                isPartialQty ? AppLocalizations.of(context).pod_reason_partial : AppLocalizations.of(context).pod_reason_label,
                style: TextStyle(fontSize: 11, fontWeight: AppTokens.fwBold, color: cs.onSurfaceVariant),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _reasonChips().map((r) {
                  final selected = reason == r.code;
                  return GestureDetector(
                    onTap: () => onReason(r.code),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? optColor.withValues(alpha: 0.15) : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(AppTokens.radiusSm),
                        border: Border.all(color: selected ? optColor : cs.outlineVariant, width: selected ? 1.5 : 1),
                      ),
                      child: Text(
                        r.label,
                        style: TextStyle(fontSize: 12, fontWeight: AppTokens.fwMedium, color: selected ? optColor : cs.onSurfaceVariant),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 14),
        ],
      ),
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
