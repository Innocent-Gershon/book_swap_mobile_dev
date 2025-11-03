// lib/domain/repositories/auth_repository.dart
import 'package:book_swap/core/errors/failures.dart';
import 'package:book_swap/data/domain/entities/user.dart';
// import 'package:book_swap/core/errors/failures.dart';
// import 'package:book_swap/domain/entities/user.dart';
import 'package:dartz/dartz.dart'; // For Either (success or failure)
import 'package:firebase_auth/firebase_auth.dart' as fb_auth; // Alias to avoid conflict

abstract class AuthRepository {
  Stream<fb_auth.User?> get authStateChanges;
  fb_auth.User? get currentUser;

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, Unit>> signOut();

  Future<Either<Failure, Unit>> sendEmailVerification();

  Future<Either<Failure, UserEntity>> getCurrentUserEntity();

  // Optionally, for user profile updates
  Future<Either<Failure, Unit>> updateDisplayName(String displayName);
  Future<Either<Failure, Unit>> updatePhotoUrl(String photoUrl);
}