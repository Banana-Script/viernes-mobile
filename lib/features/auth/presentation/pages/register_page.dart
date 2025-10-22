import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider_pkg;
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../shared/widgets/viernes_input.dart';
import '../../../../shared/widgets/viernes_gradient_button.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
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
    final isDark = ref.watch(isDarkModeProvider);
    final authProvider = provider_pkg.Provider.of<AuthProvider>(context);

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
                              'CREAR CUENTA',
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
                              'Completa los datos para crear tu cuenta',
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
                            ),

                            const SizedBox(height: 20),

                            // Password input
                            ViernesInput.password(
                              controller: _passwordController,
                              labelText: 'Contraseña',
                              hintText: 'Crea una contraseña segura',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                                size: 20,
                              ),
                              enabled: authProvider.status != AuthStatus.loading,
                            ),

                            const SizedBox(height: 20),

                            // Confirm Password input
                            ViernesInput.password(
                              controller: _confirmPasswordController,
                              labelText: 'Confirmar Contraseña',
                              hintText: 'Confirma tu contraseña',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: isDark ? ViernesColors.accent : ViernesColors.primary,
                                size: 20,
                              ),
                              enabled: authProvider.status != AuthStatus.loading,
                            ),

                            const SizedBox(height: 24),

                            // Submit button with gradient
                            ViernesGradientButton(
                              text: 'CREAR CUENTA',
                              onPressed: authProvider.status == AuthStatus.loading
                                  ? null
                                  : () => _handleRegister(authProvider),
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

                            // Sign in link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '¿Ya tienes cuenta? ',
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

  void _handleRegister(AuthProvider authProvider) {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa tu email'),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (!RegExp(r'^[\w\+\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text.trim())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa un email válido'),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor ingresa una contraseña'),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('La contraseña debe tener al menos 6 caracteres'),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor confirma tu contraseña'),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Las contraseñas no coinciden'),
          backgroundColor: ViernesColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
    );
  }
}
