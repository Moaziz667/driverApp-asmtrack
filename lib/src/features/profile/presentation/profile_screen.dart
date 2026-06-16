import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app_providers.dart';
import '../../../services/locale_provider.dart';
import '../../../services/location_service.dart';
import '../../../theme/widgets.dart';
import '../../../theme/status_colors.dart';
import '../../../theme/tokens.dart';

import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _locationSending = false;
  bool _availabilityLoading = false;

  Future<void> _setAvailability(String status) async {
    setState(() => _availabilityLoading = true);
    try {
      await ref.read(profileRepositoryProvider).updateAvailability(status);
      ref.invalidate(driverProfileProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
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
          final locale = ref.read(localeProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(DriverCopy.get('position_sent', locale)),
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

  Future<void> _logout() async {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = ref.read(localeProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(DriverCopy.get('logout_confirm_title', locale)),
        content: Text(DriverCopy.get('logout_confirm_body', locale), style: TextStyle(color: cs.onSurfaceVariant)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(DriverCopy.get('cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(DriverCopy.get('logout', locale), style: TextStyle(color: cs.error)),
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
    final locale = ref.watch(localeProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(AppTokens.space16, 0, AppTokens.space16, AppTokens.space40),
      children: [
        const SizedBox(height: AppTokens.space20),
        profileAsync.when(
          data: (profile) {
            final driverColor = statusColors.forDriverStatus(profile.onlineStatus);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section label
                _SectionLabel(icon: LucideIcons.user, label: DriverCopy.get('profile_title', locale)),

                // Profile card
                _ProfileCard(
                  phone: profile.phone,
                  city: profile.city,
                  driverId: profile.id,
                  lastPing: profile.lastLocationAt,
                  gps: profile.currentLat != null && profile.currentLng != null
                      ? '${profile.currentLat!.toStringAsFixed(4)}, ${profile.currentLng!.toStringAsFixed(4)}'
                      : null,
                  onlineStatus: profile.onlineStatus,
                  driverColor: driverColor,
                  locale: locale,
                ),

                const SizedBox(height: AppTokens.space16),

                // Shift controls
                _ShiftControls(
                  status: profile.onlineStatus,
                  loading: _availabilityLoading,
                  onSetStatus: _setAvailability,
                  locale: locale,
                ),

                const SizedBox(height: AppTokens.space16),

                // Stats
                statsAsync.when(
                  data: (stats) => _StatsCard(
                    delivered: stats.delivered,
                    failed: stats.failed,
                    total: stats.totalDeliveries,
                    locale: locale,
                    statusColors: statusColors,
                  ),
                  loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: AppTokens.space24),

                // Actions
                _SectionLabel(icon: LucideIcons.settings, label: DriverCopy.get('section_actions', locale)),
                const SizedBox(height: AppTokens.space12),
                _ActionCard(
                  children: [
                    _ActionRow(
                      icon: LucideIcons.navigation2,
                      iconColor: cs.primary,
                      title: DriverCopy.get('send_location', locale),
                      trailing: _locationSending
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(LucideIcons.chevronRight, size: 18, color: cs.onSurfaceVariant),
                      onTap: _locationSending ? null : _sendLocation,
                    ),
                    _Divider(indent: AppTokens.space56),
                    _ActionRow(
                      icon: LucideIcons.key,
                      iconColor: cs.secondary,
                      title: DriverCopy.get('change_password', locale),
                      trailing: Icon(LucideIcons.chevronRight, size: 18, color: cs.onSurfaceVariant),
                      onTap: () async {
                        try {
                          // Passwords are owned by Keycloak — open its account
                          // console (same realm the app authenticates against).
                          final client = ref.read(apiClientProvider);
                          final accountUrl = Uri.parse(client.config.accountConsoleUrl);
                          if (await canLaunchUrl(accountUrl)) {
                            await launchUrl(accountUrl, mode: LaunchMode.externalApplication);
                          }
                        } catch (_) {}
                      },
                    ),
                    _Divider(indent: AppTokens.space56),
                    _ActionRow(
                      icon: LucideIcons.logOut,
                      iconColor: cs.error,
                      title: DriverCopy.get('logout', locale),
                      titleColor: cs.error,
                      trailing: Icon(LucideIcons.chevronRight, size: 18, color: cs.error.withValues(alpha: 0.5)),
                      onTap: _logout,
                    ),
                  ],
                ),

                const SizedBox(height: AppTokens.space16),

                // Language
                _SectionLabel(icon: LucideIcons.languages, label: DriverCopy.get('language_setting', locale)),
                const SizedBox(height: AppTokens.space12),
                _LanguageSelector(locale: locale),
              ],
            );
          },
          loading: () => LoadingState(
            message: locale == 'ar' ? 'جاري تحميل الملف الشخصي…' : (locale == 'en' ? 'Loading profile…' : 'Chargement du profil…'),
          ),
          error: (_, __) => EmptyState(
            icon: LucideIcons.userX,
            title: locale == 'ar' ? 'الملف الشخصي غير متاح' : (locale == 'en' ? 'Profile unavailable' : 'Profil indisponible'),
            action: () => ref.invalidate(driverProfileProvider),
            actionLabel: locale == 'ar' ? 'إعادة المحاولة' : (locale == 'en' ? 'Retry' : 'Reessayer'),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.space12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: cs.primary),
            const SizedBox(width: AppTokens.space8),
          ],
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: AppTokens.fwBold,
              color: cs.primary,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.phone,
    required this.city,
    required this.driverId,
    required this.lastPing,
    required this.gps,
    required this.onlineStatus,
    required this.driverColor,
    required this.locale,
  });

  final String phone;
  final String? city;
  final String driverId;
  final DateTime? lastPing;
  final String? gps;
  final String onlineStatus;
  final Color driverColor;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: AppTokens.shadowSm(brightness: theme.brightness),
      ),
      child: Column(
        children: [
          // Gradient hero header tinted with the driver's live status colour.
          Container(
            padding: const EdgeInsets.all(AppTokens.space20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  driverColor.withValues(alpha: 0.20),
                  driverColor.withValues(alpha: 0.04),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTokens.radiusLg)),
            ),
            child: Row(
              children: [
                // Identity (avatar + name) intentionally omitted here — the home top bar
                // already shows it on every tab; repeating it on Profile was duplication.
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: AppTokens.fwMedium,
                        ),
                      ),
                      if (city != null) ...[
                        const SizedBox(height: AppTokens.space6),
                        Row(
                          children: [
                            Icon(LucideIcons.mapPin, size: 12, color: cs.primary),
                            const SizedBox(width: AppTokens.space4),
                            Text(
                              city!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: AppTokens.fwSemiBold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Status badge
                _StatusBadge(status: onlineStatus, color: driverColor, locale: locale),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(AppTokens.space20),
            child: Column(
              children: [
                _InfoRow(
                  icon: LucideIcons.hash,
                  label: DriverCopy.get('driver_id', locale),
                  value: driverId,
                ),
                if (lastPing != null) ...[
                  _Divider(),
                  _InfoRow(
                    icon: LucideIcons.clock,
                    label: DriverCopy.get('last_ping', locale),
                    value: DateFormat('MMM d · HH:mm').format(lastPing!.toLocal()),
                  ),
                ],
                if (gps != null) ...[
                  _Divider(),
                  _InfoRow(
                    icon: LucideIcons.globe,
                    label: DriverCopy.get('gps', locale),
                    value: gps!,
                    valueColor: cs.primary,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color, required this.locale});
  final String status;
  final Color color;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = status == 'ONLINE'
        ? DriverCopy.get('status_online_upper', locale)
        : (status == 'ON_BREAK' ? DriverCopy.get('status_on_break_upper', locale) : DriverCopy.get('status_offline_upper', locale));

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
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppTokens.space6),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: AppTokens.fwBold,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value, this.valueColor});
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.space10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: Icon(icon, size: 15, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: AppTokens.space12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: AppTokens.fwMedium,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppTokens.space8),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTokens.fwSemiBold,
              color: valueColor ?? cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({this.indent});
  final double? indent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      color: cs.outlineVariant.withValues(alpha: 0.4),
      indent: indent ?? AppTokens.space44,
    );
  }
}

class _ShiftControls extends StatelessWidget {
  const _ShiftControls({
    required this.status,
    required this.loading,
    required this.onSetStatus,
    required this.locale,
  });
  final String status;
  final bool loading;
  final Future<void> Function(String) onSetStatus;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final statusColors = theme.extension<StatusColors>()!;

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
            label: DriverCopy.get('status_offline', locale),
            active: status != 'ONLINE' && status != 'ON_BREAK',
            activeColor: statusColors.offline,
            onTap: () => onSetStatus('OFFLINE'),
          ),
          _StatusSegmentButton(
            label: DriverCopy.get('status_on_break', locale),
            active: status == 'ON_BREAK',
            activeColor: statusColors.onBreak,
            onTap: () => onSetStatus('ON_BREAK'),
          ),
          _StatusSegmentButton(
            label: DriverCopy.get('status_online', locale),
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTokens.radiusXl),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Center(
            child: Text(
              label.toUpperCase(),
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
    );
  }
}

class _LanguageSelector extends ConsumerWidget {
  const _LanguageSelector({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppTokens.space6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusXl),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
      ),
      child: Row(
        children: [
          _LangButton(label: 'FR', active: locale == 'fr', onTap: () => ref.read(localeProvider.notifier).setLocale('fr')),
          _LangButton(label: 'EN', active: locale == 'en', onTap: () => ref.read(localeProvider.notifier).setLocale('en')),
          _LangButton(label: 'AR', active: locale == 'ar', onTap: () => ref.read(localeProvider.notifier).setLocale('ar')),
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
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppTokens.space12),
          decoration: BoxDecoration(
            color: active ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            boxShadow: [
              if (active)
                BoxShadow(
                  color: cs.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
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
    );
  }
}

/// Performance card: a prominent success-rate headline + progress bar, with the
/// delivered / failed / total breakdown as a segmented footer.
class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.delivered,
    required this.failed,
    required this.total,
    required this.locale,
    required this.statusColors,
  });
  final int delivered;
  final int failed;
  final int total;
  final String locale;
  final StatusColors statusColors;

  String get _rateLabel =>
      locale == 'ar' ? 'نسبة النجاح' : (locale == 'en' ? 'Success rate' : 'Taux de réussite');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final rate = total > 0 ? (delivered / total * 100).round() : 0;
    final progress = total > 0 ? delivered / total : 0.0;
    final accent = statusColors.delivered;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
        boxShadow: AppTokens.shadowSm(brightness: theme.brightness),
      ),
      child: Padding(
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
                        _rateLabel.toUpperCase(),
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                    border: Border.all(color: accent.withValues(alpha: 0.2)),
                  ),
                  child: Icon(LucideIcons.trendingUp, color: accent, size: 24),
                ),
              ],
            ),
            const SizedBox(height: AppTokens.space14),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(accent),
              ),
            ),
            const SizedBox(height: AppTokens.space16),
            Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
            const SizedBox(height: AppTokens.space14),
            Row(
              children: [
                Expanded(child: _StatSegment(value: '$delivered', label: DriverCopy.get('metric_delivered', locale), color: accent, icon: LucideIcons.checkCircle2)),
                _SegDivider(),
                Expanded(child: _StatSegment(value: '$failed', label: DriverCopy.get('metric_failed', locale), color: cs.error, icon: LucideIcons.xCircle)),
                _SegDivider(),
                Expanded(child: _StatSegment(value: '$total', label: DriverCopy.get('metric_total', locale), color: cs.primary, icon: LucideIcons.package)),
              ],
            ),
          ],
        ),
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6), width: 1),
        boxShadow: AppTokens.shadowSm(brightness: Theme.of(context).brightness),
      ),
      child: Column(children: children),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.trailing,
    this.onTap,
    this.titleColor,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space20, vertical: AppTokens.space16),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSm),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
            const SizedBox(width: AppTokens.space16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: AppTokens.fwSemiBold,
                  fontSize: 14,
                  color: titleColor ?? cs.onSurface,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
