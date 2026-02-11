// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'frontmatter_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Frontmatter _$FrontmatterFromJson(Map<String, dynamic> json) {
  return _Frontmatter.fromJson(json);
}

/// @nodoc
mixin _$Frontmatter {
  String get title => throw _privateConstructorUsedError;
  String? get linkedPdfPath => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get modifiedAt => throw _privateConstructorUsedError;

  /// Serializes this Frontmatter to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Frontmatter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FrontmatterCopyWith<Frontmatter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FrontmatterCopyWith<$Res> {
  factory $FrontmatterCopyWith(
    Frontmatter value,
    $Res Function(Frontmatter) then,
  ) = _$FrontmatterCopyWithImpl<$Res, Frontmatter>;
  @useResult
  $Res call({
    String title,
    String? linkedPdfPath,
    List<String> tags,
    DateTime createdAt,
    DateTime modifiedAt,
  });
}

/// @nodoc
class _$FrontmatterCopyWithImpl<$Res, $Val extends Frontmatter>
    implements $FrontmatterCopyWith<$Res> {
  _$FrontmatterCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Frontmatter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? linkedPdfPath = freezed,
    Object? tags = null,
    Object? createdAt = null,
    Object? modifiedAt = null,
  }) {
    return _then(
      _value.copyWith(
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            linkedPdfPath: freezed == linkedPdfPath
                ? _value.linkedPdfPath
                : linkedPdfPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            modifiedAt: null == modifiedAt
                ? _value.modifiedAt
                : modifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FrontmatterImplCopyWith<$Res>
    implements $FrontmatterCopyWith<$Res> {
  factory _$$FrontmatterImplCopyWith(
    _$FrontmatterImpl value,
    $Res Function(_$FrontmatterImpl) then,
  ) = __$$FrontmatterImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String title,
    String? linkedPdfPath,
    List<String> tags,
    DateTime createdAt,
    DateTime modifiedAt,
  });
}

/// @nodoc
class __$$FrontmatterImplCopyWithImpl<$Res>
    extends _$FrontmatterCopyWithImpl<$Res, _$FrontmatterImpl>
    implements _$$FrontmatterImplCopyWith<$Res> {
  __$$FrontmatterImplCopyWithImpl(
    _$FrontmatterImpl _value,
    $Res Function(_$FrontmatterImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Frontmatter
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? linkedPdfPath = freezed,
    Object? tags = null,
    Object? createdAt = null,
    Object? modifiedAt = null,
  }) {
    return _then(
      _$FrontmatterImpl(
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        linkedPdfPath: freezed == linkedPdfPath
            ? _value.linkedPdfPath
            : linkedPdfPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        modifiedAt: null == modifiedAt
            ? _value.modifiedAt
            : modifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FrontmatterImpl implements _Frontmatter {
  const _$FrontmatterImpl({
    required this.title,
    this.linkedPdfPath,
    final List<String> tags = const [],
    required this.createdAt,
    required this.modifiedAt,
  }) : _tags = tags;

  factory _$FrontmatterImpl.fromJson(Map<String, dynamic> json) =>
      _$$FrontmatterImplFromJson(json);

  @override
  final String title;
  @override
  final String? linkedPdfPath;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;

  @override
  String toString() {
    return 'Frontmatter(title: $title, linkedPdfPath: $linkedPdfPath, tags: $tags, createdAt: $createdAt, modifiedAt: $modifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrontmatterImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.linkedPdfPath, linkedPdfPath) ||
                other.linkedPdfPath == linkedPdfPath) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.modifiedAt, modifiedAt) ||
                other.modifiedAt == modifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    title,
    linkedPdfPath,
    const DeepCollectionEquality().hash(_tags),
    createdAt,
    modifiedAt,
  );

  /// Create a copy of Frontmatter
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FrontmatterImplCopyWith<_$FrontmatterImpl> get copyWith =>
      __$$FrontmatterImplCopyWithImpl<_$FrontmatterImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FrontmatterImplToJson(this);
  }
}

abstract class _Frontmatter implements Frontmatter {
  const factory _Frontmatter({
    required final String title,
    final String? linkedPdfPath,
    final List<String> tags,
    required final DateTime createdAt,
    required final DateTime modifiedAt,
  }) = _$FrontmatterImpl;

  factory _Frontmatter.fromJson(Map<String, dynamic> json) =
      _$FrontmatterImpl.fromJson;

  @override
  String get title;
  @override
  String? get linkedPdfPath;
  @override
  List<String> get tags;
  @override
  DateTime get createdAt;
  @override
  DateTime get modifiedAt;

  /// Create a copy of Frontmatter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrontmatterImplCopyWith<_$FrontmatterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
