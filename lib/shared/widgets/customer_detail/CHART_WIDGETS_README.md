# Customer Detail Chart Widgets

This directory contains reusable chart and visualization widgets for the customer detail page refactor.

## Overview

Three new standalone widgets have been created to display customer analytics and insights:

1. **PurchaseIntentionChart** - Donut chart showing High/Medium/Low distribution
2. **NPSVisualization** - Net Promoter Score with gradient scale
3. **MainInterestPanel** - Main interest badge, other topics, and NPS combined

## Dependencies

All widgets use the `fl_chart` package for chart rendering:

```yaml
dependencies:
  fl_chart: ^0.68.0  # Already added to pubspec.yaml
```

## Widget Documentation

### 1. Purchase Intention Chart

**File:** `/Users/ianmoone/Development/Banana/viernes_mobile/lib/shared/widgets/customer_detail/purchase_intention_chart.dart`

**Purpose:** Displays a donut chart showing purchase intention distribution with current value.

**Features:**
- Donut chart visualization with fl_chart
- Responsive sizing (adapts to mobile/tablet)
- Color-coded segments (Green/Yellow/Red)
- Legend with color indicators
- Large center text showing current intention
- Supports dark/light themes
- Parses multilingual insight data

**Usage:**

```dart
import 'package:viernes_mobile/shared/widgets/customer_detail/purchase_intention_chart.dart';

// Basic usage with mock data
PurchaseIntentionChart(
  currentIntention: '{"en": "High", "es": "Alta"}',
  isDark: false,
)

// With custom distribution data
PurchaseIntentionChart(
  currentIntention: '{"en": "High", "es": "Alta"}',
  distribution: {
    'high': 70.0,
    'medium': 20.0,
    'low': 10.0,
  },
  isDark: false,
  languageCode: 'en',
  size: 200,
)
```

**Parameters:**
- `currentIntention` (String?) - Current purchase intention value (JSON or plain text)
- `distribution` (Map<String, double>?) - Distribution data, defaults to mock data
- `isDark` (bool) - Dark mode flag (required)
- `languageCode` (String) - Language code for parsing, defaults to 'en'
- `size` (double) - Chart diameter, defaults to 200

**Layout:**
```
┌─────────────────────────┐
│      ╱───────╲         │
│     ╱   70%   ╲        │
│    │    High   │       │  ← Donut Chart
│     ╲   20%   ╱        │
│      ╲───────╱         │
│                         │
│        High             │  ← Current Value
│  Current Intention      │
│                         │
│  ● High  ● Med  ● Low  │  ← Legend
└─────────────────────────┘
```

---

### 2. NPS Visualization

**File:** `/Users/ianmoone/Development/Banana/viernes_mobile/lib/shared/widgets/customer_detail/nps_visualization.dart`

**Purpose:** Displays Net Promoter Score with visual gradient scale.

**Features:**
- Large number display (1-10 scale)
- Visual gradient scale (red → yellow → green)
- Category labels: Detractors (1-6), Passive (7-8), Promoters (9-10)
- Color-coded based on score
- Responsive sizing
- Multilingual support
- Dark/light theme support
- Accessibility labels

**Usage:**

```dart
import 'package:viernes_mobile/shared/widgets/customer_detail/nps_visualization.dart';

// Basic usage
NPSVisualization(
  npsValue: '{"en": "8", "es": "8"}',
  isDark: false,
)

// With custom options
NPSVisualization(
  npsValue: '8',
  isDark: false,
  languageCode: 'en',
  showLabels: true,
  showScaleNumbers: true,
)
```

**Parameters:**
- `npsValue` (String?) - NPS value 1-10 (JSON or plain text)
- `isDark` (bool) - Dark mode flag (required)
- `languageCode` (String) - Language code for parsing, defaults to 'en'
- `showLabels` (bool) - Show category labels, defaults to true
- `showScaleNumbers` (bool) - Show 1-10 scale numbers, defaults to true

**Layout:**
```
┌─────────────────────────┐
│         8               │  ← Large Number
│                         │
│ Detractors  Passive  Promoters
│ ▓▓▓▓▓▓▓▓▓▓▓▓░░░░░░░    │  ← Gradient Bar
│ 1    3    5    7    10  │  ← Scale Numbers
└─────────────────────────┘
```

**Color Mapping:**
- 9-10: Green (Promoters) - ViernesColors.success
- 7-8: Yellow (Passive) - ViernesColors.warning
- 1-6: Red (Detractors) - ViernesColors.danger

---

### 3. Main Interest Panel

**File:** `/Users/ianmoone/Development/Banana/viernes_mobile/lib/shared/widgets/customer_detail/main_interest_panel.dart`

**Purpose:** Combines main interest, other topics, and NPS visualization in one panel.

**Features:**
- Large prominent main interest badge
- Multiple smaller badges for other topics
- Integrated NPS visualization
- Parses multilingual insight data
- Handles comma-separated lists
- Responsive layout
- Dark/light theme support

**Usage:**

```dart
import 'package:viernes_mobile/shared/widgets/customer_detail/main_interest_panel.dart';

// Full panel with all sections
MainInterestPanel(
  mainInterest: '{"en": "Payment Methods", "es": "Métodos de Pago"}',
  otherTopics: '{"en": "Returns, Shipping, Tracking"}',
  npsValue: '{"en": "8"}',
  isDark: false,
  languageCode: 'en',
)

// Partial data (sections auto-hide if missing)
MainInterestPanel(
  mainInterest: 'Technology',
  otherTopics: 'AI, Cloud, Security',
  isDark: false,
)
```

**Parameters:**
- `mainInterest` (String?) - Main interest value (JSON or plain text)
- `otherTopics` (String?) - Comma-separated list of topics (JSON or plain text)
- `npsValue` (String?) - NPS value 1-10 (JSON or plain text)
- `isDark` (bool) - Dark mode flag (required)
- `languageCode` (String) - Language code for parsing, defaults to 'en'
- `showNPSDivider` (bool) - Show divider before NPS, defaults to true

**Layout:**
```
┌─────────────────────────┐
│  ┏━━━━━━━━━━━━━━━┓     │
│  ┃ PAYMENT METHODS┃     │  ← Main Interest
│  ┗━━━━━━━━━━━━━━━┛     │
│                         │
│ Other Topics in Mind    │
│ [Returns] [Shipping]    │  ← Other Topics
│ [Tracking]              │
│                         │
│ ─────────────────────   │  ← Divider
│                         │
│ Net Promoter Score      │
│ [NPS Widget]            │  ← NPS Section
└─────────────────────────┘
```

---

## Integration Example

Here's how to integrate these widgets into a customer detail page:

```dart
import 'package:flutter/material.dart';
import 'package:viernes_mobile/shared/widgets/customer_detail/purchase_intention_chart.dart';
import 'package:viernes_mobile/shared/widgets/customer_detail/nps_visualization.dart';
import 'package:viernes_mobile/shared/widgets/customer_detail/main_interest_panel.dart';
import 'package:viernes_mobile/shared/widgets/viernes_glassmorphism_card.dart';
import 'package:viernes_mobile/core/theme/viernes_spacing.dart';

class CustomerDetailAnalysisTab extends StatelessWidget {
  final CustomerEntity customer;
  final bool isDark;

  const CustomerDetailAnalysisTab({
    super.key,
    required this.customer,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ViernesSpacing.md),
      child: Column(
        children: [
          // Purchase Intention Chart Section
          ViernesGlassmorphismCard(
            borderRadius: ViernesSpacing.radius14,
            padding: const EdgeInsets.all(ViernesSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  icon: Icons.shopping_bag_rounded,
                  title: 'Purchase Intention',
                  isDark: isDark,
                ),
                const SizedBox(height: ViernesSpacing.md),
                PurchaseIntentionChart(
                  currentIntention: _getInsightValue('purchase_intention'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: ViernesSpacing.md),

          // Main Interest & NPS Section
          ViernesGlassmorphismCard(
            borderRadius: ViernesSpacing.radius14,
            padding: const EdgeInsets.all(ViernesSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  icon: Icons.interests_rounded,
                  title: 'Interests & Feedback',
                  isDark: isDark,
                ),
                const SizedBox(height: ViernesSpacing.md),
                MainInterestPanel(
                  mainInterest: _getInsightValue('main_interest'),
                  otherTopics: _getInsightValue('other_topics'),
                  npsValue: _getInsightValue('nps'),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInsightValue(String feature) {
    try {
      final insight = customer.insightsInfo.firstWhere(
        (i) => i.feature == feature,
      );
      return insight.value ?? '';
    } catch (e) {
      return '';
    }
  }
}
```

---

## Styling & Theming

All widgets use the Viernes design system:

### Colors

```dart
// Semantic colors (from ViernesColors)
ViernesColors.success   // Green - High/Promoters
ViernesColors.warning   // Yellow/Orange - Medium/Passive
ViernesColors.danger    // Red - Low/Detractors
ViernesColors.info      // Blue - Other topics
ViernesColors.accent    // Cyan - Interactive elements
```

### Text Styles

```dart
// From ViernesTextStyles
ViernesTextStyles.h1        // Large numbers (NPS)
ViernesTextStyles.h3        // Current values
ViernesTextStyles.h6        // Section headers
ViernesTextStyles.bodyText  // Body content
ViernesTextStyles.labelSmall // Labels & legend
```

### Spacing

```dart
// From ViernesSpacing
ViernesSpacing.xs    // 4px
ViernesSpacing.sm    // 8px
ViernesSpacing.md    // 16px
ViernesSpacing.lg    // 24px
ViernesSpacing.xl    // 32px
```

---

## Responsive Behavior

### Mobile (< 768px)
- Chart size: 200px diameter
- Single column layout
- Full width components

### Tablet (≥ 768px)
- Chart size: 240px diameter (20% larger)
- Wider card layouts
- More spacing

---

## Accessibility

All widgets include:

1. **Semantic Labels**
   - Screen reader support for charts
   - Descriptive labels for all elements

2. **Color Contrast**
   - WCAG 2.1 AA compliant
   - High contrast in both themes

3. **Touch Targets**
   - Minimum 44x44 touch targets
   - Appropriate spacing

---

## Data Parsing

All widgets support multilingual JSON insight data:

**Input Format:**
```json
{
  "en": "High purchase intention",
  "es": "Alta intención de compra"
}
```

**Parsing:**
- Uses `InsightParser.parse()` utility
- Supports `languageCode` parameter
- Fallback to English → Spanish → first available
- Handles plain text (non-JSON) gracefully

**Supported Formats:**
```dart
// JSON multilingual
'{"en": "High", "es": "Alta"}'

// Plain text
'High'

// Number
'8'
```

---

## Testing

### Widget Tests

```dart
testWidgets('PurchaseIntentionChart displays correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PurchaseIntentionChart(
          currentIntention: 'High',
          distribution: {'high': 70, 'medium': 20, 'low': 10},
          isDark: false,
        ),
      ),
    ),
  );

  expect(find.text('High'), findsOneWidget);
  expect(find.text('70%'), findsOneWidget);
});
```

---

## Dark Mode Support

All widgets automatically adapt to dark mode:

```dart
// Light mode
PurchaseIntentionChart(
  currentIntention: 'High',
  isDark: false,  // Light theme colors
)

// Dark mode
PurchaseIntentionChart(
  currentIntention: 'High',
  isDark: true,   // Dark theme colors
)
```

**Dark Mode Changes:**
- Text colors adjust (textDark vs textLight)
- Background opacity changes
- Chart elements maintain visibility
- Gradient adjustments for contrast

---

## Performance Considerations

1. **Chart Rendering**
   - fl_chart uses Canvas for smooth rendering
   - No WebView overhead
   - 60 FPS animations

2. **Widget Rebuilds**
   - Use `const` constructors where possible
   - Minimize unnecessary rebuilds
   - Efficient data parsing

3. **Memory**
   - Lightweight widgets
   - No heavy dependencies
   - Efficient chart rendering

---

## Troubleshooting

### Chart not displaying
- Check if `fl_chart` is installed: `flutter pub get`
- Verify data format is correct
- Check for null/empty values

### Colors not matching design
- Ensure using ViernesColors constants
- Check isDark parameter is correct
- Verify theme is properly configured

### Text overflow
- Charts are responsive by default
- Use Expanded/Flexible where needed
- Test on different screen sizes

---

## Future Enhancements

Potential improvements for future iterations:

1. **Interactive Charts**
   - Tap to highlight segments
   - Show detailed tooltips
   - Expand/collapse animations

2. **More Chart Types**
   - Bar charts for comparisons
   - Line charts for trends
   - Radar charts for profiles

3. **Export Functionality**
   - Share chart images
   - Export to PDF
   - Download data

4. **Animations**
   - Entry animations
   - Value change transitions
   - Smooth updates

---

## Related Files

- `/lib/core/theme/viernes_colors.dart` - Color system
- `/lib/core/theme/viernes_text_styles.dart` - Typography
- `/lib/core/theme/viernes_spacing.dart` - Spacing system
- `/lib/core/utils/insight_parser.dart` - Data parsing utility
- `/lib/shared/widgets/customer_detail/insight_badge.dart` - Badge component
- `/lib/shared/widgets/customer_detail/section_header.dart` - Header component

---

## Authors

Created as part of the Customer Detail Page Refactor
- Agent 2: Charts & Visualizations
- Date: 2025-11-02
- Version: 1.0.0

---

## License

Part of the Viernes Mobile project.
