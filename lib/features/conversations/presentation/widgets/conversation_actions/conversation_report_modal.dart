import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';
import '../../../../customers/domain/entities/conversation_entity.dart';

/// Conversation Report Modal
///
/// Displays analytics and metrics for a conversation.
class ConversationReportModal extends StatelessWidget {
  final ConversationEntity conversation;
  final bool isLoading;

  const ConversationReportModal({
    super.key,
    required this.conversation,
    this.isLoading = false,
  });

  /// Show the modal
  static Future<void> show({
    required BuildContext context,
    required ConversationEntity conversation,
    bool isLoading = false,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => ConversationReportModal(
          conversation: conversation,
          isLoading: isLoading,
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
                    Icons.analytics_outlined,
                    color: ViernesColors.info,
                    size: 24,
                  ),
                  const SizedBox(width: ViernesSpacing.sm),
                  Text(
                    'Reporte de conversación',
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(ViernesSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Summary cards
                          _buildMetricsGrid(context, isDark),
                          const SizedBox(height: ViernesSpacing.lg),

                          // Timeline section
                          _buildSection(
                            context,
                            isDark,
                            title: 'Línea de tiempo',
                            icon: Icons.timeline,
                            child: _buildTimeline(context, isDark),
                          ),
                          const SizedBox(height: ViernesSpacing.lg),

                          // Assigned agents
                          if (conversation.assigns.isNotEmpty)
                            _buildSection(
                              context,
                              isDark,
                              title: 'Agentes asignados',
                              icon: Icons.people_outline,
                              child: _buildAssignedAgents(context, isDark),
                            ),
                          if (conversation.assigns.isNotEmpty)
                            const SizedBox(height: ViernesSpacing.lg),

                          // Tags
                          if (conversation.tags.isNotEmpty)
                            _buildSection(
                              context,
                              isDark,
                              title: 'Etiquetas',
                              icon: Icons.label_outline,
                              child: _buildTags(context, isDark),
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

  Widget _buildMetricsGrid(BuildContext context, bool isDark) {
    // Calculate metrics
    final createdAt = conversation.createdAt;
    final updatedAt = conversation.updatedAt;
    final duration = updatedAt.difference(createdAt);

    String formatDuration(Duration d) {
      if (d.inDays > 0) {
        return '${d.inDays}d ${d.inHours.remainder(24)}h';
      } else if (d.inHours > 0) {
        return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
      } else {
        return '${d.inMinutes}m';
      }
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: ViernesSpacing.sm,
      crossAxisSpacing: ViernesSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          context,
          isDark,
          title: 'Duración',
          value: formatDuration(duration),
          icon: Icons.timer_outlined,
          color: ViernesColors.info,
        ),
        _buildMetricCard(
          context,
          isDark,
          title: 'Tipo',
          value: conversation.isCall ? 'Llamada' : 'Chat',
          icon: conversation.isCall ? Icons.phone : Icons.chat_bubble_outline,
          color: ViernesColors.primary,
        ),
        _buildMetricCard(
          context,
          isDark,
          title: 'Prioridad',
          value: conversation.priority ?? 'Normal',
          icon: Icons.flag_outlined,
          color: _getPriorityColor(conversation.priority),
        ),
        _buildMetricCard(
          context,
          isDark,
          title: 'Estado',
          value: conversation.status?.description ?? 'Desconocido',
          icon: Icons.info_outline,
          color: ViernesColors.success,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    bool isDark, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: ViernesSpacing.xs),
              Text(
                title,
                style: ViernesTextStyles.bodySmall.copyWith(
                  color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: ViernesSpacing.xs),
          Text(
            value,
            style: ViernesTextStyles.h6.copyWith(
              color: ViernesColors.getTextColor(isDark),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    bool isDark, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: ViernesColors.primary),
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
        child,
      ],
    );
  }

  Widget _buildTimeline(BuildContext context, bool isDark) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        time: conversation.createdAt,
        title: 'Conversación iniciada',
        icon: Icons.play_circle_outline,
        color: ViernesColors.success,
      ),
      if (conversation.firstResponseAt != null)
        _TimelineEvent(
          time: conversation.firstResponseAt!,
          title: 'Primera respuesta',
          icon: Icons.reply,
          color: ViernesColors.info,
        ),
      _TimelineEvent(
        time: conversation.updatedAt,
        title: 'Última actualización',
        icon: Icons.update,
        color: ViernesColors.primary,
      ),
    ];

    return Container(
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
        children: events.asMap().entries.map((entry) {
          final index = entry.key;
          final event = entry.value;
          final isLast = index == events.length - 1;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline line and dot
              Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: event.color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(event.icon, size: 14, color: event.color),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 30,
                      color: ViernesColors.getBorderColor(isDark),
                    ),
                ],
              ),
              const SizedBox(width: ViernesSpacing.sm),
              // Event content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : ViernesSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: ViernesTextStyles.bodyText.copyWith(
                          color: ViernesColors.getTextColor(isDark),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatDateTime(event.time),
                        style: ViernesTextStyles.bodySmall.copyWith(
                          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAssignedAgents(BuildContext context, bool isDark) {
    return Container(
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
        children: conversation.assigns.map((assign) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.xs),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: ViernesColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    _getInitials(assign.user.fullname),
                    style: ViernesTextStyles.label.copyWith(
                      color: ViernesColors.primary,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: ViernesSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        assign.user.fullname,
                        style: ViernesTextStyles.bodyText.copyWith(
                          color: ViernesColors.getTextColor(isDark),
                        ),
                      ),
                      Text(
                        'Asignado: ${_formatDateTime(assign.createdAt)}',
                        style: ViernesTextStyles.bodySmall.copyWith(
                          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTags(BuildContext context, bool isDark) {
    return Wrap(
      spacing: ViernesSpacing.xs,
      runSpacing: ViernesSpacing.xs,
      children: conversation.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ViernesSpacing.sm,
            vertical: ViernesSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: ViernesColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: ViernesColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            tag.tagName,
            style: ViernesTextStyles.bodySmall.copyWith(
              color: ViernesColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'urgent':
      case 'urgente':
        return ViernesColors.danger;
      case 'high':
      case 'alta':
        return ViernesColors.warning;
      case 'medium':
      case 'media':
        return ViernesColors.info;
      case 'low':
      case 'baja':
        return ViernesColors.success;
      default:
        return ViernesColors.primary;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

/// Timeline event helper class
class _TimelineEvent {
  final DateTime time;
  final String title;
  final IconData icon;
  final Color color;

  _TimelineEvent({
    required this.time,
    required this.title,
    required this.icon,
    required this.color,
  });
}
