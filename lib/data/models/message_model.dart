// lib/data/models/message_model.dart
import 'package:book_swap/domain/entities/message.dart';
import 'package:book_swap/data/models/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
class MessageModel with _$MessageModel {
  const MessageModel._();

  const factory MessageModel({
    String? id, // Firestore document ID
    required String chatId,
    required String senderId,
    required String recipientId,
    required String content,
    @TimestampConverter() required DateTime timestamp,
    @Default(false) bool isRead,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) => _$MessageModelFromJson(json);

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      recipientId: data['recipientId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
    );
  }

  String get text => content;

  factory MessageModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson(data..['id'] = doc.id);
  }

  MessageEntity toEntity() {
    return MessageEntity(
      id: id ?? '',
      chatId: chatId,
      senderId: senderId,
      recipientId: recipientId,
      content: content,
      timestamp: timestamp,
      isRead: isRead,
    );
  }

  factory MessageModel.fromEntity(MessageEntity entity) {
    return MessageModel(
      id: entity.id.isEmpty ? null : entity.id,
      chatId: entity.chatId,
      senderId: entity.senderId,
      recipientId: entity.recipientId,
      content: entity.content,
      timestamp: entity.timestamp,
      isRead: entity.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
    };
  }
}