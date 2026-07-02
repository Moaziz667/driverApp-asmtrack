import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../../generated/l10n/app_localizations.dart';
import '../../../../services/notification_store.dart';
import '../../../../services/offline_queue_service.dart';
import '../../../../theme/status_colors.dart';
import '../../../../theme/tokens.dart';
import '../../../deliveries/presentation/handoff_inbox_screen.dart';

class ModernBottomNav extends StatelessWidget {
  const ModernBottomNav({super.key, 
    required this.selectedIndex,
    required this.onTabSelected,
  });
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0B10) : Colors.white,
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1),
        ),
        boxShadow: AppTokens.shadowLg(brightness: theme.brightness),
      ),
      padding: const EdgeInsets.fromLTRB(AppTokens.space8, AppTokens.space8, AppTokens.space8, 0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavTab(
              icon: PhosphorIconsRegular.path,
              activeIcon: PhosphorIconsFill.path,
              label: AppLocalizations.of(context).tabRoute,
              isSelected: selectedIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavTab(
              icon: PhosphorIconsRegular.calendarDots,
              activeIcon: PhosphorIconsFill.calendarDots,
              label: AppLocalizations.of(context).tabCalendar,
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _NavTab(
              icon: PhosphorIconsRegular.userCircle,
              activeIcon: PhosphorIconsFill.userCircle,
              label: AppLocalizations.of(context).tabProfile,
              isSelected: selectedIndex == 2,
              onTap: () => onTabSelected(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppTokens.space10),
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
              ),
              const SizedBox(height: AppTokens.space4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? AppTokens.fwBold : AppTokens.fwMedium,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeTopBar extends ConsumerWidget {
  const HomeTopBar({super.key, required this.onOpenNotifications});
  final VoidCallback onOpenNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final profile = ref.watch(driverProfileProvider).value;
    final statusColors = theme.extension<StatusColors>()!;

    final driverName = profile?.name.isNotEmpty == true ? profile!.name : 'Driver';
    final driverStatus = profile?.onlineStatus ?? 'OFFLINE';
    final initial = profile != null && profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : 'D';
    final statusColor = statusColors.forDriverStatus(driverStatus);
    
    final l10n = AppLocalizations.of(context);
    final label = driverStatus == 'ONLINE'
        ? l10n.status_online_upper
        : (driverStatus == 'ON_BREAK' ? l10n.status_on_break_upper : l10n.status_offline_upper);

    final surfaceLowest = isDark ? const Color(0xFF0A0B10) : Colors.white;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: AppTokens.space12),
        decoration: BoxDecoration(
          color: surfaceLowest,
          border: Border(
            bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1),
          ),
        ),
        // Three-zone row: identity (left) · brand (centre) · actions (right).
        // Equal-flex sides keep the wordmark optically centred while guaranteeing
        // the identity text truncates instead of colliding with it.
        child: Row(
          children: [
            // Left: identity (avatar + status/name)
            Expanded(
              child: Row(
                children: [
                  // Avatar with Status Dot
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.25),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            backgroundColor: cs.surfaceContainerLow,
                            backgroundImage: (profile?.photoUrl?.isNotEmpty == true)
                                ? NetworkImage(profile!.photoUrl!)
                                : null,
                            onBackgroundImageError: (_, __) {},
                            child: (profile?.photoUrl?.isNotEmpty != true)
                                ? Text(
                                    initial,
                                    style: TextStyle(
                                      fontWeight: AppTokens.fwBold,
                                      fontSize: 14,
                                      color: cs.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: surfaceLowest,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTokens.space10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: AppTokens.fwBold,
                            color: statusColor,
                            letterSpacing: 1.2,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          driverName.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: AppTokens.fwSemiBold,
                            color: cs.onSurface,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Centre: brand wordmark
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.space8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ASM',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: cs.primary,
                      letterSpacing: -0.5,
                      height: 1,
                    ),
                  ),
                  Text(
                    'TRACK',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: AppTokens.fwBold,
                      color: cs.primary.withValues(alpha: 0.6),
                      letterSpacing: 1,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            // Right: actions
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const _HandoffButton(),
                  const SizedBox(width: 2),
                  // Sync button
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                      onTap: () {
                        ref.invalidate(todayRouteProvider);
                        ref.invalidate(activeDeliveriesProvider);
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        child: Icon(
                          PhosphorIconsRegular.arrowsClockwise,
                          size: 22,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  _NotifButton(onTap: onOpenNotifications),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifButton extends ConsumerWidget {
  const _NotifButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final unread = ref.watch(unreadNotifCountProvider);
    
    return Material(
      color: cs.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(PhosphorIconsRegular.bell, size: 22, color: cs.primary),
              if (unread > 0)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.extension<StatusColors>()!.failed,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF0A0B10) : Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HandoffButton extends ConsumerWidget {
  const _HandoffButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final count = ref.watch(handoffsProvider).valueOrNull?.length ?? 0;
    
    if (count == 0) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        onTap: () => Navigator.of(context).pushNamed(HandoffInboxScreen.routeName),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Icon(PhosphorIconsRegular.arrowsLeftRight, size: 22, color: cs.onSurfaceVariant),
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF0A0B10) : Colors.white,
                      width: 2,
                    ),
                  ),
                  constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: AppTokens.fwBold,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusColors = theme.extension<StatusColors>()!;
    final notifications = ref.watch(notificationStoreProvider);
    final store = ref.read(notificationStoreProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) => store.markAllRead());

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          const SizedBox(height: 8),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context).notifications,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIconsRegular.bellSlash, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context).noNotifications,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: controller,
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                    itemBuilder: (_, i) {
                      final n = notifications[i];
                      final tColor = _typeColor(n.type, statusColors);
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: tColor.withValues(alpha: 0.15),
                          child: Icon(_typeIcon(n.type), size: 18, color: tColor),
                        ),
                        title: Text(n.title, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (n.body.isNotEmpty)
                              Text(
                                n.body,
                                style: theme.textTheme.bodySmall,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(_formatTime(n.receivedAt, context), style: theme.textTheme.labelSmall),
                          ],
                        ),
                        isThreeLine: n.body.isNotEmpty,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'DELIVERY_ASSIGNED': return PhosphorIconsRegular.truck;
      case 'ROUTE_VALIDATED':   return PhosphorIconsRegular.mapTrifold;
      case 'ROUTE_UPDATED':     return PhosphorIconsRegular.path;
      case 'HANDOFF_REQUIRED':  return PhosphorIconsRegular.arrowsLeftRight;
      default:                  return PhosphorIconsRegular.bell;
    }
  }

  Color _typeColor(String type, StatusColors statusColors) {
    switch (type) {
      case 'DELIVERY_ASSIGNED': return statusColors.pickedUp;
      case 'ROUTE_VALIDATED':   return statusColors.delivered;
      case 'ROUTE_UPDATED':     return statusColors.unscheduled;
      case 'HANDOFF_REQUIRED':  return statusColors.partiallyDelivered;
      default:                  return statusColors.cancelled;
    }
  }

  String _formatTime(DateTime dt, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }
}

class OfflineStatusBar extends ConsumerStatefulWidget {
  const OfflineStatusBar({super.key});

  @override
  ConsumerState<OfflineStatusBar> createState() => _OfflineStatusBarState();
}

class _OfflineStatusBarState extends ConsumerState<OfflineStatusBar> {
  bool _wasOffline = false;
  bool _showSyncedBanner = false;
  Timer? _dismissTimer;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnlineAsync = ref.watch(connectionStatusProvider);
    final pendingCount = ref.watch(offlineQueueProvider);

    final isOnline = isOnlineAsync.value ?? true;

    if (isOnline && _wasOffline) {
      _wasOffline = false;
      _showSyncedBanner = true;
      _dismissTimer?.cancel();
      _dismissTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showSyncedBanner = false;
          });
        }
      });
    } else if (!isOnline) {
      _wasOffline = true;
      _showSyncedBanner = false;
    }

    final double topPadding = MediaQuery.of(context).padding.top;

    if (!isOnline) {
      final l10n = AppLocalizations.of(context);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.only(
          top: topPadding + 6,
          bottom: 8,
          left: 16,
          right: 16,
        ),
        color: const Color(0xFFF59E0B),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(PhosphorIconsRegular.cloudSlash, size: 14, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                pendingCount > 0
                    ? '${l10n.offlineBanner} · $pendingCount ${l10n.offlinePendingUpdates}'
                    : l10n.offlineBanner,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else if (_showSyncedBanner) {
      final l10n = AppLocalizations.of(context);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.only(
          top: topPadding + 6,
          bottom: 8,
          left: 16,
          right: 16,
        ),
        color: const Color(0xFF10B981),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(PhosphorIconsBold.cloudArrowUp, size: 14, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                l10n.offlineConnectionRestored,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
