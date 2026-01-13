import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/datasources/user_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/user_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/repositories/user_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/get_user_profile_usecase.dart';
import '../../features/auth/domain/usecases/change_agent_availability_usecase.dart';
import '../../features/auth/domain/usecases/get_organization_info_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_provider;

// Dashboard imports
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_monthly_stats_usecase.dart';
import '../../features/dashboard/domain/usecases/get_ai_human_stats_usecase.dart';
import '../../features/dashboard/domain/usecases/get_customer_summary_usecase.dart';
import '../../features/dashboard/domain/usecases/export_conversation_stats_usecase.dart';
import '../../features/dashboard/presentation/providers/dashboard_provider.dart';

// Customer imports
import '../../features/customers/data/datasources/customer_remote_datasource.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/get_customer_by_id_usecase.dart';
import '../../features/customers/domain/usecases/get_filter_options_usecase.dart';
import '../../features/customers/domain/usecases/create_customer_usecase.dart';
import '../../features/customers/domain/usecases/update_customer_usecase.dart';
import '../../features/customers/domain/usecases/delete_customer_usecase.dart';
import '../../features/customers/presentation/providers/customer_provider.dart';

// Conversation imports
import '../../features/conversations/data/datasources/conversation_remote_datasource.dart';
import '../../features/conversations/data/repositories/conversation_repository_impl.dart';
import '../../features/conversations/domain/repositories/conversation_repository.dart';
import '../../features/conversations/domain/usecases/get_conversations_usecase.dart';
import '../../features/conversations/domain/usecases/get_conversation_detail_usecase.dart';
import '../../features/conversations/domain/usecases/get_messages_usecase.dart';
import '../../features/conversations/domain/usecases/send_message_usecase.dart';
import '../../features/conversations/domain/usecases/send_media_usecase.dart';
import '../../features/conversations/domain/usecases/update_conversation_status_usecase.dart';
import '../../features/conversations/domain/usecases/assign_conversation_usecase.dart';
import '../../features/conversations/domain/usecases/assign_agent_usecase.dart';
import '../../features/conversations/domain/usecases/get_filter_options_usecase.dart' as conversation_filters;
import '../../features/conversations/presentation/providers/conversation_provider.dart';

import '../services/http_client.dart';
import '../services/value_definitions_service.dart';
import '../services/organization_timezone_service.dart';

class DependencyInjection {
  // Auth dependencies
  static late final FirebaseAuth _firebaseAuth;
  static late final FirebaseAuthDataSource _authDataSource;
  static late final UserRemoteDataSource _userRemoteDataSource;
  static late final AuthRepository _authRepository;
  static late final UserRepository _userRepository;
  static late final GetCurrentUserUseCase _getCurrentUserUseCase;
  static late final SignInUseCase _signInUseCase;
  static late final SignOutUseCase _signOutUseCase;
  static late final ResetPasswordUseCase _resetPasswordUseCase;
  static late final GetUserProfileUseCase _getUserProfileUseCase;
  static late final ChangeAgentAvailabilityUseCase _changeAgentAvailabilityUseCase;
  static late final GetOrganizationInfoUseCase _getOrganizationInfoUseCase;
  static late final auth_provider.AuthProvider _authProvider;

  // Shared dependencies
  static late final HttpClient _httpClient;
  static late final ValueDefinitionsService _valueDefinitionsService;
  static late final OrganizationTimezoneService _organizationTimezoneService;

  // Dashboard dependencies
  static late final DashboardRemoteDataSource _dashboardRemoteDataSource;
  static late final DashboardRepository _dashboardRepository;
  static late final GetMonthlyStatsUseCase _getMonthlyStatsUseCase;
  static late final GetAiHumanStatsUseCase _getAiHumanStatsUseCase;
  static late final GetCustomerSummaryUseCase _getCustomerSummaryUseCase;
  static late final ExportConversationStatsUseCase _exportConversationStatsUseCase;
  static late final DashboardProvider _dashboardProvider;

  // Customer dependencies
  static late final CustomerRemoteDataSource _customerRemoteDataSource;
  static late final CustomerRepository _customerRepository;
  static late final GetCustomersUseCase _getCustomersUseCase;
  static late final GetCustomerByIdUseCase _getCustomerByIdUseCase;
  static late final GetFilterOptionsUseCase _getFilterOptionsUseCase;
  static late final CreateCustomerUseCase _createCustomerUseCase;
  static late final UpdateCustomerUseCase _updateCustomerUseCase;
  static late final DeleteCustomerUseCase _deleteCustomerUseCase;
  static late final CustomerProvider _customerProvider;

  // Conversation dependencies
  static late final ConversationRemoteDataSource _conversationRemoteDataSource;
  static late final ConversationRepository _conversationRepository;
  static late final GetConversationsUseCase _getConversationsUseCase;
  static late final GetConversationDetailUseCase _getConversationDetailUseCase;
  static late final GetMessagesUseCase _getMessagesUseCase;
  static late final SendMessageUseCase _sendMessageUseCase;
  static late final SendMediaUseCase _sendMediaUseCase;
  static late final UpdateConversationStatusUseCase _updateConversationStatusUseCase;
  static late final AssignConversationUseCase _assignConversationUseCase;
  static late final AssignAgentUseCase _assignAgentUseCase;
  static late final conversation_filters.GetFilterOptionsUseCase _getConversationFilterOptionsUseCase;
  static late final ConversationProvider _conversationProvider;

  static void initialize() {
    // Firebase
    _firebaseAuth = FirebaseAuth.instance;

    // Auth setup
    _initializeAuth();

    // Dashboard setup
    _initializeDashboard();

    // Customer setup
    _initializeCustomers();

    // Conversation setup
    _initializeConversations();
  }

  static void _initializeAuth() {
    // Shared services (needed for user remote data source)
    _httpClient = HttpClient();
    _valueDefinitionsService = ValueDefinitionsService(_httpClient);
    _organizationTimezoneService = OrganizationTimezoneService(_httpClient);

    // Data sources
    _authDataSource = FirebaseAuthDataSourceImpl(firebaseAuth: _firebaseAuth);
    _userRemoteDataSource = UserRemoteDataSourceImpl(httpClient: _httpClient);

    // Repositories
    _authRepository = AuthRepositoryImpl(dataSource: _authDataSource);
    _userRepository = UserRepositoryImpl(remoteDataSource: _userRemoteDataSource);

    // Use cases
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);
    _signInUseCase = SignInUseCase(_authRepository);
    _signOutUseCase = SignOutUseCase(_authRepository);
    _resetPasswordUseCase = ResetPasswordUseCase(repository: _authRepository);
    _getUserProfileUseCase = GetUserProfileUseCase(_userRepository);
    _changeAgentAvailabilityUseCase = ChangeAgentAvailabilityUseCase(_userRepository);
    _getOrganizationInfoUseCase = GetOrganizationInfoUseCase(_userRepository);

    // Providers
    _authProvider = auth_provider.AuthProvider(
      getCurrentUserUseCase: _getCurrentUserUseCase,
      signInUseCase: _signInUseCase,
      signOutUseCase: _signOutUseCase,
      resetPasswordUseCase: _resetPasswordUseCase,
      getUserProfileUseCase: _getUserProfileUseCase,
      changeAgentAvailabilityUseCase: _changeAgentAvailabilityUseCase,
      getOrganizationInfoUseCase: _getOrganizationInfoUseCase,
    );
  }

  static void _initializeDashboard() {
    // HttpClient is already initialized in _initializeAuth()

    // Data sources
    _dashboardRemoteDataSource = DashboardRemoteDataSourceImpl(httpClient: _httpClient);

    // Repositories
    _dashboardRepository = DashboardRepositoryImpl(
      remoteDataSource: _dashboardRemoteDataSource,
    );

    // Use cases
    _getMonthlyStatsUseCase = GetMonthlyStatsUseCase(_dashboardRepository);
    _getAiHumanStatsUseCase = GetAiHumanStatsUseCase(_dashboardRepository);
    _getCustomerSummaryUseCase = GetCustomerSummaryUseCase(_dashboardRepository);
    _exportConversationStatsUseCase = ExportConversationStatsUseCase(_dashboardRepository);

    // Providers
    _dashboardProvider = DashboardProvider(
      getMonthlyStatsUseCase: _getMonthlyStatsUseCase,
      getAiHumanStatsUseCase: _getAiHumanStatsUseCase,
      getCustomerSummaryUseCase: _getCustomerSummaryUseCase,
      exportConversationStatsUseCase: _exportConversationStatsUseCase,
    );
  }

  static void _initializeCustomers() {
    // HttpClient is already initialized in _initializeAuth()

    // Data sources
    _customerRemoteDataSource = CustomerRemoteDataSourceImpl(_httpClient);

    // Repositories
    _customerRepository = CustomerRepositoryImpl(_customerRemoteDataSource);

    // Use cases
    _getCustomersUseCase = GetCustomersUseCase(_customerRepository);
    _getCustomerByIdUseCase = GetCustomerByIdUseCase(_customerRepository);
    _getFilterOptionsUseCase = GetFilterOptionsUseCase(_customerRepository);
    _createCustomerUseCase = CreateCustomerUseCase(_customerRepository);
    _updateCustomerUseCase = UpdateCustomerUseCase(_customerRepository);
    _deleteCustomerUseCase = DeleteCustomerUseCase(_customerRepository);

    // Providers
    _customerProvider = CustomerProvider(
      getCustomersUseCase: _getCustomersUseCase,
      getCustomerByIdUseCase: _getCustomerByIdUseCase,
      getFilterOptionsUseCase: _getFilterOptionsUseCase,
      createCustomerUseCase: _createCustomerUseCase,
      updateCustomerUseCase: _updateCustomerUseCase,
      deleteCustomerUseCase: _deleteCustomerUseCase,
    );
  }

  static void _initializeConversations() {
    // HttpClient is already initialized in _initializeAuth()

    // Data sources
    _conversationRemoteDataSource = ConversationRemoteDataSourceImpl(_httpClient);

    // Repositories
    _conversationRepository = ConversationRepositoryImpl(_conversationRemoteDataSource);

    // Use cases
    _getConversationsUseCase = GetConversationsUseCase(_conversationRepository);
    _getConversationDetailUseCase = GetConversationDetailUseCase(_conversationRepository);
    _getMessagesUseCase = GetMessagesUseCase(_conversationRepository);
    _sendMessageUseCase = SendMessageUseCase(_conversationRepository);
    _sendMediaUseCase = SendMediaUseCase(_conversationRepository);
    _updateConversationStatusUseCase = UpdateConversationStatusUseCase(_conversationRepository);
    _assignConversationUseCase = AssignConversationUseCase(_conversationRepository);
    _assignAgentUseCase = AssignAgentUseCase(_conversationRepository);
    _getConversationFilterOptionsUseCase = conversation_filters.GetFilterOptionsUseCase(_conversationRepository);

    // Providers
    _conversationProvider = ConversationProvider(
      getConversationsUseCase: _getConversationsUseCase,
      getConversationDetailUseCase: _getConversationDetailUseCase,
      getMessagesUseCase: _getMessagesUseCase,
      sendMessageUseCase: _sendMessageUseCase,
      sendMediaUseCase: _sendMediaUseCase,
      updateConversationStatusUseCase: _updateConversationStatusUseCase,
      assignConversationUseCase: _assignConversationUseCase,
      assignAgentUseCase: _assignAgentUseCase,
      getFilterOptionsUseCase: _getConversationFilterOptionsUseCase,
    );
  }

  // Getters
  static auth_provider.AuthProvider get authProvider => _authProvider;
  static AuthRepository get authRepository => _authRepository;
  static FirebaseAuth get firebaseAuth => _firebaseAuth;

  // Dashboard getters
  static DashboardProvider get dashboardProvider => _dashboardProvider;
  static DashboardRepository get dashboardRepository => _dashboardRepository;

  // Customer getters
  static CustomerProvider get customerProvider => _customerProvider;
  static CustomerRepository get customerRepository => _customerRepository;

  // Conversation getters
  static ConversationProvider get conversationProvider => _conversationProvider;
  static ConversationRepository get conversationRepository => _conversationRepository;

  // Value Definitions getters
  static ValueDefinitionsService get valueDefinitionsService => _valueDefinitionsService;

  // Organization Timezone getter
  static OrganizationTimezoneService get organizationTimezoneService => _organizationTimezoneService;
}
