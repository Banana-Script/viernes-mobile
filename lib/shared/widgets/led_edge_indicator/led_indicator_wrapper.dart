import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import 'led_edge_indicator.dart';
import 'led_indicator_models.dart';

/// LED Indicator Wrapper
///
/// Wraps the entire app to display LED edge indicators globally
/// based on the agent's availability status.
///
/// This widget:
/// - Monitors the agent's organizational status from AuthProvider
/// - Shows LED indicators on all screens when status is available
/// - Uses efficient `context.select` to rebuild only when status changes
/// - Stacks the indicator on top of all content to ensure visibility
class LedIndicatorWrapper extends StatelessWidget {
  /// The child widget (typically the main app content)
  final Widget child;

  /// Configuration for the LED indicator appearance
  final LedIndicatorConfig config;

  /// The variant style of the LED indicator
  final LedIndicatorVariant variant;

  const LedIndicatorWrapper({
    super.key,
    required this.child,
    this.config = LedIndicatorConfig.defaultConfig,
    this.variant = LedIndicatorVariant.dualVertical,
  });

  @override
  Widget build(BuildContext context) {
    // Efficiently select only the fields we need to avoid unnecessary rebuilds
    final hasOrganizationalStatus = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus != null,
    );

    final isActive = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus?.isActive ?? false,
    );

    // Don't show indicator if user has no organizational status
    if (!hasOrganizationalStatus) {
      return child;
    }

    return Stack(
      children: [
        // Main app content underneath
        child,
        // LED edge indicators on top (with IgnorePointer so it doesn't block interactions)
        Positioned.fill(
          child: LedEdgeIndicator(
            isActive: isActive,
            config: config,
            variant: variant,
          ),
        ),
      ],
    );
  }
}

/// LED Indicator Scaffold Wrapper
///
/// Alternative wrapper that can be used at the Scaffold level
/// instead of globally. Useful for showing indicators only on specific screens.
class LedIndicatorScaffoldWrapper extends StatelessWidget {
  /// The scaffold body content
  final Widget body;

  /// Optional app bar
  final PreferredSizeWidget? appBar;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// Optional bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Configuration for the LED indicator
  final LedIndicatorConfig config;

  /// The variant style of the LED indicator
  final LedIndicatorVariant variant;

  const LedIndicatorScaffoldWrapper({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.config = LedIndicatorConfig.defaultConfig,
    this.variant = LedIndicatorVariant.dualVertical,
  });

  @override
  Widget build(BuildContext context) {
    final hasOrganizationalStatus = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus != null,
    );

    final isActive = context.select<AuthProvider, bool>(
      (provider) => provider.user?.organizationalStatus?.isActive ?? false,
    );

    return Scaffold(
      appBar: appBar,
      body: Stack(
        children: [
          body,
          if (hasOrganizationalStatus)
            Positioned.fill(
              child: LedEdgeIndicator(
                isActive: isActive,
                config: config,
                variant: variant,
              ),
            ),
        ],
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
