// lib/data/datasources/swap_remote_datasource.dart
import 'package:book_swap/core/errors/exceptions.dart';
import 'package:book_swap/data/domain/entities/swap.dart';
import 'package:book_swap/data/models/swap_model.dart';
import 'package:book_swap/presentation/providers/firebase_providers.dart';
// import 'package:book_swap/core/errors/exceptions.dart';
// import 'package:book_swap/core/providers/firebase_providers.dart';
// import 'package:book_swap/data/models/swap_model.dart';
// import 'package:book_swap/domain/entities/swap.dart'; // Import SwapStatus
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class SwapRemoteDataSource {
  Future<SwapModel> initiateSwap(SwapModel swap);
  Future<void> updateSwapStatus(String swapId, SwapStatus status);
  Future<void> updateSwap(SwapModel swap);
  Future<SwapModel> getSwapById(String swapId);
  Stream<List<SwapModel>> getMyInitiatedSwaps(String userId);
  Stream<List<SwapModel>> getSwapsForMyBooks(String userId);
}

class SwapRemoteDataSourceImpl implements SwapRemoteDataSource {
  final FirebaseFirestore _firestore;

  SwapRemoteDataSourceImpl(this._firestore);

  @override
  Future<SwapModel> initiateSwap(SwapModel swap) async {
    try {
      final docRef = await _firestore.collection('swaps').add(swap.toJson());
      return swap.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to initiate swap: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error initiating swap: $e');
    }
  }

  @override
  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    try {
      await _firestore.collection('swaps').doc(swapId).update({
        'status': status.label,
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
      });
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update swap status: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error updating swap status: $e');
    }
  }

  @override
  Future<void> updateSwap(SwapModel swap) async {
    try {
      if (swap.id == null) {
        throw const DatabaseException('Swap ID is required for update.');
      }
      await _firestore.collection('swaps').doc(swap.id).update(swap.toJson()..['updatedAt'] = FieldValue.serverTimestamp());
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to update swap: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error updating swap: $e');
    }
  }

  @override
  Future<SwapModel> getSwapById(String swapId) async {
    try {
      final doc = await _firestore.collection('swaps').doc(swapId).get();
      if (!doc.exists) {
        throw const DatabaseException('Swap not found.');
      }
      return SwapModel.fromDocumentSnapshot(doc);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get swap by ID: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error getting swap by ID: $e');
    }
  }

  @override
  Stream<List<SwapModel>> getMyInitiatedSwaps(String userId) {
    try {
      return _firestore
          .collection('swaps')
          .where('requesterUserId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => SwapModel.fromDocumentSnapshot(doc)).toList();
      });
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get initiated swaps: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error getting initiated swaps: $e');
    }
  }

  @override
  Stream<List<SwapModel>> getSwapsForMyBooks(String userId) {
    try {
      return _firestore
          .collection('swaps')
          .where('ownerUserId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => SwapModel.fromDocumentSnapshot(doc)).toList();
      });
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get swaps for user\'s books: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error getting swaps for user\'s books: $e');
    }
  }
}

final swapRemoteDataSourceProvider = Provider<SwapRemoteDataSource>((ref) {
  return SwapRemoteDataSourceImpl(ref.watch(firebaseFirestoreProvider));
});