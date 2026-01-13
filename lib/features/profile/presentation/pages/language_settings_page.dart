import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/locale/locale_manager.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Language Settings Page
///
/// Dedicated page for configuring language preferences.
/// Navigated to from ProfilePage via drill-down pattern.
class LanguageSettingsPage extends ConsumerWidget {
  const LanguageSettingsPage({super.key});

  /// Returns a summary string for display in parent page
  static String getLocaleSummary(Locale? locale) {
    if (locale == null) return 'System';
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      default:
        return locale.languageCode;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final currentLocale = ref.watch(localeManagerProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(context, isDark, l10n),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Language section header
                      _buildSectionHeader(isDark, l10n.language),
                      const SizedBox(height: 12),

                      // Language options card
                      ViernesGlassmorphismCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildLanguageOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              locale: null,
                              currentLocale: currentLocale,
                              icon: Icons.language,
                              title: l10n.systemLanguage,
                              description: l10n.systemLanguageDesc,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            _buildLanguageOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              locale: LocaleManager.english,
                              currentLocale: currentLocale,
                              icon: Icons.flag,
                              title: 'English',
                              description: l10n.englishDesc,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            _buildLanguageOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              locale: LocaleManager.spanish,
                              currentLocale: currentLocale,
                              icon: Icons.flag,
                              title: 'Español',
                              description: l10n.spanishDesc,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Current language preview
                      _buildSectionHeader(isDark, l10n.currentLanguage),
                      const SizedBox(height: 12),

                      // Language preview card
                      ViernesGlassmorphismCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        child: Row(
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
                              child: const Icon(
                                Icons.translate,
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
                                    l10n.activeLanguage,
                                    style: ViernesTextStyles.bodyText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ViernesColors.getTextColor(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    getLocaleSummary(currentLocale),
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

  Widget _buildAppBar(BuildContext context, bool isDark, AppLocalizations l10n) {
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
            l10n.language,
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

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required Locale? locale,
    required Locale? currentLocale,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = (currentLocale == null && locale == null) ||
        (currentLocale != null && locale != null && currentLocale.languageCode == locale.languageCode);

    return Semantics(
      label: 'Language selector: $title',
      value: isSelected ? 'Selected' : 'Not selected',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              final localeManager = ref.read(localeManagerProvider.notifier);
              await localeManager.setLocale(locale);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error changing language: $e'),
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
}
