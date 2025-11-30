import 'package:flutter/material.dart';
import '../../../../../core/theme/viernes_colors.dart';
import '../../../../../core/theme/viernes_spacing.dart';
import '../../../../../core/theme/viernes_text_styles.dart';
import '../../../../auth/domain/entities/user_entity.dart';
import '../../../../customers/domain/entities/conversation_entity.dart';

/// Conversation Actions Bottom Sheet
///
/// Shows available actions for a conversation based on its status and user permissions.
class ConversationActionsBottomSheet extends StatelessWidget {
  final ConversationEntity conversation;
  final UserEntity? currentUser;
  final bool showToolCalls;
  final VoidCallback? onViewInfo;
  final VoidCallback? onViewReport;
  final VoidCallback? onViewInternalNotes;
  final VoidCallback? onToggleToolCalls;
  final VoidCallback? onCompleteSuccessfully;
  final VoidCallback? onCompleteUnsuccessfully;
  final VoidCallback? onRequestReassignment;

  const ConversationActionsBottomSheet({
    super.key,
    required this.conversation,
    this.currentUser,
    this.showToolCalls = true,
    this.onViewInfo,
    this.onViewReport,
    this.onViewInternalNotes,
    this.onToggleToolCalls,
    this.onCompleteSuccessfully,
    this.onCompleteUnsuccessfully,
    this.onRequestReassignment,
  });

  /// Check if conversation status is active (010 = Started, 020 = In Progress)
  bool get _isActiveConversation {
    final statusValue = conversation.status?.valueDefinition ?? '';
    return statusValue == '010' || statusValue == '020';
  }

  /// Check if current user is the assigned agent
  bool get _isAssignedAgent {
    if (currentUser == null) return false;
    return conversation.agentId == currentUser!.databaseId;
  }

  /// Show the bottom sheet
  static Future<void> show({
    required BuildContext context,
    required ConversationEntity conversation,
    UserEntity? currentUser,
    bool showToolCalls = true,
    VoidCallback? onViewInfo,
    VoidCallback? onViewReport,
    VoidCallback? onViewInternalNotes,
    VoidCallback? onToggleToolCalls,
    VoidCallback? onCompleteSuccessfully,
    VoidCallback? onCompleteUnsuccessfully,
    VoidCallback? onRequestReassignment,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ConversationActionsBottomSheet(
        conversation: conversation,
        currentUser: currentUser,
        showToolCalls: showToolCalls,
        onViewInfo: onViewInfo,
        onViewReport: onViewReport,
        onViewInternalNotes: onViewInternalNotes,
        onToggleToolCalls: onToggleToolCalls,
        onCompleteSuccessfully: onCompleteSuccessfully,
        onCompleteUnsuccessfully: onCompleteUnsuccessfully,
        onRequestReassignment: onRequestReassignment,
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
            // Title
            Padding(
              padding: const EdgeInsets.all(ViernesSpacing.md),
              child: Text(
                'Acciones',
                style: ViernesTextStyles.h6.copyWith(
                  color: ViernesColors.getTextColor(isDark),
                ),
              ),
            ),
            const Divider(height: 1),
            // Always available actions
            _ActionTile(
              icon: Icons.info_outline,
              title: 'Ver información',
              onTap: () {
                Navigator.pop(context);
                onViewInfo?.call();
              },
            ),
            _ActionTile(
              icon: Icons.analytics_outlined,
              title: 'Ver reporte',
              onTap: () {
                Navigator.pop(context);
                onViewReport?.call();
              },
            ),
            _ActionTile(
              icon: Icons.note_alt_outlined,
              title: 'Ver notas internas',
              onTap: () {
                Navigator.pop(context);
                onViewInternalNotes?.call();
              },
            ),
            _ActionTile(
              icon: showToolCalls ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              title: showToolCalls ? 'Ocultar Tool Calls' : 'Mostrar Tool Calls',
              onTap: () {
                Navigator.pop(context);
                onToggleToolCalls?.call();
              },
            ),
            // Conditional actions (only for active conversations)
            if (_isActiveConversation) ...[
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.check_circle_outline,
                title: 'Completar exitosamente',
                iconColor: ViernesColors.success,
                onTap: () {
                  Navigator.pop(context);
                  onCompleteSuccessfully?.call();
                },
              ),
              _ActionTile(
                icon: Icons.cancel_outlined,
                title: 'Completar sin éxito',
                iconColor: ViernesColors.danger,
                onTap: () {
                  Navigator.pop(context);
                  onCompleteUnsuccessfully?.call();
                },
              ),
              // Reassignment only if user is assigned agent
              if (_isAssignedAgent)
                _ActionTile(
                  icon: Icons.swap_horiz,
                  title: 'Solicitar reasignación',
                  onTap: () {
                    Navigator.pop(context);
                    onRequestReassignment?.call();
                  },
                ),
            ],
            const SizedBox(height: ViernesSpacing.md),
          ],
        ),
      ),
    );
  }
}

/// Individual action tile
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = iconColor ?? ViernesColors.getTextColor(isDark);

    return ListTile(
      leading: Icon(
        icon,
        color: effectiveIconColor,
        size: 24,
      ),
      title: Text(
        title,
        style: ViernesTextStyles.bodyText.copyWith(
          color: ViernesColors.getTextColor(isDark),
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.lg,
        vertical: ViernesSpacing.xs,
      ),
    );
  }
}
