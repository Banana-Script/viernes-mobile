import 'package:flutter/material.dart';
import '../../../../core/models/notification_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../../../shared/widgets/viernes_background.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Notification Settings Page
///
/// Dedicated page for configuring notification preferences.
/// Navigated to from ProfilePage via drill-down pattern.
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  /// Returns a summary string for display in parent page
  static String getNotificationSummary(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final prefs = NotificationService.instance.preferences;
    if (!prefs.enabled) return l10n.notificationsDisabled;

    int activeCount = 0;
    if (prefs.showMessageNotifications) activeCount++;
    if (prefs.showAssignmentNotifications) activeCount++;
    if (prefs.showNewConversationNotifications) activeCount++;

    return l10n.activeTypesCount(activeCount);
  }

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  late NotificationPreferences _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _preferences = NotificationService.instance.preferences;
  }

  Future<void> _updatePreferences(NotificationPreferences newPreferences) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await NotificationService.instance.updatePreferences(newPreferences);
      setState(() {
        _preferences = newPreferences;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ViernesBackground(
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _buildAppBar(isDark, l10n),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Main toggle card
                      ViernesGlassmorphismCard(
                        borderRadius: 20,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _preferences.enabled
                                        ? Icons.notifications_active
                                        : Icons.notifications_off_outlined,
                                    color: _preferences.enabled
                                        ? ViernesColors.primary
                                        : ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.enableNotifications,
                                        style: ViernesTextStyles.bodyText.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: ViernesColors.getTextColor(isDark),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        l10n.enableNotificationsDesc,
                                        style: ViernesTextStyles.bodySmall.copyWith(
                                          color: ViernesColors.getTextColor(isDark)
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch.adaptive(
                                  value: _preferences.enabled,
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          _updatePreferences(
                                            _preferences.copyWith(enabled: value),
                                          );
                                        },
                                  activeColor: ViernesColors.primary,
                                  activeTrackColor: ViernesColors.primary.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (_preferences.enabled) ...[
                        const SizedBox(height: 24),

                        // Sound & Vibration section
                        _buildSectionHeader(isDark, l10n.soundAndVibration),
                        const SizedBox(height: 12),

                        ViernesGlassmorphismCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildToggleRow(
                                isDark: isDark,
                                icon: Icons.volume_up_outlined,
                                title: l10n.sound,
                                subtitle: l10n.playSoundShort,
                                value: _preferences.soundEnabled,
                                onChanged: (value) {
                                  _updatePreferences(
                                    _preferences.copyWith(soundEnabled: value),
                                  );
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              _buildToggleRow(
                                isDark: isDark,
                                icon: Icons.vibration,
                                title: l10n.vibration,
                                subtitle: l10n.vibrateOnNotification,
                                value: _preferences.vibrationEnabled,
                                onChanged: (value) {
                                  _updatePreferences(
                                    _preferences.copyWith(vibrationEnabled: value),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Notification types section
                        _buildSectionHeader(isDark, l10n.notificationTypes),
                        const SizedBox(height: 12),

                        ViernesGlassmorphismCard(
                          borderRadius: 20,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildToggleRow(
                                isDark: isDark,
                                icon: Icons.chat_bubble_outline,
                                title: l10n.newMessages,
                                subtitle: l10n.clientMessages,
                                value: _preferences.showMessageNotifications,
                                onChanged: (value) {
                                  _updatePreferences(
                                    _preferences.copyWith(showMessageNotifications: value),
                                  );
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              _buildToggleRow(
                                isDark: isDark,
                                icon: Icons.assignment_ind_outlined,
                                title: l10n.assignments,
                                subtitle: l10n.conversationsAssignedToYou,
                                value: _preferences.showAssignmentNotifications,
                                onChanged: (value) {
                                  _updatePreferences(
                                    _preferences.copyWith(showAssignmentNotifications: value),
                                  );
                                },
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),
                              _buildToggleRow(
                                isDark: isDark,
                                icon: Icons.add_comment_outlined,
                                title: l10n.newConversations,
                                subtitle: l10n.conversationStart,
                                value: _preferences.showNewConversationNotifications,
                                onChanged: (value) {
                                  _updatePreferences(
                                    _preferences.copyWith(showNewConversationNotifications: value),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],

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

  Widget _buildAppBar(bool isDark, AppLocalizations l10n) {
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
            l10n.notifications,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: ViernesColors.getTextColor(isDark),
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          // Loading indicator
          if (_isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  ViernesColors.primary,
                ),
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

  Widget _buildToggleRow({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
          size: 22,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ViernesTextStyles.bodyText.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch.adaptive(
          value: value,
          onChanged: _isLoading ? null : onChanged,
          activeColor: ViernesColors.primary,
          activeTrackColor: ViernesColors.primary.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}
