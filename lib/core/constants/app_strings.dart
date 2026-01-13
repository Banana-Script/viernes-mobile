/// Centralized application strings
///
/// This class contains all hard-coded strings used throughout the application.
/// Future enhancement: Migrate to full flutter_localizations for multi-language support.
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // Navigation & Headers
  static const String dashboard = 'DASHBOARD';
  static const String profile = 'PROFILE';

  // Settings
  static const String settings = 'Settings';
  static const String notifications = 'Notifications';
  static const String appearance = 'Appearance';
  static const String signOut = 'SIGN OUT';

  // Theme
  static const String lightMode = 'Light Mode';
  static const String darkMode = 'Dark Mode';
  static const String autoMode = 'Automatic';
  static const String lightModeDesc = 'Light theme for daytime use';
  static const String darkModeDesc = 'Dark theme to reduce eye strain';
  static const String autoModeDesc = 'Follows system settings';

  // Dialogs
  static const String signOutConfirmTitle = 'Sign Out';
  static const String signOutConfirmMessage = 'Are you sure you want to sign out?';
  static const String cancel = 'Cancel';
  static const String confirm = 'CONFIRM';
  static const String exportDataTitle = 'Export Data';
  static const String exportDataMessage = 'Export conversation statistics as CSV?';
  static const String export = 'EXPORT';

  // Tabs
  static const String overview = 'Overview';
  static const String analytics = 'Analytics';
  static const String insights = 'Insights';

  // Stats
  static const String totalInteractions = 'Total Interactions';
  static const String uniqueAttendees = 'Unique Attendees';
  static const String aiConversations = 'AI Conversations';
  static const String humanAssisted = 'Human Assisted';
  static const String thisMonth = 'This month';
  static const String activeUsers = 'Active users';
  static const String conversations = 'conversations';
  static const String topAdvisors = 'Top Advisors';

  // User Status
  static const String emailVerified = 'Email Verified';
  static const String emailNotVerified = 'Email Not Verified';

  // Errors
  static const String failedToLoadDashboard = 'Failed to load dashboard';
  static const String unexpectedError = 'An unexpected error occurred';
  static const String retry = 'RETRY';
  static const String noAdvisorData = 'No advisor data available';
  static const String themeChangeError = 'Error changing theme';
  static const String exportSuccess = 'Data exported successfully';
  static const String exportFailed = 'Export failed';

  // Accessibility labels
  static const String exportDataButton = 'Export data';
  static const String signOutButton = 'Sign out';
  static const String themeSelectorPrefix = 'Theme selector: ';
  static const String selected = 'Selected';
  static const String notSelected = 'Not selected';
}
