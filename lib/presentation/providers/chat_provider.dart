import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/message_model.dart';

final chatServiceProvider = Provider((ref) => ChatService());

final userChatsStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
  return ref.watch(chatServiceProvider).getUserChatsStream(userId);
});

final messagesStreamProvider = StreamProvider.family<List<MessageModel>, String>((ref, chatId) {
  return ref.watch(chatServiceProvider).getMessagesStream(chatId);
});

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }

  Future<String> createOrGetChat(String userId1, String userId2) async {
    // Check if chat already exists
    final existingChat = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId1)
        .get();
    
    for (var doc in existingChat.docs) {
      final participants = List<String>.from(doc.data()['participants']);
      if (participants.contains(userId2)) {
        return doc.id;
      }
    }
    
    // Create new chat
    final chatRef = _firestore.collection('chats').doc();
    await chatRef.set({
      'participants': [userId1, userId2],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
    
    return chatRef.id;
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final batch = _firestore.batch();
    
    // Add message
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    
    batch.set(messageRef, {
      'id': messageRef.id,
      'chatId': chatId,
      'senderId': senderId,
      'recipientId': '', // Will be populated with actual recipient
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
    
    // Update chat last message
    batch.update(
      _firestore.collection('chats').doc(chatId),
      {
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
      }
    );
    
    await batch.commit();
  }
}
