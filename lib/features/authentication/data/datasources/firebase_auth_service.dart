import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth_result_model.dart';
import '../models/user_model.dart';

abstract class FirebaseAuthService {
  Future<AuthResultModel> signInWithEmailAndPassword(String email, String password);
  Future<AuthResultModel> createUserWithEmailAndPassword(String email, String password);
  Future<AuthResultModel> signInWithGoogle();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<String?> getCurrentUserToken();
  Future<String> refreshCurrentUserToken();
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
}

class FirebaseAuthServiceImpl implements FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthServiceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Future<AuthResultModel> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final idToken = await credential.user!.getIdToken();
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'token-generation-failed',
        message: 'Failed to generate authentication token',
      );
    }

    return AuthResultModel.fromFirebaseUserCredential(credential, idToken);
  }

  @override
  Future<AuthResultModel> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final idToken = await credential.user!.getIdToken();
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'token-generation-failed',
        message: 'Failed to generate authentication token',
      );
    }

    return AuthResultModel.fromFirebaseUserCredential(credential, idToken);
  }

  @override
  Future<AuthResultModel> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign_in_canceled',
        message: 'Google sign in was canceled',
      );
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credentials
    final firebaseCredential = await _firebaseAuth.signInWithCredential(credential);

    final idToken = await firebaseCredential.user!.getIdToken();
    if (idToken == null) {
      throw FirebaseAuthException(
        code: 'token-generation-failed',
        message: 'Failed to generate authentication token',
      );
    }

    return AuthResultModel.fromFirebaseUserCredential(firebaseCredential, idToken);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  @override
  Future<String?> getCurrentUserToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return await user.getIdToken();
  }

  @override
  Future<String> refreshCurrentUserToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No current user to refresh token for',
      );
    }

    final token = await user.getIdToken(true); // Force refresh
    if (token == null) {
      throw FirebaseAuthException(
        code: 'token-refresh-failed',
        message: 'Failed to refresh authentication token',
      );
    }
    return token;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? firebaseUser) {
      if (firebaseUser == null) return null;
      return UserModel.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  UserModel? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    return UserModel.fromFirebaseUser(firebaseUser);
  }
}

// Extension to handle common Firebase Auth exceptions
extension FirebaseAuthExceptionHandler on FirebaseAuthException {
  AuthFailureModel toAuthFailure() {
    return AuthFailureModel.fromFirebaseAuthException(this);
  }
}