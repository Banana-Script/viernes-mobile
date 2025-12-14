import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/organization_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/change_agent_availability_usecase.dart';
import '../../domain/usecases/get_organization_info_usecase.dart';
import '../../../../core/utils/logger.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetUserProfileUseCase getUserProfileUseCase;
  final ChangeAgentAvailabilityUseCase changeAgentAvailabilityUseCase;
  final GetOrganizationInfoUseCase getOrganizationInfoUseCase;

  AuthProvider({
    required this.getCurrentUserUseCase,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.resetPasswordUseCase,
    required this.getUserProfileUseCase,
    required this.changeAgentAvailabilityUseCase,
    required this.getOrganizationInfoUseCase,
  }) {
    debugPrint('[AuthProvider] Constructor called, initializing auth state...');
    _initializeAuthState();
  }

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _user;
  OrganizationEntity? _organization;
  String? _errorMessage;
  StreamSubscription<UserEntity?>? _authStateSubscription;
  bool _isLoadingProfile = false;
  bool _isTogglingAvailability = false;

  AuthStatus get status => _status;
  UserEntity? get user => _user;
  OrganizationEntity? get organization => _organization;
  String? get organizationName => _organization?.name;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _user != null;
  bool get isLoadingProfile => _isLoadingProfile;
  bool get isTogglingAvailability => _isTogglingAvailability;

  void _initializeAuthState() {
    debugPrint('[AuthProvider] Setting up authStateChanges listener...');
    _authStateSubscription = getCurrentUserUseCase.authStateChanges.listen((user) async {
      debugPrint('[AuthProvider] Auth state changed: user=${user?.email}');
      if (user != null) {
        // User is authenticated in Firebase, now fetch complete profile from backend
        await _loadUserProfile(user);
      } else {
        // User is not authenticated
        debugPrint('[AuthProvider] No user, setting status to unauthenticated');
        _user = null;
        _status = AuthStatus.unauthenticated;
        _errorMessage = null;
        notifyListeners();
      }
    });
    debugPrint('[AuthProvider] Listener setup complete');
  }

  Future<void> _loadUserProfile(UserEntity firebaseUser) async {
    debugPrint('[AuthProvider] _loadUserProfile started for ${firebaseUser.email}');
    try {
      _isLoadingProfile = true;
      _status = AuthStatus.loading;
      debugPrint('[AuthProvider] Status -> loading, calling notifyListeners');
      notifyListeners();

      debugPrint('[AuthProvider] Calling getUserProfileUseCase...');
      AppLogger.info('Loading user profile from backend', tag: 'AuthProvider');

      // Fetch complete profile from backend (no UID needed, uses token)
      final completeProfile = await getUserProfileUseCase.call();

      debugPrint('[AuthProvider] Profile received: databaseId=${completeProfile.databaseId}, orgId=${completeProfile.organizationId}');
      _user = completeProfile;
      _status = AuthStatus.authenticated;
      _errorMessage = null;

      debugPrint('[AuthProvider] Status -> authenticated, user: ${completeProfile.email}');
      AppLogger.info('User profile loaded successfully', tag: 'AuthProvider');

      // Load organization info in parallel (non-blocking)
      _loadOrganizationInfo();
    } catch (e) {
      debugPrint('[AuthProvider] ERROR loading profile: $e');
      AppLogger.error('Failed to load user profile: $e', tag: 'AuthProvider');

      // Even if backend fails, we still have Firebase user data
      // So we keep the user authenticated but with limited data
      _user = firebaseUser;
      _status = AuthStatus.authenticated;
      _errorMessage = 'Could not load complete profile. Some features may be limited.';
    } finally {
      _isLoadingProfile = false;
      debugPrint('[AuthProvider] Profile load complete, calling notifyListeners. Status: $_status');
      notifyListeners();
    }
  }

  Future<void> _loadOrganizationInfo() async {
    try {
      AppLogger.info('Loading organization info', tag: 'AuthProvider');
      final organizationInfo = await getOrganizationInfoUseCase.call();
      _organization = organizationInfo;
      AppLogger.info('Organization info loaded: ${organizationInfo.name}', tag: 'AuthProvider');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load organization info: $e', tag: 'AuthProvider');
      // Organization info is optional, don't set error message
    }
  }

  /// Toggles the agent's availability status
  /// This updates the status on the backend and refreshes the user profile
  Future<void> toggleAvailability() async {
    if (_user == null) {
      AppLogger.warning('Cannot toggle availability: No user logged in', tag: 'AuthProvider');
      return;
    }

    // Determine the current status and calculate the new one
    final currentStatus = _user!.organizationalStatus;
    if (currentStatus == null) {
      AppLogger.warning('Cannot toggle availability: User has no organizational status', tag: 'AuthProvider');
      _errorMessage = 'Unable to change availability. Profile incomplete.';
      notifyListeners();
      return;
    }

    // Current status "010" = Active, "020" = Inactive
    // Toggle to the opposite
    final isCurrentlyActive = currentStatus.isActive;
    final newAvailability = !isCurrentlyActive;

    try {
      _isTogglingAvailability = true;
      _errorMessage = null;
      notifyListeners();

      AppLogger.info(
        'Toggling availability from ${isCurrentlyActive ? "active" : "inactive"} to ${newAvailability ? "active" : "inactive"}',
        tag: 'AuthProvider',
      );

      // Call the use case to change availability
      await changeAgentAvailabilityUseCase.call(newAvailability);

      // After successful change, refresh the user profile to get updated status
      AppLogger.info('Availability changed successfully, refreshing profile', tag: 'AuthProvider');
      final updatedProfile = await getUserProfileUseCase.call();

      _user = updatedProfile;
      _errorMessage = null;

      AppLogger.info('Profile refreshed after availability change', tag: 'AuthProvider');
    } catch (e) {
      AppLogger.error('Failed to toggle availability: $e', tag: 'AuthProvider');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isTogglingAvailability = false;
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
      _organization = null;
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
