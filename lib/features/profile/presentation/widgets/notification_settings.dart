import 'package:flutter/material.dart';
import '../../../../core/models/notification_preferences.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';

/// Notification Settings Widget
///
/// Allows users to configure their notification preferences.
class NotificationSettings extends StatefulWidget {
  const NotificationSettings({super.key});

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
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

    return ViernesGlassmorphismCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                color: ViernesColors.getTextColor(isDark),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Notificaciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ViernesColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Main toggle
          _buildToggleOption(
            isDark: isDark,
            title: 'Activar notificaciones',
            subtitle: 'Recibir alertas de nuevos mensajes',
            value: _preferences.enabled,
            onChanged: (value) {
              _updatePreferences(_preferences.copyWith(enabled: value));
            },
          ),

          if (_preferences.enabled) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Sound toggle
            _buildToggleOption(
              isDark: isDark,
              title: 'Sonido',
              subtitle: 'Reproducir sonido al recibir notificaciones',
              value: _preferences.soundEnabled,
              onChanged: (value) {
                _updatePreferences(_preferences.copyWith(soundEnabled: value));
              },
            ),

            const SizedBox(height: 12),

            // Vibration toggle
            _buildToggleOption(
              isDark: isDark,
              title: 'Vibración',
              subtitle: 'Vibrar al recibir notificaciones',
              value: _preferences.vibrationEnabled,
              onChanged: (value) {
                _updatePreferences(_preferences.copyWith(vibrationEnabled: value));
              },
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            Text(
              'Tipos de notificaciones',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Message notifications
            _buildToggleOption(
              isDark: isDark,
              title: 'Nuevos mensajes',
              subtitle: 'Notificar cuando llegan mensajes de clientes',
              value: _preferences.showMessageNotifications,
              onChanged: (value) {
                _updatePreferences(_preferences.copyWith(showMessageNotifications: value));
              },
            ),

            const SizedBox(height: 12),

            // Assignment notifications
            _buildToggleOption(
              isDark: isDark,
              title: 'Asignaciones',
              subtitle: 'Notificar cuando te asignan una conversación',
              value: _preferences.showAssignmentNotifications,
              onChanged: (value) {
                _updatePreferences(_preferences.copyWith(showAssignmentNotifications: value));
              },
            ),

            const SizedBox(height: 12),

            // New conversation notifications
            _buildToggleOption(
              isDark: isDark,
              title: 'Nuevas conversaciones',
              subtitle: 'Notificar cuando inicia una nueva conversación',
              value: _preferences.showNewConversationNotifications,
              onChanged: (value) {
                _updatePreferences(_preferences.copyWith(showNewConversationNotifications: value));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    required bool isDark,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
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
          activeThumbColor: ViernesColors.primary,
          activeTrackColor: ViernesColors.primary.withValues(alpha: 0.3),
        ),
      ],
    );
  }
}

/// Modal to show notification settings
class NotificationSettingsModal {
  static Future<void> show(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ViernesColors.getControlBackground(isDark),
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: NotificationSettings(),
        ),
      ),
    );
  }
}
