import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/profile_providers.dart';

/// User availability widget that matches the web app functionality
/// Shows availability status with toggle and pulsing indicator
class UserAvailabilityWidget extends ConsumerWidget {
  final bool showTitle;
  final EdgeInsetsGeometry? padding;

  const UserAvailabilityWidget({
    super.key,
    this.showTitle = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final availabilityState = ref.watch(userAvailabilityProvider);

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle) ...[
            Text(
              'Availability Status', // TODO: Add to localizations
              style: AppTheme.headingBold.copyWith(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
          ],

          availabilityState.when(
            data: (isAvailable) => _buildAvailabilityToggle(context, ref, isAvailable, l10n),
            loading: () => _buildLoadingState(context),
            error: (error, stack) => _buildErrorState(context, error.toString(), ref),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle(BuildContext context, WidgetRef ref, bool isAvailable, AppLocalizations l10n) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.viernesGray.withValues(alpha:0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status indicator with pulsing animation
          _buildStatusIndicator(isAvailable),

          const SizedBox(width: 12),

          // Status text and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAvailable ? 'Available' : 'Unavailable', // TODO: Add to localizations
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isAvailable ? AppTheme.success : AppTheme.viernesGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isAvailable
                    ? 'You are currently available to receive calls'
                    : 'You are currently unavailable to receive calls',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Toggle switch
          Switch.adaptive(
            value: isAvailable,
            onChanged: (value) async {
              final success = await ref.read(userAvailabilityProvider.notifier).setAvailability(value);

              if (!success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to update availability status'),
                    backgroundColor: AppTheme.danger,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            activeColor: AppTheme.success,
            activeTrackColor: AppTheme.success.withValues(alpha:0.3),
            inactiveThumbColor: AppTheme.viernesGray,
            inactiveTrackColor: AppTheme.viernesGray.withValues(alpha:0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isAvailable) {
    if (isAvailable) {
      return _PulsingIndicator(
        color: AppTheme.success,
        size: 12,
      );
    } else {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: AppTheme.viernesGray.withValues(alpha:0.5),
          shape: BoxShape.circle,
        ),
      );
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha:0.2),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.viernesGray),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Loading availability status...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha:0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.danger.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.danger.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: AppTheme.danger,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Failed to load availability',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.danger,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (error.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    error,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.danger.withValues(alpha:0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {
              ref.read(userAvailabilityProvider.notifier).refresh();
            },
            child: Text(
              'Retry',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing indicator for online status
class _PulsingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingIndicator({
    required this.color,
    required this.size,
  });

  @override
  State<_PulsingIndicator> createState() => _PulsingIndicatorState();
}

class _PulsingIndicatorState extends State<_PulsingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 2.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.8,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2.5,
      height: widget.size * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing ring
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha:_opacityAnimation.value),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          // Core indicator
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}