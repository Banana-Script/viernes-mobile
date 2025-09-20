import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Custom feedback widget for authentication screens
/// Shows success, error, warning, and info messages with Viernes styling
class AuthFeedbackWidget extends StatelessWidget {
  final String message;
  final AuthFeedbackType type;
  final bool showIcon;
  final VoidCallback? onDismiss;
  final Duration? autoDismissAfter;

  const AuthFeedbackWidget({
    super.key,
    required this.message,
    required this.type,
    this.showIcon = true,
    this.onDismiss,
    this.autoDismissAfter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(
              _getIcon(),
              color: _getIconColor(context),
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: _getTextColor(context),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onDismiss,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: _getIconColor(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (type) {
      case AuthFeedbackType.success:
        return AppTheme.success.withValues(alpha:0.1);
      case AuthFeedbackType.error:
        return AppTheme.danger.withValues(alpha:0.1);
      case AuthFeedbackType.warning:
        return AppTheme.warning.withValues(alpha:0.1);
      case AuthFeedbackType.info:
        return AppTheme.viernesGray.withValues(alpha:0.1);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (type) {
      case AuthFeedbackType.success:
        return AppTheme.success.withValues(alpha:0.3);
      case AuthFeedbackType.error:
        return AppTheme.danger.withValues(alpha:0.3);
      case AuthFeedbackType.warning:
        return AppTheme.warning.withValues(alpha:0.3);
      case AuthFeedbackType.info:
        return AppTheme.viernesGray.withValues(alpha:0.3);
    }
  }

  Color _getShadowColor(BuildContext context) {
    switch (type) {
      case AuthFeedbackType.success:
        return AppTheme.success.withValues(alpha:0.1);
      case AuthFeedbackType.error:
        return AppTheme.danger.withValues(alpha:0.1);
      case AuthFeedbackType.warning:
        return AppTheme.warning.withValues(alpha:0.1);
      case AuthFeedbackType.info:
        return AppTheme.viernesGray.withValues(alpha:0.1);
    }
  }

  Color _getIconColor(BuildContext context) {
    switch (type) {
      case AuthFeedbackType.success:
        return AppTheme.success;
      case AuthFeedbackType.error:
        return AppTheme.danger;
      case AuthFeedbackType.warning:
        return AppTheme.warning;
      case AuthFeedbackType.info:
        return AppTheme.viernesGray;
    }
  }

  Color _getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }

  IconData _getIcon() {
    switch (type) {
      case AuthFeedbackType.success:
        return Icons.check_circle_outline;
      case AuthFeedbackType.error:
        return Icons.error_outline;
      case AuthFeedbackType.warning:
        return Icons.warning_amber_outlined;
      case AuthFeedbackType.info:
        return Icons.info_outline;
    }
  }
}

enum AuthFeedbackType {
  success,
  error,
  warning,
  info,
}

/// Animated feedback card for important messages
class AuthAnimatedFeedback extends StatefulWidget {
  final String message;
  final AuthFeedbackType type;
  final bool showIcon;
  final VoidCallback? onDismiss;
  final Duration animationDuration;

  const AuthAnimatedFeedback({
    super.key,
    required this.message,
    required this.type,
    this.showIcon = true,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<AuthAnimatedFeedback> createState() => _AuthAnimatedFeedbackState();
}

class _AuthAnimatedFeedbackState extends State<AuthAnimatedFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: AuthFeedbackWidget(
                message: widget.message,
                type: widget.type,
                showIcon: widget.showIcon,
                onDismiss: widget.onDismiss,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Success message card specifically for authentication
class AuthSuccessCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onContinue;
  final String? continueButtonText;

  const AuthSuccessCard({
    super.key,
    required this.title,
    required this.message,
    this.onContinue,
    this.continueButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.success.withValues(alpha:0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.success.withValues(alpha:0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.success.withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: AppTheme.headingBold.copyWith(
              fontSize: 20,
              color: AppTheme.success,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: AppTheme.bodyRegular.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          if (onContinue != null) ...[
            const SizedBox(height: 24),
            ViernesGradientButton(
              text: continueButtonText ?? 'Continue',
              onPressed: onContinue,
            ),
          ],
        ],
      ),
    );
  }
}

/// Error message card specifically for authentication
class AuthErrorCard extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final String? suggestion;

  const AuthErrorCard({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.retryButtonText,
    this.suggestion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.danger.withValues(alpha:0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.danger.withValues(alpha:0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.danger,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.danger.withValues(alpha:0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            title,
            style: AppTheme.headingBold.copyWith(
              fontSize: 20,
              color: AppTheme.danger,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Message
          Text(
            message,
            style: AppTheme.bodyRegular.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          // Suggestion
          if (suggestion != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha:0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: AppTheme.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion!,
                      style: AppTheme.bodyRegular.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (onRetry != null) ...[
            const SizedBox(height: 24),
            ViernesGradientButton(
              text: retryButtonText ?? 'Try Again',
              onPressed: onRetry,
            ),
          ],
        ],
      ),
    );
  }
}