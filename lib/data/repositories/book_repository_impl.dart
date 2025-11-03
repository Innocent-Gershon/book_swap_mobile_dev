// lib/data/repositories/book_repository_impl.dart
import 'dart:async';
import 'package:book_swap/core/errors/exceptions.dart';
import 'package:book_swap/core/errors/failures.dart';
import 'package:book_swap/data/datasources/book_remote_datasource.dart';
import 'package:book_swap/domain/repositories/book_repository.dart';
import 'package:book_swap/data/models/book_model.dart';
import 'package:book_swap/domain/entities/book.dart';
import 'package:dartz/dartz.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource _remoteDataSource;

  BookRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, BookEntity>> createBook(BookEntity book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      final createdBookModel = await _remoteDataSource.createBook(bookModel);
      return Right(createdBookModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateBook(BookEntity book) async {
    try {
      final bookModel = BookModel.fromEntity(book);
      await _remoteDataSource.updateBook(bookModel);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteBook(String bookId) async {
    try {
      await _remoteDataSource.deleteBook(bookId);
      return const Right(unit);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, BookEntity>> getBookById(String bookId) async {
    try {
      final bookModel = await _remoteDataSource.getBookById(bookId);
      return Right(bookModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<BookEntity>>> getAllBooks() {
    return _remoteDataSource.getAllBooks().map((bookModels) {
      try {
        final bookEntities = bookModels.map((model) => model.toEntity()).toList().cast<BookEntity>();
        return Right<Failure, List<BookEntity>>(bookEntities);
      } catch (e) {
        return Left<Failure, List<BookEntity>>(
            DatabaseFailure('Error converting book models to entities: $e'));
      }
    }).handleError((error) {
      return Left<Failure, List<BookEntity>>(DatabaseFailure(error.toString()));
    });
  }

  @override
  Stream<Either<Failure, List<BookEntity>>> getMyBooks(String userId) {
    return _remoteDataSource.getMyBooks(userId).map((bookModels) {
      try {
        final bookEntities = bookModels.map((model) => model.toEntity()).toList().cast<BookEntity>();
        return Right<Failure, List<BookEntity>>(bookEntities);
      } catch (e) {
        return Left<Failure, List<BookEntity>>(
            DatabaseFailure('Error converting user book models to entities: $e'));
      }
    }).handleError((error) {
      return Left<Failure, List<BookEntity>>(DatabaseFailure(error.toString()));
    });
  }
}
