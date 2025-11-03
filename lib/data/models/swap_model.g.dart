// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SwapModelImpl _$$SwapModelImplFromJson(Map<String, dynamic> json) =>
    _$SwapModelImpl(
      bookId: json['bookId'] as String,
      requesterUserId: json['requesterUserId'] as String,
      ownerUserId: json['ownerUserId'] as String,
      status: const SwapStatusConverter().fromJson(json['status'] as String),
      initiatedAt: DateTime.parse(json['initiatedAt'] as String),
      updatedAt:
          const TimestampConverter().fromJson(json['updatedAt'] as Timestamp?),
      message: json['message'] as String?,
      counterBookId: json['counterBookId'] as String?,
    );

Map<String, dynamic> _$$SwapModelImplToJson(_$SwapModelImpl instance) =>
    <String, dynamic>{
      'bookId': instance.bookId,
      'requesterUserId': instance.requesterUserId,
      'ownerUserId': instance.ownerUserId,
      'status': const SwapStatusConverter().toJson(instance.status),
      'initiatedAt': instance.initiatedAt.toIso8601String(),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
      'message': instance.message,
      'counterBookId': instance.counterBookId,
    };
