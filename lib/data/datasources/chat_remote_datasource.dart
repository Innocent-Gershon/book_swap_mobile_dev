// lib/data/datasources/chat_remote_datasource.dart
import 'package:book_swap/core/errors/exceptions.dart';
import 'package:book_swap/data/models/message_model.dart';
import 'package:book_swap/presentation/providers/firebase_providers.dart';
// import 'package:book_swap/core/errors/exceptions.dart';
// import 'package:book_swap/core/providers/firebase_providers.dart';
// import 'package:book_swap/data/models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class ChatRemoteDataSource {
  Future<MessageModel> sendMessage(MessageModel message);
  Stream<List<MessageModel>> getChatMessages(String chatId);
  Stream<List<String>> getUserChatIds(String userId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChatRemoteDataSourceImpl(this._firestore);

  @override
  Future<MessageModel> sendMessage(MessageModel message) async {
    try {
      final chatMessagesRef = _firestore.collection('chats').doc(message.chatId).collection('messages');
      final docRef = await chatMessagesRef.add(message.toJson());
      // Also update chat participants list if not already present
      // This ensures we can easily query for a user's chats
      final chatRef = _firestore.collection('chats').doc(message.chatId);
      await chatRef.set({
        'participants': [message.senderId, message.recipientId]..sort(), // Keep sorted for consistent chat ID generation
        'lastMessage': message.content,
        'lastMessageSenderId': message.senderId,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return message.copyWith(id: docRef.id);
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to send message: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error sending message: $e');
    }
  }

  @override
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true) // Order by latest message first
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => MessageModel.fromDocumentSnapshot(doc)).toList();
      });
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get chat messages: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error getting chat messages: $e');
    }
  }

  @override
  Stream<List<String>> getUserChatIds(String userId) {
    try {
      return _firestore
          .collection('chats')
          .where('participants', arrayContains: userId)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => doc.id).toList();
      });
    } on FirebaseException catch (e) {
      throw DatabaseException('Failed to get user chat IDs: ${e.message}');
    } catch (e) {
      throw DatabaseException('Unknown error getting user chat IDs: $e');
    }
  }
}

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSourceImpl(ref.watch(firebaseFirestoreProvider));
});