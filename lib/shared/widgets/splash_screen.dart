import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../features/authentication/presentation/providers/auth_providers.dart';

/// Splash screen shown when app launches
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  /// Initialize authentication and navigate to appropriate screen
  Future<void> _initializeAuth() async {
    // Initialize auth state
    await ref.read(authNotifierProvider.notifier).initialize();

    // Wait for minimum splash duration
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      final isAuthenticated = ref.read(isAuthenticatedProvider);

      if (isAuthenticated) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: ViernesDecorations.viernesGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo placeholder - will use actual Viernes logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(ViernesRadius.xl),
                  boxShadow: [ViernesShadows.cardShadow],
                ),
                child: const Icon(
                  Icons.business,
                  size: 60,
                  color: ViernesColors.primary,
                ),
              )
                  .animate()
                  .scale(
                    duration: ViernesAnimations.normal,
                    curve: ViernesAnimations.easeOut,
                  )
                  .fadeIn(delay: 200.ms),

              const SizedBox(height: ViernesSpacing.space8),

              // App name
              Text(
                AppConstants.appName,
                style: ViernesTextStyles.h2.copyWith(
                  color: Colors.white,
                  fontWeight: ViernesTextStyles.fontBold,
                ),
              )
                  .animate()
                  .slideY(
                    begin: 0.3,
                    duration: ViernesAnimations.normal,
                    curve: ViernesAnimations.easeOut,
                  )
                  .fadeIn(delay: 400.ms),

              const SizedBox(height: ViernesSpacing.space4),

              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              )
                  .animate()
                  .fadeIn(delay: 800.ms),

              const SizedBox(height: ViernesSpacing.space8),

              // Version info
              Text(
                'Version ${AppConstants.appVersion}',
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
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