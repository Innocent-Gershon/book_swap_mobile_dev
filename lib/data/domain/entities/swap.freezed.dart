// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swap.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SwapEntity {
  String get id => throw _privateConstructorUsedError;
  String get bookId =>
      throw _privateConstructorUsedError; // The book being offered for swap
  String get requesterUserId =>
      throw _privateConstructorUsedError; // User initiating the swap
  String get ownerUserId =>
      throw _privateConstructorUsedError; // User who owns the book being offered
  SwapStatus get status => throw _privateConstructorUsedError;
  DateTime get initiatedAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  String? get message =>
      throw _privateConstructorUsedError; // Optional message from requester
  String? get counterBookId => throw _privateConstructorUsedError;

  /// Create a copy of SwapEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SwapEntityCopyWith<SwapEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SwapEntityCopyWith<$Res> {
  factory $SwapEntityCopyWith(
          SwapEntity value, $Res Function(SwapEntity) then) =
      _$SwapEntityCopyWithImpl<$Res, SwapEntity>;
  @useResult
  $Res call(
      {String id,
      String bookId,
      String requesterUserId,
      String ownerUserId,
      SwapStatus status,
      DateTime initiatedAt,
      DateTime? updatedAt,
      String? message,
      String? counterBookId});
}

/// @nodoc
class _$SwapEntityCopyWithImpl<$Res, $Val extends SwapEntity>
    implements $SwapEntityCopyWith<$Res> {
  _$SwapEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SwapEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
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
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$SwapEntityImplCopyWith<$Res>
    implements $SwapEntityCopyWith<$Res> {
  factory _$$SwapEntityImplCopyWith(
          _$SwapEntityImpl value, $Res Function(_$SwapEntityImpl) then) =
      __$$SwapEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String bookId,
      String requesterUserId,
      String ownerUserId,
      SwapStatus status,
      DateTime initiatedAt,
      DateTime? updatedAt,
      String? message,
      String? counterBookId});
}

/// @nodoc
class __$$SwapEntityImplCopyWithImpl<$Res>
    extends _$SwapEntityCopyWithImpl<$Res, _$SwapEntityImpl>
    implements _$$SwapEntityImplCopyWith<$Res> {
  __$$SwapEntityImplCopyWithImpl(
      _$SwapEntityImpl _value, $Res Function(_$SwapEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of SwapEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? bookId = null,
    Object? requesterUserId = null,
    Object? ownerUserId = null,
    Object? status = null,
    Object? initiatedAt = null,
    Object? updatedAt = freezed,
    Object? message = freezed,
    Object? counterBookId = freezed,
  }) {
    return _then(_$SwapEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
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

class _$SwapEntityImpl implements _SwapEntity {
  const _$SwapEntityImpl(
      {required this.id,
      required this.bookId,
      required this.requesterUserId,
      required this.ownerUserId,
      required this.status,
      required this.initiatedAt,
      this.updatedAt,
      this.message,
      this.counterBookId});

  @override
  final String id;
  @override
  final String bookId;
// The book being offered for swap
  @override
  final String requesterUserId;
// User initiating the swap
  @override
  final String ownerUserId;
// User who owns the book being offered
  @override
  final SwapStatus status;
  @override
  final DateTime initiatedAt;
  @override
  final DateTime? updatedAt;
  @override
  final String? message;
// Optional message from requester
  @override
  final String? counterBookId;

  @override
  String toString() {
    return 'SwapEntity(id: $id, bookId: $bookId, requesterUserId: $requesterUserId, ownerUserId: $ownerUserId, status: $status, initiatedAt: $initiatedAt, updatedAt: $updatedAt, message: $message, counterBookId: $counterBookId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SwapEntityImpl &&
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

  @override
  int get hashCode => Object.hash(runtimeType, id, bookId, requesterUserId,
      ownerUserId, status, initiatedAt, updatedAt, message, counterBookId);

  /// Create a copy of SwapEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SwapEntityImplCopyWith<_$SwapEntityImpl> get copyWith =>
      __$$SwapEntityImplCopyWithImpl<_$SwapEntityImpl>(this, _$identity);
}

abstract class _SwapEntity implements SwapEntity {
  const factory _SwapEntity(
      {required final String id,
      required final String bookId,
      required final String requesterUserId,
      required final String ownerUserId,
      required final SwapStatus status,
      required final DateTime initiatedAt,
      final DateTime? updatedAt,
      final String? message,
      final String? counterBookId}) = _$SwapEntityImpl;

  @override
  String get id;
  @override
  String get bookId; // The book being offered for swap
  @override
  String get requesterUserId; // User initiating the swap
  @override
  String get ownerUserId; // User who owns the book being offered
  @override
  SwapStatus get status;
  @override
  DateTime get initiatedAt;
  @override
  DateTime? get updatedAt;
  @override
  String? get message; // Optional message from requester
  @override
  String? get counterBookId;

  /// Create a copy of SwapEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SwapEntityImplCopyWith<_$SwapEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
