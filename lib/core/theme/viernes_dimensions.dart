/// Viernes Dimensions Constants
///
/// Centralized dimensional constants for consistent sizing across the app.
/// Includes tab dimensions, chart sizing, visualizations, and component sizes.
///
/// Usage:
/// ```dart
/// Container(
///   height: ViernesDimensions.tabHeight,
///   child: Icon(Icons.home, size: ViernesDimensions.tabIconSize),
/// )
/// ```
class ViernesDimensions {
  // Private constructor to prevent instantiation
  ViernesDimensions._();

  // ==================== TAB DIMENSIONS ====================

  /// Standard tab height
  static const double tabHeight = 56.0;

  /// Tab icon size
  static const double tabIconSize = 22.0;

  /// Spacing between tab icon and label
  static const double tabIconSpacing = 4.0;

  // ==================== CHART DIMENSIONS ====================

  /// Center space ratio for donut charts (0.0 - 1.0)
  /// 0.25 means 25% of chart radius is empty center
  static const double chartCenterSpaceRatio = 0.25;

  /// Section radius ratio for pie/donut chart segments
  /// Controls the thickness of the chart ring
  static const double chartSectionRadiusRatio = 0.15;

  // ==================== NPS VISUALIZATION ====================

  /// Font size for large NPS number display
  static const double npsNumberFontSize = 56.0;

  /// Height of NPS gradient bar
  static const double npsGradientBarHeight = 12.0;

  /// Width of NPS position indicator
  static const double npsIndicatorWidth = 4.0;

  // ==================== AVATAR DIMENSIONS ====================

  /// Standard avatar size (circular)
  static const double avatarSize = 80.0;

  /// Small avatar size
  static const double avatarSizeSmall = 40.0;

  /// Large avatar size
  static const double avatarSizeLarge = 120.0;

  // ==================== BUTTON DIMENSIONS ====================

  /// Standard button height
  static const double buttonHeight = 48.0;

  /// Small button height
  static const double buttonHeightSmall = 36.0;

  /// Large button height
  static const double buttonHeightLarge = 56.0;

  // ==================== ICON SIZES ====================

  /// Small icon size
  static const double iconSizeSmall = 16.0;

  /// Regular icon size
  static const double iconSizeRegular = 24.0;

  /// Large icon size
  static const double iconSizeLarge = 32.0;

  /// Extra large icon size
  static const double iconSizeXLarge = 48.0;

  // ==================== CARD DIMENSIONS ====================

  /// Standard card elevation
  static const double cardElevation = 2.0;

  /// Card elevation on hover/press
  static const double cardElevationHover = 4.0;

  // ==================== LIST ITEM DIMENSIONS ====================

  /// Standard list item height
  static const double listItemHeight = 72.0;

  /// Compact list item height
  static const double listItemHeightCompact = 56.0;

  /// Large list item height
  static const double listItemHeightLarge = 88.0;

  // ==================== DIVIDER DIMENSIONS ====================

  /// Standard divider thickness
  static const double dividerThickness = 1.0;

  /// Thick divider thickness
  static const double dividerThicknessThick = 2.0;

  // ==================== BADGE DIMENSIONS ====================

  /// Badge height
  static const double badgeHeight = 24.0;

  /// Badge padding horizontal
  static const double badgePaddingHorizontal = 12.0;

  // ==================== APP BAR DIMENSIONS ====================

  /// Standard app bar height
  static const double appBarHeight = 56.0;

  /// Large app bar height
  static const double appBarHeightLarge = 64.0;

  // ==================== BOTTOM NAVIGATION ====================

  /// Bottom navigation bar height
  static const double bottomNavHeight = 64.0;

  // ==================== METRIC CARD DIMENSIONS ====================

  /// Metric card aspect ratio (width / height)
  static const double metricCardAspectRatio = 1.3;

  // ==================== CONVERSATION TABLE ====================

  /// Row height for conversation table
  static const double conversationRowHeight = 56.0;
}
