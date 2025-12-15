import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Animated splash screen for Viernes app
///
/// Displays a professional animated splash with:
/// - Gradient background matching brand colors
/// - Lottie animation for chatbot/messaging theme
/// - Fade-in text with app name and tagline
/// - Accessibility support (respects reduce motion settings)
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _fadeController;
  late Animation<double> _logoScale;
  late Animation<double> _textOpacity;
  late Animation<double> _fadeOpacity;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSplashSequence();
  }

  void _setupAnimations() {
    // Background fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Logo scale animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );

    // Text fade animation
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
  }

  Future<void> _startSplashSequence() async {
    // Start background fade immediately
    _fadeController.forward();

    // Wait a bit, then start logo animation
    await Future.delayed(const Duration(milliseconds: 500));
    _logoController.forward();

    // Wait for logo to mostly complete, then show text
    await Future.delayed(const Duration(milliseconds: 1200));
    _textController.forward();

    // Hold for a moment to let user see the complete splash
    await Future.delayed(const Duration(milliseconds: 2000));

    // Trigger completion callback
    if (mounted) {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Accessibility: respect reduce motion preference
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF060818) : Colors.white,
      body: AnimatedBuilder(
        animation: _fadeOpacity,
        builder: (context, child) {
          return Opacity(
            opacity: reduceMotion ? 1.0 : _fadeOpacity.value,
            child: child,
          );
        },
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Lottie
                AnimatedBuilder(
                  animation: _logoScale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: reduceMotion ? 1.0 : _logoScale.value,
                      child: child,
                    );
                  },
                  child: Semantics(
                    label: 'Viernes animación',
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Lottie.asset(
                        'assets/animations/splash_animation.json',
                        animate: !reduceMotion,
                        repeat: true,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Logo and Powered By (like login page)
                AnimatedBuilder(
                  animation: _textOpacity,
                  builder: (context, child) {
                    return Opacity(
                      opacity: reduceMotion ? 1.0 : _textOpacity.value,
                      child: child,
                    );
                  },
                  child: Semantics(
                    label: 'Viernes - Powered by Banana',
                    child: Column(
                      children: [
                        Image.asset(
                          isDark
                              ? 'assets/images/auth/logo-dark.png'
                              : 'assets/images/auth/logo.png',
                          width: 180,
                          height: 45,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        Image.asset(
                          isDark
                              ? 'assets/images/auth/powered-by-dark.png'
                              : 'assets/images/auth/powered-by-2.png',
                          width: 110,
                          height: 18,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
