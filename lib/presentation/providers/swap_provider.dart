import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/swap_model.dart';
import 'chat_provider.dart';
import '../../services/notification_service.dart';

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
        .snapshots()
        .handleError((error) {
          print('Error loading user swaps: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final swaps = snapshot.docs
                .map((doc) {
                  try {
                    return SwapModel.fromFirestore(doc);
                  } catch (e) {
                    print('Error parsing swap ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<SwapModel>()
                .toList();
            swaps.sort((a, b) => b.initiatedAt.compareTo(a.initiatedAt));
            return swaps;
          } catch (e) {
            print('Error processing user swaps: $e');
            return <SwapModel>[];
          }
        });
  }

  Stream<List<SwapModel>> getSwapRequestsStream(String userId) {
    return _firestore
        .collection('swaps')
        .where('ownerUserId', isEqualTo: userId)
        .snapshots()
        .handleError((error) {
          print('Error loading swap requests: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final swaps = snapshot.docs
                .map((doc) {
                  try {
                    return SwapModel.fromFirestore(doc);
                  } catch (e) {
                    print('Error parsing swap ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<SwapModel>()
                .toList();
            swaps.sort((a, b) => b.initiatedAt.compareTo(a.initiatedAt));
            return swaps;
          } catch (e) {
            print('Error processing swap requests: $e');
            return <SwapModel>[];
          }
        });
  }

  Future<void> createSwapRequest({
    required String bookId,
    required String requesterId,
    required String ownerId,
  }) async {
    final batch = _firestore.batch();
    
    // Get book details for notification
    final bookDoc = await _firestore.collection('books').doc(bookId).get();
    final bookTitle = bookDoc.data()?['title'] ?? 'Unknown Book';
    
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
    
    // Get requester name
    final requesterDoc = await _firestore.collection('users').doc(requesterId).get();
    final requesterName = requesterDoc.data()?['name'] ?? 'Someone';
    
    // Create notification for book owner
    await NotificationService().createNotification(
      userId: ownerId,
      type: 'swap_request',
      title: 'New Swap Request',
      message: '$requesterName wants to swap your book. Go to My Listings to accept or reject.',
      swapId: swapRef.id,
      bookTitle: bookTitle,
    );
    
    // Create notification for requester (confirmation)
    await NotificationService().createNotification(
      userId: requesterId,
      type: 'swap_request_sent',
      title: 'Swap Request Sent',
      message: 'Your request for "$bookTitle" has been sent. Waiting for owner approval.',
      swapId: swapRef.id,
      bookTitle: bookTitle,
    );
  }

  Future<void> updateSwapStatus(String swapId, String status) async {
    final batch = _firestore.batch();
    
    // Get the swap document first to get book ID and user IDs
    final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
    final swapData = swapDoc.data();
    
    if (swapData == null) return;
    
    final bookId = swapData['bookId'] as String;
    final ownerUserId = swapData['ownerUserId'] as String;
    final requesterUserId = swapData['requesterUserId'] as String;
    
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
    
    // Create chat and notification if swap is accepted
    if (status == 'accepted') {
      final chatService = ChatService();
      await chatService.createOrGetChat(ownerUserId, requesterUserId);
      
      // Get book details for notification
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      final bookTitle = bookDoc.data()?['title'] ?? 'Unknown Book';
      
      // Create notification for requester
      await NotificationService().createNotification(
        userId: requesterUserId,
        type: 'swap_accepted',
        title: 'Swap Request Accepted!',
        message: 'Your request for "$bookTitle" has been accepted',
        swapId: swapId,
        bookTitle: bookTitle,
      );
    }
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
