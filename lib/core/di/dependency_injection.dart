import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_provider;

class DependencyInjection {
  static late final FirebaseAuth _firebaseAuth;
  static late final FirebaseAuthDataSource _authDataSource;
  static late final AuthRepository _authRepository;
  static late final GetCurrentUserUseCase _getCurrentUserUseCase;
  static late final SignInUseCase _signInUseCase;
  static late final SignUpUseCase _signUpUseCase;
  static late final SignOutUseCase _signOutUseCase;
  static late final auth_provider.AuthProvider _authProvider;

  static void initialize() {
    // Firebase
    _firebaseAuth = FirebaseAuth.instance;

    // Data sources
    _authDataSource = FirebaseAuthDataSourceImpl(firebaseAuth: _firebaseAuth);

    // Repositories
    _authRepository = AuthRepositoryImpl(dataSource: _authDataSource);

    // Use cases
    _getCurrentUserUseCase = GetCurrentUserUseCase(_authRepository);
    _signInUseCase = SignInUseCase(_authRepository);
    _signUpUseCase = SignUpUseCase(_authRepository);
    _signOutUseCase = SignOutUseCase(_authRepository);

    // Providers
    _authProvider = auth_provider.AuthProvider(
      getCurrentUserUseCase: _getCurrentUserUseCase,
      signInUseCase: _signInUseCase,
      signUpUseCase: _signUpUseCase,
      signOutUseCase: _signOutUseCase,
    );
  }

  // Getters
  static auth_provider.AuthProvider get authProvider => _authProvider;
  static AuthRepository get authRepository => _authRepository;
  static FirebaseAuth get firebaseAuth => _firebaseAuth;
}