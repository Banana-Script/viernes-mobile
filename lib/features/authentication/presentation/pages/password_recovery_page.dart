import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/router/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_notifier.dart';
import '../utils/auth_validation.dart';
import '../utils/auth_error_handler.dart';
import '../widgets/auth_loading_widget.dart';
import '../widgets/auth_feedback_widget.dart';

class PasswordRecoveryPage extends ConsumerStatefulWidget {
  const PasswordRecoveryPage({super.key});

  @override
  ConsumerState<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends ConsumerState<PasswordRecoveryPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  String? _emailError;
  String? _generalError;

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
    _emailController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    // Clear previous errors
    setState(() {
      _emailError = null;
      _generalError = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) return;

    try {
      final success = await ref.read(authNotifierProvider.notifier).resetPassword(
        email: AuthValidation.sanitizeInput(_emailController.text),
      );

      if (success) {
        setState(() {
          _emailSent = true;
        });
      } else {
        // Error is handled by the auth state listener
      }
    } catch (e) {
      // Error handling is done in the provider
      AuthErrorHandler.logError(e as Exception, 'Password Reset');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      _buildBackButton(theme),
                      const SizedBox(height: 40),

                      // Header section
                      _buildHeader(l10n, theme),
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

                      // Main content based on state
                      if (!_emailSent) ...[
                        _buildPasswordResetForm(l10n, isLoading),
                      ] else ...[
                        _buildSuccessState(l10n, theme),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay
          AuthLoadingOverlay(
            isVisible: isLoading,
            message: 'Sending password reset email...',
          ),
        ],
      ),
    );
  }

  // UI Builder Methods
  Widget _buildBackButton(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => AppNavigation.pop(),
        icon: const Icon(Icons.arrow_back),
        style: IconButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          padding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Column(
        children: [
          // Animated icon container
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.viernesGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.viernesGray.withValues(alpha:0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              _emailSent ? Icons.mark_email_read : Icons.lock_reset,
              color: Colors.white,
              size: 48,
            ),
          ),

          const SizedBox(height: 32),

          // Title
          Text(
            _emailSent ? l10n.checkYourEmail : l10n.resetPassword,
            style: AppTheme.headingBold.copyWith(
              fontSize: 32,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Subtitle
          Text(
            _emailSent
                ? l10n.emailSentInstructions
                : l10n.passwordResetInstructions,
            style: AppTheme.bodyRegular.copyWith(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha:0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordResetForm(AppLocalizations l10n, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email field
          _buildEmailField(l10n, isLoading),
          const SizedBox(height: 32),

          // Send reset email button
          ViernesGradientButton(
            text: l10n.sendResetEmail,
            isLoading: isLoading,
            onPressed: _sendPasswordResetEmail,
            height: 56,
          ),

          const SizedBox(height: 24),

          // Back to login link
          _buildBackToLoginLink(l10n),
        ],
      ),
    );
  }

  Widget _buildEmailField(AppLocalizations l10n, bool isLoading) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      enabled: !isLoading,
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
      onFieldSubmitted: (_) => _sendPasswordResetEmail(),
    );
  }

  Widget _buildBackToLoginLink(AppLocalizations l10n) {
    return Center(
      child: TextButton(
        onPressed: () => AppNavigation.goToLogin(),
        child: RichText(
          text: TextSpan(
            text: '${l10n.rememberYourPassword} ',
            style: AppTheme.bodyRegular.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: l10n.backToLogin,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.viernesGray,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState(AppLocalizations l10n, ThemeData theme) {
    return Column(
      children: [
        // Success card
        AuthSuccessCard(
          title: l10n.emailSentSuccessfully,
          message: l10n.followInstructions,
          onContinue: () => AppNavigation.goToLogin(),
          continueButtonText: l10n.backToLogin,
        ),

        const SizedBox(height: 24),

        // Send another email option
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _emailSent = false;
                _emailController.clear();
                _generalError = null;
              });
            },
            child: Text(
              l10n.sendAnotherEmail,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.viernesGray,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}