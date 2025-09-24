# Viernes AI Design System Documentation

## Overview
This comprehensive design system documentation extracts the complete visual identity and design system from the Viernes frontend project. The design system is built on Tailwind CSS with extensive customization and follows a mobile-first, responsive approach.

## Table of Contents
1. [Brand Identity](#brand-identity)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Spacing System](#spacing-system)
5. [Component Library](#component-library)
6. [Layout System](#layout-system)
7. [Animation & Transitions](#animation--transitions)
8. [Responsive Design](#responsive-design)
9. [Theme System](#theme-system)
10. [Brand Assets](#brand-assets)

---

## Brand Identity

### Core Brand Values
- **Primary Colors**: Dark gray (#374151) representing professionalism and reliability
- **Secondary Colors**: Bright yellow (#FFE61B) representing innovation and energy
- **Accent Colors**: Cyan (#51f5f8) for interactive elements and highlights

### Brand Gradient
```css
.viernes-gradient {
  background: linear-gradient(135deg, #374151 0%, #FFE61B 100%);
}
```

---

## Color System

### Primary Colors
```scss
// Primary (Gray Scale)
$primary: #374151;           // Main dark gray
$primary-light: #9CA3AF;     // Light gray
$primary-dark-light: rgba(55,65,81,.15); // Light overlay

// Secondary (Yellow Scale)
$secondary: #FFE61B;         // Main yellow
$secondary-light: #FFF04D;   // Light yellow
$secondary-dark: #E6CF00;    // Dark yellow

// Accent (Cyan Scale)
$accent: #51f5f8;           // Main cyan
$accent-light: #7df8fc;     // Light cyan
```

### Semantic Colors
```scss
// Status Colors
$success: #16a34a;          // Green
$success-light: #dcfce7;
$success-dark: #15803d;

$danger: #e7515a;           // Red
$danger-light: #fff5f5;

$warning: #e2a03f;          // Orange
$warning-light: #fff9ed;

$info: #2196f3;             // Blue
$info-light: #e7f7ff;
```

### Background Colors
```scss
// Light Theme
$bg-light: #fafafa;         // Page background
$panel-light: #ffffff;      // Panel/card background

// Dark Theme
$bg-dark: #060818;          // Page background
$panel-dark: #000000;       // Panel/card background
```

### Usage Guidelines
- **Primary Gray**: Use for text, borders, and primary UI elements
- **Secondary Yellow**: Use for highlights, CTAs, and brand emphasis
- **Accent Cyan**: Use for interactive states and secondary actions
- **Status Colors**: Use consistently for success, error, warning, and info states

---

## Typography

### Font Family
```css
font-family: 'Nunito', sans-serif;
```

### Typography Scale
```scss
// Headings
$h1: 40px;    // Large titles
$h2: 32px;    // Section headers
$h3: 28px;    // Subsection headers
$h4: 24px;    // Component titles
$h5: 20px;    // Small headers
$h6: 16px;    // Captions

// Body Text
$body-base: 14px;    // Default body text
$body-sm: 12px;      // Small text
$body-lg: 16px;      // Large body text
```

### Font Weights
```scss
$font-normal: 400;
$font-semibold: 600;
$font-bold: 700;
```

### Line Heights
```scss
$leading-tight: 1.25;
$leading-normal: 1.5;
$leading-relaxed: 1.625;
```

### Usage Examples
```css
/* Main headings */
.heading-1 { font-size: 40px; font-weight: 700; line-height: 1.25; }
.heading-2 { font-size: 32px; font-weight: 600; line-height: 1.25; }

/* Body text */
.body-text { font-size: 14px; font-weight: 400; line-height: 1.5; }
.body-small { font-size: 12px; font-weight: 400; line-height: 1.5; }
```

---

## Spacing System

### Base Spacing Scale
```scss
$space-0: 0;
$space-1: 4px;      // 0.25rem
$space-2: 8px;      // 0.5rem
$space-3: 12px;     // 0.75rem
$space-4: 16px;     // 1rem
$space-5: 20px;     // 1.25rem
$space-6: 24px;     // 1.5rem
$space-8: 32px;     // 2rem
$space-10: 40px;    // 2.5rem
$space-12: 48px;    // 3rem
$space-16: 64px;    // 4rem
$space-20: 80px;    // 5rem
```

### Custom Spacing
```scss
$space-4-5: 18px;   // Custom spacing for specific use cases
```

### Border Radius
```scss
$radius-sm: 4px;    // Small radius
$radius-md: 6px;    // Default radius
$radius-lg: 8px;    // Large radius
$radius-xl: 12px;   // Extra large radius
$radius-full: 50%;  // Circular
```

### Shadows
```scss
// Default shadow
$shadow-default: 0 2px 2px rgb(224 230 237 / 46%), 1px 6px 7px rgb(224 230 237 / 46%);

// Button shadows (before hover)
$shadow-primary: 0 10px 20px rgba(55, 65, 81, 0.6);
$shadow-secondary: 0 10px 20px rgba(255, 230, 27, 0.6);
```

---

## Component Library

### Buttons

#### Primary Button
```scss
.btn-primary {
  @apply border-primary bg-primary text-white shadow-primary/60;
  @apply relative flex items-center justify-center rounded-md border px-5 py-2 text-sm font-semibold;
  @apply transition duration-300 hover:shadow-none;
}

// Dark mode override
.dark .btn-primary {
  @apply bg-gray-200 text-black border-gray-200;
}
```

#### Secondary Button
```scss
.btn-secondary {
  @apply border-secondary bg-secondary text-black shadow-secondary/60;
}
```

#### Viernes Gradient Button
```scss
.btn-viernes {
  background: linear-gradient(135deg, #374151 0%, #FFE61B 100%);
  color: white;
  font-weight: bold;
  padding: 12px 24px;
  border-radius: 8px;
  border: none;
  transition: all 0.3s ease;
  text-transform: uppercase;
}

.btn-viernes:hover {
  box-shadow: 0 10px 25px rgba(55, 65, 81, 0.4);
  transform: translateY(-1px);
}
```

#### Button Sizes
```scss
.btn-sm { @apply px-2.5 py-1.5 text-xs; }
.btn { @apply px-5 py-2 text-sm; }        // Default
.btn-lg { @apply px-7 py-2.5 text-base; }
```

### Form Elements

#### Input Fields
```scss
.form-input {
  @apply w-full rounded-md border border-white-light bg-white px-4 py-2 text-sm font-semibold text-black;
  @apply !outline-none focus:border-primary focus:ring-transparent;
  @apply placeholder:text-gray-500;
  @apply dark:border-[#17263c] dark:bg-[#121e32] dark:text-white dark:placeholder:text-gray-400;
}
```

#### Size Variants
```scss
.form-input-sm { @apply py-1.5 text-xs; }
.form-input { @apply py-2 text-sm; }        // Default
.form-input-lg { @apply py-2.5 text-base; }
```

#### Checkboxes & Radio Buttons
```scss
.form-checkbox, .form-radio {
  @apply h-5 w-5 cursor-pointer rounded border-2 border-white-light bg-transparent text-primary;
  @apply !shadow-none !outline-none !ring-0 checked:bg-[length:90%_90%];
  @apply dark:border-[#253b5c] dark:checked:border-transparent;
}

// Custom yellow checkbox
.yellow-checkbox:checked {
  background-color: #ffe61b !important;
  border-color: #ffe61b !important;
}
```

### Cards & Panels

#### Panel Component
```scss
.panel {
  @apply relative rounded-md bg-white p-5 shadow dark:bg-black;
}
```

#### Plan Card (Example)
```scss
.plan-card {
  @apply relative bg-white dark:bg-gray-800 first:rounded-l-lg last:rounded-r-lg;
  @apply border border-gray-200 dark:border-gray-700 border-r-0 last:border-r p-6 flex flex-col;
}

// Popular badge
.plan-card .popular-badge {
  @apply absolute -top-6 left-1/2 transform -translate-x-1/2 w-[calc(100%+1px)];
  @apply bg-[#fee61c] text-black text-sm font-semibold py-2 rounded-md rounded-b-none text-center;
}
```

### Navigation

#### Sidebar Navigation
```scss
.sidebar .nav-item > a {
  @apply mb-1 flex w-full items-center justify-between overflow-hidden whitespace-nowrap rounded-md p-2.5;
  @apply text-[#506690] hover:bg-[#000]/[0.08] hover:text-black;
  @apply dark:hover:bg-[#181f32] dark:hover:text-white-dark;
}

.sidebar .nav-item > a.active {
  @apply bg-[#000]/[0.08] text-black dark:bg-[#FFE61B]/20 dark:text-[#FFE61B];
}
```

### Dropdowns
```scss
.dropdown ul {
  @apply my-1 min-w-[120px] rounded bg-white p-0 py-2 shadow dark:bg-[#1b2e4b];
  @apply text-black dark:text-white-dark;
}

.dropdown ul li > a, .dropdown ul li > button {
  @apply flex items-center px-4 py-2 hover:bg-primary/10 hover:text-primary;
}
```

### Tables
```scss
table {
  @apply w-full !border-collapse;
}

table thead tr, table tfoot tr {
  @apply border-b-0 !bg-[#f6f8fa] dark:!bg-[#1a2941];
}

table tbody tr {
  @apply border-b !border-white-light/40 dark:!border-[#191e3a];
}

table.table-hover tbody tr {
  @apply hover:!bg-white-light/20 dark:hover:!bg-[#1a2941]/40;
}
```

---

## Layout System

### Container
```scss
.container {
  @apply center: true;
}

.boxed-layout {
  @apply mx-auto max-w-[1400px];
}
```

### Sidebar Layouts
```scss
// Main content adjustment for sidebar
.main-container .main-content {
  @apply transition-all duration-300 lg:ltr:ml-[260px] lg:rtl:mr-[260px];
}

// Collapsible sidebar
.collapsible-vertical .sidebar {
  @apply hover:w-[260px] ltr:-left-[260px] rtl:-right-[260px] lg:w-[70px] lg:ltr:left-0 lg:rtl:right-0;
}

.collapsible-vertical .main-content {
  @apply lg:w-[calc(100%-70px)] lg:ltr:ml-[70px] lg:rtl:mr-[70px];
}
```

### Header Layout
```scss
// Sticky header
.navbar-sticky header, .navbar-floating header {
  @apply sticky top-0 z-20;
}

// Floating header
.navbar-floating header {
  @apply bg-[#fafafa]/90 px-6 pt-4 dark:bg-[#060818]/90;
}
```

---

## Animation & Transitions

### Available Animations
```scss
// From theme config
$animations: [
  'animate__fadeIn',
  'animate__fadeInDown',
  'animate__fadeInUp',
  'animate__fadeInLeft',
  'animate__fadeInRight',
  'animate__slideInDown',
  'animate__slideInLeft',
  'animate__slideInRight',
  'animate__zoomIn'
];
```

### Custom Transitions
```scss
// Progress bar animation
@keyframes progress-bar-stripes {
  0% { background-position: 1rem 0; }
  to { background-position: 0 0; }
}

.animated-progress {
  animation: progress-bar-stripes 1s linear infinite;
}

// Slide down animation
.slide-down-enter-active {
  @apply transition duration-100 ease-out;
}

.slide-down-leave-active {
  @apply transition duration-75 ease-in;
}

// Modal fade animation
.modal-fade-enter-active {
  @apply transition duration-300 ease-out;
}

.modal-fade-leave-active {
  @apply transition duration-200 ease-in;
}
```

### Standard Transitions
```scss
// Default transition duration
$transition-default: 300ms;
$transition-fast: 150ms;
$transition-slow: 500ms;

// Easing functions
$ease-out: ease-out;
$ease-in: ease-in;
$ease-in-out: ease-in-out;
```

---

## Responsive Design

### Breakpoint System (Tailwind CSS)
```scss
// Mobile first approach
$screen-sm: 640px;    // Small devices
$screen-md: 768px;    // Medium devices
$screen-lg: 1024px;   // Large devices
$screen-xl: 1280px;   // Extra large devices
$screen-2xl: 1536px;  // 2X large devices
```

### Mobile-First Considerations
- All components designed mobile-first
- Sidebar collapses to overlay on mobile
- Tables become horizontally scrollable
- Form inputs stack vertically on small screens
- Navigation transforms to hamburger menu
- Text sizes scale appropriately

### Responsive Utilities
```scss
// Hide/show based on screen size
.lg:hidden          // Hide on large screens and up
.lg:block           // Show as block on large screens and up
.md:flex            // Show as flex on medium screens and up

// Responsive spacing
.p-4 .lg:p-8        // 4 units padding, 8 units on large screens
.mx-4 .lg:mx-auto   // Margin auto on large screens
```

---

## Theme System

### Light/Dark Mode
```scss
// Base theme configuration
$theme-light: 'light';
$theme-dark: 'dark';
$theme-system: 'system';  // Follows OS preference
```

### Dark Mode Overrides
```scss
// Background adjustments
body.dark {
  @apply bg-[#060818];
}

.dark .panel {
  @apply bg-black;
}

// Text color adjustments
.dark .text-primary {
  @apply text-[#FFE61B];  // Yellow in dark mode
}

// Button adjustments
.dark .btn-primary {
  @apply bg-gray-200 text-black border-gray-200;
}

// Navigation adjustments
.dark .sidebar .nav-item > a.active {
  @apply dark:bg-[#FFE61B]/20 dark:text-[#FFE61B];
}
```

### Theme-Aware Colors Function
```javascript
export const getThemeColors = (isDark: boolean) => ({
  primary: '#374151',
  primaryLight: isDark ? 'rgba(55,65,81,.15)' : '#9CA3AF',
  controlBg: isDark ? '#1b2e4b' : '#ffffff',
  textColor: isDark ? '#e0e6ed' : '#1f2937',
  borderColor: isDark ? '#253e5c' : '#e0e6ed',
});
```

---

## Brand Assets

### Logo Specifications

#### Available Logo Files
- `/assets/images/viernes-logo.png` - Main logo
- `/assets/images/Viernes-negativo.png` - Negative version
- `/assets/images/auth/Viernes-AI-Negativo.png` - Auth page version
- `/assets/images/logo.svg` - SVG version
- `/assets/images/auth/logo-white.svg` - White version for dark backgrounds

#### Logo Usage Guidelines
```scss
.viernes-logo {
  filter: brightness(1);
  transition: filter 0.3s ease;
}

// Responsive logo sizing for collapsible sidebar
.collapsible-vertical .sidebar .main-logo img {
  @apply lg:h-8 lg:w-8 object-contain transition-all duration-300;
}
```

#### Brand Colors in Context
- Logo uses the primary gray (#374151) and secondary yellow (#FFE61B)
- Maintain contrast ratios for accessibility
- Use white/negative version on dark backgrounds

### Icon System
- Custom SVG icons for consistent styling
- Icon components follow React pattern
- Standard sizing: 16px, 20px, 24px
- Color inherits from parent or theme

---

## Implementation Guidelines

### For Flutter Mobile App

#### Color Implementation
```dart
// Define color constants
class ViernesColors {
  // Primary colors
  static const Color primary = Color(0xFF374151);
  static const Color primaryLight = Color(0xFF9CA3AF);

  // Secondary colors
  static const Color secondary = Color(0xFFFFE61B);
  static const Color secondaryLight = Color(0xFFFFF04D);

  // Accent colors
  static const Color accent = Color(0xFF51F5F8);
  static const Color accentLight = Color(0xFF7DF8FC);

  // Status colors
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFE7515A);
  static const Color warning = Color(0xFFE2A03F);
  static const Color info = Color(0xFF2196F3);
}
```

#### Typography Implementation
```dart
class ViernesTextStyles {
  static const String fontFamily = 'Nunito';

  static const TextStyle h1 = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    height: 1.25,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    fontFamily: fontFamily,
  );
}
```

#### Spacing Implementation
```dart
class ViernesSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Custom spacing
  static const double custom = 18.0; // 4.5 equivalent
}
```

#### Theme Implementation
```dart
ThemeData buildViernesTheme({bool isDark = false}) {
  return ThemeData(
    fontFamily: 'Nunito',
    primaryColor: ViernesColors.primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ViernesColors.primary,
      secondary: ViernesColors.secondary,
      brightness: isDark ? Brightness.dark : Brightness.light,
    ),
    // Additional theme configuration...
  );
}
```

### Component Consistency Rules
1. **Buttons**: Always use consistent padding, border radius, and shadow patterns
2. **Forms**: Maintain consistent input styling across all form elements
3. **Cards**: Use standard panel styling with consistent shadows and borders
4. **Navigation**: Follow established patterns for active states and hover effects
5. **Animations**: Use standard transition durations (300ms default)

### Accessibility Considerations
- Maintain WCAG AA contrast ratios
- Use semantic HTML elements
- Provide keyboard navigation
- Include proper ARIA labels
- Test with screen readers
- Support system theme preferences

---

## Conclusion

This design system provides a comprehensive foundation for building the Viernes Mobile app with visual consistency. All measurements, colors, and patterns have been extracted from the production frontend application to ensure perfect alignment with the existing brand identity.

Key principles:
- **Consistency**: Use defined tokens consistently across components
- **Scalability**: Design system supports growth and new components
- **Accessibility**: Built with inclusive design principles
- **Maintainability**: Centralized token system for easy updates
- **Responsive**: Mobile-first approach with responsive considerations

For implementation questions or clarifications, refer to the source files in the Viernes frontend project at `/Users/ianmoone/Development/Banana/viernes-front`.