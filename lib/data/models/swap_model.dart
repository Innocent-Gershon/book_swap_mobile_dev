// lib/data/models/swap_model.dart
import 'package:book_swap/domain/entities/swap.dart';
import 'package:book_swap/data/models/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'swap_model.freezed.dart';
part 'swap_model.g.dart';

@freezed
class SwapModel with _$SwapModel {
  const SwapModel._();

  const factory SwapModel({
    String? id, // Firestore document ID
    required String bookId,
    required String requesterUserId,
    required String ownerUserId,
    @SwapStatusConverter() required SwapStatus status, // Custom converter
    @TimestampConverter() required DateTime initiatedAt,
    @TimestampConverter() DateTime? updatedAt,
    String? message,
    String? counterBookId,
  }) = _SwapModel;

  factory SwapModel.fromJson(Map<String, dynamic> json) => _$SwapModelFromJson(json);

  factory SwapModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapModel(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      requesterUserId: data['requesterUserId'] ?? '',
      ownerUserId: data['ownerUserId'] ?? '',
      status: SwapStatus.values.firstWhere(
        (e) => e.label == data['status'],
        orElse: () => SwapStatus.pending,
      ),
      initiatedAt: (data['initiatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      message: data['message'],
      counterBookId: data['counterBookId'],
    );
  }

  factory SwapModel.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapModel.fromJson(data..['id'] = doc.id);
  }

  SwapEntity toEntity() {
    return SwapEntity(
      id: id ?? '',
      bookId: bookId,
      requesterUserId: requesterUserId,
      ownerUserId: ownerUserId,
      status: status,
      initiatedAt: initiatedAt,
      updatedAt: updatedAt,
      message: message,
      counterBookId: counterBookId,
    );
  }

  factory SwapModel.fromEntity(SwapEntity entity) {
    return SwapModel(
      id: entity.id.isEmpty ? null : entity.id,
      bookId: entity.bookId,
      requesterUserId: entity.requesterUserId,
      ownerUserId: entity.ownerUserId,
      status: entity.status,
      initiatedAt: entity.initiatedAt,
      updatedAt: entity.updatedAt,
      message: entity.message,
      counterBookId: entity.counterBookId,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'bookId': bookId,
      'requesterUserId': requesterUserId,
      'ownerUserId': ownerUserId,
      'status': status.label,
      'initiatedAt': Timestamp.fromDate(initiatedAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'message': message,
      'counterBookId': counterBookId,
    };
    map.removeWhere((_, v) => v == null);
    return map;
  }
}

// Custom converter for SwapStatus enum to String
class SwapStatusConverter implements JsonConverter<SwapStatus, String> {
  const SwapStatusConverter();

  @override
  SwapStatus fromJson(String value) {
    return SwapStatus.values.firstWhere(
      (e) => e.label == value,
      orElse: () => SwapStatus.pending, // Default to pending if unknown
    );
  }

  @override
  String toJson(SwapStatus status) {
    return status.label;
  }
}