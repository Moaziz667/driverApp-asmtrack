import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app_providers.dart';
import '../../../config/app_config.dart';
import '../../../services/locale_provider.dart';
import '../../../theme/tokens.dart';
import '../../../theme/widgets.dart';
import 'setup_account_screen.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  static const routeName = '/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // DEV-ONLY: only used on web (ROPC sign-in). Mobile uses the SSO redirect.
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  /// Lets the driver point this installed build at a different backend (local vs dev server)
  /// WITHOUT rebuilding. Persisted in TokenStorage; updating appConfigProvider rebuilds the Dio
  /// client + derives the matching Keycloak host automatically (api host : 8089).
  Future<void> _editServerUrl() async {
    final current = ref.read(appConfigProvider).apiBaseUrl;
    final ctrl = TextEditingController(text: current);
    final entered = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context).loginServerUrl),
        content: TextField(
          controller: ctrl,
          autocorrect: false,
          keyboardType: TextInputType.url,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).loginServerUrlHint,
            helperText: AppLocalizations.of(context).loginServerUrlDesc,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLocalizations.of(context).loginServerCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: Text(AppLocalizations.of(context).loginServerSave)),
        ],
      ),
    );
    if (entered == null || entered.isEmpty) return;
    final uri = Uri.tryParse(entered);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).loginServerUrlInvalid)));
      }
      return;
    }
    final normalized = entered.endsWith('/') ? entered.substring(0, entered.length - 1) : entered;
    await ref.read(tokenStorageProvider).saveApiBaseUrl(normalized);
    ref.read(appConfigProvider.notifier).state = AppConfig.fromStorage(normalized);
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text('Serveur: ${uri.host}')));
    }
  }

  Future<void> _onSubmit() async {
    try {
      await ref.read(authControllerProvider.notifier).login(
            email: kIsWeb ? _emailCtrl.text.trim() : null,
            password: kIsWeb ? _passwordCtrl.text : null,
          );
      // Navigation on success is handled centrally by DriverApp's auth listener.
    } catch (_) {
      if (mounted) {
        final message = ref.read(authControllerProvider).error ??
            AppLocalizations.of(context).login_failed_error;
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final auth = ref.watch(authControllerProvider);
    final locale = ref.watch(localeProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF0F172A), const Color(0xFF020617)]
                : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.vertical - 32,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language switcher (top-right)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _LangSwitcher(
                      locale: locale,
                      onPick: (l) => ref.read(localeProvider.notifier).setLocale(l),
                    ),
                  ),

                  // Branding
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      const AppLogo(size: 76),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context).login_driver_space,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context).login_secure_access.toUpperCase(),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),

                  // Auth card
                  Card(
                    elevation: theme.brightness == Brightness.dark ? 12 : 4,
                    color: cs.surfaceContainerLow.withValues(alpha: theme.brightness == Brightness.dark ? 0.6 : 0.9),
                    shadowColor: Colors.black.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTokens.radiusXl),
                      side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4), width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.shieldCheck, size: 16, color: cs.primary),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context).login_auth_header.toUpperCase(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            AppLocalizations.of(context).login_auth_desc,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface.withValues(alpha: 0.8),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // DEV-ONLY web sign-in form (ROPC). Mobile keeps the
                          // single SSO button below.
                          if (kIsWeb) ...[
                            TextField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.username],
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(LucideIcons.mail, size: 18),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passwordCtrl,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              onSubmitted: (_) => auth.isLoading ? null : _onSubmit(),
                              decoration: const InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: Icon(LucideIcons.lock, size: 18),
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                          SizedBox(
                            height: 56,
                            child: FilledButton.icon(
                              onPressed: auth.isLoading ? null : _onSubmit,
                              icon: auth.isLoading
                                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                  : const Icon(LucideIcons.logIn, size: 18),
                              label: Text(
                                auth.isLoading
                                    ? AppLocalizations.of(context).login_action_connecting
                                    : AppLocalizations.of(context).login_action_connect,
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          // Secure-login trust line (hidden on the web dev form —
                          // ROPC is not the SSO flow this line advertises).
                          if (!kIsWeb)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(LucideIcons.lock, size: 13, color: cs.onSurfaceVariant),
                                const SizedBox(width: 6),
                                Text(
                                  AppLocalizations.of(context).login_secure_sso,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          if (auth.error != null) ...[
                            const SizedBox(height: 18),
                            _ErrorBanner(auth.error!, cs),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Secondary action tiles + version
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      _ActionTile(
                        icon: LucideIcons.userPlus,
                        title: AppLocalizations.of(context).login_action_setup,
                        subtitle: AppLocalizations.of(context).login_action_setup_sub,
                        onTap: () => Navigator.of(context).pushNamed(SetupAccountScreen.routeName),
                      ),
                      const SizedBox(height: 16),
                      _VersionLabel(locale: locale),
                      const SizedBox(height: 2),
                      // Backend switcher: lets one installed build target local vs dev without a rebuild.
                      TextButton.icon(
                        onPressed: _editServerUrl,
                        icon: Icon(LucideIcons.server, size: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                        label: Text(
                          Uri.tryParse(ref.watch(appConfigProvider).apiBaseUrl)?.host ?? '—',
                          style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                        ),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangSwitcher extends StatelessWidget {
  const _LangSwitcher({required this.locale, required this.onPick});
  final String locale;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final l in const ['fr', 'en', 'ar']) _pill(context, l),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String l) {
    final cs = Theme.of(context).colorScheme;
    final active = locale == l;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTokens.radiusFull),
      child: InkWell(
        onTap: () => onPick(l),
        borderRadius: BorderRadius.circular(AppTokens.radiusFull),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTokens.radiusFull),
          ),
          child: Text(
            l.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: active ? Colors.white : cs.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: cs.surfaceContainerLow.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.8),
      borderRadius: BorderRadius.circular(AppTokens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTokens.radiusLg),
            border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                ),
                child: Icon(icon, size: 20, color: cs.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel({required this.locale});
  final String locale;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox(height: 14);
        final info = snap.data!;
        return Text(
          '${AppLocalizations.of(context).login_version} ${info.version} (${info.buildNumber})',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner(this.message, this.colorScheme);
  final String message;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          border: Border.all(color: colorScheme.error),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 16, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(child: Text(message, style: TextStyle(fontSize: 13, color: colorScheme.error))),
          ],
        ),
      );
}
