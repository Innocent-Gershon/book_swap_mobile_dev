import 'package:book_swap/core/errors/failures.dart';
import 'package:book_swap/domain/entities/book.dart';
import 'package:dartz/dartz.dart';

abstract class BookRepository {
  Future<Either<Failure, BookEntity>> createBook(BookEntity book);
  Future<Either<Failure, Unit>> updateBook(BookEntity book);
  Future<Either<Failure, Unit>> deleteBook(String bookId);
  Future<Either<Failure, BookEntity>> getBookById(String bookId);
  Stream<Either<Failure, List<BookEntity>>> getAllBooks();
  Stream<Either<Failure, List<BookEntity>>> getMyBooks(String userId);
}
