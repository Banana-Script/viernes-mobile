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

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  // Individual field errors
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _termsError;
  String? _generalError;

  // Password strength
  int _passwordStrength = 0;

  // Animation controllers
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
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

      // Navigate on successful registration
      if (next.isAuthenticated && next.user != null) {
        // Show success message first
        setState(() {
          _generalError = null;
        });

        // Navigate to dashboard after a brief delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            AppNavigation.goToDashboard();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => AppNavigation.goToLogin(),
        ),
        title: Text(
          l10n.createAccount,
          style: AppTheme.headingBold.copyWith(
            fontSize: 20,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
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
                        const SizedBox(height: 20),

                        // Welcome header
                        _buildWelcomeHeader(l10n),
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

                        // Name fields row
                        Row(
                          children: [
                            Expanded(child: _buildFirstNameField(l10n)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildLastNameField(l10n)),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Email field
                        _buildEmailField(l10n),
                        const SizedBox(height: 20),

                        // Password field with strength indicator
                        _buildPasswordField(l10n),
                        const SizedBox(height: 20),

                        // Confirm password field
                        _buildConfirmPasswordField(l10n),
                        const SizedBox(height: 24),

                        // Terms and conditions checkbox
                        _buildTermsCheckbox(l10n),
                        const SizedBox(height: 32),

                        // Register button
                        _buildRegisterButton(l10n, isLoading),
                        const SizedBox(height: 16),

                        // OR divider
                        _buildOrDivider(),
                        const SizedBox(height: 16),

                        // Google Sign Up button
                        _buildGoogleSignUpButton(l10n, isLoading),
                        const SizedBox(height: 32),

                        // Sign in link
                        _buildSignInLink(l10n),
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
            message: 'Creating your account...',
          ),
        ],
      ),
    );
  }

  // UI Builder Methods
  Widget _buildWelcomeHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppTheme.viernesGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.viernesGray.withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.signUpToGetStarted,
          style: AppTheme.headingBold.copyWith(
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Join thousands of businesses using Viernes',
          style: AppTheme.bodyRegular.copyWith(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFirstNameField(AppLocalizations l10n) {
    return TextFormField(
      controller: _firstNameController,
      textInputAction: TextInputAction.next,
      enabled: !ref.watch(authNotifierProvider).isLoading,
      decoration: InputDecoration(
        labelText: l10n.firstName,
        prefixIcon: const Icon(Icons.person_outline),
        errorText: _firstNameError,
      ),
      validator: (value) {
        final error = AuthValidation.validateFirstName(value, l10n);
        setState(() {
          _firstNameError = error;
        });
        return error;
      },
      onChanged: (value) {
        if (_firstNameError != null) {
          setState(() {
            _firstNameError = null;
          });
        }
      },
    );
  }

  Widget _buildLastNameField(AppLocalizations l10n) {
    return TextFormField(
      controller: _lastNameController,
      textInputAction: TextInputAction.next,
      enabled: !ref.watch(authNotifierProvider).isLoading,
      decoration: InputDecoration(
        labelText: l10n.lastName,
        prefixIcon: const Icon(Icons.person_outline),
        errorText: _lastNameError,
      ),
      validator: (value) {
        final error = AuthValidation.validateLastName(value, l10n);
        setState(() {
          _lastNameError = error;
        });
        return error;
      },
      onChanged: (value) {
        if (_lastNameError != null) {
          setState(() {
            _lastNameError = null;
          });
        }
      },
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
            if (_emailError != null) {
              setState(() {
                _emailError = null;
              });
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
          textInputAction: TextInputAction.next,
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
            final error = AuthValidation.validatePassword(value, l10n, requireStrong: true);
            setState(() {
              _passwordError = error;
            });
            return error;
          },
          onChanged: (value) {
            if (_passwordError != null) {
              setState(() {
                _passwordError = null;
              });
            }

            // Update password strength
            setState(() {
              _passwordStrength = AuthValidation.getPasswordStrength(value);
            });
          },
        ),

        // Password strength indicator
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthIndicator(),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final strengthColors = [
      AppTheme.danger,
      AppTheme.danger,
      AppTheme.warning,
      AppTheme.success,
      AppTheme.viernesGreen,
    ];

    final strengthTexts = [
      'Very weak',
      'Weak',
      'Fair',
      'Good',
      'Strong',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 4 ? 4 : 0),
                decoration: BoxDecoration(
                  color: index < _passwordStrength
                      ? strengthColors[_passwordStrength.clamp(0, 4)]
                      : Colors.grey.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          strengthTexts[_passwordStrength.clamp(0, 4)],
          style: AppTheme.bodyRegular.copyWith(
            fontSize: 12,
            color: strengthColors[_passwordStrength.clamp(0, 4)],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmPasswordField(AppLocalizations l10n) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _obscureConfirmPassword,
      textInputAction: TextInputAction.done,
      enabled: !ref.watch(authNotifierProvider).isLoading,
      decoration: InputDecoration(
        labelText: l10n.confirmPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
          ),
          onPressed: () {
            setState(() {
              _obscureConfirmPassword = !_obscureConfirmPassword;
            });
          },
        ),
        errorText: _confirmPasswordError,
      ),
      validator: (value) {
        final error = AuthValidation.validatePasswordConfirmation(
          value,
          _passwordController.text,
          l10n,
        );
        setState(() {
          _confirmPasswordError = error;
        });
        return error;
      },
      onChanged: (value) {
        if (_confirmPasswordError != null) {
          setState(() {
            _confirmPasswordError = null;
          });
        }
      },
      onFieldSubmitted: (_) => _handleRegister(),
    );
  }

  Widget _buildTermsCheckbox(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                  if (_acceptTerms) {
                    _termsError = null;
                  }
                });
              },
              activeColor: AppTheme.viernesGray,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _acceptTerms = !_acceptTerms;
                    if (_acceptTerms) {
                      _termsError = null;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(
                    text: TextSpan(
                      text: '${l10n.iAgreeToThe} ',
                      style: AppTheme.bodyRegular.copyWith(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
                      ),
                      children: [
                        TextSpan(
                          text: l10n.termsOfService,
                          style: TextStyle(
                            color: AppTheme.viernesGray,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        TextSpan(text: ' ${l10n.and} '),
                        TextSpan(
                          text: l10n.privacyPolicy,
                          style: TextStyle(
                            color: AppTheme.viernesGray,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_termsError != null)
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 4),
            child: Text(
              _termsError!,
              style: TextStyle(
                color: AppTheme.danger,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegisterButton(AppLocalizations l10n, bool isLoading) {
    return ViernesGradientButton(
      text: l10n.createAccount,
      onPressed: isLoading ? null : _handleRegister,
      isLoading: isLoading,
      height: 56,
    );
  }

  Widget _buildOrDivider() {
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

  Widget _buildGoogleSignUpButton(AppLocalizations l10n, bool isLoading) {
    return SizedBox(
      height: 56,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : _handleGoogleSignUp,
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
                text: l10n.signUpWithGoogle,
                isLoading: false,
                loadingColor: Theme.of(context).colorScheme.primary,
              )
            : Text(
                l10n.signUpWithGoogle,
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

  Widget _buildSignInLink(AppLocalizations l10n) {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: '${l10n.alreadyHaveAccount} ',
          style: AppTheme.bodyRegular.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.8),
            fontSize: 16,
          ),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () => AppNavigation.goToLogin(),
                child: Text(
                  l10n.login,
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
  Future<void> _handleRegister() async {
    final l10n = AppLocalizations.of(context)!;

    // Clear previous errors
    setState(() {
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      _confirmPasswordError = null;
      _termsError = null;
      _generalError = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Validate terms acceptance
    if (!_acceptTerms) {
      setState(() {
        _termsError = AuthValidation.validateTermsAcceptance(_acceptTerms, l10n);
      });
      return;
    }

    // Clear any previous errors in provider
    ref.read(authNotifierProvider.notifier).clearError();

    try {
      await ref.read(authNotifierProvider.notifier).register(
        email: AuthValidation.sanitizeInput(_emailController.text),
        password: _passwordController.text,
        firstName: AuthValidation.sanitizeInput(_firstNameController.text),
        lastName: AuthValidation.sanitizeInput(_lastNameController.text),
      );

      // Success handling is done in the listener
    } catch (e) {
      // Error handling is done in the listener
      AuthErrorHandler.logError(e as Exception, 'Registration');
    }
  }

  Future<void> _handleGoogleSignUp() async {
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
      AuthErrorHandler.logError(e as Exception, 'Google Sign Up');
    }
  }
}