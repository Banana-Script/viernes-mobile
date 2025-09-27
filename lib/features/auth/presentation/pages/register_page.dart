import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_button.dart';
import '../../../../shared/widgets/viernes_input.dart';
import '../../../../shared/widgets/viernes_card.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
          'Create Account',
          style: ViernesTextStyles.h5.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? ViernesColors.secondary : ViernesColors.primary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? ViernesColors.secondary : ViernesColors.primary,
        ),
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
                            Icons.person_add,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        ViernesSpacing.spaceLg,

                        // Welcome text
                        Text(
                          'Join Viernes',
                          style: ViernesTextStyles.h2.copyWith(
                            color: isDark ? Colors.white : ViernesColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        ViernesSpacing.spaceXs,
                        Text(
                          'Create your account to get started',
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

                  // Registration Form Card
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
                            labelText: 'Password',
                            hintText: 'Create a secure password',
                            enabled: authProvider.status != AuthStatus.loading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          ViernesSpacing.spaceLg,

                          // Confirm password field
                          ViernesInput.password(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm Password',
                            hintText: 'Confirm your password',
                            enabled: authProvider.status != AuthStatus.loading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),

                          ViernesSpacing.spaceXl,

                          // Create account button
                          ViernesButton.gradient(
                            text: 'Create Account',
                            isLoading: authProvider.status == AuthStatus.loading,
                            onPressed: authProvider.status == AuthStatus.loading
                                ? null
                                : () => _signUp(authProvider),
                            icon: const Icon(Icons.person_add, size: 20),
                          ),

                          ViernesSpacing.spaceLg,

                          // Already have account
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account? ',
                                style: ViernesTextStyles.bodyText.copyWith(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.7)
                                      : ViernesColors.primary.withValues(alpha: 0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: authProvider.status == AuthStatus.loading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                child: Text(
                                  'Sign In',
                                  style: ViernesTextStyles.bodyText.copyWith(
                                    color: isDark ? ViernesColors.secondary : ViernesColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
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
                      'By creating an account, you agree to our Terms of Service and Privacy Policy',
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

  void _signUp(AuthProvider authProvider) {
    if (_formKey.currentState!.validate()) {
      authProvider.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    }
  }
}