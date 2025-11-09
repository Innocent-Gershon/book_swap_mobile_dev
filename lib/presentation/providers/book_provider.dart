import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/book_model.dart';

final bookServiceProvider = Provider((ref) => BookService());

final booksStreamProvider = StreamProvider<List<BookModel>>((ref) {
  return ref.watch(bookServiceProvider).getBooksStream();
});

final browseBooksStreamProvider = StreamProvider.family<List<BookModel>, String?>((ref, currentUserId) {
  return ref.watch(bookServiceProvider).getBrowseBooksStream(currentUserId);
});

final userBooksStreamProvider = StreamProvider.family<List<BookModel>, String>((ref, userId) {
  return ref.watch(bookServiceProvider).getUserBooksStream(userId);
});

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookModel>> getBooksStream() {
    return _firestore
        .collection('books')
        .snapshots()
        .handleError((error) {
          print('Error loading books: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final books = snapshot.docs
                .map((doc) {
                  try {
                    return BookModel.fromFirestore(doc);
                  } catch (e) {
                    print('Error parsing book ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<BookModel>()
                .toList();
            books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return books;
          } catch (e) {
            print('Error processing books: $e');
            return <BookModel>[];
          }
        });
  }

  Stream<List<BookModel>> getBrowseBooksStream(String? currentUserId) {
    return _firestore
        .collection('books')
        .snapshots()
        .handleError((error) {
          print('Error loading browse books: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final books = snapshot.docs
                .map((doc) {
                  try {
                    return BookModel.fromFirestore(doc);
                  } catch (e) {
                    print('Error parsing book ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<BookModel>()
                .where((book) => currentUserId == null || book.ownerId != currentUserId)
                .toList();
            books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return books;
          } catch (e) {
            print('Error processing browse books: $e');
            return <BookModel>[];
          }
        });
  }

  Stream<List<BookModel>> getUserBooksStream(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .handleError((error) {
          print('Error loading user books: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final books = snapshot.docs
                .map((doc) {
                  try {
                    return BookModel.fromFirestore(doc);
                  } catch (e) {
                    print('Error parsing book ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<BookModel>()
                .toList();
            books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            return books;
          } catch (e) {
            print('Error processing user books: $e');
            return <BookModel>[];
          }
        });
  }

  Future<void> addBook(BookModel book) async {
    await _firestore.collection('books').add(book.toMap());
  }

  Future<void> updateBook(String bookId, Map<String, dynamic> updates) async {
    await _firestore.collection('books').doc(bookId).update(updates);
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  Future<BookModel?> getBook(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (doc.exists) {
        return BookModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get book: $e');
    }
  }

  Future<void> requestSwap(String bookId, String requesterId) async {
    final batch = _firestore.batch();
    
    // Update book status to pending
    batch.update(
      _firestore.collection('books').doc(bookId),
      {'status': 'pending'}
    );
    
    // Create swap request
    batch.set(
      _firestore.collection('swaps').doc(),
      {
        'bookId': bookId,
        'requesterId': requesterId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      }
    );
    
    await batch.commit();
  }
}
