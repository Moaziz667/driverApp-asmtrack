import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../models/delivery_models.dart';
import '../../models/status_labels.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';
import '../../../../services/locale_provider.dart';
import '../../../../theme/status_colors.dart';

class DeliveryCard extends ConsumerWidget {
  const DeliveryCard({
    super.key,
    required this.delivery,
    this.onTap,
    this.onPrimary,
    this.primaryLabel,
  });

  final DriverDelivery delivery;
  final VoidCallback? onTap;
  final VoidCallback? onPrimary;
  final String? primaryLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final statusColors = Theme.of(context).extension<StatusColors>()!;

    final Color statusColor = switch (delivery.status) {
      DeliveryStatus.unscheduled       => statusColors.unscheduled,
      DeliveryStatus.scheduled         => statusColors.scheduled,
      DeliveryStatus.pickedUp          => statusColors.pickedUp,
      DeliveryStatus.inTransit         => statusColors.inTransit,
      DeliveryStatus.awaitingHandoff   => statusColors.pickedUp,
      DeliveryStatus.delivered         => statusColors.delivered,
      DeliveryStatus.partially_delivered => statusColors.partiallyDelivered,
      DeliveryStatus.failed            => statusColors.failed,
      DeliveryStatus.cancelled         => statusColors.cancelled,
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Color strip
            Container(
              height: 3,
              color: statusColor,
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + priority row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              deliveryStatusLabel(delivery.status, AppLocalizations.of(context), isReturn: delivery.isReturnPickup),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: statusColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // ADR-033 — flag a return collection so the driver spots it in the route list.
                      if (delivery.isReturnPickup) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.tertiary.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: cs.tertiary.withValues(alpha: 0.15)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(PhosphorIconsRegular.arrowUUpLeft, size: 11, color: cs.tertiary),
                              const SizedBox(width: 4),
                              Text(
                                delivery.rmaNumber ?? AppLocalizations.of(context).return_pickup_badge,
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: cs.tertiary,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (delivery.priority != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.secondary.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: cs.secondary.withValues(alpha: 0.15)),
                          ),
                          child: Text(
                            _titleCase(delivery.priority!),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.secondary,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Address
                  Text(
                    delivery.address ?? AppLocalizations.of(context).deliveryNoAddressProvided,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                  ),
                  if (delivery.city != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(PhosphorIconsRegular.mapPin, size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          delivery.city!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  Divider(color: cs.outlineVariant, height: 1),
                  const SizedBox(height: 12),
                  // Footer metadata
                  Row(
                    children: [
                      _Meta(
                        label: AppLocalizations.of(context).deliveryOrder,
                        value: delivery.orderId ?? 'N/A',
                      ),
                      const SizedBox(width: 16),
                      _Meta(
                        label: l10n.delivery_detail_articles,
                        value: '${delivery.items.length}',
                      ),
                      const Spacer(),
                      Icon(PhosphorIconsBold.caretRight, size: 12, color: cs.onSurfaceVariant),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _titleCase(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
