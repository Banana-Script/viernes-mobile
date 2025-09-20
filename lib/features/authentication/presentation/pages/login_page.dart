import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_notifier.dart';
import '../utils/auth_validation.dart';
import '../utils/auth_error_handler.dart';
import '../widgets/auth_loading_widget.dart';
import '../widgets/auth_feedback_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  // Animation controllers for enhanced UX
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Start entrance animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    // Listen to auth state changes for error handling
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.error != null) {
        setState(() {
          _generalError = next.error;
        });

        // Clear error after showing it
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _generalError = null;
            });
          }
        });
      }

      // Navigate on successful authentication
      if (next.isAuthenticated && next.user != null) {
        AppNavigation.goToDashboard();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 40),

                        // Enhanced Viernes Branding Section
                        _buildBrandingHeader(l10n),
                        const SizedBox(height: 40),

                        // Error display
                        if (_generalError != null)
                          AuthAnimatedFeedback(
                            message: _generalError!,
                            type: AuthFeedbackType.error,
                            onDismiss: () {
                              setState(() {
                                _generalError = null;
                              });
                            },
                          ),

                        const SizedBox(height: 24),

                        // Email field with enhanced validation
                        _buildEmailField(l10n),
                        const SizedBox(height: 20),

                        // Password field with enhanced validation
                        _buildPasswordField(l10n),
                        const SizedBox(height: 16),

                        // Remember me checkbox
                        _buildRememberMeCheckbox(l10n),
                        const SizedBox(height: 32),

                        // Enhanced login button
                        _buildLoginButton(l10n, isLoading),
                        const SizedBox(height: 16),

                        // OR divider
                        _buildOrDivider(l10n),
                        const SizedBox(height: 16),

                        // Enhanced Google Sign In button
                        _buildGoogleSignInButton(l10n, isLoading),
                        const SizedBox(height: 32),

                        // Forgot password link
                        _buildForgotPasswordLink(l10n),
                        const SizedBox(height: 16),

                        // Sign up link with enhanced styling
                        _buildSignUpLink(l10n),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          AuthLoadingOverlay(
            isVisible: isLoading,
            message: 'Signing you in...',
          ),
        ],
      ),
    );
  }

  // UI Builder Methods
  Widget _buildBrandingHeader(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.viernesGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.viernesGray.withValues(alpha:0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Viernes logo/icon placeholder
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'VIERNES',
            style: AppTheme.buttonText.copyWith(
              fontSize: 36,
              letterSpacing: 3.0,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.welcome,
            style: AppTheme.buttonText.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !ref.watch(authNotifierProvider).isLoading,
          decoration: InputDecoration(
            labelText: l10n.email,
            hintText: l10n.enterYourEmailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            errorText: _emailError,
          ),
          validator: (value) {
            final error = AuthValidation.validateEmail(value, l10n);
            setState(() {
              _emailError = error;
            });
            return error;
          },
          onChanged: (value) {
            // Clear error when user starts typing
            if (_emailError != null) {
              setState(() {
                _emailError = null;
              });
            }

            // Suggest email corrections for common typos
            final suggestion = AuthValidation.suggestEmailCorrection(value);
            if (suggestion != null && suggestion != value) {
              // Could show suggestion UI here
            }
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !ref.watch(authNotifierProvider).isLoading,
          decoration: InputDecoration(
            labelText: l10n.password,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            errorText: _passwordError,
          ),
          validator: (value) {
            final error = AuthValidation.validatePassword(value, l10n);
            setState(() {
              _passwordError = error;
            });
            return error;
          },
          onChanged: (value) {
            // Clear error when user starts typing
            if (_passwordError != null) {
              setState(() {
                _passwordError = null;
              });
            }
          },
          onFieldSubmitted: (_) => _handleLogin(),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox(AppLocalizations l10n) {
    return Row(
      children: [
        Checkbox(
          value: _rememberMe,
          onChanged: (value) {
            setState(() {
              _rememberMe = value ?? false;
            });
          },
          activeColor: AppTheme.viernesGray,
        ),
        const SizedBox(width: 8),
        Text(
          l10n.rememberMe,
          style: AppTheme.bodyRegular.copyWith(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(AppLocalizations l10n, bool isLoading) {
    return ViernesGradientButton(
      text: l10n.login,
      onPressed: isLoading ? null : _handleLogin,
      isLoading: isLoading,
      height: 56,
    );
  }

  Widget _buildOrDivider(AppLocalizations l10n) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: AppTheme.bodyRegular.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildGoogleSignInButton(AppLocalizations l10n, bool isLoading) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : _handleGoogleSignIn,
        icon: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://developers.google.com/identity/images/g-logo.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        label: isLoading
            ? AuthButtonLoading(
                text: l10n.signInWithGoogle,
                isLoading: false,
                loadingColor: Theme.of(context).colorScheme.primary,
              )
            : Text(
                l10n.signInWithGoogle,
                style: AppTheme.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(AppLocalizations l10n) {
    return Center(
      child: TextButton(
        onPressed: _handleForgotPassword,
        child: Text(
          l10n.forgotPassword,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.viernesGray,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(AppLocalizations l10n) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '${l10n.dontHaveAccount} ',
          style: AppTheme.bodyRegular.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
            fontSize: 16,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => AppNavigation.goToRegister(),
                child: Text(
                  l10n.signUp,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.viernesYellow,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Event Handlers
  Future<void> _handleLogin() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _passwordError = null;
      _generalError = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Clear any previous errors in provider
    ref.read(authNotifierProvider.notifier).clearError();

    // Attempt login
    try {
      await ref.read(authNotifierProvider.notifier).loginWithEmail(
        email: AuthValidation.sanitizeInput(_emailController.text),
        password: _passwordController.text,
      );

      // Success message will be handled by navigation
    } catch (e) {
      // Error handling is done in the listener
      AuthErrorHandler.logError(e as Exception, 'Login');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    // Clear previous errors
    setState(() {
      _generalError = null;
    });

    // Clear any previous errors in provider
    ref.read(authNotifierProvider.notifier).clearError();

    try {
      await ref.read(authNotifierProvider.notifier).loginWithGoogle();
    } catch (e) {
      // Error handling is done in the listener
      AuthErrorHandler.logError(e as Exception, 'Google Sign In');
    }
  }

  void _handleForgotPassword() {
    AppNavigation.goToPasswordRecovery();
  }
}