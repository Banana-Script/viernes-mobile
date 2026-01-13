import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../shared/widgets/viernes_glassmorphism_card.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../../domain/entities/customer_entity.dart';

/// Customer Card Widget
///
/// A compact card displaying customer information in a mobile-optimized format.
/// Features:
/// - Avatar with initial
/// - Customer name and contact info
/// - Segment and purchase intention badges
/// - Date information
/// - Tap to view detail
///
/// Design follows Viernes glassmorphism aesthetic with smooth animations.
class CustomerCard extends StatelessWidget {
  final CustomerEntity customer;
  final VoidCallback? onTap;
  final bool isDark;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: ViernesSpacing.sm),
      child: ViernesGlassmorphismCard(
        borderRadius: ViernesSpacing.radiusXxl,
        padding: const EdgeInsets.all(ViernesSpacing.md),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Avatar, Name, and Agent
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with gradient
                _buildAvatar(),
                const SizedBox(width: ViernesSpacing.space3),

                // Name and agent info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer name
                      Text(
                        customer.name,
                        style: ViernesTextStyles.h6.copyWith(
                          color: ViernesColors.getTextColor(isDark),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Pre-assigned agent
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 12,
                            color: ViernesColors.getTextColor(isDark)
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.assignedAgent?.name ?? (l10n?.appName ?? 'Viernes'),
                              style: ViernesTextStyles.bodySmall.copyWith(
                                color: ViernesColors.getTextColor(isDark)
                                    .withValues(alpha: 0.6),
                                fontStyle: customer.assignedAgent == null
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
              ],
            ),

            // Badges row (below name)
            if (customer.segment != null || _getParsedPurchaseIntention() != null) ...[
              const SizedBox(height: ViernesSpacing.sm),
              Wrap(
                spacing: ViernesSpacing.xs,
                runSpacing: ViernesSpacing.xs,
                children: [
                  if (customer.segment != null) _buildSegmentBadge(),
                  if (_getParsedPurchaseIntention() != null) _buildPurchaseIntentionBadge(),
                ],
              ),
            ],

            const SizedBox(height: ViernesSpacing.space3),

            // Divider
            Container(
              height: 1,
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.1),
            ),

            const SizedBox(height: ViernesSpacing.space3),

            // Contact information
            _buildContactInfo(Icons.email_outlined, customer.email),
            const SizedBox(height: ViernesSpacing.xs),
            _buildContactInfo(Icons.phone_outlined, customer.phoneNumber),

            const SizedBox(height: ViernesSpacing.space3),

            // Bottom row: Dates
            Row(
              children: [
                Expanded(
                  child: _buildDateInfo(
                    l10n?.created ?? 'Created',
                    customer.createdAt,
                    l10n,
                    localeCode,
                  ),
                ),
                if (customer.lastInteraction != null) ...[
                  Container(
                    width: 1,
                    height: 20,
                    color: ViernesColors.getTextColor(isDark)
                        .withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: ViernesSpacing.sm),
                  Expanded(
                    child: _buildDateInfo(
                      l10n?.lastContact ?? 'Last Contact',
                      customer.lastInteraction!,
                      l10n,
                      localeCode,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initial = customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?';

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ViernesColors.secondary.withValues(alpha: 0.8),
            ViernesColors.accent.withValues(alpha: 0.8),
          ],
        ),
        shape: BoxShape.circle,
        border: Border.all(
          color: isDark
              ? ViernesColors.accent.withValues(alpha: 0.3)
              : ViernesColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Color _getSegmentColor(String segment) {
    switch (segment.toLowerCase()) {
      case 'vip':
        return const Color(0xFF9333EA); // Purple
      case 'premium':
        return const Color(0xFF0EA5E9); // Blue
      case 'standard':
        return const Color(0xFF16A34A); // Green
      case 'basic':
        return const Color(0xFF64748B); // Gray
      default:
        return const Color(0xFF64748B);
    }
  }

  Widget _buildSegmentBadge() {
    final segment = customer.segment!;
    final color = _getSegmentColor(segment);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        segment.toUpperCase(),
        style: ViernesTextStyles.labelSmall.copyWith(
          color: color,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getPurchaseIntentionColor(String intention) {
    final lowerIntention = intention.toLowerCase();

    // Check for high/alto variants
    if (lowerIntention.contains('high') || lowerIntention.contains('alto')) {
      return const Color(0xFF16A34A); // Green
    }
    // Check for low/bajo variants
    else if (lowerIntention.contains('low') || lowerIntention.contains('bajo')) {
      return const Color(0xFFE7515A); // Red
    }
    // Check for medium/medio variants
    else if (lowerIntention.contains('medium') || lowerIntention.contains('medio')) {
      return const Color(0xFFE2A03F); // Yellow/Orange
    }

    // Default gray for unknown values
    return const Color(0xFF64748B); // Gray
  }

  Widget _buildPurchaseIntentionBadge() {
    final intention = _getParsedPurchaseIntention()!;
    final color = _getPurchaseIntentionColor(intention);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ViernesSpacing.sm,
        vertical: ViernesSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(ViernesSpacing.radiusLg),
        border: Border.all(
          color: color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            intention.toLowerCase().contains('high') || intention.toLowerCase().contains('alto')
                ? Icons.arrow_upward
                : intention.toLowerCase().contains('low') || intention.toLowerCase().contains('bajo')
                    ? Icons.arrow_downward
                    : Icons.remove,
            size: 10,
            color: color,
          ),
          const SizedBox(width: 2),
          Text(
            intention.toUpperCase(),
            style: ViernesTextStyles.labelSmall.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
        ),
        const SizedBox(width: ViernesSpacing.xs),
        Expanded(
          child: Text(
            text,
            style: ViernesTextStyles.bodySmall.copyWith(
              color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String label, DateTime date, AppLocalizations? l10n, String localeCode) {
    final dateStr = _formatDate(date, l10n, localeCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ViernesTextStyles.helper.copyWith(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          dateStr,
          style: ViernesTextStyles.bodySmall.copyWith(
            color: ViernesColors.getTextColor(isDark).withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatDate(DateTime date, AppLocalizations? l10n, String localeCode) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return l10n?.minutesAgo(difference.inMinutes) ?? '${difference.inMinutes}m ago';
      }
      return l10n?.hoursAgo(difference.inHours) ?? '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return l10n?.yesterdayTime ?? 'Yesterday';
    } else if (difference.inDays < 7) {
      return l10n?.daysAgo(difference.inDays) ?? '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return l10n?.weeksAgo(weeks) ?? '${weeks}w ago';
    } else {
      return DateFormat.yMMMd(localeCode).format(date);
    }
  }

  /// Parse purchase intention from JSON string or return plain value
  /// Handles formats like: {"es":"MUY ALTO","en":"VERY HIGH"}
  String? _getParsedPurchaseIntention() {
    if (customer.purchaseIntention == null) return null;

    final rawValue = customer.purchaseIntention!;

    // If it starts with '{', try to parse as JSON
    if (rawValue.trim().startsWith('{')) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(rawValue);

        // Try English first (both lowercase and uppercase), then Spanish
        if (jsonMap.containsKey('en') && jsonMap['en'] != null) {
          final value = jsonMap['en'] as String;
          // Skip N/A values
          if (value.toUpperCase() != 'N/A') return value;
        } else if (jsonMap.containsKey('EN') && jsonMap['EN'] != null) {
          final value = jsonMap['EN'] as String;
          if (value.toUpperCase() != 'N/A') return value;
        }

        if (jsonMap.containsKey('es') && jsonMap['es'] != null) {
          final value = jsonMap['es'] as String;
          if (value.toUpperCase() != 'N/A') return value;
        } else if (jsonMap.containsKey('ES') && jsonMap['ES'] != null) {
          final value = jsonMap['ES'] as String;
          if (value.toUpperCase() != 'N/A') return value;
        }

        // If all values are N/A, return null to hide the badge
        return null;
      } catch (e) {
        // If parsing fails, return raw value
        return rawValue;
      }
    }

    // Return as-is if not JSON format
    return rawValue;
  }
}
