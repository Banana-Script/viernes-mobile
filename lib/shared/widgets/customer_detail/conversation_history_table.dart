import 'package:flutter/material.dart';
import '../../../core/theme/viernes_colors.dart';
import '../../../core/theme/viernes_text_styles.dart';
import '../../../core/theme/viernes_spacing.dart';
import '../../../core/utils/timezone_utils.dart';
import '../../../features/customers/domain/entities/conversation_entity.dart';
import '../../../gen_l10n/app_localizations.dart';
import '../viernes_glassmorphism_card.dart';
import 'section_header.dart';
import 'insight_badge.dart';

/// Conversation History Table Widget
///
/// Mobile-friendly conversation history display using cards instead of DataTable.
/// Shows customer's previous consultations (CHAT and CALL conversations).
///
/// Features:
/// - Card-based layout optimized for mobile
/// - Type indicators (chat/call icons)
/// - Status badges
/// - Agent assignment display
/// - Last activity timestamps
/// - Pull-to-refresh support
/// - Pagination (load more)
/// - Empty state handling
/// - Loading skeleton
///
/// Example:
/// ```dart
/// ConversationHistoryTable(
///   conversations: conversations,
///   isDark: isDark,
///   isLoading: false,
///   hasMorePages: true,
///   onRefresh: () async => await loadConversations(),
///   onLoadMore: () => loadMoreConversations(),
///   onViewConversation: (conversation) => navigateToConversation(conversation),
/// )
/// ```
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
          const SizedBox(height: ViernesSpacing.lg),

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

  /// Build conversations list
  Widget _buildConversationsList(AppLocalizations? l10n, String localeCode) {
    return Column(
      children: [
        // Conversation cards
        ...conversations.map((conversation) => Padding(
            padding: const EdgeInsets.only(bottom: ViernesSpacing.md),
            child: _buildConversationCard(conversation, l10n, localeCode),
          )),

        // Load more button
        if (hasMorePages) ...[
          const SizedBox(height: ViernesSpacing.sm),
          _buildLoadMoreButton(l10n),
        ],

        // Loading indicator for load more
        if (isLoading && conversations.isNotEmpty) ...[
          const SizedBox(height: ViernesSpacing.md),
          Center(
            child: SizedBox(
              width: 24,
              height: 24,
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

  /// Build individual conversation card
  Widget _buildConversationCard(ConversationEntity conversation, AppLocalizations? l10n, String localeCode) {
    return Container(
      decoration: BoxDecoration(
        color: (isDark ? ViernesColors.panelDark : ViernesColors.panelLight)
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
        border: Border.all(
          color: (isDark ? ViernesColors.primaryLight : ViernesColors.primaryLight)
              .withValues(alpha: 0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onViewConversation?.call(conversation),
          borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(ViernesSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Type Icon + Date
                Row(
                  children: [
                    // Type icon
                    _buildTypeIcon(conversation.type),
                    const SizedBox(width: ViernesSpacing.sm),

                    // Date
                    Expanded(
                      child: Text(
                        _formatDate(conversation.createdAt, localeCode),
                        style: ViernesTextStyles.bodyText.copyWith(
                          color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // View button
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                          .withValues(alpha: 0.4),
                    ),
                  ],
                ),

                const SizedBox(height: ViernesSpacing.sm),

                // Agent
                if (conversation.agent != null)
                  _buildInfoRow(
                    l10n?.agent ?? 'Agent',
                    conversation.agent!.fullname,
                  ),

                const SizedBox(height: ViernesSpacing.xs),

                // Status
                if (conversation.status != null)
                  Row(
                    children: [
                      Text(
                        l10n?.statusLabel ?? 'Status: ',
                        style: ViernesTextStyles.labelSmall.copyWith(
                          color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      InsightBadge(
                        text: conversation.status!.description,
                        isDark: isDark,
                        color: _getStatusColor(conversation.status!.description),
                      ),
                    ],
                  ),

                const SizedBox(height: ViernesSpacing.xs),

                // Last activity
                _buildInfoRow(
                  l10n?.lastActivity ?? 'Last activity',
                  _formatRelativeTime(conversation.updatedAt, l10n, localeCode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build type icon
  Widget _buildTypeIcon(ConversationType type) {
    final IconData icon;
    final Color color;

    if (type == ConversationType.call) {
      icon = Icons.phone_rounded;
      color = ViernesColors.success;
    } else {
      icon = Icons.chat_bubble_rounded;
      color = ViernesColors.info;
    }

    return Container(
      padding: const EdgeInsets.all(ViernesSpacing.xs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusSm),
      ),
      child: Icon(
        icon,
        size: 18,
        color: color,
      ),
    );
  }

  /// Build info row (label + value)
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: ViernesTextStyles.labelSmall.copyWith(
            color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                .withValues(alpha: 0.6),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: ViernesTextStyles.labelSmall.copyWith(
              color: isDark ? ViernesColors.textDark : ViernesColors.textLight,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Build load more button
  Widget _buildLoadMoreButton(AppLocalizations? l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onLoadMore,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: ViernesSpacing.md),
          side: BorderSide(
            color: (isDark ? ViernesColors.accent : ViernesColors.primary)
                .withValues(alpha: 0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
          ),
        ),
        child: Text(
          l10n?.loadMore ?? 'Load More',
          style: ViernesTextStyles.label.copyWith(
            color: isDark ? ViernesColors.accent : ViernesColors.primary,
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState(AppLocalizations? l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ViernesSpacing.xl),
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              size: 64,
              color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: ViernesSpacing.md),
            Text(
              l10n?.noConversationsYet ?? 'No conversations yet',
              style: ViernesTextStyles.bodyLarge.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: ViernesSpacing.sm),
            Text(
              l10n?.conversationHistoryWillAppear ?? 'Conversation history will appear here',
              style: ViernesTextStyles.bodySmall.copyWith(
                color: (isDark ? ViernesColors.textDark : ViernesColors.textLight)
                    .withValues(alpha: 0.4),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading skeleton
  Widget _buildLoadingSkeleton() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: ViernesSpacing.md),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: (isDark ? ViernesColors.panelDark : ViernesColors.panelLight)
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(ViernesSpacing.radiusMd),
            ),
          ),
        );
      }),
    );
  }

  /// Get status color
  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('resolved') || statusLower.contains('closed')) {
      return ViernesColors.success;
    } else if (statusLower.contains('pending') || statusLower.contains('open')) {
      return ViernesColors.warning;
    } else if (statusLower.contains('active') || statusLower.contains('in progress')) {
      return ViernesColors.info;
    }
    return ViernesColors.primary;
  }

  /// Format date to readable string (locale-aware, timezone-aware)
  String _formatDate(DateTime date, String localeCode) {
    return TimezoneUtils.formatFullDate(date, timezone, localeCode);
  }

  /// Format relative time (locale-aware, timezone-aware)
  String _formatRelativeTime(DateTime date, AppLocalizations? l10n, String localeCode) {
    return TimezoneUtils.formatRelativeTime(date, timezone, localeCode, l10n);
  }
}
