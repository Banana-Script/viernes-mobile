import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../../../core/utils/logger.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;

  AuthProvider({
    required this.getCurrentUserUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.getUserProfileUseCase,
  }) {
    _initializeAuthState();
  }

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  String? _errorMessage;
  StreamSubscription<UserEntity?>? _authStateSubscription;
  bool _isLoadingProfile = false;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isLoadingProfile => _isLoadingProfile;

  void _initializeAuthState() {
    _authStateSubscription = getCurrentUserUseCase.authStateChanges.listen((user) async {
      if (user != null) {
        // User is authenticated in Firebase, now fetch complete profile from backend
        await _loadUserProfile(user);
      } else {
        // User is not authenticated
        _user = null;
        _status = AuthStatus.unauthenticated;
        _errorMessage = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(UserEntity firebaseUser) async {
    try {
      _isLoadingProfile = true;
      _status = AuthStatus.loading;
      notifyListeners();

      AppLogger.info('Loading user profile from backend for uid: ${firebaseUser.uid}', tag: 'AuthProvider');

      // Fetch complete profile from backend
      final completeProfile = await getUserProfileUseCase.call(firebaseUser.uid);

      _user = completeProfile;
      _status = AuthStatus.authenticated;
      _errorMessage = null;

      AppLogger.info('User profile loaded successfully', tag: 'AuthProvider');
    } catch (e) {
      AppLogger.error('Failed to load user profile: $e', tag: 'AuthProvider');

      // Even if backend fails, we still have Firebase user data
      // So we keep the user authenticated but with limited data
      _user = firebaseUser;
      _status = AuthStatus.authenticated;
      _errorMessage = 'Could not load complete profile. Some features may be limited.';
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading();

      await signInUseCase(
        email: email,
        password: password,
      );

      // Let the stream handle state updates
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _user = null;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading();

      await signOutUseCase();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> resetPassword({required String email}) async {
    try {
      _setLoading();

      await resetPasswordUseCase(email: email);

      _status = AuthStatus.unauthenticated;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}