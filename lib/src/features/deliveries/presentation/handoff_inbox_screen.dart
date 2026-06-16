import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app_providers.dart';
import '../../../services/locale_provider.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets.dart';
import '../models/handoff_models.dart';
import 'handoff_scanner_screen.dart';
import 'handoff_token_sheet.dart';

/// Persistent inbox of the driver's open custody transfers — the recoverable
/// counterpart to the transient realtime banner. Receiving driver scans the
/// sender's QR; sending driver shows it.
class HandoffInboxScreen extends ConsumerWidget {
  const HandoffInboxScreen({super.key});
  static const routeName = '/handoffs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    final async = ref.watch(handoffsProvider);
    final myId = ref.watch(driverProfileProvider).valueOrNull?.id;

    Future<void> refresh() async {
      ref.invalidate(handoffsProvider);
      await ref.read(handoffsProvider.future);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(DriverCopy.get('handoff_inbox_title', locale)),
      ),
      body: async.when(
        loading: () => const LoadingState(),
        error: (_, __) => EmptyState(
          icon: LucideIcons.alertTriangle,
          title: DriverCopy.get('handoff_inbox_error', locale),
          action: refresh,
          actionLabel: DriverCopy.get('handoff_inbox_retry', locale),
        ),
        data: (list) {
          final incoming = list.where((h) => h.isIncomingFor(myId)).toList();
          final outgoing = list.where((h) => h.isOutgoingFor(myId)).toList();

          if (incoming.isEmpty && outgoing.isEmpty) {
            // Wrap in a scrollable so pull-to-refresh still works when empty.
            return RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                  EmptyState(
                    icon: LucideIcons.arrowLeftRight,
                    title: DriverCopy.get('handoff_inbox_empty_title', locale),
                    subtitle: DriverCopy.get('handoff_inbox_empty_sub', locale),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (incoming.isNotEmpty) ...[
                  _SectionHeader(label: DriverCopy.get('handoff_inbox_incoming', locale)),
                  for (final h in incoming)
                    _HandoffCard(
                      handoff: h,
                      incoming: true,
                      locale: locale,
                      onAction: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const HandoffScannerScreen()),
                        );
                        if (result == true) await refresh();
                      },
                      onManual: h.deliveryId == null ? null : () async {
                        final code = await showDialog<String>(
                          context: context,
                          builder: (_) => _ManualCodeDialog(locale: locale),
                        );
                        if (code == null || code.trim().isEmpty) return;
                        try {
                          await ref.read(deliveryRepositoryProvider)
                              .confirmHandoff(h.deliveryId!, code.trim().toUpperCase());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(DriverCopy.get('handoff_manual_success', locale))),
                            );
                          }
                          await refresh();
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(DriverCopy.get('handoff_manual_error', locale)),
                                backgroundColor: Theme.of(context).colorScheme.error,
                              ),
                            );
                          }
                        }
                      },
                    ),
                ],
                if (outgoing.isNotEmpty) ...[
                  if (incoming.isNotEmpty) const SizedBox(height: 8),
                  _SectionHeader(label: DriverCopy.get('handoff_inbox_outgoing', locale)),
                  for (final h in outgoing)
                    _HandoffCard(
                      handoff: h,
                      incoming: false,
                      locale: locale,
                      onAction: h.deliveryId == null
                          ? null
                          : () => showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) => HandoffTokenSheet(deliveryId: h.deliveryId!),
                              ),
                    ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _HandoffCard extends StatelessWidget {
  const _HandoffCard({
    required this.handoff,
    required this.incoming,
    required this.locale,
    required this.onAction,
    this.onManual,
  });

  final HandoffSummary handoff;
  final bool incoming;
  final String locale;
  final VoidCallback? onAction;
  final VoidCallback? onManual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final counterpartLabel = incoming
        ? DriverCopy.get('handoff_inbox_from', locale)
        : DriverCopy.get('handoff_inbox_to', locale);
    final counterpartName = incoming ? handoff.fromDriverName : handoff.toDriverName;
    final subtitle = handoff.dropoffAddress ?? handoff.erpOrderId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Icon(
              incoming ? LucideIcons.scanLine : LucideIcons.qrCode,
              size: 20,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  handoff.clientName ?? '—',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '$counterpartLabel ${counterpartName ?? '—'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(incoming ? LucideIcons.scanLine : LucideIcons.qrCode, size: 16),
                label: Text(
                  DriverCopy.get(incoming ? 'handoff_action_scan' : 'handoff_action_show', locale),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              // Camera-broken fallback: enter the 6-char code by hand (incoming only).
              if (incoming && onManual != null)
                TextButton.icon(
                  onPressed: onManual,
                  icon: const Icon(LucideIcons.keyboard, size: 14),
                  label: Text(
                    DriverCopy.get('handoff_manual_action', locale),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Manual code entry — fallback when the receiver's camera is unusable.
class _ManualCodeDialog extends StatefulWidget {
  const _ManualCodeDialog({required this.locale});
  final String locale;

  @override
  State<_ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<_ManualCodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return AlertDialog(
      title: Text(DriverCopy.get('handoff_manual_title', locale)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4),
        decoration: InputDecoration(
          hintText: DriverCopy.get('handoff_manual_hint', locale),
          counterText: '',
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(DriverCopy.get('cancel', locale)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(DriverCopy.get('handoff_manual_confirm', locale)),
        ),
      ],
    );
  }
}
