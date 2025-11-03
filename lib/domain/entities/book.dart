import 'package:freezed_annotation/freezed_annotation.dart';

part 'book.freezed.dart';

@freezed
class BookEntity with _$BookEntity {
  const factory BookEntity({
    required String id,
    required String title,
    required String author,
    required String description,
    required String condition,
    required String ownerId,
    required String imageUrl,
    required bool isAvailable,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime postedDate,
    String? swapFor,
  }) = _BookEntity;
}
