import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/timezone_utils.dart';
import '../../../features/customers/domain/entities/conversation_entity.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../viernes_glassmorphism_card.dart';
import 'section_header.dart';

/// Conversation History Table Widget
///
/// Compact, elegant conversation history display optimized for mobile.
/// Shows customer's previous consultations (CHAT and CALL conversations).
///
/// Design principles:
/// - Single-row compact layout (~56px per item) for efficient scanning
/// - Lightweight visual treatment (nested inside parent glassmorphism)
/// - Essential info only: type, status, agent, relative time
/// - Inline status badges to reduce vertical space
/// - Subtle hover/tap feedback with chevron affordance
///
/// Features:
/// - Compact row-based layout optimized for history lists
/// - Type indicators (chat/call icons) with status color coding
/// - Inline status and agent information
/// - Relative timestamps for quick scanning
/// - Pagination (load more)
/// - Empty state handling
/// - Loading skeleton
class ConversationHistoryTable extends StatelessWidget {
  final List<ConversationEntity> conversations;
  final bool isDark;
  final bool isLoading;
  final bool hasMorePages;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final Function(ConversationEntity)? onViewConversation;
  final String timezone;

  const ConversationHistoryTable({
    super.key,
    required this.conversations,
    required this.isDark,
    this.isLoading = false,
    this.hasMorePages = false,
    this.onRefresh,
    this.onLoadMore,
    this.onViewConversation,
    required this.timezone,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return ViernesGlassmorphismCard(
      borderRadius: ViernesSpacing.radius24,
      padding: const EdgeInsets.all(ViernesSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          SectionHeader(
            icon: Icons.history_rounded,
            title: l10n?.conversationHistory ?? 'Conversation History',
            isDark: isDark,
          ),
          const SizedBox(height: ViernesSpacing.md),

          // Content
          if (isLoading && conversations.isEmpty)
            _buildLoadingSkeleton()
          else if (conversations.isEmpty)
            _buildEmptyState(l10n)
          else
            _buildConversationsList(l10n, localeCode),
        ],
      ),
    );
  }

  /// Build conversations list with compact row items
  Widget _buildConversationsList(AppLocalizations? l10n, String localeCode) {
    final textColor = isDark ? ViernesColors.textDark : ViernesColors.textLight;

    return Column(
      children: [
        // Compact conversation rows with subtle separators
        ...conversations.asMap().entries.map((entry) {
          final index = entry.key;
          final conversation = entry.value;
          final isLast = index == conversations.length - 1;

          return Column(
            children: [
              _buildCompactRow(conversation, l10n, localeCode, textColor),
              if (!isLast)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 44),
                  color: textColor.withValues(alpha: 0.08),
                ),
            ],
          );
        }),

        // Load more button
        if (hasMorePages) ...[
          const SizedBox(height: ViernesSpacing.md),
          _buildLoadMoreButton(l10n),
        ],

        // Loading indicator for load more
        if (isLoading && conversations.isNotEmpty) ...[
          const SizedBox(height: ViernesSpacing.sm),
          Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? ViernesColors.accent : ViernesColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build compact single-row conversation item
  /// Height target: ~56px for efficient vertical scanning
  Widget _buildCompactRow(
    ConversationEntity conversation,
    AppLocalizations? l10n,
    String localeCode,
    Color textColor,
  ) {
    final statusColor = conversation.status != null
        ? _getStatusColor(conversation.status!.description)
        : ViernesColors.primaryLight;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onViewConversation?.call(conversation),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: ViernesSpacing.space3,
            horizontal: ViernesSpacing.xs,
          ),
          child: Row(
            children: [
              // Compact type icon with status color indicator
              _buildCompactIcon(conversation, statusColor),
              const SizedBox(width: ViernesSpacing.space3),

              // Main content: Type, Status badge, Agent
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: Type + inline status badge
                    Row(
                      children: [
                        Text(
                          conversation.type == ConversationType.call
                              ? (l10n?.phoneCallType ?? 'Phone Call')
                              : (l10n?.chatType ?? 'Chat'),
                          style: ViernesTextStyles.label.copyWith(
                            color: textColor,
                            fontSize: 13,
                          ),
                        ),
                        if (conversation.status != null) ...[
                          const SizedBox(width: ViernesSpacing.sm),
                          _buildInlineStatusBadge(
                            conversation.status!.description,
                            statusColor,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Row 2: Agent info
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 11,
                          color: textColor.withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            conversation.agent?.fullname ?? (l10n?.appName ?? 'Viernes'),
                            style: ViernesTextStyles.bodySmall.copyWith(
                              color: textColor.withValues(alpha: 0.55),
                              fontSize: 11,
                              fontStyle: conversation.agent == null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right side: Relative time + chevron
              const SizedBox(width: ViernesSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatRelativeTime(conversation.updatedAt, l10n, localeCode),
                    style: ViernesTextStyles.bodySmall.copyWith(
                      color: textColor.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: ViernesSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: textColor.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build compact icon with status color ring
  Widget _buildCompactIcon(ConversationEntity conversation, Color statusColor) {
    final IconData icon = conversation.type == ConversationType.call
        ? Icons.phone_rounded
        : Icons.chat_bubble_rounded;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ViernesColors.secondary.withValues(alpha: 0.85),
            ViernesColors.accent.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Build inline status badge (compact pill style)
  Widget _buildInlineStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: ViernesTextStyles.helper.copyWith(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Build load more button (compact style)
  Widget _buildLoadMoreButton(AppLocalizations? l10n) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: isLoading ? null : onLoadMore,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.sm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: isDark ? ViernesColors.accent : ViernesColors.primary,
            ),
            const SizedBox(width: ViernesSpacing.xs),
            Text(
              l10n?.loadMore ?? 'Load More',
              style: ViernesTextStyles.labelSmall.copyWith(
                color: isDark ? ViernesColors.accent : ViernesColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state (compact version)
  Widget _buildEmptyState(AppLocalizations? l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: ViernesSpacing.lg,
          horizontal: ViernesSpacing.md,
        ),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 40,
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.25),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              l10n?.noConversationsYet ?? 'No conversations yet',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading skeleton (compact version)
  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.sm),
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDark ? ViernesColors.panelDark : ViernesColors.panelLight)
                      .withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: ViernesSpacing.space3),
              // Content placeholder
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: (isDark ? ViernesColors.panelDark : ViernesColors.panelLight)
                            .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 10,
                      width: 80,
                      decoration: BoxDecoration(
                        color: (isDark ? ViernesColors.panelDark : ViernesColors.panelLight)
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              // Time placeholder
              Container(
                height: 10,
                width: 30,
                decoration: BoxDecoration(
                  color: (isDark ? ViernesColors.panelDark : ViernesColors.panelLight)
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Get status color based on status text
  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('resolved') || statusLower.contains('closed')) {
      return ViernesColors.success;
    } else if (statusLower.contains('pending') || statusLower.contains('open')) {
      return ViernesColors.warning;
    } else if (statusLower.contains('active') || statusLower.contains('in progress')) {
      return ViernesColors.info;
    }
    return ViernesColors.primaryLight;
  }

  /// Format relative time (locale-aware, timezone-aware)
  String _formatRelativeTime(DateTime date, AppLocalizations? l10n, String localeCode) {
    return TimezoneUtils.formatRelativeTime(date, timezone, localeCode, l10n);
  }
}
