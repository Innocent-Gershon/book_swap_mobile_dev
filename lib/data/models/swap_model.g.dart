// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swap_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SwapModelImpl _$$SwapModelImplFromJson(Map<String, dynamic> json) =>
    _$SwapModelImpl(
      id: json['id'] as String?,
      bookId: json['bookId'] as String,
      requesterUserId: json['requesterUserId'] as String,
      ownerUserId: json['ownerUserId'] as String,
      status: const SwapStatusConverter().fromJson(json['status'] as String),
      initiatedAt: const TimestampConverter().fromJson(json['initiatedAt']),
      updatedAt: const TimestampConverter().fromJson(json['updatedAt']),
      message: json['message'] as String?,
      counterBookId: json['counterBookId'] as String?,
    );

Map<String, dynamic> _$$SwapModelImplToJson(_$SwapModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookId': instance.bookId,
      'requesterUserId': instance.requesterUserId,
      'ownerUserId': instance.ownerUserId,
      'status': const SwapStatusConverter().toJson(instance.status),
      'initiatedAt': const TimestampConverter().toJson(instance.initiatedAt),
      'updatedAt': _$JsonConverterToJson<dynamic, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
      'message': instance.message,
      'counterBookId': instance.counterBookId,
    };

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
