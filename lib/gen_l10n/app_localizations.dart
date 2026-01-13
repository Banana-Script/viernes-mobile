import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen_l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Viernes'**
  String get appName;

  /// Welcome back message for login
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Sign in prompt message
  ///
  /// In en, this message translates to:
  /// **'Sign in to your Viernes account'**
  String get signInToAccount;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'Enter email address'**
  String get enterEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Divider text between sign in and create account
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Terms and privacy disclaimer
  ///
  /// In en, this message translates to:
  /// **'By signing in, you agree to our Terms of Service and Privacy Policy'**
  String get termsAndPrivacy;

  /// Join message for registration
  ///
  /// In en, this message translates to:
  /// **'Join Viernes'**
  String get joinViernes;

  /// Create account prompt message
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get createAccountToStart;

  /// Password creation hint
  ///
  /// In en, this message translates to:
  /// **'Create a secure password'**
  String get createSecurePassword;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Confirm password field hint
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmYourPassword;

  /// Already have account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// Terms and privacy disclaimer for registration
  ///
  /// In en, this message translates to:
  /// **'By creating an account, you agree to our Terms of Service and Privacy Policy'**
  String get termsAndPrivacyCreate;

  /// Dashboard screen title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Dashboard app bar title
  ///
  /// In en, this message translates to:
  /// **'Viernes Dashboard'**
  String get viernesDashboard;

  /// Welcome message on dashboard
  ///
  /// In en, this message translates to:
  /// **'Welcome to Viernes!'**
  String get welcomeToViernes;

  /// Viernes description
  ///
  /// In en, this message translates to:
  /// **'Your AI-powered business assistant'**
  String get aiBusinessAssistant;

  /// Account information section title
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// User ID field label
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// Email verified status
  ///
  /// In en, this message translates to:
  /// **'Email Verified'**
  String get emailVerified;

  /// Email not verified status
  ///
  /// In en, this message translates to:
  /// **'Email Not Verified'**
  String get emailNotVerified;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Quick actions description
  ///
  /// In en, this message translates to:
  /// **'Explore Viernes features and manage your business with AI assistance.'**
  String get exploreViernes;

  /// Settings button text
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Help button text
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirm;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Valid email validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Password minimum length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Confirm password validation error
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// Password match validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Profile section title
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profile;

  /// Notifications section title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Appearance settings section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Light theme mode
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Dark theme mode
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Automatic theme mode
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get autoMode;

  /// Light mode description
  ///
  /// In en, this message translates to:
  /// **'Light theme for daytime use'**
  String get lightModeDesc;

  /// Dark mode description
  ///
  /// In en, this message translates to:
  /// **'Dark theme to reduce eye strain'**
  String get darkModeDesc;

  /// Auto mode description
  ///
  /// In en, this message translates to:
  /// **'Follows system settings'**
  String get autoModeDesc;

  /// Sign out confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutConfirmTitle;

  /// Sign out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmMessage;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// Export data dialog title
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportDataTitle;

  /// Export data confirmation message
  ///
  /// In en, this message translates to:
  /// **'Export conversation statistics as CSV?'**
  String get exportDataMessage;

  /// Export button text
  ///
  /// In en, this message translates to:
  /// **'EXPORT'**
  String get export;

  /// Overview tab
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Analytics tab
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Insights tab
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Total interactions stat
  ///
  /// In en, this message translates to:
  /// **'Total Interactions'**
  String get totalInteractions;

  /// Unique attendees stat
  ///
  /// In en, this message translates to:
  /// **'Unique Attendees'**
  String get uniqueAttendees;

  /// AI conversations stat
  ///
  /// In en, this message translates to:
  /// **'AI Conversations'**
  String get aiConversations;

  /// Human assisted stat
  ///
  /// In en, this message translates to:
  /// **'Human Assisted'**
  String get humanAssisted;

  /// This month label
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// Active users label
  ///
  /// In en, this message translates to:
  /// **'Active users'**
  String get activeUsers;

  /// Conversations label
  ///
  /// In en, this message translates to:
  /// **'conversations'**
  String get conversations;

  /// Top advisors section
  ///
  /// In en, this message translates to:
  /// **'Top Advisors'**
  String get topAdvisors;

  /// Dashboard load error
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get failedToLoadDashboard;

  /// Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'RETRY'**
  String get retry;

  /// No advisor data message
  ///
  /// In en, this message translates to:
  /// **'No advisor data available'**
  String get noAdvisorData;

  /// Theme change error message
  ///
  /// In en, this message translates to:
  /// **'Error changing theme'**
  String get themeChangeError;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccess;

  /// Export failed message
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// Export data button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportDataButton;

  /// Sign out button accessibility label
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// Theme selector accessibility prefix
  ///
  /// In en, this message translates to:
  /// **'Theme selector: '**
  String get themeSelectorPrefix;

  /// Selected accessibility label
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Not selected accessibility label
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get notSelected;

  /// Used label for consumption chart
  ///
  /// In en, this message translates to:
  /// **'Used'**
  String get used;

  /// Total minutes label
  ///
  /// In en, this message translates to:
  /// **'Total Minutes'**
  String get totalMinutes;

  /// Total messages label
  ///
  /// In en, this message translates to:
  /// **'Total Messages'**
  String get totalMessages;

  /// Consumed minutes label
  ///
  /// In en, this message translates to:
  /// **'Consumed Minutes'**
  String get consumedMinutes;

  /// Consumed messages label
  ///
  /// In en, this message translates to:
  /// **'Consumed Messages'**
  String get consumedMessages;

  /// Remaining label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// Recharged minutes label
  ///
  /// In en, this message translates to:
  /// **'Recharged Minutes'**
  String get rechargedMinutes;

  /// Theme label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Preview label
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// Current theme label
  ///
  /// In en, this message translates to:
  /// **'Current theme'**
  String get currentTheme;

  /// Disabled label
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Active types label for notifications
  ///
  /// In en, this message translates to:
  /// **'active types'**
  String get activeTypes;

  /// Enable notifications option
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// Receive alerts description
  ///
  /// In en, this message translates to:
  /// **'Receive alerts for new messages, assignments, and conversations'**
  String get receiveAlerts;

  /// Sound and vibration section
  ///
  /// In en, this message translates to:
  /// **'Sound and Vibration'**
  String get soundAndVibration;

  /// Sound label
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// Vibration label
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// Play sound description
  ///
  /// In en, this message translates to:
  /// **'Play sound when receiving notifications'**
  String get playSound;

  /// Vibrate on notification description
  ///
  /// In en, this message translates to:
  /// **'Vibrate when receiving notifications'**
  String get vibrateOnNotification;

  /// Notification types section
  ///
  /// In en, this message translates to:
  /// **'Notification Types'**
  String get notificationTypes;

  /// New messages notification type
  ///
  /// In en, this message translates to:
  /// **'New Messages'**
  String get newMessages;

  /// New messages description
  ///
  /// In en, this message translates to:
  /// **'Alerts when customers send new messages'**
  String get newMessagesDesc;

  /// Assignments notification type
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get assignments;

  /// Assignments description
  ///
  /// In en, this message translates to:
  /// **'Alerts when conversations are assigned to you'**
  String get assignmentsDesc;

  /// New conversations notification type
  ///
  /// In en, this message translates to:
  /// **'New Conversations'**
  String get newConversations;

  /// New conversations description
  ///
  /// In en, this message translates to:
  /// **'Alerts when new conversations are initiated'**
  String get newConversationsDesc;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Description for language settings option
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSettingsDesc;

  /// System language option
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get systemLanguage;

  /// Description for system language option
  ///
  /// In en, this message translates to:
  /// **'Follow device language settings'**
  String get systemLanguageDesc;

  /// Description for English language option
  ///
  /// In en, this message translates to:
  /// **'English language'**
  String get englishDesc;

  /// Description for Spanish language option
  ///
  /// In en, this message translates to:
  /// **'Spanish language'**
  String get spanishDesc;

  /// Label for current language section
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// Label for active language
  ///
  /// In en, this message translates to:
  /// **'Active Language'**
  String get activeLanguage;

  /// Error when trying to create a customer that already exists
  ///
  /// In en, this message translates to:
  /// **'User already has access to the organization'**
  String get errorUserAlreadyExists;

  /// Error when customer data validation fails
  ///
  /// In en, this message translates to:
  /// **'Invalid customer data'**
  String get errorInvalidCustomerData;

  /// Generic error when creating customer fails
  ///
  /// In en, this message translates to:
  /// **'Error creating customer'**
  String get errorCreatingCustomer;

  /// Success message when customer is created
  ///
  /// In en, this message translates to:
  /// **'Customer created successfully'**
  String get customerCreatedSuccess;

  /// Success message when customer is updated
  ///
  /// In en, this message translates to:
  /// **'Customer updated successfully'**
  String get customerUpdatedSuccess;

  /// Title for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChangesTitle;

  /// Message for unsaved changes dialog
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Are you sure you want to leave?'**
  String get unsavedChangesMessage;

  /// Button to stay on the current page
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Button to discard changes and leave
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @customerDetails.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customerDetails;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomers;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter customer full name'**
  String get enterFullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @identification.
  ///
  /// In en, this message translates to:
  /// **'Identification'**
  String get identification;

  /// No description provided for @enterIdentification.
  ///
  /// In en, this message translates to:
  /// **'Enter ID number (optional)'**
  String get enterIdentification;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter age (optional)'**
  String get enterAge;

  /// No description provided for @enterOccupation.
  ///
  /// In en, this message translates to:
  /// **'Enter occupation (optional)'**
  String get enterOccupation;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @nameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinLength;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed'**
  String get phoneCannotBeChanged;

  /// No description provided for @invalidAge.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get invalidAge;

  /// No description provided for @ageMustBeBetween.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 1 and 120'**
  String get ageMustBeBetween;

  /// No description provided for @ageMustBeBetweenEdit.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 0 and 120'**
  String get ageMustBeBetweenEdit;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @noCustomersYet.
  ///
  /// In en, this message translates to:
  /// **'No customers have been added yet'**
  String get noCustomersYet;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search query'**
  String get tryAdjustingFilters;

  /// No description provided for @loadingCustomerDetails.
  ///
  /// In en, this message translates to:
  /// **'Loading customer details...'**
  String get loadingCustomerDetails;

  /// No description provided for @errorLoadingCustomer.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Customer'**
  String get errorLoadingCustomer;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @customerNotFound.
  ///
  /// In en, this message translates to:
  /// **'Customer Not Found'**
  String get customerNotFound;

  /// No description provided for @customerNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The customer you are looking for does not exist.'**
  String get customerNotFoundMessage;

  /// No description provided for @createCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get createCustomer;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @ownerAgent.
  ///
  /// In en, this message translates to:
  /// **'Owner/Agent'**
  String get ownerAgent;

  /// No description provided for @segmentFilter.
  ///
  /// In en, this message translates to:
  /// **'Segment'**
  String get segmentFilter;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get dateCreated;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @allCustomers.
  ///
  /// In en, this message translates to:
  /// **'All Customers'**
  String get allCustomers;

  /// No description provided for @myCustomers.
  ///
  /// In en, this message translates to:
  /// **'My Customers'**
  String get myCustomers;

  /// No description provided for @viernesUnassigned.
  ///
  /// In en, this message translates to:
  /// **'Viernes (Unassigned)'**
  String get viernesUnassigned;

  /// No description provided for @noSegmentsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No segments available'**
  String get noSegmentsAvailable;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get memberSince;

  /// No description provided for @contactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInformation;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @customerSegment.
  ///
  /// In en, this message translates to:
  /// **'Customer Segment'**
  String get customerSegment;

  /// No description provided for @purchaseIntention.
  ///
  /// In en, this message translates to:
  /// **'Purchase Intention'**
  String get purchaseIntention;

  /// No description provided for @mainInterestNps.
  ///
  /// In en, this message translates to:
  /// **'Main Interest & NPS'**
  String get mainInterestNps;

  /// No description provided for @conversationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversationsLabel;

  /// No description provided for @insightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsLabel;

  /// No description provided for @purchaseIntent.
  ///
  /// In en, this message translates to:
  /// **'Purchase Intent'**
  String get purchaseIntent;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @lastContact.
  ///
  /// In en, this message translates to:
  /// **'Last Contact'**
  String get lastContact;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTab;

  /// No description provided for @analysisTab.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get analysisTab;

  /// No description provided for @activityTab.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTab;

  /// No description provided for @viewingConversation.
  ///
  /// In en, this message translates to:
  /// **'Viewing conversation #{id}'**
  String viewingConversation(String id);

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String hoursAgo(int count);

  /// No description provided for @yesterdayTime.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterdayTime;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String daysAgo(int count);

  /// No description provided for @weeksAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}w ago'**
  String weeksAgo(int count);

  /// No description provided for @deleteCustomerTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Customer?'**
  String get deleteCustomerTitle;

  /// No description provided for @deleteCustomerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete '**
  String get deleteCustomerConfirm;

  /// No description provided for @actionCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionCannotBeUndone;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oops;

  /// No description provided for @failedToLoadCustomers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load customers'**
  String get failedToLoadCustomers;

  /// Age field label
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// Occupation field label
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @profileSummary.
  ///
  /// In en, this message translates to:
  /// **'Profile Summary'**
  String get profileSummary;

  /// No description provided for @detailedInsights.
  ///
  /// In en, this message translates to:
  /// **'Detailed Insights'**
  String get detailedInsights;

  /// No description provided for @sentimentAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Sentiment Analysis'**
  String get sentimentAnalysis;

  /// No description provided for @emotions.
  ///
  /// In en, this message translates to:
  /// **'Emotions'**
  String get emotions;

  /// No description provided for @attitudes.
  ///
  /// In en, this message translates to:
  /// **'Attitudes'**
  String get attitudes;

  /// No description provided for @personality.
  ///
  /// In en, this message translates to:
  /// **'Personality'**
  String get personality;

  /// No description provided for @intentions.
  ///
  /// In en, this message translates to:
  /// **'Intentions'**
  String get intentions;

  /// No description provided for @interactionsAndActions.
  ///
  /// In en, this message translates to:
  /// **'Interactions & Actions'**
  String get interactionsAndActions;

  /// No description provided for @interactionsPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Interactions per month'**
  String get interactionsPerMonth;

  /// No description provided for @lastInteractionReasons.
  ///
  /// In en, this message translates to:
  /// **'Last Interaction Reasons'**
  String get lastInteractionReasons;

  /// No description provided for @actionsToCall.
  ///
  /// In en, this message translates to:
  /// **'Actions to Call:'**
  String get actionsToCall;

  /// No description provided for @conversationHistory.
  ///
  /// In en, this message translates to:
  /// **'Conversation History'**
  String get conversationHistory;

  /// No description provided for @agent.
  ///
  /// In en, this message translates to:
  /// **'Agent'**
  String get agent;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status: '**
  String get statusLabel;

  /// No description provided for @lastActivity.
  ///
  /// In en, this message translates to:
  /// **'Last activity'**
  String get lastActivity;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @noConversationsYet.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversationsYet;

  /// No description provided for @conversationHistoryWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Conversation history will appear here'**
  String get conversationHistoryWillAppear;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// Timezone settings page title
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezoneSettings;

  /// Organization timezone option
  ///
  /// In en, this message translates to:
  /// **'Organization timezone'**
  String get organizationTimezone;

  /// Device timezone option
  ///
  /// In en, this message translates to:
  /// **'Device timezone'**
  String get deviceTimezone;

  /// Current timezone section header
  ///
  /// In en, this message translates to:
  /// **'Current Timezone'**
  String get currentTimezone;

  /// Description explaining timezone setting effect
  ///
  /// In en, this message translates to:
  /// **'All dates and times in the app will be displayed according to the selected timezone.'**
  String get timezoneDescription;

  /// Message when organization timezone is not available
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get timezoneNotAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
