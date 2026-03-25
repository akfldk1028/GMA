// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_marker_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PdfMarker _$PdfMarkerFromJson(Map<String, dynamic> json) {
  return _PdfMarker.fromJson(json);
}

/// @nodoc
mixin _$PdfMarker {
  String get id => throw _privateConstructorUsedError;
  int get pageNumber => throw _privateConstructorUsedError;
  MarkerColor get color => throw _privateConstructorUsedError;
  String? get selectedText => throw _privateConstructorUsedError;
  @PdfRectConverter()
  PdfRect? get textRect => throw _privateConstructorUsedError;
  @PdfRectListConverter()
  List<PdfRect>? get lineRects => throw _privateConstructorUsedError;
  String? get capturedImagePath => throw _privateConstructorUsedError;

  /// Serializes this PdfMarker to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfMarker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfMarkerCopyWith<PdfMarker> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfMarkerCopyWith<$Res> {
  factory $PdfMarkerCopyWith(PdfMarker value, $Res Function(PdfMarker) then) =
      _$PdfMarkerCopyWithImpl<$Res, PdfMarker>;
  @useResult
  $Res call({
    String id,
    int pageNumber,
    MarkerColor color,
    String? selectedText,
    @PdfRectConverter() PdfRect? textRect,
    @PdfRectListConverter() List<PdfRect>? lineRects,
    String? capturedImagePath,
  });
}

/// @nodoc
class _$PdfMarkerCopyWithImpl<$Res, $Val extends PdfMarker>
    implements $PdfMarkerCopyWith<$Res> {
  _$PdfMarkerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfMarker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageNumber = null,
    Object? color = null,
    Object? selectedText = freezed,
    Object? textRect = freezed,
    Object? lineRects = freezed,
    Object? capturedImagePath = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            pageNumber: null == pageNumber
                ? _value.pageNumber
                : pageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as MarkerColor,
            selectedText: freezed == selectedText
                ? _value.selectedText
                : selectedText // ignore: cast_nullable_to_non_nullable
                      as String?,
            textRect: freezed == textRect
                ? _value.textRect
                : textRect // ignore: cast_nullable_to_non_nullable
                      as PdfRect?,
            lineRects: freezed == lineRects
                ? _value.lineRects
                : lineRects // ignore: cast_nullable_to_non_nullable
                      as List<PdfRect>?,
            capturedImagePath: freezed == capturedImagePath
                ? _value.capturedImagePath
                : capturedImagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfMarkerImplCopyWith<$Res>
    implements $PdfMarkerCopyWith<$Res> {
  factory _$$PdfMarkerImplCopyWith(
    _$PdfMarkerImpl value,
    $Res Function(_$PdfMarkerImpl) then,
  ) = __$$PdfMarkerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int pageNumber,
    MarkerColor color,
    String? selectedText,
    @PdfRectConverter() PdfRect? textRect,
    @PdfRectListConverter() List<PdfRect>? lineRects,
    String? capturedImagePath,
  });
}

/// @nodoc
class __$$PdfMarkerImplCopyWithImpl<$Res>
    extends _$PdfMarkerCopyWithImpl<$Res, _$PdfMarkerImpl>
    implements _$$PdfMarkerImplCopyWith<$Res> {
  __$$PdfMarkerImplCopyWithImpl(
    _$PdfMarkerImpl _value,
    $Res Function(_$PdfMarkerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfMarker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageNumber = null,
    Object? color = null,
    Object? selectedText = freezed,
    Object? textRect = freezed,
    Object? lineRects = freezed,
    Object? capturedImagePath = freezed,
  }) {
    return _then(
      _$PdfMarkerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as MarkerColor,
        selectedText: freezed == selectedText
            ? _value.selectedText
            : selectedText // ignore: cast_nullable_to_non_nullable
                  as String?,
        textRect: freezed == textRect
            ? _value.textRect
            : textRect // ignore: cast_nullable_to_non_nullable
                  as PdfRect?,
        lineRects: freezed == lineRects
            ? _value._lineRects
            : lineRects // ignore: cast_nullable_to_non_nullable
                  as List<PdfRect>?,
        capturedImagePath: freezed == capturedImagePath
            ? _value.capturedImagePath
            : capturedImagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfMarkerImpl implements _PdfMarker {
  const _$PdfMarkerImpl({
    required this.id,
    required this.pageNumber,
    required this.color,
    this.selectedText,
    @PdfRectConverter() this.textRect,
    @PdfRectListConverter() final List<PdfRect>? lineRects,
    this.capturedImagePath,
  }) : _lineRects = lineRects;

  factory _$PdfMarkerImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfMarkerImplFromJson(json);

  @override
  final String id;
  @override
  final int pageNumber;
  @override
  final MarkerColor color;
  @override
  final String? selectedText;
  @override
  @PdfRectConverter()
  final PdfRect? textRect;
  final List<PdfRect>? _lineRects;
  @override
  @PdfRectListConverter()
  List<PdfRect>? get lineRects {
    final value = _lineRects;
    if (value == null) return null;
    if (_lineRects is EqualUnmodifiableListView) return _lineRects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? capturedImagePath;

  @override
  String toString() {
    return 'PdfMarker(id: $id, pageNumber: $pageNumber, color: $color, selectedText: $selectedText, textRect: $textRect, lineRects: $lineRects, capturedImagePath: $capturedImagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfMarkerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.selectedText, selectedText) ||
                other.selectedText == selectedText) &&
            (identical(other.textRect, textRect) ||
                other.textRect == textRect) &&
            const DeepCollectionEquality().equals(
              other._lineRects,
              _lineRects,
            ) &&
            (identical(other.capturedImagePath, capturedImagePath) ||
                other.capturedImagePath == capturedImagePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pageNumber,
    color,
    selectedText,
    textRect,
    const DeepCollectionEquality().hash(_lineRects),
    capturedImagePath,
  );

  /// Create a copy of PdfMarker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfMarkerImplCopyWith<_$PdfMarkerImpl> get copyWith =>
      __$$PdfMarkerImplCopyWithImpl<_$PdfMarkerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfMarkerImplToJson(this);
  }
}

abstract class _PdfMarker implements PdfMarker {
  const factory _PdfMarker({
    required final String id,
    required final int pageNumber,
    required final MarkerColor color,
    final String? selectedText,
    @PdfRectConverter() final PdfRect? textRect,
    @PdfRectListConverter() final List<PdfRect>? lineRects,
    final String? capturedImagePath,
  }) = _$PdfMarkerImpl;

  factory _PdfMarker.fromJson(Map<String, dynamic> json) =
      _$PdfMarkerImpl.fromJson;

  @override
  String get id;
  @override
  int get pageNumber;
  @override
  MarkerColor get color;
  @override
  String? get selectedText;
  @override
  @PdfRectConverter()
  PdfRect? get textRect;
  @override
  @PdfRectListConverter()
  List<PdfRect>? get lineRects;
  @override
  String? get capturedImagePath;

  /// Create a copy of PdfMarker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfMarkerImplCopyWith<_$PdfMarkerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
