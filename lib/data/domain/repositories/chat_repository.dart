// lib/domain/repositories/chat_repository.dart
import 'package:book_swap/core/errors/failures.dart';
import 'package:book_swap/data/domain/entities/message.dart';
// import 'package:book_swap/domain/entities/message.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepository {
  Future<Either<Failure, Unit>> sendMessage(MessageEntity message);
  Stream<Either<Failure, List<MessageEntity>>> getChatMessages(String chatId);
  Stream<Either<Failure, List<String>>> getUserChatIds(String userId); // Get list of chat IDs for a user
  // Optionally: Stream<Either<Failure, List<ChatEntity>>> getUserChats(String userId);
  // (If you want to have a ChatEntity for metadata about the chat)
}