// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scrapnote_page_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScrapNotePage _$ScrapNotePageFromJson(Map<String, dynamic> json) {
  return _ScrapNotePage.fromJson(json);
}

/// @nodoc
mixin _$ScrapNotePage {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<String> get elementIds => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ScrapNotePage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScrapNotePage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScrapNotePageCopyWith<ScrapNotePage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScrapNotePageCopyWith<$Res> {
  factory $ScrapNotePageCopyWith(
    ScrapNotePage value,
    $Res Function(ScrapNotePage) then,
  ) = _$ScrapNotePageCopyWithImpl<$Res, ScrapNotePage>;
  @useResult
  $Res call({
    String id,
    String name,
    List<String> elementIds,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ScrapNotePageCopyWithImpl<$Res, $Val extends ScrapNotePage>
    implements $ScrapNotePageCopyWith<$Res> {
  _$ScrapNotePageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScrapNotePage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? elementIds = null,
    Object? createdAt = null,
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
            elementIds: null == elementIds
                ? _value.elementIds
                : elementIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ScrapNotePageImplCopyWith<$Res>
    implements $ScrapNotePageCopyWith<$Res> {
  factory _$$ScrapNotePageImplCopyWith(
    _$ScrapNotePageImpl value,
    $Res Function(_$ScrapNotePageImpl) then,
  ) = __$$ScrapNotePageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    List<String> elementIds,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ScrapNotePageImplCopyWithImpl<$Res>
    extends _$ScrapNotePageCopyWithImpl<$Res, _$ScrapNotePageImpl>
    implements _$$ScrapNotePageImplCopyWith<$Res> {
  __$$ScrapNotePageImplCopyWithImpl(
    _$ScrapNotePageImpl _value,
    $Res Function(_$ScrapNotePageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScrapNotePage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? elementIds = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ScrapNotePageImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        elementIds: null == elementIds
            ? _value._elementIds
            : elementIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ScrapNotePageImpl implements _ScrapNotePage {
  const _$ScrapNotePageImpl({
    required this.id,
    this.name = 'Untitled',
    final List<String> elementIds = const [],
    required this.createdAt,
  }) : _elementIds = elementIds;

  factory _$ScrapNotePageImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScrapNotePageImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey()
  final String name;
  final List<String> _elementIds;
  @override
  @JsonKey()
  List<String> get elementIds {
    if (_elementIds is EqualUnmodifiableListView) return _elementIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elementIds);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ScrapNotePage(id: $id, name: $name, elementIds: $elementIds, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScrapNotePageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(
              other._elementIds,
              _elementIds,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    const DeepCollectionEquality().hash(_elementIds),
    createdAt,
  );

  /// Create a copy of ScrapNotePage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScrapNotePageImplCopyWith<_$ScrapNotePageImpl> get copyWith =>
      __$$ScrapNotePageImplCopyWithImpl<_$ScrapNotePageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScrapNotePageImplToJson(this);
  }
}

abstract class _ScrapNotePage implements ScrapNotePage {
  const factory _ScrapNotePage({
    required final String id,
    final String name,
    final List<String> elementIds,
    required final DateTime createdAt,
  }) = _$ScrapNotePageImpl;

  factory _ScrapNotePage.fromJson(Map<String, dynamic> json) =
      _$ScrapNotePageImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  List<String> get elementIds;
  @override
  DateTime get createdAt;

  /// Create a copy of ScrapNotePage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScrapNotePageImplCopyWith<_$ScrapNotePageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
