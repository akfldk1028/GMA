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
  String get file => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get created => throw _privateConstructorUsedError;

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
    String file,
    String filePath,
    List<String> tags,
    DateTime created,
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
    Object? file = null,
    Object? filePath = null,
    Object? tags = null,
    Object? created = null,
  }) {
    return _then(
      _value.copyWith(
            file: null == file
                ? _value.file
                : file // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            created: null == created
                ? _value.created
                : created // ignore: cast_nullable_to_non_nullable
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
    String file,
    String filePath,
    List<String> tags,
    DateTime created,
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
    Object? file = null,
    Object? filePath = null,
    Object? tags = null,
    Object? created = null,
  }) {
    return _then(
      _$FrontmatterImpl(
        file: null == file
            ? _value.file
            : file // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        created: null == created
            ? _value.created
            : created // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FrontmatterImpl implements _Frontmatter {
  const _$FrontmatterImpl({
    required this.file,
    required this.filePath,
    required final List<String> tags,
    required this.created,
  }) : _tags = tags;

  factory _$FrontmatterImpl.fromJson(Map<String, dynamic> json) =>
      _$$FrontmatterImplFromJson(json);

  @override
  final String file;
  @override
  final String filePath;
  final List<String> _tags;
  @override
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime created;

  @override
  String toString() {
    return 'Frontmatter(file: $file, filePath: $filePath, tags: $tags, created: $created)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FrontmatterImpl &&
            (identical(other.file, file) || other.file == file) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.created, created) || other.created == created));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    file,
    filePath,
    const DeepCollectionEquality().hash(_tags),
    created,
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
    required final String file,
    required final String filePath,
    required final List<String> tags,
    required final DateTime created,
  }) = _$FrontmatterImpl;

  factory _Frontmatter.fromJson(Map<String, dynamic> json) =
      _$FrontmatterImpl.fromJson;

  @override
  String get file;
  @override
  String get filePath;
  @override
  List<String> get tags;
  @override
  DateTime get created;

  /// Create a copy of Frontmatter
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FrontmatterImplCopyWith<_$FrontmatterImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
