import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_swap/data/models/book_model.dart';
import 'package:book_swap/data/models/chat_model.dart';
import 'package:book_swap/data/services/firebase_service.dart';

// Auth providers
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return FirebaseService.currentUser;
});

// Book providers
final booksStreamProvider = StreamProvider<List<BookModel>>((ref) {
  return FirebaseService.getBooksStream();
});

final userBooksStreamProvider = StreamProvider.family<List<BookModel>, String>((ref, userId) {
  return FirebaseService.getUserBooksStream(userId);
});

// Chat providers
final userChatsStreamProvider = StreamProvider.family<List<Chat>, String>((ref, userId) {
  return FirebaseService.getUserChatsStream(userId);
});

final chatMessagesStreamProvider = StreamProvider.family<List<ChatMessage>, String>((ref, chatId) {
  return FirebaseService.getChatMessagesStream(chatId);
});

// Settings provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier();
});

class NotificationSettings {
  final bool swapNotifications;
  final bool chatNotifications;
  final bool emailNotifications;

  NotificationSettings({
    this.swapNotifications = true,
    this.chatNotifications = true,
    this.emailNotifications = true,
  });

  NotificationSettings copyWith({
    bool? swapNotifications,
    bool? chatNotifications,
    bool? emailNotifications,
  }) {
    return NotificationSettings(
      swapNotifications: swapNotifications ?? this.swapNotifications,
      chatNotifications: chatNotifications ?? this.chatNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(NotificationSettings());

  void toggleSwapNotifications() {
    state = state.copyWith(swapNotifications: !state.swapNotifications);
  }

  void toggleChatNotifications() {
    state = state.copyWith(chatNotifications: !state.chatNotifications);
  }

  void toggleEmailNotifications() {
    state = state.copyWith(emailNotifications: !state.emailNotifications);
  }
}
