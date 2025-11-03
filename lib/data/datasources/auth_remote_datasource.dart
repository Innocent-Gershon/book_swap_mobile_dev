// lib/data/datasources/auth_remote_datasource.dart
import 'package:book_swap/core/errors/exceptions.dart';
import 'package:book_swap/core/routes/app_router.dart';
import 'package:book_swap/data/models/user_model.dart' show UserModel;
// import 'package:book_swap/core/errors/exceptions.dart';
// import 'package:book_swap/core/providers/firebase_providers.dart';
import 'package:book_swap/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<UserModel> signUpWithEmailAndPassword({required String email, required String password});
  Future<UserModel> signInWithEmailAndPassword({required String email, required String password});
  Future<void> signOut();
  Future<void> sendEmailVerification();
  Future<UserModel> getCurrentUserModel();
  Future<void> updateDisplayName(String displayName);
  Future<void> updatePhotoUrl(String photoUrl);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl(this._firebaseAuth);

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<UserModel> signUpWithEmailAndPassword({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        // Automatically create a user document in Firestore on signup
        // This will be handled in the repository layer
        return UserModel.fromFirebaseUser(credential.user!);
      } else {
        throw const AuthException('User creation failed: No user returned.');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else {
        message = e.message ?? 'An unknown authentication error occurred during sign up.';
      }
      throw AuthException(message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return UserModel.fromFirebaseUser(credential.user!);
      } else {
        throw const AuthException('Sign in failed: No user returned.');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        message = 'The user account has been disabled.';
      } else {
        message = e.message ?? 'An unknown authentication error occurred during sign in.';
      }
      throw AuthException(message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else if (user == null) {
        throw const AuthException('No user is currently signed in to send verification email.');
      } else if (user.emailVerified) {
        throw const AuthException('Email is already verified.');
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> getCurrentUserModel() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const AuthException('No user logged in.');
    }
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    try {
      await _firebaseAuth.currentUser?.updateDisplayName(displayName);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> updatePhotoUrl(String photoUrl) async {
    try {
      await _firebaseAuth.currentUser?.updatePhotoURL(photoUrl);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(firebaseAuthProvider));
});