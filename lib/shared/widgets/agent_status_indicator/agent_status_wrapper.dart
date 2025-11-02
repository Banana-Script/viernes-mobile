import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import 'agent_status_indicator.dart';

/// Agent Status Wrapper
///
/// Wraps the entire app to show the agent status indicator on all screens.
/// This widget automatically listens to the user's organizational status
/// and displays the appropriate indicator.
///
/// Usage:
/// Wrap your MaterialApp's home or your main scaffold with this wrapper.
class AgentStatusWrapper extends StatelessWidget {
  final Widget child;
  final AgentStatusVariant variant;
  final VoidCallback? onStatusTap;
  final bool showIndicator;

  const AgentStatusWrapper({
    super.key,
    required this.child,
    this.variant = AgentStatusVariant.topBar,
    this.onStatusTap,
    this.showIndicator = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final organizationalStatus = user?.organizationalStatus;

        // DEBUG: Print status
        print('[AgentStatusWrapper] User: ${user != null ? "logged in" : "null"}');
        print('[AgentStatusWrapper] OrgStatus: ${organizationalStatus != null ? "exists (${organizationalStatus.valueDefinition})" : "null"}');

        // Don't show indicator if:
        // - showIndicator is false
        // - No user is logged in
        // - User has no organizational status
        if (!showIndicator || user == null || organizationalStatus == null) {
          print('[AgentStatusWrapper] Not showing indicator - showIndicator=$showIndicator, user=${user != null}, orgStatus=${organizationalStatus != null}');
          return child;
        }

        final isActive = organizationalStatus.isActive;
        print('[AgentStatusWrapper] Showing indicator - isActive=$isActive');

        // For topBar variant, we need to structure differently
        if (variant == AgentStatusVariant.topBar) {
          return Column(
            children: [
              AgentStatusIndicator(
                isActive: isActive,
                variant: variant,
                onTap: onStatusTap,
              ),
              Expanded(child: child),
            ],
          );
        }

        // For other variants, overlay on top
        return Stack(
          children: [
            child,
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: variant == AgentStatusVariant.expandableBanner
                    ? AgentStatusIndicator(
                        isActive: isActive,
                        variant: variant,
                        onTap: onStatusTap,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: variant == AgentStatusVariant.floatingPill
                            ? Align(
                                alignment: Alignment.topRight,
                                child: AgentStatusIndicator(
                                  isActive: isActive,
                                  variant: variant,
                                  onTap: onStatusTap,
                                ),
                              )
                            : Align(
                                alignment: Alignment.topCenter,
                                child: AgentStatusIndicator(
                                  isActive: isActive,
                                  variant: variant,
                                  onTap: onStatusTap,
                                ),
                              ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Agent Status App Bar
///
/// A custom app bar that includes the agent status indicator.
/// This is useful when you want the status to be part of the app bar itself.
class AgentStatusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final AgentStatusVariant variant;
  final VoidCallback? onStatusTap;

  const AgentStatusAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.variant = AgentStatusVariant.glassBadge,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;
        final organizationalStatus = user?.organizationalStatus;
        final isActive = organizationalStatus?.isActive ?? false;

        // Build status widget based on variant
        Widget? statusWidget;
        if (user != null && organizationalStatus != null) {
          if (variant == AgentStatusVariant.glassBadge ||
              variant == AgentStatusVariant.floatingPill) {
            statusWidget = AgentStatusIndicator(
              isActive: isActive,
              variant: variant,
              onTap: onStatusTap,
            );
          }
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top bar indicator (if selected)
            if (user != null &&
                organizationalStatus != null &&
                variant == AgentStatusVariant.topBar)
              AgentStatusIndicator(
                isActive: isActive,
                variant: variant,
                onTap: onStatusTap,
              ),

            // App bar
            AppBar(
              title: Text(title),
              leading: leading,
              automaticallyImplyLeading: automaticallyImplyLeading,
              actions: [
                if (statusWidget != null) statusWidget,
                if (statusWidget != null) const SizedBox(width: 8),
                ...?actions,
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize {
    // Add extra height for top bar variant
    if (variant == AgentStatusVariant.topBar) {
      return const Size.fromHeight(kToolbarHeight + 3);
    }
    return const Size.fromHeight(kToolbarHeight);
  }
}
