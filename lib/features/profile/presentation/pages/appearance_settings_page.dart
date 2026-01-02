import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Appearance Settings Page
///
/// Dedicated page for configuring theme and appearance preferences.
/// Navigated to from ProfilePage via drill-down pattern.
class AppearanceSettingsPage extends ConsumerWidget {
  const AppearanceSettingsPage({super.key});

  /// Returns a summary string for display in parent page
  static String getThemeSummary(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Modo claro';
      case ThemeMode.dark:
        return 'Modo oscuro';
      case ThemeMode.system:
        return 'Automático';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final themeMode = ref.watch(themeManagerProvider);

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context, isDark),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Theme section header
                      _buildSectionHeader(isDark, 'Tema'),
                      const SizedBox(height: 12),

                      // Theme options card
                      ViernesGlassmorphismCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildThemeOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              themeMode: ThemeMode.light,
                              currentTheme: themeMode,
                              icon: Icons.light_mode,
                              title: AppStrings.lightMode,
                              description: AppStrings.lightModeDesc,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            _buildThemeOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              themeMode: ThemeMode.dark,
                              currentTheme: themeMode,
                              icon: Icons.dark_mode,
                              title: AppStrings.darkMode,
                              description: AppStrings.darkModeDesc,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            _buildThemeOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              themeMode: ThemeMode.system,
                              currentTheme: themeMode,
                              icon: Icons.brightness_auto,
                              title: AppStrings.autoMode,
                              description: AppStrings.autoModeDesc,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Preview section
                      _buildSectionHeader(isDark, 'Vista Previa'),
                      const SizedBox(height: 12),

                      // Theme preview card
                      ViernesGlassmorphismCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Preview header
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ViernesColors.secondary.withValues(alpha: 0.6),
                                        ViernesColors.accent.withValues(alpha: 0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isDark ? Icons.dark_mode : Icons.light_mode,
                                    color: Colors.black87,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tema actual',
                                        style: ViernesTextStyles.bodyText.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: ViernesColors.getTextColor(isDark),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        getThemeSummary(themeMode),
                                        style: ViernesTextStyles.bodySmall.copyWith(
                                          color: ViernesColors.getTextColor(isDark)
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Color swatches
                            Row(
                              children: [
                                _buildColorSwatch('Primary', ViernesColors.primary),
                                const SizedBox(width: 12),
                                _buildColorSwatch('Secondary', ViernesColors.secondary),
                                const SizedBox(width: 12),
                                _buildColorSwatch('Accent', ViernesColors.accent),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: ViernesColors.getTextColor(isDark),
            ),
            style: IconButton.styleFrom(
              backgroundColor: ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Text(
            'Apariencia',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ViernesColors.getTextColor(isDark),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: ViernesTextStyles.bodySmall.copyWith(
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required ThemeMode themeMode,
    required ThemeMode currentTheme,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = currentTheme == themeMode;

    return Semantics(
      label: '${AppStrings.themeSelectorPrefix}$title',
      value: isSelected ? AppStrings.selected : AppStrings.notSelected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final themeManager = ref.read(themeManagerProvider.notifier);
              await themeManager.setThemeMode(themeMode);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${AppStrings.themeChangeError}: $e'),
                    backgroundColor: ViernesColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [
                              ViernesColors.secondary.withValues(alpha: 0.6),
                              ViernesColors.accent.withValues(alpha: 0.6),
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.black87
                        : ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: ViernesTextStyles.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ViernesColors.getTextColor(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: ViernesTextStyles.bodySmall.copyWith(
                          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),

                // Selected indicator
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          ViernesColors.secondary.withValues(alpha: 0.8),
                          ViernesColors.accent.withValues(alpha: 0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.black87,
                      size: 16,
                    ),
                  )
                else
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwatch(String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: ViernesTextStyles.bodySmall.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
