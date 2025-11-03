import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
class MessageEntity with _$MessageEntity {
  const factory MessageEntity({
    required String id,
    required String chatId,
    required String senderId,
    required String recipientId,
    required String content,
    required DateTime timestamp,
    @Default(false) bool isRead,
  }) = _MessageEntity;
}
