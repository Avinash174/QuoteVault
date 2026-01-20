// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quote_collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

QuoteCollection _$QuoteCollectionFromJson(Map<String, dynamic> json) {
  return _QuoteCollection.fromJson(json);
}

/// @nodoc
mixin _$QuoteCollection {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<Quote> get quotes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;

  /// Serializes this QuoteCollection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of QuoteCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $QuoteCollectionCopyWith<QuoteCollection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuoteCollectionCopyWith<$Res> {
  factory $QuoteCollectionCopyWith(
    QuoteCollection value,
    $Res Function(QuoteCollection) then,
  ) = _$QuoteCollectionCopyWithImpl<$Res, QuoteCollection>;
  @useResult
  $Res call({String id, String name, List<Quote> quotes, DateTime? createdAt});
}

/// @nodoc
class _$QuoteCollectionCopyWithImpl<$Res, $Val extends QuoteCollection>
    implements $QuoteCollectionCopyWith<$Res> {
  _$QuoteCollectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of QuoteCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quotes = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            quotes: null == quotes
                ? _value.quotes
                : quotes // ignore: cast_nullable_to_non_nullable
                      as List<Quote>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$QuoteCollectionImplCopyWith<$Res>
    implements $QuoteCollectionCopyWith<$Res> {
  factory _$$QuoteCollectionImplCopyWith(
    _$QuoteCollectionImpl value,
    $Res Function(_$QuoteCollectionImpl) then,
  ) = __$$QuoteCollectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, List<Quote> quotes, DateTime? createdAt});
}

/// @nodoc
class __$$QuoteCollectionImplCopyWithImpl<$Res>
    extends _$QuoteCollectionCopyWithImpl<$Res, _$QuoteCollectionImpl>
    implements _$$QuoteCollectionImplCopyWith<$Res> {
  __$$QuoteCollectionImplCopyWithImpl(
    _$QuoteCollectionImpl _value,
    $Res Function(_$QuoteCollectionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of QuoteCollection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? quotes = null,
    Object? createdAt = freezed,
  }) {
    return _then(
      _$QuoteCollectionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        quotes: null == quotes
            ? _value._quotes
            : quotes // ignore: cast_nullable_to_non_nullable
                  as List<Quote>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$QuoteCollectionImpl implements _QuoteCollection {
  const _$QuoteCollectionImpl({
    required this.id,
    required this.name,
    final List<Quote> quotes = const [],
    this.createdAt,
  }) : _quotes = quotes;

  factory _$QuoteCollectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$QuoteCollectionImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  final List<Quote> _quotes;
  @override
  @JsonKey()
  List<Quote> get quotes {
    if (_quotes is EqualUnmodifiableListView) return _quotes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quotes);
  }

  @override
  final DateTime? createdAt;

  @override
  String toString() {
    return 'QuoteCollection(id: $id, name: $name, quotes: $quotes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QuoteCollectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._quotes, _quotes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_quotes),
    createdAt,
  );

  /// Create a copy of QuoteCollection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$QuoteCollectionImplCopyWith<_$QuoteCollectionImpl> get copyWith =>
      __$$QuoteCollectionImplCopyWithImpl<_$QuoteCollectionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$QuoteCollectionImplToJson(this);
  }
}

abstract class _QuoteCollection implements QuoteCollection {
  const factory _QuoteCollection({
    required final String id,
    required final String name,
    final List<Quote> quotes,
    final DateTime? createdAt,
  }) = _$QuoteCollectionImpl;

  factory _QuoteCollection.fromJson(Map<String, dynamic> json) =
      _$QuoteCollectionImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<Quote> get quotes;
  @override
  DateTime? get createdAt;

  /// Create a copy of QuoteCollection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$QuoteCollectionImplCopyWith<_$QuoteCollectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
