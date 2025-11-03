// lib/data/repositories/auth_repository_impl.dart
import 'package:book_swap/core/errors/exceptions.dart';
import 'package:book_swap/core/errors/failures.dart';
// import 'package:book_swap/core/providers/firebase_providers.dart';
import 'package:book_swap/data/datasources/auth_remote_datasource.dart';
import 'package:book_swap/data/domain/entities/user.dart';
import 'package:book_swap/data/domain/repositories/auth_repository.dart';
import 'package:book_swap/data/models/user_model.dart';
// import 'package:book_swap/domain/entities/user.dart';
// import 'package:book_swap/domain/repositories/auth_repository.dart';
import 'package:book_swap/presentation/providers/firebase_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FirebaseFirestore _firestore; // To create/update user profile in Firestore

  AuthRepositoryImpl(this._remoteDataSource, this._firestore);

  @override
  Stream<User?> get authStateChanges => _remoteDataSource.authStateChanges;

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Create a user document in Firestore on successful signup
      await _firestore.collection('users').doc(userModel.uid).set(userModel.toJson());
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(userModel.toEntity());
    } on AuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendEmailVerification() async {
    try {
      await _remoteDataSource.sendEmailVerification();
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUserEntity() async {
    try {
      final userModel = await _remoteDataSource.getCurrentUserModel();
      // Fetch user profile from Firestore to ensure we have the most complete data
      final doc = await _firestore.collection('users').doc(userModel.uid).get();
      if (doc.exists) {
        final firestoreUserModel = UserModel.fromDocumentSnapshot(doc);
        return Right(firestoreUserModel.toEntity());
      } else {
        // If Firestore doc doesn't exist, create it from Firebase Auth data
        await _firestore.collection('users').doc(userModel.uid).set(userModel.toJson());
        return Right(userModel.toEntity());
      }
    } on AuthException catch (e) {
      return Left(_mapFirebaseAuthExceptionToFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDisplayName(String displayName) async {
    try {
      await _remoteDataSource.updateDisplayName(displayName);
      // Also update in Firestore
      final uid = _remoteDataSource.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({'displayName': displayName});
      }
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Failed to update display name in Firestore.'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updatePhotoUrl(String photoUrl) async {
    try {
      await _remoteDataSource.updatePhotoUrl(photoUrl);
      // Also update in Firestore
      final uid = _remoteDataSource.currentUser?.uid;
      if (uid != null) {
        await _firestore.collection('users').doc(uid).update({'photoUrl': photoUrl});
      }
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirebaseException catch (e) {
      return Left(DatabaseFailure(e.message ?? 'Failed to update photo URL in Firestore.'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }


  Failure _mapFirebaseAuthExceptionToFailure(String message) {
    if (message.contains('email-already-in-use')) {
      return const EmailAlreadyInUseFailure('The email is already registered. Please sign in or use a different email.');
    } else if (message.contains('weak-password')) {
      return const WeakPasswordFailure('The password provided is too weak.');
    } else if (message.contains('user-not-found') || message.contains('wrong-password') || message.contains('invalid-email')) {
      return const InvalidEmailPasswordFailure('Invalid email or password.');
    } else if (message.contains('user-disabled')) {
      return const UserDisabledFailure('This user account has been disabled.');
    } else if (message.contains('operation-not-allowed')) {
      return const OperationNotAllowedFailure('Email/password sign-in is not enabled. Please contact support.');
    }
    return AuthFailure(message);
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(firebaseFirestoreProvider),
  );
});