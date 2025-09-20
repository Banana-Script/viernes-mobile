import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Custom loading widget with Viernes branding for authentication screens
class AuthLoadingWidget extends StatefulWidget {
  final String? message;
  final double size;
  final bool showMessage;

  const AuthLoadingWidget({
    super.key,
    this.message,
    this.size = 24.0,
    this.showMessage = true,
  });

  @override
  State<AuthLoadingWidget> createState() => _AuthLoadingWidgetState();
}

class _AuthLoadingWidgetState extends State<AuthLoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Viernes-themed loading indicator
        AnimatedBuilder(
          animation: _rotationController,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * 3.14159,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        gradient: AppTheme.viernesGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.viernesGray.withValues(alpha:0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.hourglass_empty,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),

        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.message!,
            style: AppTheme.bodyRegular.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// Viernes-branded circular progress indicator
class ViernesCircularProgressIndicator extends StatefulWidget {
  final double size;
  final double strokeWidth;

  const ViernesCircularProgressIndicator({
    super.key,
    this.size = 24.0,
    this.strokeWidth = 3.0,
  });

  @override
  State<ViernesCircularProgressIndicator> createState() =>
      _ViernesCircularProgressIndicatorState();
}

class _ViernesCircularProgressIndicatorState
    extends State<ViernesCircularProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ViernesProgressPainter(
              progress: _controller.value,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );
  }
}

class _ViernesProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _ViernesProgressPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const gradient = AppTheme.viernesGradient;

    // Create gradient shader
    final rect = Offset.zero & size;
    final shader = gradient.createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw the arc
    const startAngle = -3.14159 / 2; // Start from top
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Full screen loading overlay for authentication operations
class AuthLoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;

  const AuthLoadingOverlay({
    super.key,
    this.message,
    this.isVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withValues(alpha:0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AuthLoadingWidget(size: 48),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: AppTheme.bodyMedium.copyWith(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Button loading state widget
class AuthButtonLoading extends StatelessWidget {
  final String text;
  final bool isLoading;
  final Color? loadingColor;

  const AuthButtonLoading({
    super.key,
    required this.text,
    this.isLoading = false,
    this.loadingColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                loadingColor ?? Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTheme.buttonText.copyWith(
              fontSize: 14,
              color: loadingColor ?? Colors.white,
            ),
          ),
        ],
      );
    }

    return Text(
      text.toUpperCase(),
      style: AppTheme.buttonText.copyWith(
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    );
  }
}