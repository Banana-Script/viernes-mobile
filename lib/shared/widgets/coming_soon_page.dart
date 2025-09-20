import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/router/app_router.dart';
import '../../l10n/app_localizations.dart';

class ComingSoonPage extends StatelessWidget {
  final String featureName;

  const ComingSoonPage({
    super.key,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          featureName,
          style: AppTheme.headingBold.copyWith(
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => AppNavigation.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Viernes gradient circle with construction icon
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: AppTheme.viernesGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.viernesGray.withValues(alpha:0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.construction,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // Feature name title
              Text(
                featureName,
                style: AppTheme.headingBold.copyWith(
                  fontSize: 28,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Coming soon message
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.viernesYellow.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.viernesYellow.withValues(alpha:0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  l10n.comingSoon.toUpperCase(),
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.viernesGray,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                'We\'re working hard to bring you this feature. '
                'Stay tuned for updates!',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Feature highlights
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha:0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'What to expect:',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.viernesGray,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureHighlight(
                      context,
                      icon: Icons.speed,
                      title: 'Fast Performance',
                      description: 'Optimized for mobile experience',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureHighlight(
                      context,
                      icon: Icons.security,
                      title: 'Secure & Reliable',
                      description: 'Enterprise-grade security',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureHighlight(
                      context,
                      icon: Icons.mobile_friendly,
                      title: 'Mobile-First',
                      description: 'Designed specifically for mobile',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Action buttons
              Column(
                children: [
                  // Primary action button
                  ViernesGradientButton(
                    text: 'Back to Dashboard',
                    width: double.infinity,
                    onPressed: () => AppNavigation.goToDashboard(),
                  ),

                  const SizedBox(height: 12),

                  // Secondary action button
                  TextButton(
                    onPressed: () => AppNavigation.goToProfile(),
                    child: Text(
                      'Manage Notifications',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.viernesGray,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlight(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.viernesYellow.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.viernesGray,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}