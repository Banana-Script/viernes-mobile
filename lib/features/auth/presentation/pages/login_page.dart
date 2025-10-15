import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_button.dart';
import '../../../../shared/widgets/viernes_input.dart';
import '../../../../shared/widgets/viernes_card.dart';
import '../providers/auth_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? ViernesColors.backgroundDark : ViernesColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Viernes',
          style: ViernesTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? ViernesColors.secondary : ViernesColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          // Show error message if there's an error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (authProvider.status == AuthStatus.error && authProvider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(authProvider.errorMessage!),
                  backgroundColor: ViernesColors.danger,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
                  ),
                ),
              );
              authProvider.clearError();
            }
          });

          return SafeArea(
            child: SingleChildScrollView(
              padding: ViernesSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ViernesSpacing.spaceXl,

                  // Welcome Card
                  ViernesCard.filled(
                    backgroundColor: isDark
                        ? ViernesColors.secondary.withValues(alpha: 0.1)
                        : ViernesColors.primary.withValues(alpha: 0.05),
                    child: Column(
                      children: [
                        // Logo/Brand section
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: ViernesColors.viernesGradient,
                            borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
                          ),
                          child: const Icon(
                            Icons.business_center,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        ViernesSpacing.spaceLg,

                        // Welcome text
                        Text(
                          'Welcome back!',
                          style: ViernesTextStyles.h2.copyWith(
                            color: isDark ? Colors.white : ViernesColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ViernesSpacing.spaceXs,
                        Text(
                          'Sign in to your Viernes account',
                          style: ViernesTextStyles.bodyLarge.copyWith(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.7)
                                : ViernesColors.primary.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  ViernesSpacing.spaceXxl,

                  // Login Form Card
                  ViernesCard.elevated(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email field
                          ViernesInput.email(
                            controller: _emailController,
                            enabled: authProvider.status != AuthStatus.loading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          ViernesSpacing.spaceLg,

                          // Password field
                          ViernesInput.password(
                            controller: _passwordController,
                            enabled: authProvider.status != AuthStatus.loading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),

                          ViernesSpacing.spaceXl,

                          // Sign in button
                          ViernesButton.gradient(
                            text: 'Sign In',
                            isLoading: authProvider.status == AuthStatus.loading,
                            onPressed: authProvider.status == AuthStatus.loading
                                ? null
                                : () => _signIn(authProvider),
                            icon: Icons.login,
                          ),

                          ViernesSpacing.spaceLg,

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: ViernesSpacing.horizontal(ViernesSpacing.md),
                                child: Text(
                                  'or',
                                  style: ViernesTextStyles.bodyText.copyWith(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : ViernesColors.primary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          ViernesSpacing.spaceLg,

                          // Create account button
                          ViernesButton.secondary(
                            text: 'Create Account',
                            onPressed: authProvider.status == AuthStatus.loading
                                ? null
                                : () => _navigateToRegister(context),
                            icon: Icons.person_add,
                          ),
                        ],
                      ),
                    ),
                  ),

                  ViernesSpacing.spaceXxl,

                  // Terms and privacy
                  Padding(
                    padding: ViernesSpacing.horizontal(ViernesSpacing.lg),
                    child: Text(
                      'By signing in, you agree to our Terms of Service and Privacy Policy',
                      style: ViernesTextStyles.caption.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : ViernesColors.primary.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  ViernesSpacing.spaceLg,
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _signIn(AuthProvider authProvider) {
    if (_formKey.currentState!.validate()) {
      authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  void _navigateToRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const RegisterPage(),
      ),
    );
  }
}