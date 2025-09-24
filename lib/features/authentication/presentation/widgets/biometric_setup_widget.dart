import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import 'auth_feedback_widget.dart';

class BiometricSetupWidget extends ConsumerStatefulWidget {
  final VoidCallback? onEnabled;
  final VoidCallback? onDisabled;

  const BiometricSetupWidget({
    Key? key,
    this.onEnabled,
    this.onDisabled,
  }) : super(key: key);

  @override
  ConsumerState<BiometricSetupWidget> createState() => _BiometricSetupWidgetState();
}

class _BiometricSetupWidgetState extends ConsumerState<BiometricSetupWidget> {
  bool _isLoading = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    setState(() => _isLoading = true);

    try {
      final localAuth = ref.read(localAuthProvider);
      final canCheck = await localAuth.canCheckBiometrics;

      if (canCheck) {
        final biometrics = await localAuth.getAvailableBiometrics();
        setState(() {
          _availableBiometrics = biometrics;
        });
      }
    } catch (e) {
      // Handle error silently - biometrics just won't be available
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);

    if (_isLoading || !authState.isBiometricAvailable || _availableBiometrics.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  _getBiometricIcon(),
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getBiometricTitle(l10n),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch(
                  value: authState.isBiometricEnabled,
                  onChanged: _handleToggleBiometric,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getBiometricDescription(l10n),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return Icons.face;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }

  String _getBiometricTitle(AppLocalizations l10n) {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return l10n.enableFaceId;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return l10n.enableFingerprint;
    } else {
      return l10n.enableBiometric;
    }
  }

  String _getBiometricDescription(AppLocalizations l10n) {
    if (_availableBiometrics.contains(BiometricType.face)) {
      return l10n.faceIdDescription;
    } else if (_availableBiometrics.contains(BiometricType.fingerprint)) {
      return l10n.fingerprintDescription;
    } else {
      return l10n.biometricDescription;
    }
  }

  Future<void> _handleToggleBiometric(bool enabled) async {
    if (enabled) {
      // Test biometric authentication before enabling
      final authNotifier = ref.read(authNotifierProvider.notifier);
      final success = await authNotifier.authenticateWithBiometrics();

      if (success) {
        authNotifier.setBiometricEnabled(true);
        widget.onEnabled?.call();

        if (mounted) {
          AuthFeedbackSnackbar.showSuccess(
            context,
            'Biometric authentication enabled successfully',
          );
        }
      } else {
        if (mounted) {
          AuthFeedbackSnackbar.showError(
            context,
            'Failed to enable biometric authentication',
          );
        }
      }
    } else {
      // Disable biometric authentication
      final authNotifier = ref.read(authNotifierProvider.notifier);
      authNotifier.setBiometricEnabled(false);
      widget.onDisabled?.call();

      if (mounted) {
        AuthFeedbackSnackbar.showInfo(
          context,
          'Biometric authentication disabled',
        );
      }
    }
  }
}

// Quick biometric auth button for login screen
class QuickBiometricButton extends ConsumerWidget {
  final VoidCallback? onAuthenticated;

  const QuickBiometricButton({
    Key? key,
    this.onAuthenticated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    if (!authState.canUseBiometric) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () => _handleBiometricAuth(context, ref),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Icon(
          Icons.fingerprint,
          size: 28,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Future<void> _handleBiometricAuth(BuildContext context, WidgetRef ref) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    try {
      final success = await authNotifier.authenticateWithBiometrics();

      if (success) {
        // Get stored credentials and auto-login
        // This would require stored credentials - for now just call callback
        onAuthenticated?.call();

        if (context.mounted) {
          AuthFeedbackSnackbar.showSuccess(
            context,
            'Biometric authentication successful',
          );
        }
      } else {
        if (context.mounted) {
          AuthFeedbackSnackbar.showError(
            context,
            'Biometric authentication failed',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AuthFeedbackSnackbar.showError(
          context,
          'Biometric authentication error: ${e.toString()}',
        );
      }
    }
  }
}