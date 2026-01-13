import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/viernes_colors.dart';
import '../../../../core/theme/viernes_text_styles.dart';
import '../../../../core/theme/viernes_spacing.dart';
import '../../../../gen_l10n/app_localizations.dart';
import '../providers/customer_provider.dart';

/// Customer View Toggle Widget
///
/// A toggle switch between "All Customers" and "My Customers" views.
/// Design inspired by ViernesAvailabilityToggle with custom styling.
///
/// Features:
/// - Smooth animation between states
/// - Glassmorphism design
/// - Clear visual feedback
class CustomerViewToggle extends StatelessWidget {
  const CustomerViewToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Consumer<CustomerProvider>(
      builder: (context, provider, _) {
        final showAllCustomers = !provider.showMyCustomersOnly;

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
                label: l10n?.allCustomers ?? 'All Customers',
                isSelected: showAllCustomers,
                onTap: () => provider.toggleMyCustomers(false),
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
                label: l10n?.myCustomers ?? 'My Customers',
                isSelected: !showAllCustomers,
                onTap: () => provider.toggleMyCustomers(true),
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
