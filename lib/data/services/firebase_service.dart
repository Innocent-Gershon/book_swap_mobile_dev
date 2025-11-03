import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_swap/data/models/book_model.dart';
import 'package:book_swap/data/models/chat_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth methods
  static User? get currentUser => _auth.currentUser;
  
  static Future<UserCredential> signUp(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // Store user data in Firestore
    if (credential.user != null) {
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    
    await credential.user?.sendEmailVerification();
    return credential;
  }

  static Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> resendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  // Book CRUD operations
  static Future<void> createBook(BookModel book) async {
    await _firestore.collection('books').doc(book.id).set(book.toMap());
  }

  static Stream<List<BookModel>> getBooksStream() {
    return _firestore
        .collection('books')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  static Stream<List<BookModel>> getUserBooksStream(String userId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookModel.fromFirestore(doc))
            .toList());
  }

  static Future<void> updateBook(BookModel book) async {
    await _firestore.collection('books').doc(book.id).update(book.toMap());
  }

  static Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  // Swap operations
  static Future<void> initiateSwap(String bookId, String requesterId) async {
    await _firestore.collection('books').doc(bookId).update({
      'status': SwapStatus.pending.name,
      'swapRequesterId': requesterId,
    });
  }

  // Chat operations
  static Future<String> createChat(List<String> participants, String? bookId) async {
    final chatRef = _firestore.collection('chats').doc();
    final chat = Chat(
      id: chatRef.id,
      participants: participants,
      bookId: bookId,
      createdAt: DateTime.now(),
    );
    await chatRef.set(chat.toMap());
    return chatRef.id;
  }

  static Stream<List<Chat>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chat.fromFirestore(doc))
            .toList());
  }

  static Future<Chat?> findExistingChat(String userId1, String userId2, String? bookId) async {
    final query = await _firestore
        .collection('chats')
        .where('participants', arrayContains: userId1)
        .get();
    
    for (final doc in query.docs) {
      final chat = Chat.fromFirestore(doc);
      if (chat.participants.contains(userId2) && chat.bookId == bookId) {
        return chat;
      }
    }
    return null;
  }

  static Future<void> sendMessage(String chatId, ChatMessage message) async {
    final batch = _firestore.batch();
    
    // Add message
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();
    batch.set(messageRef, message.copyWith(id: messageRef.id).toMap());
    
    // Update chat last message
    final chatRef = _firestore.collection('chats').doc(chatId);
    batch.update(chatRef, {
      'lastMessage': message.message,
      'lastMessageTime': message.timestamp.toIso8601String(),
    });
    
    await batch.commit();
  }

  static Future<String?> getUserEmail(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['email'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Stream<List<ChatMessage>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromFirestore(doc))
            .toList());
  }
}

extension ChatMessageExtension on ChatMessage {
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
