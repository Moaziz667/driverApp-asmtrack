import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:profile_picker_plus/profile_picker_plus.dart';

import '../../../app_providers.dart';
import 'package:driver_app/generated/l10n/app_localizations.dart';
import '../../../theme/tokens.dart';

/// Mandatory first-login step: the driver must add a profile photo before reaching the home tabs.
/// Uses [ProfilePicker] for pick → crop → compress pipeline.
class OnboardingPhotoScreen extends ConsumerStatefulWidget {
  const OnboardingPhotoScreen({super.key});

  @override
  ConsumerState<OnboardingPhotoScreen> createState() =>
      _OnboardingPhotoScreenState();
}

class _OnboardingPhotoScreenState extends ConsumerState<OnboardingPhotoScreen> {
  File? _picked;
  bool _busy = false;

  Future<void> _onImageSelected(File? file) async {
    if (file == null) return;
    if (mounted) setState(() => _picked = file);
  }

  Future<void> _submit() async {
    if (_picked == null || _busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(profileRepositoryProvider).uploadPhoto(_picked!.path);
      ref.invalidate(driverProfileProvider);
    } catch (_) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.profileUploadFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                ProfilePicker(
                  radius: 64,
                  fallbackInitials: 'D',
                  initialImageFile: _picked,
                  onImageSelected: _onImageSelected,
                  allowRemove: false,
                  cropEnabled: true,
                  badgePosition: BadgePosition.bottomRight,
                  theme: ProfilePickerTheme(
                    primaryColor: cs.primary,
                    backgroundColor: cs.surfaceContainerLow,
                  ),
                  pickerStrings: ProfilePickerStrings(
                    cameraLabel: loc.profileTakePhoto,
                    galleryLabel: loc.profileChooseGallery,
                    cancelLabel: loc.cancel,
                    cropTitle: loc.profilePhotoCropTitle,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  loc.profilePhotoRequired,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: AppTokens.fwBold,
                    color: cs.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.profilePhotoRequiredSub,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_picked == null || _busy) ? null : _submit,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(loc.profilePhotoConfirm),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
