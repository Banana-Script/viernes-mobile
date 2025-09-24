import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';

/// Placeholder page for features not yet implemented
class ComingSoonPage extends StatelessWidget {
  final String title;
  final String? description;
  final IconData? icon;

  const ComingSoonPage({
    super.key,
    required this.title,
    this.description,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(ViernesSpacing.space6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: ViernesColors.secondary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.construction,
                  size: 50,
                  color: ViernesColors.secondary,
                ),
              )
                  .animate()
                  .scale(
                    duration: ViernesAnimations.normal,
                    curve: ViernesAnimations.easeOut,
                  )
                  .fadeIn(),

              const SizedBox(height: ViernesSpacing.space8),

              // Title
              Text(
                title,
                style: ViernesTextStyles.h3,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    duration: ViernesAnimations.normal,
                  )
                  .fadeIn(delay: 200.ms),

              const SizedBox(height: ViernesSpacing.space4),

              // Description
              Text(
                description ?? 'This feature is coming soon!',
                style: ViernesTextStyles.bodyBase.copyWith(
                  color: ViernesColors.textGray,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    duration: ViernesAnimations.normal,
                  )
                  .fadeIn(delay: 400.ms),

              const SizedBox(height: ViernesSpacing.space8),

              // Coming soon badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: ViernesSpacing.space4,
                  vertical: ViernesSpacing.space2,
                ),
                decoration: BoxDecoration(
                  color: ViernesColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(ViernesRadius.full),
                  border: Border.all(
                    color: ViernesColors.accent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: ViernesColors.accent,
                    ),
                    const SizedBox(width: ViernesSpacing.space2),
                    Text(
                      'Coming Soon',
                      style: ViernesTextStyles.bodySmall.copyWith(
                        color: ViernesColors.accent,
                        fontWeight: ViernesTextStyles.fontSemiBold,
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    duration: ViernesAnimations.normal,
                    curve: ViernesAnimations.easeOut,
                  )
                  .fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}