import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Demo page showcasing all Viernes branding elements
/// This demonstrates the exact match to the web app's design system
class ViernesThemeDemoPage extends StatelessWidget {
  const ViernesThemeDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Viernes Theme Demo',
          style: AppTheme.headingBold.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Brand Logo Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.viernesGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.viernesGray.withValues(alpha:0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'VIERNES',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: 36,
                      letterSpacing: 3.0,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI-Powered Business Solutions',
                    style: AppTheme.buttonText.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha:0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Colors Section
            Text(
              'Brand Colors',
              style: AppTheme.headingBold.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _ColorGrid(),
            const SizedBox(height: 24),

            // Buttons Section
            Text(
              'Button Styles',
              style: AppTheme.headingBold.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _ButtonsDemo(),
            const SizedBox(height: 24),

            // Typography Section
            Text(
              'Typography (Nunito)',
              style: AppTheme.headingBold.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _TypographyDemo(),
            const SizedBox(height: 24),

            // Cards Section
            Text(
              'Card Styles',
              style: AppTheme.headingBold.copyWith(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _CardsDemo(),
          ],
        ),
      ),
    );
  }
}

class _ColorGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _ColorCard('Primary', AppTheme.primary, '#374151'),
        _ColorCard('Secondary', AppTheme.secondary, '#FFE61B'),
        _ColorCard('Accent', AppTheme.accent, '#51F5F8'),
        _ColorCard('Success', AppTheme.success, '#16A34A'),
        _ColorCard('Warning', AppTheme.warning, '#E2A03F'),
        _ColorCard('Danger', AppTheme.danger, '#E7515A'),
      ],
    );
  }
}

class _ColorCard extends StatelessWidget {
  final String name;
  final Color color;
  final String hex;

  const _ColorCard(this.name, this.color, this.hex);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha:0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: AppTheme.bodyMedium.copyWith(
                fontSize: 12,
                color: _getTextColor(color),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              hex,
              style: AppTheme.bodyRegular.copyWith(
                fontSize: 10,
                color: _getTextColor(color).withValues(alpha:0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    // Simple contrast calculation
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

class _ButtonsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Viernes Gradient Button
        ViernesGradientButton(
          text: 'Viernes Gradient Button',
          onPressed: () {},
          height: 50,
        ),
        const SizedBox(height: 16),

        // Regular Elevated Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {},
            child: Text('Primary Button'),
          ),
        ),
        const SizedBox(height: 16),

        // Outlined Button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: () {},
            child: Text('Outlined Button'),
          ),
        ),
        const SizedBox(height: 16),

        // Text Button
        TextButton(
          onPressed: () {},
          child: Text(
            'Text Button',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.viernesYellow,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypographyDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Theme.of(context).viernesCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Heading Bold - 24px',
            style: AppTheme.headingBold.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            'Body Medium - 16px',
            style: AppTheme.bodyMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Body Regular - 14px',
            style: AppTheme.bodyRegular.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            'Button Text - 14px Bold',
            style: AppTheme.buttonText.copyWith(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardsDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Standard Viernes Card
        Container(
          decoration: Theme.of(context).viernesCard,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.trending_up,
                      color: AppTheme.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sample Metric',
                          style: AppTheme.bodyMedium.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '↗ 23.5% from last month',
                          style: AppTheme.bodyRegular.copyWith(
                            fontSize: 12,
                            color: AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '1,234',
                    style: AppTheme.headingBold.copyWith(
                      fontSize: 20,
                      color: AppTheme.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Another card style
        Container(
          decoration: Theme.of(context).viernesCard,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.viernesYellow,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Viernes Theme Implementation',
                      style: AppTheme.bodyMedium.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Exact match to web app branding with Nunito font and gradient styling',
                      style: AppTheme.bodyRegular.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}