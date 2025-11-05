// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SwapModel _$SwapModelFromJson(Map<String, dynamic> json) {
  return _SwapModel.fromJson(json);
}

/// @nodoc
mixin _$SwapModel {
  String? get id => throw _privateConstructorUsedError; // Firestore document ID
  String get bookId => throw _privateConstructorUsedError;
  String get requesterUserId => throw _privateConstructorUsedError;
  String get ownerUserId => throw _privateConstructorUsedError;
  @SwapStatusConverter()
  SwapStatus get status =>
      throw _privateConstructorUsedError; // Custom converter
  @TimestampConverter()
  DateTime get initiatedAt => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  String? get counterBookId => throw _privateConstructorUsedError;

  /// Serializes this SwapModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SwapModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SwapModelCopyWith<SwapModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwapModelCopyWith<$Res> {
  factory $SwapModelCopyWith(SwapModel value, $Res Function(SwapModel) then) =
      _$SwapModelCopyWithImpl<$Res, SwapModel>;
  @useResult
  $Res call(
      {String? id,
      String bookId,
      String requesterUserId,
      String ownerUserId,
      @SwapStatusConverter() SwapStatus status,
      @TimestampConverter() DateTime initiatedAt,
      @TimestampConverter() DateTime? updatedAt,
      String? message,
      String? counterBookId});
}

/// @nodoc
class _$SwapModelCopyWithImpl<$Res, $Val extends SwapModel>
    implements $SwapModelCopyWith<$Res> {
  _$SwapModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SwapModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bookId = null,
    Object? requesterUserId = null,
    Object? ownerUserId = null,
    Object? status = null,
    Object? initiatedAt = null,
    Object? updatedAt = freezed,
    Object? message = freezed,
    Object? counterBookId = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as String,
      requesterUserId: null == requesterUserId
          ? _value.requesterUserId
          : requesterUserId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUserId: null == ownerUserId
          ? _value.ownerUserId
          : ownerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SwapStatus,
      initiatedAt: null == initiatedAt
          ? _value.initiatedAt
          : initiatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      counterBookId: freezed == counterBookId
          ? _value.counterBookId
          : counterBookId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SwapModelImplCopyWith<$Res>
    implements $SwapModelCopyWith<$Res> {
  factory _$$SwapModelImplCopyWith(
          _$SwapModelImpl value, $Res Function(_$SwapModelImpl) then) =
      __$$SwapModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String bookId,
      String requesterUserId,
      String ownerUserId,
      @SwapStatusConverter() SwapStatus status,
      @TimestampConverter() DateTime initiatedAt,
      @TimestampConverter() DateTime? updatedAt,
      String? message,
      String? counterBookId});
}

/// @nodoc
class __$$SwapModelImplCopyWithImpl<$Res>
    extends _$SwapModelCopyWithImpl<$Res, _$SwapModelImpl>
    implements _$$SwapModelImplCopyWith<$Res> {
  __$$SwapModelImplCopyWithImpl(
      _$SwapModelImpl _value, $Res Function(_$SwapModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SwapModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? bookId = null,
    Object? requesterUserId = null,
    Object? ownerUserId = null,
    Object? status = null,
    Object? initiatedAt = null,
    Object? updatedAt = freezed,
    Object? message = freezed,
    Object? counterBookId = freezed,
  }) {
    return _then(_$SwapModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      bookId: null == bookId
          ? _value.bookId
          : bookId // ignore: cast_nullable_to_non_nullable
              as String,
      requesterUserId: null == requesterUserId
          ? _value.requesterUserId
          : requesterUserId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerUserId: null == ownerUserId
          ? _value.ownerUserId
          : ownerUserId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SwapStatus,
      initiatedAt: null == initiatedAt
          ? _value.initiatedAt
          : initiatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      counterBookId: freezed == counterBookId
          ? _value.counterBookId
          : counterBookId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SwapModelImpl extends _SwapModel {
  const _$SwapModelImpl(
      {this.id,
      required this.bookId,
      required this.requesterUserId,
      required this.ownerUserId,
      @SwapStatusConverter() required this.status,
      @TimestampConverter() required this.initiatedAt,
      @TimestampConverter() this.updatedAt,
      this.message,
      this.counterBookId})
      : super._();

  factory _$SwapModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SwapModelImplFromJson(json);

  @override
  final String? id;
// Firestore document ID
  @override
  final String bookId;
  @override
  final String requesterUserId;
  @override
  final String ownerUserId;
  @override
  @SwapStatusConverter()
  final SwapStatus status;
// Custom converter
  @override
  @TimestampConverter()
  final DateTime initiatedAt;
  @override
  @TimestampConverter()
  final DateTime? updatedAt;
  @override
  final String? message;
  @override
  final String? counterBookId;

  @override
  String toString() {
    return 'SwapModel(id: $id, bookId: $bookId, requesterUserId: $requesterUserId, ownerUserId: $ownerUserId, status: $status, initiatedAt: $initiatedAt, updatedAt: $updatedAt, message: $message, counterBookId: $counterBookId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwapModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.bookId, bookId) || other.bookId == bookId) &&
            (identical(other.requesterUserId, requesterUserId) ||
                other.requesterUserId == requesterUserId) &&
            (identical(other.ownerUserId, ownerUserId) ||
                other.ownerUserId == ownerUserId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.initiatedAt, initiatedAt) ||
                other.initiatedAt == initiatedAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.counterBookId, counterBookId) ||
                other.counterBookId == counterBookId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, bookId, requesterUserId,
      ownerUserId, status, initiatedAt, updatedAt, message, counterBookId);

  /// Create a copy of SwapModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SwapModelImplCopyWith<_$SwapModelImpl> get copyWith =>
      __$$SwapModelImplCopyWithImpl<_$SwapModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SwapModelImplToJson(
      this,
    );
  }
}

abstract class _SwapModel extends SwapModel {
  const factory _SwapModel(
      {final String? id,
      required final String bookId,
      required final String requesterUserId,
      required final String ownerUserId,
      @SwapStatusConverter() required final SwapStatus status,
      @TimestampConverter() required final DateTime initiatedAt,
      @TimestampConverter() final DateTime? updatedAt,
      final String? message,
      final String? counterBookId}) = _$SwapModelImpl;
  const _SwapModel._() : super._();

  factory _SwapModel.fromJson(Map<String, dynamic> json) =
      _$SwapModelImpl.fromJson;

  @override
  String? get id; // Firestore document ID
  @override
  String get bookId;
  @override
  String get requesterUserId;
  @override
  String get ownerUserId;
  @override
  @SwapStatusConverter()
  SwapStatus get status; // Custom converter
  @override
  @TimestampConverter()
  DateTime get initiatedAt;
  @override
  @TimestampConverter()
  DateTime? get updatedAt;
  @override
  String? get message;
  @override
  String? get counterBookId;

  /// Create a copy of SwapModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwapModelImplCopyWith<_$SwapModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
