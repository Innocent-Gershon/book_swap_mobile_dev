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
      initiatedAt:
          const TimestampConverter().fromJson(json['initiatedAt'] as Timestamp),
      updatedAt: _$JsonConverterFromJson<Timestamp, DateTime>(
          json['updatedAt'], const TimestampConverter().fromJson),
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
      'updatedAt': _$JsonConverterToJson<Timestamp, DateTime>(
          instance.updatedAt, const TimestampConverter().toJson),
      'message': instance.message,
      'counterBookId': instance.counterBookId,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);
