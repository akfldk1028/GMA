// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'note_metadata_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

NoteMetadata _$NoteMetadataFromJson(Map<String, dynamic> json) {
  return _NoteMetadata.fromJson(json);
}

/// @nodoc
mixin _$NoteMetadata {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get modifiedAt => throw _privateConstructorUsedError;
  String? get linkedPdfPath => throw _privateConstructorUsedError;
  String? get previewText => throw _privateConstructorUsedError;

  /// Serializes this NoteMetadata to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NoteMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NoteMetadataCopyWith<NoteMetadata> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NoteMetadataCopyWith<$Res> {
  factory $NoteMetadataCopyWith(
    NoteMetadata value,
    $Res Function(NoteMetadata) then,
  ) = _$NoteMetadataCopyWithImpl<$Res, NoteMetadata>;
  @useResult
  $Res call({
    String id,
    String title,
    String filePath,
    DateTime createdAt,
    DateTime modifiedAt,
    String? linkedPdfPath,
    String? previewText,
  });
}

/// @nodoc
class _$NoteMetadataCopyWithImpl<$Res, $Val extends NoteMetadata>
    implements $NoteMetadataCopyWith<$Res> {
  _$NoteMetadataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NoteMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? filePath = null,
    Object? createdAt = null,
    Object? modifiedAt = null,
    Object? linkedPdfPath = freezed,
    Object? previewText = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            modifiedAt: null == modifiedAt
                ? _value.modifiedAt
                : modifiedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            linkedPdfPath: freezed == linkedPdfPath
                ? _value.linkedPdfPath
                : linkedPdfPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            previewText: freezed == previewText
                ? _value.previewText
                : previewText // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NoteMetadataImplCopyWith<$Res>
    implements $NoteMetadataCopyWith<$Res> {
  factory _$$NoteMetadataImplCopyWith(
    _$NoteMetadataImpl value,
    $Res Function(_$NoteMetadataImpl) then,
  ) = __$$NoteMetadataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String filePath,
    DateTime createdAt,
    DateTime modifiedAt,
    String? linkedPdfPath,
    String? previewText,
  });
}

/// @nodoc
class __$$NoteMetadataImplCopyWithImpl<$Res>
    extends _$NoteMetadataCopyWithImpl<$Res, _$NoteMetadataImpl>
    implements _$$NoteMetadataImplCopyWith<$Res> {
  __$$NoteMetadataImplCopyWithImpl(
    _$NoteMetadataImpl _value,
    $Res Function(_$NoteMetadataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NoteMetadata
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? filePath = null,
    Object? createdAt = null,
    Object? modifiedAt = null,
    Object? linkedPdfPath = freezed,
    Object? previewText = freezed,
  }) {
    return _then(
      _$NoteMetadataImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        modifiedAt: null == modifiedAt
            ? _value.modifiedAt
            : modifiedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        linkedPdfPath: freezed == linkedPdfPath
            ? _value.linkedPdfPath
            : linkedPdfPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        previewText: freezed == previewText
            ? _value.previewText
            : previewText // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NoteMetadataImpl extends _NoteMetadata {
  const _$NoteMetadataImpl({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.modifiedAt,
    this.linkedPdfPath,
    this.previewText,
  }) : super._();

  factory _$NoteMetadataImpl.fromJson(Map<String, dynamic> json) =>
      _$$NoteMetadataImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String filePath;
  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;
  @override
  final String? linkedPdfPath;
  @override
  final String? previewText;

  @override
  String toString() {
    return 'NoteMetadata(id: $id, title: $title, filePath: $filePath, createdAt: $createdAt, modifiedAt: $modifiedAt, linkedPdfPath: $linkedPdfPath, previewText: $previewText)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NoteMetadataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.modifiedAt, modifiedAt) ||
                other.modifiedAt == modifiedAt) &&
            (identical(other.linkedPdfPath, linkedPdfPath) ||
                other.linkedPdfPath == linkedPdfPath) &&
            (identical(other.previewText, previewText) ||
                other.previewText == previewText));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    filePath,
    createdAt,
    modifiedAt,
    linkedPdfPath,
    previewText,
  );

  /// Create a copy of NoteMetadata
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NoteMetadataImplCopyWith<_$NoteMetadataImpl> get copyWith =>
      __$$NoteMetadataImplCopyWithImpl<_$NoteMetadataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NoteMetadataImplToJson(this);
  }
}

abstract class _NoteMetadata extends NoteMetadata {
  const factory _NoteMetadata({
    required final String id,
    required final String title,
    required final String filePath,
    required final DateTime createdAt,
    required final DateTime modifiedAt,
    final String? linkedPdfPath,
    final String? previewText,
  }) = _$NoteMetadataImpl;
  const _NoteMetadata._() : super._();

  factory _NoteMetadata.fromJson(Map<String, dynamic> json) =
      _$NoteMetadataImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String get filePath;
  @override
  DateTime get createdAt;
  @override
  DateTime get modifiedAt;
  @override
  String? get linkedPdfPath;
  @override
  String? get previewText;

  /// Create a copy of NoteMetadata
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NoteMetadataImplCopyWith<_$NoteMetadataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
