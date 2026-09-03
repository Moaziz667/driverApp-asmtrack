import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

import '../../../app_providers.dart';
import '../../../services/location_service.dart';
import '../../../theme/widgets.dart';

/// Phases of the scan flow. The screen deliberately moves through a
/// "capturing (hold steady) → validating → success" sequence rather than popping
/// the instant a code lands in frame — a smoother, more trustworthy hand-off.
enum _ScanPhase { scanning, locked, capturing, validating, success }

class HandoffScannerScreen extends ConsumerStatefulWidget {
  const HandoffScannerScreen({super.key});

  @override
  ConsumerState<HandoffScannerScreen> createState() =>
      _HandoffScannerScreenState();
}

class _HandoffScannerScreenState extends ConsumerState<HandoffScannerScreen>
    with TickerProviderStateMixin {
  static const double _frameSize = 260;

  /// Deliberate "hold the code steady" capture window before validating, so a QR
  /// that flashes through the frame for a few milliseconds can't auto-confirm.
  static const Duration _captureDuration = Duration(seconds: 5);

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  // Smooth vertical sweep of the scan line.
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  // One-shot pop animation for the success checkmark.
  late final AnimationController _successPop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  // Drives the 5s capture countdown; on completion the token is validated.
  late final AnimationController _capture =
      AnimationController(vsync: this, duration: _captureDuration)
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) _finishCapture();
        });

  _ScanPhase _phase = _ScanPhase.scanning;
  bool _ready = false;
  bool _torchOn = false;
  String? _pendingDeliveryId;
  String? _pendingToken;

  @override
  void initState() {
    super.initState();
    // Brief delay so the camera initialises fully before accepting any scan —
    // prevents firing on whatever happens to be in frame when the screen opens.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    _sweep.dispose();
    _successPop.dispose();
    _capture.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool get _busy => _phase != _ScanPhase.scanning;

  void _onDetect(BarcodeCapture capture) {
    if (!_ready || _busy) return;
    final String? code = capture.barcodes.firstOrNull?.rawValue;
    if (code != null) _beginCapture(code);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error, _) => _CameraError(error: error),
          ),

          // Dimmed surround with a clear cut-out window over the frame.
          _ScrimOverlay(frameSize: _frameSize),

          // Animated frame + sweeping scan line.
          Center(
            child: SizedBox(
              width: _frameSize,
              height: _frameSize,
              child: _buildFrame(cs),
            ),
          ),

          // Top bar: close + torch.
          Positioned(
            top: 50,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(
                    LucideIcons.x,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                IconButton(
                  icon: Icon(
                    _torchOn ? LucideIcons.zap : LucideIcons.zapOff,
                    color: _torchOn ? cs.primary : Colors.white,
                    size: 26,
                  ),
                  onPressed: () async {
                    await _controller.toggleTorch();
                    if (mounted) setState(() => _torchOn = !_torchOn);
                  },
                ),
              ],
            ),
          ),

          // Bottom guidance.
          Positioned(
            bottom: 56,
            left: 30,
            right: 30,
            child: Column(
              children: [
                Icon(LucideIcons.scanLine, color: cs.primary, size: 30),
                const SizedBox(height: 14),
                Text(
                  AppLocalizations.of(context).handoffScanGuidance,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).handoffScanDescription,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          if (_phase == _ScanPhase.capturing) _buildCapturing(cs),
          if (_phase == _ScanPhase.validating) _buildValidating(),
          if (_phase == _ScanPhase.success) _buildSuccess(cs),
        ],
      ),
    );
  }

  // ── Frame + scan line ──────────────────────────────────────────────────────

  Widget _buildFrame(ColorScheme cs) {
    final bool locked =
        _phase == _ScanPhase.locked ||
        _phase == _ScanPhase.capturing ||
        _phase == _ScanPhase.validating;
    final Color accent = _phase == _ScanPhase.success
        ? Colors.green.shade400
        : cs.primary;
    return Stack(
      children: [
        // Outline.
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          decoration: BoxDecoration(
            border: Border.all(
              color: accent.withValues(alpha: locked ? 0.9 : 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        // Corners.
        Positioned(top: 0, left: 0, child: _corner(accent, 0)),
        Positioned(top: 0, right: 0, child: _corner(accent, 1.5708)),
        Positioned(bottom: 0, right: 0, child: _corner(accent, 3.14159)),
        Positioned(bottom: 0, left: 0, child: _corner(accent, 4.71239)),
        // Sweeping scan line — only while actively scanning.
        if (_phase == _ScanPhase.scanning)
          AnimatedBuilder(
            animation: _sweep,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_sweep.value);
              final y = 12 + t * (_frameSize - 24);
              return Positioned(
                left: 14,
                right: 14,
                top: y,
                child: Container(
                  height: 2.5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cs.primary.withValues(alpha: 0),
                        cs.primary,
                        cs.primary.withValues(alpha: 0),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _corner(Color color, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: color, width: 5),
            left: BorderSide(color: color, width: 5),
          ),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(2)),
        ),
      ),
    );
  }

  // ── Overlays ───────────────────────────────────────────────────────────────

  Widget _buildCapturing(ColorScheme cs) {
    return AnimatedBuilder(
      animation: _capture,
      builder: (context, _) {
        final remaining = (_captureDuration.inSeconds * (1 - _capture.value))
            .ceil()
            .clamp(1, _captureDuration.inSeconds);
        return Container(
          color: Colors.black.withValues(alpha: 0.55),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 96,
                        height: 96,
                        child: CircularProgressIndicator(
                          value: _capture.value,
                          strokeWidth: 5,
                          color: cs.primary,
                          backgroundColor: Colors.white24,
                        ),
                      ),
                      Text(
                        '$remaining',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  AppLocalizations.of(context).handoffKeepAligned,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocalizations.of(context).handoffReading,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildValidating() {
    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      child: LoadingState(
        message: AppLocalizations.of(context).handoffValidating,
      ),
    );
  }

  Widget _buildSuccess(ColorScheme cs) {
    return Container(
      color: Colors.black.withValues(alpha: 0.9),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: CurvedAnimation(
                parent: _successPop,
                curve: Curves.elasticOut,
              ),
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.green.shade400.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade400, width: 2),
                ),
                child: Icon(
                  LucideIcons.check,
                  color: Colors.green.shade400,
                  size: 52,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              AppLocalizations.of(context).handoffTransferConfirmed,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context).handoffTransferComplete,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Flow ─────────────────────────────────────────────────────────────────

  /// 1) Validate the QR format immediately (fail fast on a non-token), then enter
  /// the deliberate 5s capture window — the driver must hold the code steady. The
  /// server validation only fires once the countdown completes (_finishCapture).
  void _beginCapture(String raw) {
    final parts = raw.split('|');
    if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
      _failGracefully(AppLocalizations.of(context).handoffInvalidQr);
      return;
    }
    _pendingDeliveryId = parts[0];
    _pendingToken = parts[1];
    HapticFeedback.selectionClick();
    setState(() => _phase = _ScanPhase.capturing);
    _capture.forward(from: 0);
  }

  /// 2) Capture window elapsed → validate against the server. Capture GPS for the
  /// custody audit trail — best-effort, never blocks the confirm.
  Future<void> _finishCapture() async {
    if (!mounted || _pendingDeliveryId == null || _pendingToken == null) return;
    HapticFeedback.mediumImpact();
    setState(() => _phase = _ScanPhase.validating);
    try {
      final pos = await LocationService().currentPosition();
      await ref
          .read(deliveryRepositoryProvider)
          .confirmHandoff(
            _pendingDeliveryId!,
            _pendingToken!,
            lat: pos?.lat,
            lng: pos?.lng,
          );
      await _controller.stop();

      // 3) Deliberate success beat, then return.
      HapticFeedback.heavyImpact();
      if (!mounted) return;
      setState(() => _phase = _ScanPhase.success);
      _successPop.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 1100));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      await _failGracefully(_friendlyError(context, e));
    }
  }

  Future<void> _failGracefully(String message) async {
    _capture.reset();
    _pendingDeliveryId = null;
    _pendingToken = null;
    HapticFeedback.vibrate();
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cs.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
    // Resume scanning after a short cooldown so the same bad code doesn't re-fire instantly.
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) setState(() => _phase = _ScanPhase.scanning);
  }

  /// Maps backend / transport failures to a driver-friendly message —
  /// never surfaces a raw exception string.
  String _friendlyError(BuildContext context, Object e) {
    final l10n = AppLocalizations.of(context);
    final s = e.toString().toLowerCase();
    if (s.contains('expired') || s.contains('expir')) {
      return l10n.handoffTokenExpiredDetail;
    }
    if (s.contains('not found') || s.contains('404') || s.contains('invalid')) {
      return l10n.handoffTokenUsed;
    }
    if (s.contains('403') ||
        s.contains('forbidden') ||
        s.contains('not authorized')) {
      return l10n.handoffNotForYou;
    }
    if (s.contains('concurrent') ||
        s.contains('409') ||
        s.contains('conflict')) {
      return l10n.handoffTransferUpdated;
    }
    if (s.contains('socket') ||
        s.contains('timeout') ||
        s.contains('connection') ||
        s.contains('network')) {
      return l10n.handoffConnectionError;
    }
    return l10n.handoffGenerateFailed;
  }
}

/// Dark scrim with a transparent square window over the scan frame.
class _ScrimOverlay extends StatelessWidget {
  const _ScrimOverlay({required this.frameSize});
  final double frameSize;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withValues(alpha: 0.55),
          BlendMode.srcOut,
        ),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                backgroundBlendMode: BlendMode.dstOut,
              ),
            ),
            Center(
              child: Container(
                width: frameSize,
                height: frameSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown when the camera cannot start (permission denied, no camera, etc.).
class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});
  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.cameraOff, color: Colors.white70, size: 48),
            const SizedBox(height: 16),
            Text(
              denied
                  ? AppLocalizations.of(context).cameraAccessDenied
                  : AppLocalizations.of(context).cameraUnavailable,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              denied
                  ? AppLocalizations.of(context).cameraPermInstructions
                  : AppLocalizations.of(context).cameraStartFailed,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
