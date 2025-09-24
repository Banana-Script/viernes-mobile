import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthFeedbackWidget extends StatelessWidget {
  final String? message;
  final AuthFeedbackType type;
  final VoidCallback? onDismiss;
  final bool dismissible;
  final Duration? autoDismissAfter;

  const AuthFeedbackWidget({
    super.key,
    this.message,
    this.type = AuthFeedbackType.info,
    this.onDismiss,
    this.dismissible = true,
    this.autoDismissAfter,
  });

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = _getColors(theme);

    Widget content = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getIcon(),
            color: colors.iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (dismissible) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                color: colors.iconColor.withValues(alpha: 0.7),
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );

    // Add animation
    content = content
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.3, duration: 300.ms);

    // Auto dismiss if specified
    if (autoDismissAfter != null) {
      Future.delayed(autoDismissAfter!, () {
        onDismiss?.call();
      });
    }

    return content;
  }

  IconData _getIcon() {
    switch (type) {
      case AuthFeedbackType.success:
        return Icons.check_circle;
      case AuthFeedbackType.error:
        return Icons.error;
      case AuthFeedbackType.warning:
        return Icons.warning;
      case AuthFeedbackType.info:
        return Icons.info;
    }
  }

  _FeedbackColors _getColors(ThemeData theme) {
    switch (type) {
      case AuthFeedbackType.success:
        return _FeedbackColors(
          backgroundColor: Colors.green.shade50,
          borderColor: Colors.green.shade200,
          iconColor: Colors.green.shade600,
          textColor: Colors.green.shade800,
        );
      case AuthFeedbackType.error:
        return _FeedbackColors(
          backgroundColor: Colors.red.shade50,
          borderColor: Colors.red.shade200,
          iconColor: Colors.red.shade600,
          textColor: Colors.red.shade800,
        );
      case AuthFeedbackType.warning:
        return _FeedbackColors(
          backgroundColor: Colors.orange.shade50,
          borderColor: Colors.orange.shade200,
          iconColor: Colors.orange.shade600,
          textColor: Colors.orange.shade800,
        );
      case AuthFeedbackType.info:
        return _FeedbackColors(
          backgroundColor: Colors.blue.shade50,
          borderColor: Colors.blue.shade200,
          iconColor: Colors.blue.shade600,
          textColor: Colors.blue.shade800,
        );
    }
  }
}

class _FeedbackColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  const _FeedbackColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}

enum AuthFeedbackType {
  success,
  error,
  warning,
  info,
}

// Snackbar helpers
class AuthFeedbackSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    AuthFeedbackType type = AuthFeedbackType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case AuthFeedbackType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        icon = Icons.check_circle;
        break;
      case AuthFeedbackType.error:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        icon = Icons.error;
        break;
      case AuthFeedbackType.warning:
        backgroundColor = Colors.orange.shade600;
        textColor = Colors.white;
        icon = Icons.warning;
        break;
      case AuthFeedbackType.info:
        backgroundColor = Colors.blue.shade600;
        textColor = Colors.white;
        icon = Icons.info;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: AuthFeedbackType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: AuthFeedbackType.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: AuthFeedbackType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: AuthFeedbackType.info);
  }
}

// Biometric feedback widget
class BiometricFeedbackWidget extends StatelessWidget {
  final bool isVisible;
  final String? message;

  const BiometricFeedbackWidget({
    super.key,
    required this.isVisible,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.fingerprint,
            color: Colors.blue.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message ?? 'Use your fingerprint or face to sign in',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9));
  }
}