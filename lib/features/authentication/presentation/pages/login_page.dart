import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/errors/failures.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state_provider.dart';
import '../providers/auth_notifier.dart';
import '../utils/auth_error_handler.dart';
import '../utils/auth_validation.dart';
import '../widgets/auth_feedback_widget.dart';
import '../widgets/auth_loading_widget.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Listen for auth state changes
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.isAuthenticated) {
        // Navigate to home page
        context.go('/dashboard');
      } else if (next.hasError) {
        AuthFeedbackSnackbar.showError(
          context,
          AuthErrorHandler.getErrorMessage(AuthFailure(message: next.error!)),
        );
        authNotifier.clearError();
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: AuthLoadingOverlay(
          isVisible: authState.isLoading,
          message: 'Signing you in...',
          child: _buildBody(context, theme, l10n, authState, authNotifier),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AuthState authState,
    AuthNotifier authNotifier,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 48),
          _buildHeader(theme, l10n),
          const SizedBox(height: 48),
          _buildBiometricPrompt(authState, authNotifier),
          const SizedBox(height: 24),
          _buildLoginForm(theme, l10n, authState.isLoading),
          const SizedBox(height: 24),
          _buildLoginButton(theme, l10n, authState.isLoading, authNotifier),
          const SizedBox(height: 16),
          _buildDivider(theme, l10n),
          const SizedBox(height: 16),
          _buildGoogleSignInButton(theme, l10n, authState.isLoading, authNotifier),
          const SizedBox(height: 32),
          _buildForgotPasswordLink(theme, l10n),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        // Viernes Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.chat_bubble_outline,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.welcomeToViernes,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signInToContinue,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBiometricPrompt(AuthState authState, AuthNotifier authNotifier) {
    final canUseBiometric = authState.canUseBiometric;

    if (!canUseBiometric) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () async {
        final success = await authNotifier.authenticateWithBiometrics();
        if (success) {
          // Biometric authentication successful
          // The stored credentials should be used to sign in
        }
      },
      child: BiometricFeedbackWidget(
        isVisible: true,
        message: 'Tap to use biometric authentication',
      ),
    );
  }

  Widget _buildLoginForm(ThemeData theme, AppLocalizations l10n, bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
            validator: AuthValidation.validateEmail,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: l10n.enterYourEmail,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            enabled: !isLoading,
            validator: AuthValidation.validatePassword,
            onFieldSubmitted: (_) => _handleEmailLogin(),
            decoration: InputDecoration(
              labelText: l10n.password,
              hintText: l10n.enterYourPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: isLoading ? null : (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Text(
                  l10n.rememberMe,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(
    ThemeData theme,
    AppLocalizations l10n,
    bool isLoading,
    AuthNotifier authNotifier,
  ) {
    return SizedBox(
      height: 56,
      child: AuthLoadingButton(
        isLoading: isLoading,
        onPressed: _handleEmailLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          l10n.signIn,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            l10n.orContinueWith,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(
    ThemeData theme,
    AppLocalizations l10n,
    bool isLoading,
    AuthNotifier authNotifier,
  ) {
    return SizedBox(
      height: 56,
      child: AuthLoadingButton(
        isLoading: isLoading,
        onPressed: () => authNotifier.loginWithGoogle(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google icon would go here - using a placeholder
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icons/google.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.continueWithGoogle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink(ThemeData theme, AppLocalizations l10n) {
    return TextButton(
      onPressed: () {
        context.push('/password-recovery');
      },
      child: Text(
        l10n.forgotPassword,
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _handleEmailLogin() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authNotifier = ref.read(authNotifierProvider.notifier);
    authNotifier.loginWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }
}