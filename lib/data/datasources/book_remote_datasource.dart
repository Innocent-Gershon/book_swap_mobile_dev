import 'package:book_swap/data/models/book_model.dart';

abstract class BookRemoteDataSource {
  Future<BookModel> createBook(BookModel book);
  Future<void> updateBook(BookModel book);
  Future<void> deleteBook(String bookId);
  Future<BookModel> getBookById(String bookId);
  Stream<List<BookModel>> getAllBooks();
  Stream<List<BookModel>> getMyBooks(String userId);
}
