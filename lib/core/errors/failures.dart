// lib/core/errors/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General Failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Authentication Failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure(super.message);
}

class InvalidEmailPasswordFailure extends AuthFailure {
  const InvalidEmailPasswordFailure(super.message);
}

class UserNotFoundFailure extends AuthFailure {
  const UserNotFoundFailure(super.message);
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure(super.message);
}

class OperationNotAllowedFailure extends AuthFailure {
  const OperationNotAllowedFailure(super.message);
}

class UserDisabledFailure extends AuthFailure {
  const UserDisabledFailure(super.message);
}

// Firestore / Database Failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class NotFoundFailure extends DatabaseFailure {
  const NotFoundFailure(super.message);
}

class PermissionDeniedFailure extends DatabaseFailure {
  const PermissionDeniedFailure(super.message);
}

// Storage Failures
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class FileUploadFailure extends StorageFailure {
  const FileUploadFailure(super.message);
}

// Local Failures
class InputValidationFailure extends Failure {
  const InputValidationFailure(super.message);
}