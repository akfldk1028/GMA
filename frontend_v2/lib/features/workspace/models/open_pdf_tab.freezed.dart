// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'open_pdf_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

OpenPdfTab _$OpenPdfTabFromJson(Map<String, dynamic> json) {
  return _OpenPdfTab.fromJson(json);
}

/// @nodoc
mixin _$OpenPdfTab {
  String get path => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  int get lastPageNumber => throw _privateConstructorUsedError;
  String? get pdfRegistryId => throw _privateConstructorUsedError;

  /// Serializes this OpenPdfTab to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OpenPdfTab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpenPdfTabCopyWith<OpenPdfTab> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpenPdfTabCopyWith<$Res> {
  factory $OpenPdfTabCopyWith(
    OpenPdfTab value,
    $Res Function(OpenPdfTab) then,
  ) = _$OpenPdfTabCopyWithImpl<$Res, OpenPdfTab>;
  @useResult
  $Res call({
    String path,
    String title,
    int lastPageNumber,
    String? pdfRegistryId,
  });
}

/// @nodoc
class _$OpenPdfTabCopyWithImpl<$Res, $Val extends OpenPdfTab>
    implements $OpenPdfTabCopyWith<$Res> {
  _$OpenPdfTabCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpenPdfTab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? title = null,
    Object? lastPageNumber = null,
    Object? pdfRegistryId = freezed,
  }) {
    return _then(
      _value.copyWith(
            path: null == path
                ? _value.path
                : path // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            lastPageNumber: null == lastPageNumber
                ? _value.lastPageNumber
                : lastPageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            pdfRegistryId: freezed == pdfRegistryId
                ? _value.pdfRegistryId
                : pdfRegistryId // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OpenPdfTabImplCopyWith<$Res>
    implements $OpenPdfTabCopyWith<$Res> {
  factory _$$OpenPdfTabImplCopyWith(
    _$OpenPdfTabImpl value,
    $Res Function(_$OpenPdfTabImpl) then,
  ) = __$$OpenPdfTabImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String path,
    String title,
    int lastPageNumber,
    String? pdfRegistryId,
  });
}

/// @nodoc
class __$$OpenPdfTabImplCopyWithImpl<$Res>
    extends _$OpenPdfTabCopyWithImpl<$Res, _$OpenPdfTabImpl>
    implements _$$OpenPdfTabImplCopyWith<$Res> {
  __$$OpenPdfTabImplCopyWithImpl(
    _$OpenPdfTabImpl _value,
    $Res Function(_$OpenPdfTabImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OpenPdfTab
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? path = null,
    Object? title = null,
    Object? lastPageNumber = null,
    Object? pdfRegistryId = freezed,
  }) {
    return _then(
      _$OpenPdfTabImpl(
        path: null == path
            ? _value.path
            : path // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        lastPageNumber: null == lastPageNumber
            ? _value.lastPageNumber
            : lastPageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        pdfRegistryId: freezed == pdfRegistryId
            ? _value.pdfRegistryId
            : pdfRegistryId // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OpenPdfTabImpl implements _OpenPdfTab {
  const _$OpenPdfTabImpl({
    required this.path,
    required this.title,
    this.lastPageNumber = 0,
    this.pdfRegistryId,
  });

  factory _$OpenPdfTabImpl.fromJson(Map<String, dynamic> json) =>
      _$$OpenPdfTabImplFromJson(json);

  @override
  final String path;
  @override
  final String title;
  @override
  @JsonKey()
  final int lastPageNumber;
  @override
  final String? pdfRegistryId;

  @override
  String toString() {
    return 'OpenPdfTab(path: $path, title: $title, lastPageNumber: $lastPageNumber, pdfRegistryId: $pdfRegistryId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpenPdfTabImpl &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.lastPageNumber, lastPageNumber) ||
                other.lastPageNumber == lastPageNumber) &&
            (identical(other.pdfRegistryId, pdfRegistryId) ||
                other.pdfRegistryId == pdfRegistryId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, path, title, lastPageNumber, pdfRegistryId);

  /// Create a copy of OpenPdfTab
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpenPdfTabImplCopyWith<_$OpenPdfTabImpl> get copyWith =>
      __$$OpenPdfTabImplCopyWithImpl<_$OpenPdfTabImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OpenPdfTabImplToJson(this);
  }
}

abstract class _OpenPdfTab implements OpenPdfTab {
  const factory _OpenPdfTab({
    required final String path,
    required final String title,
    final int lastPageNumber,
    final String? pdfRegistryId,
  }) = _$OpenPdfTabImpl;

  factory _OpenPdfTab.fromJson(Map<String, dynamic> json) =
      _$OpenPdfTabImpl.fromJson;

  @override
  String get path;
  @override
  String get title;
  @override
  int get lastPageNumber;
  @override
  String? get pdfRegistryId;

  /// Create a copy of OpenPdfTab
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpenPdfTabImplCopyWith<_$OpenPdfTabImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
