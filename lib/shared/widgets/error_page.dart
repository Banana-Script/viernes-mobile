import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';

/// Error page for displaying errors and exceptions
class ErrorPage extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const ErrorPage({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ViernesSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ViernesColors.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: ViernesColors.danger,
                ),
              )
                  .animate()
                  .scale(
                    duration: ViernesAnimations.normal,
                    curve: ViernesAnimations.easeOut,
                  )
                  .fadeIn(),

              const SizedBox(height: ViernesSpacing.space8),

              // Error title
              Text(
                'Oops! Something went wrong',
                style: ViernesTextStyles.h4,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    duration: ViernesAnimations.normal,
                  )
                  .fadeIn(delay: 200.ms),

              const SizedBox(height: ViernesSpacing.space4),

              // Error message
              Container(
                padding: const EdgeInsets.all(ViernesSpacing.space4),
                decoration: BoxDecoration(
                  color: ViernesColors.danger.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(ViernesRadius.md),
                  border: Border.all(
                    color: ViernesColors.danger.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  error,
                  style: ViernesTextStyles.bodyBase.copyWith(
                    color: ViernesColors.danger,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    duration: ViernesAnimations.normal,
                  )
                  .fadeIn(delay: 400.ms),

              const SizedBox(height: ViernesSpacing.space8),

              // Action buttons
              Column(
                children: [
                  if (onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    )
                        .animate()
                        .scale(
                          duration: ViernesAnimations.normal,
                        )
                        .fadeIn(delay: 600.ms),

                  if (onRetry != null) const SizedBox(height: ViernesSpacing.space4),

                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(200, 48),
                    ),
                  )
                      .animate()
                      .scale(
                        duration: ViernesAnimations.normal,
                      )
                      .fadeIn(delay: 800.ms),
                ],
              ),

              const SizedBox(height: ViernesSpacing.space8),

              // Additional help text
              Text(
                'If this problem persists, please contact support.',
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.textGray,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }
}