import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/theme_manager.dart';
import '../../../../core/timezone/timezone_manager.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Timezone Settings Page
///
/// Dedicated page for configuring timezone preferences.
/// Users can choose between organization timezone (default) or device timezone.
/// Navigated to from ProfilePage via drill-down pattern.
class TimezoneSettingsPage extends ConsumerWidget {
  const TimezoneSettingsPage({super.key});

  /// Returns a summary string for display in parent page
  static String getTimezoneSummary(TimezoneState state, AppLocalizations? l10n) {
    if (state.preference == TimezonePreference.device) {
      return l10n?.deviceTimezone ?? 'Device';
    }
    return l10n?.organizationTimezone ?? 'Organization';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final timezoneState = ref.watch(timezoneManagerProvider);
    final l10n = AppLocalizations.of(context);

    final options = TimezoneManager.getAvailableOptions(timezoneState);

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
                      // Timezone section header
                      _buildSectionHeader(isDark, l10n?.timezoneSettings ?? 'Timezone Settings'),
                      const SizedBox(height: 12),

                      // Timezone options card
                      ViernesGlassmorphismCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            // Organization timezone option
                            _buildTimezoneOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              option: options[0], // Organization
                              currentPreference: timezoneState.preference,
                              l10n: l10n,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(height: 1),
                            ),
                            // Device timezone option
                            _buildTimezoneOption(
                              context: context,
                              ref: ref,
                              isDark: isDark,
                              option: options[1], // Device
                              currentPreference: timezoneState.preference,
                              l10n: l10n,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Current timezone preview
                      _buildSectionHeader(isDark, l10n?.currentTimezone ?? 'Current Timezone'),
                      const SizedBox(height: 12),

                      // Timezone preview card
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
                                Icons.access_time,
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
                                    TimezoneManager.getTimezoneDisplayName(timezoneState.currentTimezone),
                                    style: ViernesTextStyles.bodyText.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: ViernesColors.getTextColor(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    TimezoneManager.getTimezoneOffset(timezoneState.currentTimezone),
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

                      // Info card
                      const SizedBox(height: 24),
                      _buildInfoCard(isDark, l10n),

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

  Widget _buildAppBar(BuildContext context, bool isDark, AppLocalizations? l10n) {
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
            l10n?.timezoneSettings ?? 'Timezone',
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

  Widget _buildTimezoneOption({
    required BuildContext context,
    required WidgetRef ref,
    required bool isDark,
    required TimezoneOption option,
    required TimezonePreference currentPreference,
    required AppLocalizations? l10n,
  }) {
    final isSelected = option.preference == currentPreference;
    final isDisabled = !option.isAvailable;

    // Get localized title
    String title;
    String description;
    if (option.preference == TimezonePreference.organization) {
      title = l10n?.organizationTimezone ?? 'Organization timezone';
      description = option.isAvailable
          ? option.description
          : (l10n?.timezoneNotAvailable ?? 'Not available');
    } else {
      title = l10n?.deviceTimezone ?? 'Device timezone';
      description = option.description;
    }

    return Semantics(
      label: 'Timezone selector: $title',
      value: isSelected ? 'Selected' : 'Not selected',
      button: true,
      enabled: !isDisabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () async {
                  try {
                    final manager = ref.read(timezoneManagerProvider.notifier);
                    await manager.setPreference(option.preference);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error changing timezone: $e'),
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
          child: Opacity(
            opacity: isDisabled ? 0.5 : 1.0,
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
                      option.icon,
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
      ),
    );
  }

  Widget _buildInfoCard(bool isDark, AppLocalizations? l10n) {
    return ViernesGlassmorphismCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: ViernesColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n?.timezoneDescription ??
                'All dates and times in the app will be displayed according to the selected timezone.',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
