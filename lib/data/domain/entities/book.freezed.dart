// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'book.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BookEntity {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get author => throw _privateConstructorUsedError;
  String get userId =>
      throw _privateConstructorUsedError; // ID of the user who posted the book
  String get condition =>
      throw _privateConstructorUsedError; // e.g., 'New', 'Like New', 'Good', 'Used'
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get description =>
      throw _privateConstructorUsedError; // Optional: for more details
  String? get swapFor =>
      throw _privateConstructorUsedError; // What the user is looking to swap for
  bool get isAvailable =>
      throw _privateConstructorUsedError; // Can be set to false if swapped/deleted
  DateTime get postedDate => throw _privateConstructorUsedError;

  /// Create a copy of BookEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BookEntityCopyWith<BookEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookEntityCopyWith<$Res> {
  factory $BookEntityCopyWith(
          BookEntity value, $Res Function(BookEntity) then) =
      _$BookEntityCopyWithImpl<$Res, BookEntity>;
  @useResult
  $Res call(
      {String id,
      String title,
      String author,
      String userId,
      String condition,
      String? imageUrl,
      String? description,
      String? swapFor,
      bool isAvailable,
      DateTime postedDate});
}

/// @nodoc
class _$BookEntityCopyWithImpl<$Res, $Val extends BookEntity>
    implements $BookEntityCopyWith<$Res> {
  _$BookEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BookEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? userId = null,
    Object? condition = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? swapFor = freezed,
    Object? isAvailable = null,
    Object? postedDate = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      swapFor: freezed == swapFor
          ? _value.swapFor
          : swapFor // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      postedDate: null == postedDate
          ? _value.postedDate
          : postedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookEntityImplCopyWith<$Res>
    implements $BookEntityCopyWith<$Res> {
  factory _$$BookEntityImplCopyWith(
          _$BookEntityImpl value, $Res Function(_$BookEntityImpl) then) =
      __$$BookEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String title,
      String author,
      String userId,
      String condition,
      String? imageUrl,
      String? description,
      String? swapFor,
      bool isAvailable,
      DateTime postedDate});
}

/// @nodoc
class __$$BookEntityImplCopyWithImpl<$Res>
    extends _$BookEntityCopyWithImpl<$Res, _$BookEntityImpl>
    implements _$$BookEntityImplCopyWith<$Res> {
  __$$BookEntityImplCopyWithImpl(
      _$BookEntityImpl _value, $Res Function(_$BookEntityImpl) _then)
      : super(_value, _then);

  /// Create a copy of BookEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? author = null,
    Object? userId = null,
    Object? condition = null,
    Object? imageUrl = freezed,
    Object? description = freezed,
    Object? swapFor = freezed,
    Object? isAvailable = null,
    Object? postedDate = null,
  }) {
    return _then(_$BookEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as String,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      swapFor: freezed == swapFor
          ? _value.swapFor
          : swapFor // ignore: cast_nullable_to_non_nullable
              as String?,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
      postedDate: null == postedDate
          ? _value.postedDate
          : postedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$BookEntityImpl implements _BookEntity {
  const _$BookEntityImpl(
      {required this.id,
      required this.title,
      required this.author,
      required this.userId,
      required this.condition,
      this.imageUrl,
      this.description,
      this.swapFor,
      this.isAvailable = true,
      required this.postedDate});

  @override
  final String id;
  @override
  final String title;
  @override
  final String author;
  @override
  final String userId;
// ID of the user who posted the book
  @override
  final String condition;
// e.g., 'New', 'Like New', 'Good', 'Used'
  @override
  final String? imageUrl;
  @override
  final String? description;
// Optional: for more details
  @override
  final String? swapFor;
// What the user is looking to swap for
  @override
  @JsonKey()
  final bool isAvailable;
// Can be set to false if swapped/deleted
  @override
  final DateTime postedDate;

  @override
  String toString() {
    return 'BookEntity(id: $id, title: $title, author: $author, userId: $userId, condition: $condition, imageUrl: $imageUrl, description: $description, swapFor: $swapFor, isAvailable: $isAvailable, postedDate: $postedDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.swapFor, swapFor) || other.swapFor == swapFor) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable) &&
            (identical(other.postedDate, postedDate) ||
                other.postedDate == postedDate));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, title, author, userId,
      condition, imageUrl, description, swapFor, isAvailable, postedDate);

  /// Create a copy of BookEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BookEntityImplCopyWith<_$BookEntityImpl> get copyWith =>
      __$$BookEntityImplCopyWithImpl<_$BookEntityImpl>(this, _$identity);
}

abstract class _BookEntity implements BookEntity {
  const factory _BookEntity(
      {required final String id,
      required final String title,
      required final String author,
      required final String userId,
      required final String condition,
      final String? imageUrl,
      final String? description,
      final String? swapFor,
      final bool isAvailable,
      required final DateTime postedDate}) = _$BookEntityImpl;

  @override
  String get id;
  @override
  String get title;
  @override
  String get author;
  @override
  String get userId; // ID of the user who posted the book
  @override
  String get condition; // e.g., 'New', 'Like New', 'Good', 'Used'
  @override
  String? get imageUrl;
  @override
  String? get description; // Optional: for more details
  @override
  String? get swapFor; // What the user is looking to swap for
  @override
  bool get isAvailable; // Can be set to false if swapped/deleted
  @override
  DateTime get postedDate;

  /// Create a copy of BookEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BookEntityImplCopyWith<_$BookEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
