import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/swap_model.dart';

final swapServiceProvider = Provider((ref) => SwapService());

final userSwapsStreamProvider = StreamProvider.family<List<SwapModel>, String>((ref, userId) {
  return ref.watch(swapServiceProvider).getUserSwapsStream(userId);
});

final swapRequestsStreamProvider = StreamProvider.family<List<SwapModel>, String>((ref, userId) {
  return ref.watch(swapServiceProvider).getSwapRequestsStream(userId);
});

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<SwapModel>> getUserSwapsStream(String userId) {
    return _firestore
        .collection('swaps')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<SwapModel>> getSwapRequestsStream(String userId) {
    return _firestore
        .collection('swaps')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  Future<void> createSwapRequest({
    required String bookId,
    required String requesterId,
    required String ownerId,
  }) async {
    final batch = _firestore.batch();
    
    // Create swap document
    final swapRef = _firestore.collection('swaps').doc();
    batch.set(swapRef, {
      'id': swapRef.id,
      'bookId': bookId,
      'requesterId': requesterId,
      'ownerId': ownerId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Update book status
    batch.update(
      _firestore.collection('books').doc(bookId),
      {
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      }
    );
    
    await batch.commit();
  }

  Future<void> updateSwapStatus(String swapId, String status) async {
    final batch = _firestore.batch();
    
    // Update swap status
    batch.update(
      _firestore.collection('swaps').doc(swapId),
      {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }
    );
    
    // If accepted, update book status to swapped
    if (status == 'accepted') {
      final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
      final bookId = swapDoc.data()?['bookId'];
      
      if (bookId != null) {
        batch.update(
          _firestore.collection('books').doc(bookId),
          {
            'status': 'swapped',
            'updatedAt': FieldValue.serverTimestamp(),
          }
        );
      }
    } else if (status == 'rejected') {
      // If rejected, make book available again
      final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
      final bookId = swapDoc.data()?['bookId'];
      
      if (bookId != null) {
        batch.update(
          _firestore.collection('books').doc(bookId),
          {
            'status': 'available',
            'updatedAt': FieldValue.serverTimestamp(),
          }
        );
      }
    }
    
    await batch.commit();
  }
}
