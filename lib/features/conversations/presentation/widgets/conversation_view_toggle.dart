import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../providers/conversation_provider.dart';

/// Conversation View Toggle Widget
///
/// A toggle switch between "All Conversations" and "My Conversations" views.
/// Design matches CustomerViewToggle with custom styling.
///
/// Features:
/// - Smooth animation between states
/// - Glassmorphism design
/// - Clear visual feedback
/// - Filter button on the right
class ConversationViewToggle extends StatelessWidget {
  const ConversationViewToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ConversationProvider>(
      builder: (context, provider, _) {
        final showAllConversations = provider.viewMode == ConversationViewMode.all;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1a1a1a).withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(ViernesSpacing.radius14),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                  : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildOption(
                label: 'All Conversations',
                isSelected: showAllConversations,
                onTap: () => provider.setViewMode(ConversationViewMode.all),
                isDark: isDark,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(ViernesSpacing.radius14 - 1),
                  bottomLeft: Radius.circular(ViernesSpacing.radius14 - 1),
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: isDark
                    ? const Color(0xFF2d2d2d).withValues(alpha: 0.5)
                    : const Color(0xFFe5e7eb).withValues(alpha: 0.5),
              ),
              _buildOption(
                label: 'My Conversations',
                isSelected: !showAllConversations,
                onTap: () => provider.setViewMode(ConversationViewMode.my),
                isDark: isDark,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(ViernesSpacing.radius14 - 1),
                  bottomRight: Radius.circular(ViernesSpacing.radius14 - 1),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required BorderRadius borderRadius,
  }) {
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    ViernesColors.secondary.withValues(alpha: 0.7),
                    ViernesColors.accent.withValues(alpha: 0.7),
                  ],
                )
              : null,
          borderRadius: borderRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: borderRadius,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ViernesSpacing.md,
                vertical: ViernesSpacing.space3,
              ),
              child: Text(
                label,
                style: ViernesTextStyles.buttonSmall.copyWith(
                  color: isSelected
                      ? Colors.black
                      : ViernesColors.getTextColor(isDark),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
