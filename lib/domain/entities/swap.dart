import 'package:freezed_annotation/freezed_annotation.dart';

part 'swap.freezed.dart';

enum SwapStatus {
  pending('pending'),
  accepted('accepted'),
  rejected('rejected'),
  completed('completed'),
  cancelled('cancelled');

  const SwapStatus(this.label);
  final String label;
}

@freezed
class SwapEntity with _$SwapEntity {
  const factory SwapEntity({
    required String id,
    required String bookId,
    required String requesterUserId,
    required String ownerUserId,
    required SwapStatus status,
    required DateTime initiatedAt,
    DateTime? updatedAt,
    String? message,
    String? counterBookId,
  }) = _SwapEntity;
}
