import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail({required String email});
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final FirebaseAuth firebaseAuth;

  FirebaseAuthDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return UserModel.fromFirebaseUser(user);
    }
    return null;
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user != null) {
        return UserModel.fromFirebaseUser(user);
      }
      return null;
    });
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final sanitizedEmail = email.trim().toLowerCase();

    if (sanitizedEmail.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }

    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: sanitizedEmail,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Sign in failed');
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    final sanitizedEmail = email.trim().toLowerCase();

    if (sanitizedEmail.isEmpty) {
      throw Exception('Email es requerido');
    }

    try {
      await firebaseAuth.sendPasswordResetEmail(email: sanitizedEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  Exception _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
        return Exception('Email o contraseña incorrectos');
      case 'email-already-in-use':
        return Exception('An account already exists with this email');
      case 'weak-password':
        return Exception('Password is too weak');
      case 'invalid-email':
        return Exception('Email is not valid');
      case 'user-disabled':
        return Exception('This user account has been disabled');
      case 'too-many-requests':
        return Exception('Too many requests. Try again later');
      case 'operation-not-allowed':
        return Exception('Email/password accounts are not enabled');
      default:
        return Exception('Authentication failed: ${e.message}');
    }
  }
}