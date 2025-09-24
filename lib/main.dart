import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart'; // Will use when needed

import 'core/config/environment.dart';
import 'core/config/firebase_config.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'shared/providers/app_providers.dart';
import 'l10n/l10n.dart';
import 'l10n/app_localizations.dart';

/// Default entry point - configures for development
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure for development by default
  AppConfig.configure(Environment.development);

  // Initialize Firebase
  await FirebaseConfig.initialize();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const ProviderScope(
      child: ViernesApp(),
    ),
  );
}

/// Main application widget
class ViernesApp extends ConsumerWidget {
  const ViernesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Viernes Mobile',
      debugShowCheckedModeBanner: AppConfig.instance.debugMode,

      // Theme configuration
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Routing
      routerConfig: router,

      // Localization
      locale: locale,
      supportedLocales: L10n.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Builder for global wrappers
      builder: (context, child) {
        return _AppWrapper(child: child ?? const SizedBox.shrink());
      },
    );
  }
}

/// App wrapper for global providers and overlays
class _AppWrapper extends ConsumerWidget {
  final Widget child;

  const _AppWrapper({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(globalLoadingProvider);
    final error = ref.watch(globalErrorProvider);

    return Stack(
      children: [
        child,

        // Global loading overlay
        if (isLoading)
          const Positioned.fill(
            child: _LoadingOverlay(),
          ),

        // Global error snackbar
        if (error != null)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _ErrorSnackbar(error: error),
          ),
      ],
    );
  }
}

/// Global loading overlay
class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Global error snackbar
class _ErrorSnackbar extends ConsumerWidget {
  final String error;

  const _ErrorSnackbar({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      child: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.error,
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () => ref.read(globalErrorProvider.notifier).clearError(),
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}