import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/viernes_input.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Masks email for security (e.g., "user@example.com" -> "u***@example.com")
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.isEmpty) return email;

    final maskedUsername = username.length > 1
        ? '${username[0]}${'*' * (username.length - 1)}'
        : username;

    return '$maskedUsername@$domain';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context);

    // Show success message when email is sent
    if (_emailSent) {
      return _buildSuccessScreen(isDark);
    }

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
                            'assets/images/auth/logo.png',
                            width: 180,
                            height: 45,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          Image.asset(
                            'assets/images/auth/powered-by-2.png',
                            width: 110,
                            height: 18,
                            fit: BoxFit.contain,
                            opacity: const AlwaysStoppedAnimation(0.8),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Forgot Password Card with glassmorphism
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
                              'RECUPERAR CONTRASEÑA',
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
                              'Ingresa tu email y te enviaremos instrucciones para restablecer tu contraseña',
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
                              labelText: 'Email',
                              hintText: 'tu@email.com',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                                size: 20,
                              ),
                              enabled: authProvider.status != AuthStatus.loading,
                              validator: Validators.email,
                            ),

                            const SizedBox(height: 24),

                            // Submit button with gradient
                            ViernesGradientButton(
                              text: 'ENVIAR INSTRUCCIONES',
                              onPressed: authProvider.status == AuthStatus.loading
                                  ? null
                                  : () async => await _handleForgotPassword(authProvider),
                              isLoading: authProvider.status == AuthStatus.loading,
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Container(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF2d2d2d)
                                  : const Color(0xFFe5e7eb),
                            ),

                            const SizedBox(height: 24),

                            // Back to login link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Recordaste tu contraseña? ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? ViernesColors.textDark.withValues(alpha: 0.7)
                                        : ViernesColors.textLight.withValues(alpha: 0.7),
                                  ),
                                ),
                                TextButton(
                                  onPressed: authProvider.status == AuthStatus.loading
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(50, 30),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    'INICIAR SESIÓN',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? ViernesColors.accent : ViernesColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),

              // Back button (top-left)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                          : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(20),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                          color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Theme toggle button (top-right)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                          : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final themeManager = ref.read(themeManagerProvider.notifier);
                        themeManager.toggleTheme();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Center(
                        child: Text(
                          isDark ? '🌙' : '☀️',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(bool isDark) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: ViernesColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: ViernesColors.success,
                  ),
                ),

                const SizedBox(height: 32),

                // Success title
                Text(
                  '¡Email Enviado!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Success message
                Text(
                  'Hemos enviado las instrucciones para restablecer tu contraseña a:',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? ViernesColors.textDark.withValues(alpha: 0.7)
                        : ViernesColors.textLight.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  _maskEmail(_emailController.text.trim()),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? ViernesColors.accent : ViernesColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Info box
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                          : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 32,
                        color: isDark ? ViernesColors.accent : ViernesColors.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? ViernesColors.textDark.withValues(alpha: 0.7)
                              : ViernesColors.textLight.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Si no recibes el email en unos minutos, revisa tu carpeta de spam.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? ViernesColors.textDark.withValues(alpha: 0.5)
                              : ViernesColors.textLight.withValues(alpha: 0.5),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Back to login button
                ViernesGradientButton(
                  text: 'VOLVER AL LOGIN',
                  onPressed: () => Navigator.of(context).pop(),
                  isLoading: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleForgotPassword(AuthProvider authProvider) async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    await authProvider.resetPassword(email: _emailController.text.trim());

    // SECURITY: Always show success screen to prevent user enumeration
    // This prevents attackers from discovering which emails are registered
    if (mounted) {
      setState(() {
        _emailSent = true;
      });
    }

    // Clear any errors silently
    if (authProvider.status == AuthStatus.error) {
      authProvider.clearError();
    }
  }
}
