// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_registry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PdfRegistryEntry _$PdfRegistryEntryFromJson(Map<String, dynamic> json) {
  return _PdfRegistryEntry.fromJson(json);
}

/// @nodoc
mixin _$PdfRegistryEntry {
  String get id => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  DateTime get registeredAt => throw _privateConstructorUsedError;

  /// Serializes this PdfRegistryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfRegistryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfRegistryEntryCopyWith<PdfRegistryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfRegistryEntryCopyWith<$Res> {
  factory $PdfRegistryEntryCopyWith(
    PdfRegistryEntry value,
    $Res Function(PdfRegistryEntry) then,
  ) = _$PdfRegistryEntryCopyWithImpl<$Res, PdfRegistryEntry>;
  @useResult
  $Res call({String id, String path, DateTime registeredAt});
}

/// @nodoc
class _$PdfRegistryEntryCopyWithImpl<$Res, $Val extends PdfRegistryEntry>
    implements $PdfRegistryEntryCopyWith<$Res> {
  _$PdfRegistryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfRegistryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? registeredAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            registeredAt: null == registeredAt
                ? _value.registeredAt
                : registeredAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfRegistryEntryImplCopyWith<$Res>
    implements $PdfRegistryEntryCopyWith<$Res> {
  factory _$$PdfRegistryEntryImplCopyWith(
    _$PdfRegistryEntryImpl value,
    $Res Function(_$PdfRegistryEntryImpl) then,
  ) = __$$PdfRegistryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String path, DateTime registeredAt});
}

/// @nodoc
class __$$PdfRegistryEntryImplCopyWithImpl<$Res>
    extends _$PdfRegistryEntryCopyWithImpl<$Res, _$PdfRegistryEntryImpl>
    implements _$$PdfRegistryEntryImplCopyWith<$Res> {
  __$$PdfRegistryEntryImplCopyWithImpl(
    _$PdfRegistryEntryImpl _value,
    $Res Function(_$PdfRegistryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfRegistryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? path = null,
    Object? registeredAt = null,
  }) {
    return _then(
      _$PdfRegistryEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        registeredAt: null == registeredAt
            ? _value.registeredAt
            : registeredAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfRegistryEntryImpl implements _PdfRegistryEntry {
  const _$PdfRegistryEntryImpl({
    required this.id,
    required this.path,
    required this.registeredAt,
  });

  factory _$PdfRegistryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfRegistryEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String path;
  @override
  final DateTime registeredAt;

  @override
  String toString() {
    return 'PdfRegistryEntry(id: $id, path: $path, registeredAt: $registeredAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfRegistryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.registeredAt, registeredAt) ||
                other.registeredAt == registeredAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, path, registeredAt);

  /// Create a copy of PdfRegistryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfRegistryEntryImplCopyWith<_$PdfRegistryEntryImpl> get copyWith =>
      __$$PdfRegistryEntryImplCopyWithImpl<_$PdfRegistryEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfRegistryEntryImplToJson(this);
  }
}

abstract class _PdfRegistryEntry implements PdfRegistryEntry {
  const factory _PdfRegistryEntry({
    required final String id,
    required final String path,
    required final DateTime registeredAt,
  }) = _$PdfRegistryEntryImpl;

  factory _PdfRegistryEntry.fromJson(Map<String, dynamic> json) =
      _$PdfRegistryEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get path;
  @override
  DateTime get registeredAt;

  /// Create a copy of PdfRegistryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfRegistryEntryImplCopyWith<_$PdfRegistryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
