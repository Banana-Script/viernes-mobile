import 'package:flutter/material.dart';
import '../../../../../../core/theme/viernes_colors.dart';

/// Send Button Component
///
/// Animated button that shows loading state during message sending.
class SendButton extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const SendButton({
    super.key,
    this.isLoading = false,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isEnabled
            ? (isDark ? ViernesColors.secondary : ViernesColors.primary)
            : ViernesColors.getTextColor(isDark).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled && !isLoading ? onPressed : null,
          borderRadius: BorderRadius.circular(20),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? ViernesColors.primary : Colors.white,
                    ),
                  )
                : Icon(
                    Icons.send,
                    size: 20,
                    color: isEnabled
                        ? (isDark ? ViernesColors.primary : Colors.white)
                        : ViernesColors.getTextColor(isDark).withValues(alpha: 0.4),
                  ),
          ),
        ),
      ),
    );
  }
}
