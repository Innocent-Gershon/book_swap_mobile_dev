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

final totalUnreadCountProvider = StreamProvider.family<int, String>((ref, userId) {
  return ref.watch(chatServiceProvider).getTotalUnreadCountStream(userId);
});

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .handleError((error) {
          print('Error loading user chats: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final chats = snapshot.docs
                .map((doc) {
                  try {
                    return {'id': doc.id, ...doc.data()};
                  } catch (e) {
                    print('Error parsing chat ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<Map<String, dynamic>>()
                .toList();
            
            // Sort in memory instead of using orderBy to avoid index requirement
            chats.sort((a, b) {
              final aTime = a['lastMessageAt'];
              final bTime = b['lastMessageAt'];
              if (aTime == null && bTime == null) return 0;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });
            
            return chats;
          } catch (e) {
            print('Error processing user chats: $e');
            return <Map<String, dynamic>>[];
          }
        });
  }

  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .handleError((error) {
          print('Error loading messages: $error');
          return const Stream.empty();
        })
        .map((snapshot) {
          try {
            final messages = snapshot.docs
                .map((doc) {
                  try {
                    return MessageModel.fromFirestore(doc);
                  } catch (e) {
                    print('Error parsing message ${doc.id}: $e');
                    return null;
                  }
                })
                .whereType<MessageModel>()
                .toList();
            
            // Sort in memory
            messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            
            return messages;
          } catch (e) {
            print('Error processing messages: $e');
            return <MessageModel>[];
          }
        });
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
      'unreadCount_$userId1': 0,
      'unreadCount_$userId2': 0,
    });
    
    return chatRef.id;
  }
  
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Check if chat exists
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) {
        print('Chat does not exist: $chatId');
        return;
      }
      
      // Reset unread count for this user
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount_$userId': 0,
      });
      
      // Mark all messages as read
      final messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      if (messages.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (var doc in messages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }
  
  Stream<int> getTotalUnreadCountStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
          int total = 0;
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final unreadCount = data['unreadCount_$userId'] ?? 0;
            total += unreadCount as int;
          }
          return total;
        });
  }

  Future<void> editMessage(String chatId, String messageId, String newContent) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'content': newContent,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error editing message: $e');
      rethrow;
    }
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      print('Error deleting message: $e');
      rethrow;
    }
  }

  Future<String> getOtherUserName(String chatId, String currentUserId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) return 'User';
      
      final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
      final otherUserId = participants.firstWhere(
        (id) => id != currentUserId,
        orElse: () => '',
      );
      
      if (otherUserId.isEmpty) return 'User';
      
      final userDoc = await _firestore.collection('users').doc(otherUserId).get();
      return userDoc.data()?['name'] ?? 'User';
    } catch (e) {
      print('Error getting other user name: $e');
      return 'User';
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        throw Exception('Chat not found');
      }
      
      final chatData = chatDoc.data();
      if (chatData == null) {
        throw Exception('Chat data is null');
      }
      
      final participants = List<String>.from(chatData['participants'] ?? []);
      if (participants.isEmpty) {
        throw Exception('No participants');
      }
      
      final recipientId = participants.firstWhere(
        (id) => id != senderId,
        orElse: () => '',
      );
      
      if (recipientId.isEmpty) {
        throw Exception('Recipient not found');
      }
      
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'chatId': chatId,
        'senderId': senderId,
        'recipientId': recipientId,
        'content': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'isEdited': false,
      });
      
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'unreadCount_$recipientId': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
}
