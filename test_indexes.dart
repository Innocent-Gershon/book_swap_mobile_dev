// Test script to verify Firestore indexes are working
// Run this with: dart test_indexes.dart

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Initialize Firestore (you'll need to set up Firebase first)
  final firestore = FirebaseFirestore.instance;
  
  
  try {
    // Test query 1: Get user swaps (requesterUserId + initiatedAt)
    final userSwapsQuery = firestore
        .collection('swaps')
        .where('requesterUserId', isEqualTo: 'test-user-id')
        .orderBy('initiatedAt', descending: true)
        .limit(1);
    
    await userSwapsQuery.get();
    
    // Test query 2: Get swap requests (ownerUserId + initiatedAt)
    final swapRequestsQuery = firestore
        .collection('swaps')
        .where('ownerUserId', isEqualTo: 'test-user-id')
        .orderBy('initiatedAt', descending: true)
        .limit(1);
    
    await swapRequestsQuery.get();
    
    // Queries executed successfully
  } catch (e) {
    // Index creation may be required - check Firebase Console
  }
}
