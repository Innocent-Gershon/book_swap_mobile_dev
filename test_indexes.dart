// Test script to verify Firestore indexes are working
// Run this with: dart test_indexes.dart

import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // Initialize Firestore (you'll need to set up Firebase first)
  final firestore = FirebaseFirestore.instance;
  
  print('Testing Firestore indexes...');
  
  try {
    // Test query 1: Get user swaps (requesterUserId + initiatedAt)
    print('Testing getUserSwapsStream query...');
    final userSwapsQuery = firestore
        .collection('swaps')
        .where('requesterUserId', isEqualTo: 'test-user-id')
        .orderBy('initiatedAt', descending: true)
        .limit(1);
    
    final userSwapsSnapshot = await userSwapsQuery.get();
    print('✓ getUserSwapsStream query executed successfully');
    print('  Found ${userSwapsSnapshot.docs.length} documents');
    
    // Test query 2: Get swap requests (ownerUserId + initiatedAt)
    print('Testing getSwapRequestsStream query...');
    final swapRequestsQuery = firestore
        .collection('swaps')
        .where('ownerUserId', isEqualTo: 'test-user-id')
        .orderBy('initiatedAt', descending: true)
        .limit(1);
    
    final swapRequestsSnapshot = await swapRequestsQuery.get();
    print('✓ getSwapRequestsStream query executed successfully');
    print('  Found ${swapRequestsSnapshot.docs.length} documents');
    
    print('\n🎉 All index tests passed! The offer tab should now work correctly.');
    
  } catch (e) {
    print('❌ Error testing indexes: $e');
    print('Make sure Firebase is properly initialized and the indexes are deployed.');
  }
}
