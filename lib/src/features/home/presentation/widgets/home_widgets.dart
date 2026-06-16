import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app_providers.dart';
import '../../../../services/locale_provider.dart';
import '../../../../services/notification_store.dart';
import '../../../../services/offline_queue_service.dart';
import '../../../../theme/status_colors.dart';
import '../../../../theme/tokens.dart';
import '../../../deliveries/presentation/handoff_inbox_screen.dart';

class ModernBottomNav extends StatelessWidget {
  const ModernBottomNav({super.key, 
    required this.selectedIndex,
    required this.onTabSelected,
    required this.locale,
  });
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final String locale;

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
              label: DriverCopy.get('tab_route', locale),
              isSelected: selectedIndex == 0,
              onTap: () => onTabSelected(0),
            ),
            _NavTab(
              icon: PhosphorIconsRegular.calendarDots,
              activeIcon: PhosphorIconsFill.calendarDots,
              label: DriverCopy.get('tab_calendar', locale),
              isSelected: selectedIndex == 1,
              onTap: () => onTabSelected(1),
            ),
            _NavTab(
              icon: PhosphorIconsRegular.userCircle,
              activeIcon: PhosphorIconsFill.userCircle,
              label: DriverCopy.get('tab_profile', locale),
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
    final locale = ref.watch(localeProvider);
    final profile = ref.watch(driverProfileProvider).value;
    final todayRoutes = ref.watch(todayRouteProvider).value;
    final statusColors = theme.extension<StatusColors>()!;

    final driverName = profile?.name.isNotEmpty == true ? profile!.name.split(' ').first : 'Driver';
    final driverStatus = profile?.onlineStatus ?? 'OFFLINE';
    final initial = profile != null && profile.name.isNotEmpty
        ? profile.name[0].toUpperCase()
        : 'D';
    final statusColor = statusColors.forDriverStatus(driverStatus);

    final totalStops = todayRoutes?.totalStops ?? todayRoutes?.stops.length ?? 0;
    final completedStops = todayRoutes?.completedStops ?? 0;
    final progress = totalStops > 0 ? completedStops / totalStops : 0.0;

    final greeting = _greeting(locale);

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(AppTokens.space16, AppTokens.space12, AppTokens.space16, AppTokens.space12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A0B10) : const Color(0xFFF8FAFC),
          border: Border(
            bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar with status ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2.5),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: cs.surfaceContainerLow,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontWeight: AppTokens.fwBold,
                        fontSize: 15,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.space12),

                // Greeting + progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting, $driverName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: AppTokens.fwBold,
                          color: cs.onSurface,
                        ),
                      ),
                      if (totalStops > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '$completedStops/$totalStops ${_stopsLabel(completedStops, totalStops, locale)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: AppTokens.fwMedium,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Status pill
                _DriverStatusPill(status: driverStatus, statusColor: statusColor),
                const SizedBox(width: AppTokens.space8),

                // Handoff inbox
                const _HandoffButton(),
                const SizedBox(width: AppTokens.space8),

                // Notification bell
                _NotifButton(onTap: onOpenNotifications),
              ],
            ),
            if (totalStops > 0) ...[
              const SizedBox(height: AppTokens.space10),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _greeting(String locale) {
    final hour = DateTime.now().hour;
    if (locale == 'ar') {
      if (hour < 12) return 'صباح الخير';
      if (hour < 17) return 'مساء الخير';
      return 'مساء الخير';
    }
    if (locale == 'en') {
      if (hour < 12) return 'Good morning';
      if (hour < 17) return 'Good afternoon';
      return 'Good evening';
    }
    if (hour < 12) return 'Bonjour';
    if (hour < 17) return 'Bon après-midi';
    return 'Bonsoir';
  }

  String _stopsLabel(int done, int total, String locale) {
    if (locale == 'ar') return 'توقف';
    if (locale == 'en') return total == 1 ? 'stop' : 'stops';
    return total == 1 ? 'arrêt' : 'arrêts';
  }
}

class _DriverStatusPill extends ConsumerWidget {
  const _DriverStatusPill({required this.status, required this.statusColor});
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final label = status == 'ONLINE'
        ? DriverCopy.get('status_online_upper', locale)
        : (status == 'ON_BREAK' ? DriverCopy.get('status_on_break_upper', locale) : DriverCopy.get('status_offline_upper', locale));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.space10, vertical: AppTokens.space4),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        border: Border.all(color: statusColor.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTokens.space6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: AppTokens.fwBold,
              color: statusColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotifButton extends ConsumerWidget {
  const _NotifButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final unread = ref.watch(unreadNotifCountProvider);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(PhosphorIconsRegular.bell, size: 20, color: cs.onSurfaceVariant),
            if (unread > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC7372F),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
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
    );
  }
}

class _HandoffButton extends ConsumerWidget {
  const _HandoffButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final count = ref.watch(handoffsProvider).valueOrNull?.length ?? 0;
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(HandoffInboxScreen.routeName),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(PhosphorIconsRegular.arrowsLeftRight, size: 20, color: cs.onSurfaceVariant),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC7372F),
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
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
    final locale = ref.watch(localeProvider);

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
                  DriverCopy.get('notifications', locale),
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
                          DriverCopy.get('no_notifications', locale),
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
                            Text(_formatTime(n.receivedAt, locale), style: theme.textTheme.labelSmall),
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

  String _formatTime(DateTime dt, String locale) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (locale == 'ar') {
      if (diff.inMinutes < 1) return 'الآن';
      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
      return 'منذ ${diff.inDays} ي';
    } else if (locale == 'en') {
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } else {
      if (diff.inMinutes < 1) return 'A l\'instant';
      if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
      if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
      return 'Il y a ${diff.inDays}j';
    }
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
    final locale = ref.watch(localeProvider);
    
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
                    ? '${DriverCopy.get('offline_banner', locale)} · $pendingCount ${locale == 'ar' ? 'تعديلات معلقة' : locale == 'en' ? 'pending updates' : 'modifications en attente'}'
                    : DriverCopy.get('offline_banner', locale),
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
                locale == 'ar'
                    ? 'تم استعادة الاتصال · جاري المزامنة...'
                    : locale == 'en'
                        ? 'Connection restored · Syncing data...'
                        : 'Connexion rétablie · Synchronisation...',
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
