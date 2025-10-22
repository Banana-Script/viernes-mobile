/// Centralized application strings
///
/// This class contains all hard-coded strings used throughout the application.
/// Future enhancement: Migrate to full flutter_localizations for multi-language support.
class AppStrings {
  // Private constructor to prevent instantiation
  AppStrings._();

  // Navigation & Headers
  static const String dashboard = 'DASHBOARD';
  static const String profile = 'PERFIL';

  // Settings
  static const String settings = 'Configuración';
  static const String signOut = 'CERRAR SESIÓN';

  // Theme
  static const String lightMode = 'Modo Claro';
  static const String darkMode = 'Modo Oscuro';
  static const String autoMode = 'Automático';
  static const String lightModeDesc = 'Tema claro para usar durante el día';
  static const String darkModeDesc = 'Tema oscuro para reducir la fatiga visual';
  static const String autoModeDesc = 'Sigue la configuración del sistema';

  // Dialogs
  static const String signOutConfirmTitle = 'Cerrar Sesión';
  static const String signOutConfirmMessage = '¿Estás seguro que deseas cerrar sesión?';
  static const String cancel = 'Cancelar';
  static const String confirm = 'SALIR';
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
  static const String themeChangeError = 'Error al cambiar el tema';
  static const String exportSuccess = 'Data exported successfully';
  static const String exportFailed = 'Export failed';

  // Accessibility labels
  static const String exportDataButton = 'Exportar datos';
  static const String signOutButton = 'Cerrar sesión';
  static const String themeSelectorPrefix = 'Selector de tema: ';
  static const String selected = 'Seleccionado';
  static const String notSelected = 'No seleccionado';
}
