import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_manager.dart';
import '../../core/theme/viernes_colors.dart';
import '../../core/theme/viernes_spacing.dart';

/// Modern theme toggle widget following Viernes 2025 design
///
/// Features:
/// - Smooth animations
/// - Touch-friendly design
/// - Visual feedback
/// - Accessibility support
class ViernesThemeToggle extends ConsumerWidget {
  final bool showLabel;
  final double size;
  final EdgeInsets? margin;

  const ViernesThemeToggle({
    super.key,
    this.showLabel = false,
    this.size = 56.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeManagerProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final themeManager = ref.read(themeManagerProvider.notifier);

    return Container(
      margin: margin,
      child: showLabel
          ? _buildWithLabel(context, themeManager, isDark, themeMode)
          : _buildToggleOnly(context, themeManager, isDark),
    );
  }

  Widget _buildToggleOnly(BuildContext context, ThemeManager themeManager, bool isDark) {
    return GestureDetector(
      onTap: () => themeManager.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: size,
        height: size * 0.6, // Oval shape like in designs
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          color: isDark ? ViernesColors.panelDark : ViernesColors.panelLight,
          border: Border.all(
            color: ViernesColors.accent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: ViernesColors.accent.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
          padding: const EdgeInsets.all(4),
          child: Container(
            width: size * 0.4,
            height: size * 0.4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? ViernesColors.secondary : ViernesColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: isDark ? Colors.black : Colors.white,
              size: size * 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithLabel(BuildContext context, ThemeManager themeManager, bool isDark, ThemeMode themeMode) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleOnly(context, themeManager, isDark),
        const SizedBox(width: ViernesSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark
                    ? ViernesColors.getTextColor(true).withValues(alpha: 0.7)
                    : ViernesColors.getTextColor(false).withValues(alpha: 0.7),
              ),
            ),
            Text(
              themeManager.themeDisplayName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? ViernesColors.getTextColor(true)
                    : ViernesColors.getTextColor(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Theme selector widget for settings
/// Shows all available theme options
class ViernesThemeSelector extends ConsumerWidget {
  const ViernesThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeManagerProvider);
    final isDark = ref.watch(isDarkModeProvider);
    final themeManager = ref.read(themeManagerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: ViernesSpacing.sm),
        ...ThemeManager.availableThemes.map((theme) {
          final isSelected = currentTheme == theme;
          return _ThemeOption(
            theme: theme,
            isSelected: isSelected,
            isDark: isDark,
            onTap: () => themeManager.setThemeMode(theme),
          );
        }),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final ThemeMode theme;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: ViernesSpacing.md,
              vertical: ViernesSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
              color: isSelected
                  ? (isDark ? ViernesColors.secondary.withValues(alpha: 0.1) : ViernesColors.primary.withValues(alpha: 0.1))
                  : Colors.transparent,
              border: isSelected
                  ? Border.all(
                      color: isDark ? ViernesColors.secondary : ViernesColors.primary,
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  ThemeManager.getThemeIcon(theme),
                  color: isSelected
                      ? (isDark ? ViernesColors.secondary : ViernesColors.primary)
                      : (isDark ? ViernesColors.getTextColor(true) : ViernesColors.getTextColor(false)),
                  size: 20,
                ),
                const SizedBox(width: ViernesSpacing.sm),
                Expanded(
                  child: Text(
                    ThemeManager.getThemeDisplayName(theme),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? (isDark ? ViernesColors.secondary : ViernesColors.primary)
                          : (isDark ? ViernesColors.getTextColor(true) : ViernesColors.getTextColor(false)),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: isDark ? ViernesColors.secondary : ViernesColors.primary,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating theme toggle button
/// Perfect for quick access in app bars or floating
class ViernesFloatingThemeToggle extends ConsumerWidget {
  final double size;

  const ViernesFloatingThemeToggle({
    super.key,
    this.size = 48.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final themeManager = ref.read(themeManagerProvider.notifier);

    return FloatingActionButton(
      onPressed: () => themeManager.toggleTheme(),
      backgroundColor: isDark ? ViernesColors.secondary : ViernesColors.primary,
      foregroundColor: isDark ? Colors.black : Colors.white,
      elevation: 4,
      mini: size < 48,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: child,
          );
        },
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
        ),
      ),
    );
  }
}