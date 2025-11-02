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
import '../services/http_client.dart';

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
  static late final auth_provider.AuthProvider _authProvider;

  // Shared dependencies
  static late final HttpClient _httpClient;

  // Dashboard dependencies
  static late final DashboardRemoteDataSource _dashboardRemoteDataSource;
  static late final DashboardRepository _dashboardRepository;
  static late final GetMonthlyStatsUseCase _getMonthlyStatsUseCase;
  static late final GetAiHumanStatsUseCase _getAiHumanStatsUseCase;
  static late final GetCustomerSummaryUseCase _getCustomerSummaryUseCase;
  static late final ExportConversationStatsUseCase _exportConversationStatsUseCase;
  static late final DashboardProvider _dashboardProvider;

  static void initialize() {
    // Firebase
    _firebaseAuth = FirebaseAuth.instance;

    // Auth setup
    _initializeAuth();

    // Dashboard setup
    _initializeDashboard();
  }

  static void _initializeAuth() {
    // Shared services (needed for user remote data source)
    _httpClient = HttpClient();

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

    // Providers
    _authProvider = auth_provider.AuthProvider(
      getCurrentUserUseCase: _getCurrentUserUseCase,
      signInUseCase: _signInUseCase,
      signOutUseCase: _signOutUseCase,
      resetPasswordUseCase: _resetPasswordUseCase,
      getUserProfileUseCase: _getUserProfileUseCase,
      changeAgentAvailabilityUseCase: _changeAgentAvailabilityUseCase,
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

  // Getters
  static auth_provider.AuthProvider get authProvider => _authProvider;
  static AuthRepository get authRepository => _authRepository;
  static FirebaseAuth get firebaseAuth => _firebaseAuth;

  // Dashboard getters
  static DashboardProvider get dashboardProvider => _dashboardProvider;
  static DashboardRepository get dashboardRepository => _dashboardRepository;
}
