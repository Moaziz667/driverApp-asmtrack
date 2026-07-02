import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:profile_picker_plus/profile_picker_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app_providers.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';
import '../../../services/locale_provider.dart';
import '../../../services/location_service.dart';
import '../../../theme/widgets.dart';
import '../../../theme/status_colors.dart';
import '../../../theme/tokens.dart';

/// Driver profile — SAP Fiori-inspired layout: centered hero avatar,
/// quick-action grid, grouped settings sections, sign-out.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _locationSending = false;
  bool _availabilityLoading = false;
  bool _photoUploading = false;

  Future<void> _setAvailability(String status) async {
    setState(() => _availabilityLoading = true);
    try {
      await ref.read(profileRepositoryProvider).updateAvailability(status);
      ref.invalidate(driverProfileProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).profileError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _availabilityLoading = false);
    }
  }

  Future<void> _sendLocation() async {
    setState(() => _locationSending = true);
    try {
      final point = await LocationService().currentPosition();
      if (point != null) {
        await ref.read(profileRepositoryProvider).updateLocation(point.lat, point.lng);
        if (mounted) {
          final loc = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(loc.position_sent),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _locationSending = false);
    }
  }

  Future<void> _onPhotoSelected(File? file) async {
    if (file == null || _photoUploading) return;
    setState(() => _photoUploading = true);
    try {
      await ref.read(profileRepositoryProvider).uploadPhoto(file.path);
      ref.invalidate(driverProfileProvider);
    } catch (_) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.profileUploadFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _photoUploading = false);
    }
  }

  Future<void> _changePassword() async {
    try {
      final client = ref.read(apiClientProvider);
      final accountUrl = Uri.parse(client.config.accountConsoleUrl);
      if (await canLaunchUrl(accountUrl)) {
        await launchUrl(accountUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _logout() async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.logout_confirm_title),
        content: Text(loc.logout_confirm_body, style: TextStyle(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.logout, style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(authControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = theme.extension<StatusColors>()!;
    final profileAsync = ref.watch(driverProfileProvider);
    final statsAsync = ref.watch(driverStatsProvider);
    final loc = AppLocalizations.of(context);

    return profileAsync.when(
      loading: () => LoadingState(message: loc.profileLoading),
      error: (_, __) => EmptyState(
        icon: LucideIcons.userX,
        title: loc.profileUnavailable,
        action: () => ref.invalidate(driverProfileProvider),
        actionLabel: loc.profileRetry,
      ),
      data: (profile) {
        final driverColor = statusColors.forDriverStatus(profile.onlineStatus);
        final initials = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'D';
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.space16, AppTokens.space16, AppTokens.space16, AppTokens.space32),
          children: [
            // ── Hero avatar (centered, tappable) ──
            Center(
              child: ProfilePicker(
                radius: 48,
                fallbackInitials: initials,
                initialImageUrl: (profile.photoUrl?.isNotEmpty == true) ? profile.photoUrl : null,
                onImageSelected: _onPhotoSelected,
                allowRemove: false,
                badgePosition: BadgePosition.bottomRight,
                theme: ProfilePickerTheme(
                  primaryColor: cs.primary,
                  backgroundColor: cs.surfaceContainerLow,
                ),
                pickerStrings: ProfilePickerStrings(
                  cameraLabel: loc.profileTakePhoto,
                  galleryLabel: loc.profileChooseGallery,
                  cancelLabel: loc.cancel,
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space16),

            // ── Name + contact (centered) ──
            Center(
              child: Column(
                children: [
                  Text(
                    profile.name.isNotEmpty ? profile.name : 'Driver',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: AppTokens.fwBold,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTokens.space4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.phone, size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: AppTokens.space6),
                      Flexible(
                        child: Text(
                          profile.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: AppTokens.fwMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (profile.city != null && profile.city!.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.space2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.mapPin, size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppTokens.space6),
                        Flexible(
                          child: Text(
                            profile.city!,
                            style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppTokens.space10),
                  _StatusPill(status: profile.onlineStatus, color: driverColor),
                ],
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // ── Quick actions (2-column grid) ──
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: LucideIcons.navigation2,
                    iconColor: cs.primary,
                    label: loc.send_location,
                    loading: _locationSending,
                    onTap: _locationSending ? null : _sendLocation,
                  ),
                ),
                const SizedBox(width: AppTokens.space12),
                Expanded(
                  child: _QuickActionCard(
                    icon: LucideIcons.key,
                    iconColor: cs.secondary,
                    label: loc.change_password,
                    onTap: _changePassword,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            // ── Availability ──
            _SectionHeader(label: loc.section_availability),
            const SizedBox(height: AppTokens.space12),
            _ShiftControls(
              status: profile.onlineStatus,
              loading: _availabilityLoading,
              onSetStatus: _setAvailability,
            ),
            const SizedBox(height: AppTokens.space24),

            // ── Performance ──
            _SectionHeader(label: loc.section_performance),
            const SizedBox(height: AppTokens.space12),
            statsAsync.when(
              data: (stats) => _StatsCard(
                delivered: stats.delivered,
                failed: stats.failed,
                total: stats.totalDeliveries,
                statusColors: statusColors,
              ),
              loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: AppTokens.space24),

            // ── Account (read-only) ──
            _SectionHeader(label: loc.section_account),
            const SizedBox(height: AppTokens.space12),
            _GroupCard(
              children: [
                _InfoTile(
                  icon: LucideIcons.hash,
                  label: loc.driver_id,
                  value: profile.id,
                ),
                if (profile.lastLocationAt != null) ...[
                  const _GroupDivider(),
                  _InfoTile(
                    icon: LucideIcons.clock,
                    label: loc.last_ping,
                    value: DateFormat('MMM d · HH:mm').format(profile.lastLocationAt!.toLocal()),
                  ),
                ],
                if (profile.currentLat != null && profile.currentLng != null) ...[
                  const _GroupDivider(),
                  _InfoTile(
                    icon: LucideIcons.globe,
                    label: loc.gps,
                    value: '${profile.currentLat!.toStringAsFixed(4)}, ${profile.currentLng!.toStringAsFixed(4)}',
                    valueColor: cs.primary,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppTokens.space24),

            // ── Language ──
            _SectionHeader(label: loc.language_setting),
            const SizedBox(height: AppTokens.space12),
            _LanguageSelector(),
            const SizedBox(height: AppTokens.space24),

            // ── Sign out ──
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(LucideIcons.logOut, size: 16),
                label: Text(loc.logout),
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.error,
                  side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.space20, vertical: AppTokens.space12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.radiusMd)),
                  textStyle: const TextStyle(fontWeight: AppTokens.fwSemiBold, fontSize: 13),
                ),
              ),
            ),
            const SizedBox(height: AppTokens.space24),

            // ── Footer ──
            const _AppVersionFooter(),
          ],
        );
      },
    );
  }
}

// ─── Quick action card ────────────────────────────────────────────────────────
class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.loading = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTokens.space16, horizontal: AppTokens.space12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              loading
                  ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
                  : Icon(icon, size: 22, color: iconColor),
              const SizedBox(height: AppTokens.space8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: AppTokens.fwSemiBold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Status pill ──────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.color});
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final label = status == 'ONLINE'
        ? loc.status_online_upper
        : (status == 'ON_BREAK' ? loc.status_on_break_upper : loc.status_offline_upper);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space10, vertical: AppTokens.space4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: AppTokens.space6),
          Text(
            label,
            style: TextStyle(fontSize: 10, fontWeight: AppTokens.fwBold, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontWeight: AppTokens.fwBold,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ─── Grouped card (settings list) ─────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: cs.outlineVariant.withValues(alpha: 0.4),
      indent: AppTokens.space16,
      endIndent: AppTokens.space16,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value, this.valueColor});
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space16, vertical: AppTokens.space14),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, size: 16, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: AppTokens.space12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: AppTokens.fwMedium,
            ),
          ),
          const SizedBox(width: AppTokens.space8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: AppTokens.fwSemiBold,
                color: valueColor ?? cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Availability (shift) control ─────────────────────────────────────────────
class _ShiftControls extends StatelessWidget {
  const _ShiftControls({
    required this.status,
    required this.loading,
    required this.onSetStatus,
  });
  final String status;
  final bool loading;
  final Future<void> Function(String) onSetStatus;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>()!;
    final loc = AppLocalizations.of(context);

    if (loading) {
      return Container(
        height: 56,
        alignment: Alignment.center,
        child: const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTokens.space6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        children: [
          _StatusSegmentButton(
            label: loc.status_offline,
            active: status != 'ONLINE' && status != 'ON_BREAK',
            activeColor: statusColors.offline,
            onTap: () => onSetStatus('OFFLINE'),
          ),
          _StatusSegmentButton(
            label: loc.status_on_break,
            active: status == 'ON_BREAK',
            activeColor: statusColors.onBreak,
            onTap: () => onSetStatus('ON_BREAK'),
          ),
          _StatusSegmentButton(
            label: loc.statusOnline,
            active: status == 'ONLINE',
            activeColor: statusColors.online,
            onTap: () => onSetStatus('ONLINE'),
          ),
        ],
      ),
    );
  }
}

class _StatusSegmentButton extends StatelessWidget {
  const _StatusSegmentButton({
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
  });
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusXl),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
            decoration: BoxDecoration(
              color: active ? activeColor : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            ),
            child: Center(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: AppTokens.fwBold,
                  color: active ? Colors.white : cs.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Language selector ────────────────────────────────────────────────────────
class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final currentLocale = ref.watch(localeProvider);
    return Container(
      padding: const EdgeInsets.all(AppTokens.space6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        children: [
          _LangButton(label: 'FR', active: currentLocale == 'fr', onTap: () => ref.read(localeProvider.notifier).setLocale('fr')),
          _LangButton(label: 'EN', active: currentLocale == 'en', onTap: () => ref.read(localeProvider.notifier).setLocale('en')),
          _LangButton(label: 'AR', active: currentLocale == 'ar', onTap: () => ref.read(localeProvider.notifier).setLocale('ar')),
        ],
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  const _LangButton({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTokens.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
            decoration: BoxDecoration(
              color: active ? cs.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: AppTokens.fwBold,
                  fontSize: 13,
                  color: active ? Colors.white : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Performance KPIs ─────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.delivered,
    required this.failed,
    required this.total,
    required this.statusColors,
  });
  final int delivered;
  final int failed;
  final int total;
  final StatusColors statusColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context);
    final rate = total > 0 ? (delivered / total * 100).round() : 0;
    final progress = total > 0 ? delivered / total : 0.0;
    final accent = statusColors.delivered;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
      ),
      padding: const EdgeInsets.all(AppTokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.profileSuccessRate.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: AppTokens.fwBold,
                        letterSpacing: 0.6,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppTokens.space4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$rate',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: AppTokens.fwBold,
                            letterSpacing: -1,
                            color: accent,
                          ),
                        ),
                        Text('%', style: TextStyle(fontSize: 18, fontWeight: AppTokens.fwBold, color: accent)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                child: Icon(LucideIcons.trendingUp, color: accent, size: 22),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.space14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          const SizedBox(height: AppTokens.space16),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: AppTokens.space14),
          Row(
            children: [
              Expanded(child: _StatSegment(value: '$delivered', label: loc.metric_delivered, color: accent, icon: LucideIcons.checkCircle2)),
              _SegDivider(),
              Expanded(child: _StatSegment(value: '$failed', label: loc.metric_failed, color: cs.error, icon: LucideIcons.xCircle)),
              _SegDivider(),
              Expanded(child: _StatSegment(value: '$total', label: loc.metric_total, color: cs.primary, icon: LucideIcons.package)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SegDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(width: 1, height: 34, color: cs.outlineVariant.withValues(alpha: 0.5));
  }
}

class _StatSegment extends StatelessWidget {
  const _StatSegment({required this.value, required this.label, required this.color, required this.icon});
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: AppTokens.space6),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: AppTokens.fwBold,
            color: cs.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppTokens.space2),
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: AppTokens.fwBold,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────
class _AppVersionFooter extends StatelessWidget {
  const _AppVersionFooter();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          Text(
            'ASM Track',
            style: TextStyle(
              fontSize: 12,
              fontWeight: AppTokens.fwBold,
              color: cs.onSurfaceVariant,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: AppTokens.space2),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              if (!snap.hasData) return const SizedBox(height: 14);
              return Text(
                'v${snap.data!.version} (${snap.data!.buildNumber})',
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
