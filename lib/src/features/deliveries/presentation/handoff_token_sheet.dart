import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

import '../../../app_providers.dart';
import '../../../theme/widgets.dart';
import '../models/delivery_models.dart';

class HandoffTokenSheet extends ConsumerStatefulWidget {
  const HandoffTokenSheet({super.key, required this.deliveryId});
  final String deliveryId;

  @override
  ConsumerState<HandoffTokenSheet> createState() => _HandoffTokenSheetState();
}

class _HandoffTokenSheetState extends ConsumerState<HandoffTokenSheet> {
  HandoffTokenInfo? _info;
  String? _error;
  bool _isLoading = true;

  Timer? _ticker;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchToken();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  bool get _expired => _info != null && _remaining <= Duration.zero;

  Future<void> _fetchToken() async {
    _ticker?.cancel();
    setState(() {
      _isLoading = true;
      _error = null;
      _info = null;
    });
    try {
      final info = await ref.read(deliveryRepositoryProvider).getHandoffToken(widget.deliveryId);
      if (!mounted) return;
      setState(() => _info = info);
      _startCountdown();
    } catch (e) {
      if (mounted) setState(() => _error = _friendlyError(context, e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    final expiry = _info?.expiresAt;
    if (expiry == null) return;
    void update() {
      final left = expiry.difference(DateTime.now());
      setState(() => _remaining = left.isNegative ? Duration.zero : left);
      if (left.isNegative) _ticker?.cancel();
    }

    update();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => update());
  }

  /// Maps backend / transport failures to a driver-friendly message —
  /// never surfaces a raw exception string.
  String _friendlyError(BuildContext context, Object e) {
    final l10n = AppLocalizations.of(context);
    final s = e.toString().toLowerCase();
    if (s.contains('403') || s.contains('forbidden') || s.contains('not authorized')) {
      return l10n.handoffUnauthorized;
    }
    if (s.contains('not found') || s.contains('404') || s.contains('not awaiting')) {
      return l10n.handoffNoTransfer;
    }
    if (s.contains('socket') || s.contains('timeout') || s.contains('connection') || s.contains('network')) {
      return l10n.handoffConnectionError;
    }
    return l10n.handoffGenerateFailed;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)), // Tactical 4px
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Icon(LucideIcons.arrowLeftRight, color: cs.primary, size: 32),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).handoffAuthTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).handoffAuthDescription,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          if (_isLoading)
            SizedBox(height: 200, child: LoadingState(message: AppLocalizations.of(context).handoffGeneratingToken))
          else if (_error != null)
            _buildError()
          else if (_info != null)
            _buildQr(_info!)
          else
            const SizedBox(height: 200),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).calendarClose),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQr(HandoffTokenInfo info) {
    final cs = Theme.of(context).colorScheme;
    final expired = _expired;
    return Column(
      children: [
        // QR — dimmed + overlaid with a lock once expired so a stale code can't be scanned.
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(
              opacity: expired ? 0.25 : 1,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: QrImageView(
                  data: '${widget.deliveryId}|${info.token}',
                  version: QrVersions.auto,
                  size: 200.0,
                  gapless: false,
                ),
              ),
            ),
            if (expired)
              Icon(LucideIcons.lock, color: cs.error, size: 44),
          ],
        ),
        const SizedBox(height: 24),

        if (!expired) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: cs.primary, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context).handoffTokenLabel,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                ),
                Text(
                  info.token,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w900, color: cs.primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCountdown(),
        ] else
          _buildExpired(),
      ],
    );
  }

  Widget _buildCountdown() {
    final cs = Theme.of(context).colorScheme;
    // Warn (amber) under a minute left.
    final bool urgent = _remaining.inSeconds <= 60 && _info?.expiresAt != null;
    final Color color = urgent ? const Color(0xFFD97706) : cs.onSurfaceVariant;
    final m = _remaining.inMinutes;
    final s = _remaining.inSeconds % 60;
    final l10n = AppLocalizations.of(context);
    final label = _info?.expiresAt == null
        ? l10n.handoffExpiresIn('5:00')
        : l10n.handoffExpiresIn('${m}:${s.toString().padLeft(2, '0')}');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(LucideIcons.clock, size: 14, color: color),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: urgent ? FontWeight.w700 : FontWeight.w400)),
      ],
    );
  }

  Widget _buildExpired() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          AppLocalizations.of(context).handoffCodeExpired,
          style: TextStyle(color: cs.error, fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: FilledButton.icon(
            onPressed: _fetchToken,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: Text(AppLocalizations.of(context).handoffNewCode),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(LucideIcons.alertCircle, color: cs.error, size: 48),
        const SizedBox(height: 16),
        Text(_error!, style: TextStyle(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: FilledButton(
            onPressed: _fetchToken,
            child: Text(AppLocalizations.of(context).handoffRetry),
          ),
        ),
      ],
    );
  }
}
