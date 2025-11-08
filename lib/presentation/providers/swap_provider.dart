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
        .where('requesterUserId', isEqualTo: userId)
        .orderBy('initiatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SwapModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<SwapModel>> getSwapRequestsStream(String userId) {
    return _firestore
        .collection('swaps')
        .where('ownerUserId', isEqualTo: userId)
        .orderBy('initiatedAt', descending: true)
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
      'bookId': bookId,
      'requesterUserId': requesterId,
      'ownerUserId': ownerId,
      'status': 'pending',
      'initiatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Update book status
    batch.update(
      _firestore.collection('books').doc(bookId),
      {
        'status': 'pending',
        'swapRequesterId': requesterId,
      }
    );
    
    await batch.commit();
  }

  Future<void> updateSwapStatus(String swapId, String status) async {
    final batch = _firestore.batch();
    
    // Get the swap document first to get book ID
    final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
    final swapData = swapDoc.data();
    
    if (swapData == null) return;
    
    final bookId = swapData['bookId'] as String;
    
    // Update swap status
    batch.update(
      _firestore.collection('swaps').doc(swapId),
      {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      }
    );
    
    // Update book status based on swap decision
    if (status == 'accepted') {
      batch.update(
        _firestore.collection('books').doc(bookId),
        {
          'status': 'swapped',
        }
      );
    } else if (status == 'rejected') {
      batch.update(
        _firestore.collection('books').doc(bookId),
        {
          'status': 'available',
          'swapRequesterId': FieldValue.delete(),
        }
      );
    }
    
    await batch.commit();
  }

  Future<void> updateSwapStatusByBookId(String bookId, String status) async {
    // Find swap by book ID
    final swapQuery = await _firestore
        .collection('swaps')
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'pending')
        .limit(1)
        .get();
    
    if (swapQuery.docs.isEmpty) return;
    
    final swapDoc = swapQuery.docs.first;
    await updateSwapStatus(swapDoc.id, status);
  }
}
