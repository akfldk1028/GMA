// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Note _$NoteFromJson(Map<String, dynamic> json) {
  return _Note.fromJson(json);
}

/// @nodoc
mixin _$Note {
  String get id => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get filePath => throw _privateConstructorUsedError;
  Frontmatter? get frontmatter => throw _privateConstructorUsedError;
  List<Marker> get markers => throw _privateConstructorUsedError;

  /// Serializes this Note to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteCopyWith<Note> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteCopyWith<$Res> {
  factory $NoteCopyWith(Note value, $Res Function(Note) then) =
      _$NoteCopyWithImpl<$Res, Note>;
  @useResult
  $Res call({
    String id,
    String content,
    String? filePath,
    Frontmatter? frontmatter,
    List<Marker> markers,
  });

  $FrontmatterCopyWith<$Res>? get frontmatter;
}

/// @nodoc
class _$NoteCopyWithImpl<$Res, $Val extends Note>
    implements $NoteCopyWith<$Res> {
  _$NoteCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? filePath = freezed,
    Object? frontmatter = freezed,
    Object? markers = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: freezed == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            frontmatter: freezed == frontmatter
                ? _value.frontmatter
                : frontmatter // ignore: cast_nullable_to_non_nullable
                      as Frontmatter?,
            markers: null == markers
                ? _value.markers
                : markers // ignore: cast_nullable_to_non_nullable
                      as List<Marker>,
          )
          as $Val,
    );
  }

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FrontmatterCopyWith<$Res>? get frontmatter {
    if (_value.frontmatter == null) {
      return null;
    }

    return $FrontmatterCopyWith<$Res>(_value.frontmatter!, (value) {
      return _then(_value.copyWith(frontmatter: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$NoteImplCopyWith<$Res> implements $NoteCopyWith<$Res> {
  factory _$$NoteImplCopyWith(
    _$NoteImpl value,
    $Res Function(_$NoteImpl) then,
  ) = __$$NoteImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String content,
    String? filePath,
    Frontmatter? frontmatter,
    List<Marker> markers,
  });

  @override
  $FrontmatterCopyWith<$Res>? get frontmatter;
}

/// @nodoc
class __$$NoteImplCopyWithImpl<$Res>
    extends _$NoteCopyWithImpl<$Res, _$NoteImpl>
    implements _$$NoteImplCopyWith<$Res> {
  __$$NoteImplCopyWithImpl(_$NoteImpl _value, $Res Function(_$NoteImpl) _then)
    : super(_value, _then);

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? content = null,
    Object? filePath = freezed,
    Object? frontmatter = freezed,
    Object? markers = null,
  }) {
    return _then(
      _$NoteImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: freezed == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        frontmatter: freezed == frontmatter
            ? _value.frontmatter
            : frontmatter // ignore: cast_nullable_to_non_nullable
                  as Frontmatter?,
        markers: null == markers
            ? _value._markers
            : markers // ignore: cast_nullable_to_non_nullable
                  as List<Marker>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoteImpl implements _Note {
  const _$NoteImpl({
    required this.id,
    required this.content,
    this.filePath,
    this.frontmatter,
    final List<Marker> markers = const [],
  }) : _markers = markers;

  factory _$NoteImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoteImplFromJson(json);

  @override
  final String id;
  @override
  final String content;
  @override
  final String? filePath;
  @override
  final Frontmatter? frontmatter;
  final List<Marker> _markers;
  @override
  @JsonKey()
  List<Marker> get markers {
    if (_markers is EqualUnmodifiableListView) return _markers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_markers);
  }

  @override
  String toString() {
    return 'Note(id: $id, content: $content, filePath: $filePath, frontmatter: $frontmatter, markers: $markers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.frontmatter, frontmatter) ||
                other.frontmatter == frontmatter) &&
            const DeepCollectionEquality().equals(other._markers, _markers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    content,
    filePath,
    frontmatter,
    const DeepCollectionEquality().hash(_markers),
  );

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteImplCopyWith<_$NoteImpl> get copyWith =>
      __$$NoteImplCopyWithImpl<_$NoteImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteImplToJson(this);
  }
}

abstract class _Note implements Note {
  const factory _Note({
    required final String id,
    required final String content,
    final String? filePath,
    final Frontmatter? frontmatter,
    final List<Marker> markers,
  }) = _$NoteImpl;

  factory _Note.fromJson(Map<String, dynamic> json) = _$NoteImpl.fromJson;

  @override
  String get id;
  @override
  String get content;
  @override
  String? get filePath;
  @override
  Frontmatter? get frontmatter;
  @override
  List<Marker> get markers;

  /// Create a copy of Note
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteImplCopyWith<_$NoteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
