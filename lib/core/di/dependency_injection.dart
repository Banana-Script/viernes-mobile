import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
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
  static late final AuthRepository _authRepository;
  static late final GetCurrentUserUseCase _getCurrentUserUseCase;
  static late final SignInUseCase _signInUseCase;
  static late final SignUpUseCase _signUpUseCase;
  static late final SignOutUseCase _signOutUseCase;
  static late final ResetPasswordUseCase _resetPasswordUseCase;
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
    // Data sources
    _authDataSource = FirebaseAuthDataSourceImpl(firebaseAuth: _firebaseAuth);

    // Repositories
    _authRepository = AuthRepositoryImpl(dataSource: _authDataSource);

    // Use cases
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);
    _signInUseCase = SignInUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
    _signOutUseCase = SignOutUseCase(_authRepository);
    _resetPasswordUseCase = ResetPasswordUseCase(repository: _authRepository);

    // Providers
    _authProvider = auth_provider.AuthProvider(
      getCurrentUserUseCase: _getCurrentUserUseCase,
      signInUseCase: _signInUseCase,
      signUpUseCase: _signUpUseCase,
      signOutUseCase: _signOutUseCase,
      resetPasswordUseCase: _resetPasswordUseCase,
    );
  }

  static void _initializeDashboard() {
    // Shared services
    _httpClient = HttpClient();

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