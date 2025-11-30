import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';
import '../../../../customers/domain/entities/conversation_entity.dart';
import '../status_badge.dart';
import '../priority_badge.dart';

/// Conversation Info Panel
///
/// Displays detailed information about a conversation in a bottom sheet.
class ConversationInfoPanel extends StatelessWidget {
  final ConversationEntity conversation;

  const ConversationInfoPanel({
    super.key,
    required this.conversation,
  });

  /// Show the panel as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required ConversationEntity conversation,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ConversationInfoPanel(
          conversation: conversation,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: ViernesColors.getControlBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: ViernesSpacing.sm),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(ViernesSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: ViernesColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: ViernesSpacing.sm),
                  Text(
                    'Información de la conversación',
                    style: ViernesTextStyles.h6.copyWith(
                      color: ViernesColors.getTextColor(isDark),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(ViernesSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer info
                    _buildSection(
                      context,
                      isDark,
                      title: 'Cliente',
                      icon: Icons.person_outline,
                      children: [
                        _buildInfoRow(
                          context,
                          isDark,
                          label: 'Nombre',
                          value: conversation.user?.fullname ?? 'Desconocido',
                        ),
                        if (conversation.user != null)
                          _buildInfoRow(
                            context,
                            isDark,
                            label: 'Email',
                            value: conversation.user!.email,
                          ),
                      ],
                    ),
                    const SizedBox(height: ViernesSpacing.lg),

                    // Status & Priority
                    _buildSection(
                      context,
                      isDark,
                      title: 'Estado',
                      icon: Icons.flag_outlined,
                      children: [
                        Row(
                          children: [
                            if (conversation.status != null)
                              StatusBadge(status: conversation.status!.description),
                            const SizedBox(width: ViernesSpacing.sm),
                            if (conversation.priority != null)
                              PriorityBadge(priority: conversation.priority),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: ViernesSpacing.lg),

                    // Agent info
                    if (conversation.agent != null)
                      _buildSection(
                        context,
                        isDark,
                        title: 'Agente asignado',
                        icon: Icons.support_agent,
                        children: [
                          _buildInfoRow(
                            context,
                            isDark,
                            label: 'Nombre',
                            value: conversation.agent!.fullname,
                          ),
                          _buildInfoRow(
                            context,
                            isDark,
                            label: 'Email',
                            value: conversation.agent!.email,
                          ),
                        ],
                      ),
                    if (conversation.agent != null)
                      const SizedBox(height: ViernesSpacing.lg),

                    // Dates
                    _buildSection(
                      context,
                      isDark,
                      title: 'Fechas',
                      icon: Icons.schedule,
                      children: [
                        _buildInfoRow(
                          context,
                          isDark,
                          label: 'Creada',
                          value: _formatDateTime(conversation.createdAt),
                        ),
                        _buildInfoRow(
                          context,
                          isDark,
                          label: 'Última actualización',
                          value: _formatDateTime(conversation.updatedAt),
                        ),
                      ],
                    ),
                    const SizedBox(height: ViernesSpacing.lg),

                    // Conversation type info
                    _buildSection(
                      context,
                      isDark,
                      title: 'Tipo',
                      icon: Icons.chat_bubble_outline,
                      children: [
                        _buildInfoRow(
                          context,
                          isDark,
                          label: 'Tipo',
                          value: conversation.isCall ? 'Llamada' : 'Chat',
                        ),
                        _buildInfoRow(
                          context,
                          isDark,
                          label: 'Origen',
                          value: conversation.origin,
                        ),
                      ],
                    ),
                    const SizedBox(height: ViernesSpacing.lg),

                    // Conversation ID
                    _buildSection(
                      context,
                      isDark,
                      title: 'Identificador',
                      icon: Icons.tag,
                      children: [
                        _buildInfoRow(
                          context,
                          isDark,
                          label: 'ID',
                          value: '#${conversation.id}',
                        ),
                      ],
                    ),
                    const SizedBox(height: ViernesSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: ViernesColors.primary,
            ),
            const SizedBox(width: ViernesSpacing.xs),
            Text(
              title,
              style: ViernesTextStyles.label.copyWith(
                color: ViernesColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: ViernesSpacing.sm),
        Container(
          padding: const EdgeInsets.all(ViernesSpacing.md),
          decoration: BoxDecoration(
            color: isDark
                ? ViernesColors.getControlBackground(isDark).withValues(alpha: 0.5)
                : ViernesColors.primaryLight.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: ViernesColors.getBorderColor(isDark).withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    bool isDark, {
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: ViernesTextStyles.bodySmall.copyWith(
                color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: ViernesTextStyles.bodyText.copyWith(
                color: ViernesColors.getTextColor(isDark),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inDays == 0) {
      return 'Hoy ${_formatTime(dateTime)}';
    } else if (diff.inDays == 1) {
      return 'Ayer ${_formatTime(dateTime)}';
    } else if (diff.inDays < 7) {
      return '${_getDayName(dateTime.weekday)} ${_formatTime(dateTime)}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${_formatTime(dateTime)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }
}
