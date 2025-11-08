import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/book_model.dart';

final bookServiceProvider = Provider((ref) => BookService());

final booksStreamProvider = StreamProvider<List<BookModel>>((ref) {
  return ref.watch(bookServiceProvider).getBooksStream();
});

final userBooksStreamProvider = StreamProvider.family<List<BookModel>, String>((ref, userId) {
  return ref.watch(bookServiceProvider).getUserBooksStream(userId);
});

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<BookModel>> getBooksStream() {
    return _firestore
        .collection('books')
        .where('status', isEqualTo: 'available')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<BookModel>> getUserBooksStream(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
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
