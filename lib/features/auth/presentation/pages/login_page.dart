import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/utils/validators.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../shared/widgets/viernes_input.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../providers/auth_provider.dart';
import 'forgot_password_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    // Show error message if there's an error
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authProvider.status == AuthStatus.error && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: ViernesColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        authProvider.clearError();
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF060818), const Color(0xFF0a0f1e)]
                : [const Color(0xFFfafafa), const Color(0xFFffffff)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 60),

                    // Logo section
                    Center(
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
                          const SizedBox(height: 12),
                          Image.asset(
                            isDark
                                ? 'assets/images/auth/powered-by-dark.png'
                                : 'assets/images/auth/powered-by-2.png',
                            width: 110,
                            height: 18,
                            fit: BoxFit.contain,
                            opacity: const AlwaysStoppedAnimation(0.8),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Auth card with glassmorphism
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                            : Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                              : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.5)
                                : Colors.black.withValues(alpha: 0.12),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Title
                            Text(
                              l10n.signIn.toUpperCase(),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                                letterSpacing: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Subtitle
                            Text(
                              l10n.loginInstructions,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? ViernesColors.textDark.withValues(alpha: 0.7)
                                    : ViernesColors.textLight.withValues(alpha: 0.7),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Email input
                            ViernesInput.email(
                              controller: _emailController,
                              labelText: l10n.email,
                              hintText: l10n.emailPlaceholder,
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                                size: 20,
                              ),
                              enabled: authProvider.status != AuthStatus.loading,
                            ),

                            const SizedBox(height: 20),

                            // Password input
                            ViernesInput.password(
                              controller: _passwordController,
                              labelText: l10n.password,
                              hintText: l10n.yourPassword,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                                size: 20,
                              ),
                              enabled: authProvider.status != AuthStatus.loading,
                            ),

                            const SizedBox(height: 16),

                            // Forgot password link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: authProvider.status == AuthStatus.loading
                                    ? null
                                    : () => _handleForgotPassword(),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(50, 30),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  l10n.forgotPasswordQuestion,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? ViernesColors.accent : ViernesColors.primary,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Submit button with gradient
                            ViernesGradientButton(
                              text: l10n.signIn.toUpperCase(),
                              onPressed: authProvider.status == AuthStatus.loading
                                  ? null
                                  : () => _handleLogin(authProvider),
                              isLoading: authProvider.status == AuthStatus.loading,
                            ),

                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _handleLogin(AuthProvider authProvider) {
    // Validate inputs using centralized Validators
    final emailError = Validators.email(_emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final passwordError = Validators.password(_passwordController.text);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _handleForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ForgotPasswordPage(),
      ),
    );
  }
}
