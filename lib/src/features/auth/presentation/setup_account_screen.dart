import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app_providers.dart';
import '../../../theme/tokens.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';
import 'login_screen.dart';

class SetupAccountScreen extends ConsumerStatefulWidget {
  const SetupAccountScreen({super.key});
  static const routeName = '/setup-account';

  @override
  ConsumerState<SetupAccountScreen> createState() => _SetupAccountScreenState();
}

class _SetupAccountScreenState extends ConsumerState<SetupAccountScreen> {
  final _formKey = GlobalKey<FormState>(debugLabel: 'setup_form');
  final _tokenCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isValidating = false;
  bool _isResending = false;
  String? _validatedName;
  String? _error;
  String? _tokenError;

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _validateToken() async {
    final token = _tokenCtrl.text.trim();
    if (token.isEmpty) {
      setState(() => _tokenError = AppLocalizations.of(context).setupEnterCodeHint);
      return;
    }

    setState(() {
      _isValidating = true;
      _tokenError = null;
      _validatedName = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.dio.get<Map<String, dynamic>>(
        '/auth/driver/setup/validate',
        queryParameters: {'token': token},
      );
      final name = response.data?['name'] as String? ?? '';
      setState(() {
        _validatedName = name;
        _isValidating = false;
      });
    } catch (e) {
      String errorMsg;
      if (e is DioException && e.type != DioExceptionType.badResponse) {
        errorMsg = AppLocalizations.of(context).setupServerInaccessible;
      } else {
        final errorStr = e.toString().toUpperCase();
        if (errorStr.contains('INVITE_NOT_FOUND')) {
          errorMsg = AppLocalizations.of(context).setupCodeNotFound;
        } else if (errorStr.contains('INVITE_EXPIRED')) {
          errorMsg = AppLocalizations.of(context).setupCodeExpired;
        } else if (errorStr.contains('INVITE_ALREADY_USED')) {
          errorMsg = AppLocalizations.of(context).setupCodeAlreadyUsed;
        } else if (errorStr.contains('INVALID_TOKEN_FORMAT')) {
          errorMsg = AppLocalizations.of(context).setupInvalidFormat;
        } else if (errorStr.contains('CONNECTION_REFUSED') || errorStr.contains('CONNECTION TIMED OUT')) {
          errorMsg = AppLocalizations.of(context).setupServerInaccessible;
        } else {
          errorMsg = AppLocalizations.of(context).setupInvalidOrExpired;
        }
      }
      setState(() {
        _tokenError = errorMsg;
        _isValidating = false;
      });
    }
  }

  Future<void> _resendCode() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      setState(() => _tokenError = AppLocalizations.of(context).setupEnterPhoneHint);
      return;
    }

    setState(() {
      _isResending = true;
      _tokenError = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      final response = await client.dio.post<Map<String, dynamic>>(
        '/auth/driver/setup/resend',
        queryParameters: {'phone': phone},
      );
      final newToken = response.data?['token'] as String?;
      final status = response.data?['status'] as String?;
      
      setState(() {
        if (newToken != null) {
          _tokenCtrl.text = newToken;
        }
        _tokenError = null;
        _isResending = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'SENT' 
                ? AppLocalizations.of(context).setupCodeSentEmail
                : AppLocalizations.of(context).setupCodeResentEmail,
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _tokenError = e is DioException && e.type != DioExceptionType.badResponse
            ? AppLocalizations.of(context).setupServerInaccessible
            : AppLocalizations.of(context).setupPhoneNotFoundOrActive;
        _isResending = false;
      });
    }
  }

  Future<void> _onSubmit() async {
    if (_validatedName == null) {
      await _validateToken();
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.dio.post<void>(
        '/auth/driver/setup',
        data: {
          'token': _tokenCtrl.text.trim(),
          'password': _passwordCtrl.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).setupAccountActivated),
            duration: const Duration(seconds: 4),
          ),
        );
        Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
      }
    } catch (e) {
      setState(() {
        _error = e is DioException && e.type != DioExceptionType.badResponse
            ? AppLocalizations.of(context).setupServerInaccessible
            : AppLocalizations.of(context).setupActivationFailed;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 40, 28, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 28),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushReplacementNamed(LoginScreen.routeName),
                          child: Text(
                            AppLocalizations.of(context).registerSignIn,
                            style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context).setupConfigureAccount,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).setupActivationTitle,
                      style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 32, 28, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(LucideIcons.info, size: 16, color: colorScheme.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppLocalizations.of(context).setupActivationSubtitle,
                              style: TextStyle(fontSize: 13, color: colorScheme.onPrimaryContainer, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(AppLocalizations.of(context).setupActivationCode, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 12),
                    // Field on its own line + button below — no Row/Expanded, which was the
                    // source of the "render box never laid out" hit-test failure.
                    TextFormField(
                      controller: _tokenCtrl,
                      decoration: InputDecoration(
                        hintText: 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
                        prefixIcon: const Icon(LucideIcons.key, size: 18),
                        border: const OutlineInputBorder(),
                        errorText: _tokenError,
                        suffixIcon: _validatedName != null
                            ? Icon(LucideIcons.checkCircle, size: 18, color: colorScheme.primary)
                            : null,
                      ),
                      enabled: _validatedName == null,
                      onChanged: (_) {
                        if (_tokenError != null || _validatedName != null) {
                          setState(() {
                            _tokenError = null;
                            _validatedName = null;
                          });
                        }
                      },
                    ),
                    if (_validatedName == null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: _isValidating ? null : _validateToken,
                          child: _isValidating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(AppLocalizations.of(context).setupValidateCode),
                        ),
                      ),
                    ],
                    if (_validatedName == null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context).setupNoCodeReceived,
                              style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 10),
                            // Full-width field on its own line + button below — no Row/Expanded,
                            // so nothing can shrink or overlap the input's tap area.
                            TextField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: AppLocalizations.of(context).setupPhoneHint,
                                prefixIcon: const Icon(LucideIcons.phone, size: 18),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: FilledButton(
                                onPressed: _isResending ? null : _resendCode,
                                child: _isResending
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 1.5),
                                      )
                                    : Text(AppLocalizations.of(context).setupResendCode),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_validatedName != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.userCheck, size: 16, color: colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context).setupWelcome(_validatedName!),
                              style: TextStyle(fontSize: 13, color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_validatedName != null) ...[
                      const SizedBox(height: 32),
                      Text(AppLocalizations.of(context).setupPasswordLabel, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).setupPasswordMin,
                          prefixIcon: const Icon(LucideIcons.lock, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.length < 6) return AppLocalizations.of(context).setupPasswordMin;
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(AppLocalizations.of(context).setupConfirmPassword, style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _obscureConfirm,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context).setupConfirmPasswordHint,
                          prefixIcon: const Icon(LucideIcons.lock, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirm ? LucideIcons.eye : LucideIcons.eyeOff,
                              size: 18,
                            ),
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                        ),
                        validator: (v) {
                          if (v != _passwordCtrl.text) return AppLocalizations.of(context).setupPasswordMismatch;
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _onSubmit,
                          icon: _isLoading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(LucideIcons.shieldCheck),
                          label: Text(_isLoading ? AppLocalizations.of(context).setupActivating : AppLocalizations.of(context).setupActivateAccount),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 20),
                        _ErrorBanner(_error!, colorScheme),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.error),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, size: 16, color: colorScheme.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13, color: colorScheme.error),
              ),
            ),
          ],
        ),
      );
}
