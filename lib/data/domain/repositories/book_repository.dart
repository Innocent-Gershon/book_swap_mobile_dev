// lib/domain/repositories/book_repository.dart
import 'package:book_swap/core/errors/failures.dart';
import 'package:book_swap/data/domain/entities/book.dart';
// import 'package:book_swap/core/errors/failures.dart';
// import 'package:book_swap/domain/entities/book.dart' hide BookEntity;
import 'package:dartz/dartz.dart';

abstract class BookRepository {
  Future<Either<Failure, BookEntity>> createBook(BookEntity book);
  Future<Either<Failure, Unit>> updateBook(BookEntity book);
  Future<Either<Failure, Unit>> deleteBook(String bookId);
  Future<Either<Failure, BookEntity>> getBookById(String bookId);
  Stream<Either<Failure, List<BookEntity>>> getAllBooks(); // For browse listings
  Stream<Either<Failure, List<BookEntity>>> getMyBooks(String userId); // For 'My Listings'
}