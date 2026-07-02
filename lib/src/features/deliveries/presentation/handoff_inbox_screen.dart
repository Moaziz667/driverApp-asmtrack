import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app_providers.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets.dart';
import '../models/handoff_models.dart';
import 'handoff_scanner_screen.dart';
import 'handoff_token_sheet.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

/// Persistent inbox of the driver's open custody transfers — the recoverable
/// counterpart to the transient realtime banner. Receiving driver scans the
/// sender's QR; sending driver shows it.
class HandoffInboxScreen extends ConsumerWidget {
  const HandoffInboxScreen({super.key});
  static const routeName = '/handoffs';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final async = ref.watch(handoffsProvider);
    final myId = ref.watch(driverProfileProvider).valueOrNull?.id;

    Future<void> refresh() async {
      ref.invalidate(handoffsProvider);
      await ref.read(handoffsProvider.future);
    }

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).handoff_inbox_title),
      ),
      body: async.when(
        loading: () => const LoadingState(),
        error: (_, __) => EmptyState(
          icon: LucideIcons.alertTriangle,
          title: AppLocalizations.of(context).handoff_inbox_error,
          action: refresh,
          actionLabel: AppLocalizations.of(context).handoff_inbox_retry,
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
                    title: AppLocalizations.of(context).handoff_inbox_empty_title,
                    subtitle: AppLocalizations.of(context).handoff_inbox_empty_sub,
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
                  _SectionHeader(label: AppLocalizations.of(context).handoff_inbox_incoming),
                  for (final h in incoming)
                    _HandoffCard(
                      handoff: h,
                      incoming: true,
                      onAction: () async {
                        final result = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(builder: (_) => const HandoffScannerScreen()),
                        );
                        if (result == true) await refresh();
                      },
                      onManual: h.deliveryId == null ? null : () async {
                        final code = await showDialog<String>(
                          context: context,
                          builder: (_) => const _ManualCodeDialog(),
                        );
                        if (code == null || code.trim().isEmpty) return;
                        try {
                          await ref.read(deliveryRepositoryProvider)
                              .confirmHandoff(h.deliveryId!, code.trim().toUpperCase());
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context).handoff_manual_success)),
                            );
                          }
                          await refresh();
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context).handoff_manual_error),
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
                  _SectionHeader(label: AppLocalizations.of(context).handoff_inbox_outgoing),
                  for (final h in outgoing)
                    _HandoffCard(
                      handoff: h,
                      incoming: false,
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
    required this.onAction,
    this.onManual,
  });

  final HandoffSummary handoff;
  final bool incoming;
  final VoidCallback? onAction;
  final VoidCallback? onManual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final counterpartLabel = incoming
        ? AppLocalizations.of(context).handoff_inbox_from
        : AppLocalizations.of(context).handoff_inbox_to;
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
                  incoming ? AppLocalizations.of(context).handoff_action_scan : AppLocalizations.of(context).handoff_action_show,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              // Camera-broken fallback: enter the 6-char code by hand (incoming only).
              if (incoming && onManual != null)
                TextButton.icon(
                  onPressed: onManual,
                  icon: const Icon(LucideIcons.keyboard, size: 14),
                  label: Text(
                    AppLocalizations.of(context).handoff_manual_action,
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
  const _ManualCodeDialog();

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
    return AlertDialog(
      title: Text(AppLocalizations.of(context).handoff_manual_title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 4),
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context).handoff_manual_hint,
          counterText: '',
        ),
        onSubmitted: (v) => Navigator.of(context).pop(v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(AppLocalizations.of(context).handoff_manual_confirm),
        ),
      ],
    );
  }
}
