import 'package:flutter/material.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../shared/widgets/viernes_card.dart';

class ConversationsPage extends StatelessWidget {
  const ConversationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: ViernesColors.getControlBackground(isDark),
      appBar: AppBar(
        title: Text(
          'Conversations',
          style: ViernesTextStyles.h3.copyWith(
            color: ViernesColors.getTextColor(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: ViernesColors.getControlBackground(isDark),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: ViernesSpacing.screenPadding,
        child: Column(
          children: [
            ViernesSpacing.spaceXl,
            ViernesCard.filled(
              backgroundColor: isDark
                  ? ViernesColors.secondary.withValues(alpha: 0.1)
                  : ViernesColors.primary.withValues(alpha: 0.05),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: ViernesColors.viernesGradient,
                      borderRadius: BorderRadius.circular(ViernesSpacing.radiusFull),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  ViernesSpacing.spaceLg,
                  Text(
                    'Conversations',
                    style: ViernesTextStyles.h2.copyWith(
                      color: isDark ? Colors.white : ViernesColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ViernesSpacing.spaceXs,
                  Text(
                    'Manage your customer conversations',
                    style: ViernesTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.7)
                          : ViernesColors.primary.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            ViernesSpacing.spaceXxl,
            ViernesCard.outlined(
              child: Padding(
                padding: const EdgeInsets.all(ViernesSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      Icons.construction,
                      size: 64,
                      color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
                    ),
                    ViernesSpacing.spaceMd,
                    Text(
                      'Coming Soon',
                      style: ViernesTextStyles.h3.copyWith(
                        color: ViernesColors.getTextColor(isDark),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ViernesSpacing.spaceSm,
                    Text(
                      'The conversations feature is under development and will be available soon.',
                      style: ViernesTextStyles.bodyText.copyWith(
                        color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}