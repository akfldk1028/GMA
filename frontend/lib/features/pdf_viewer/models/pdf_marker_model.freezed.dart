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

PdfRect _$PdfRectFromJson(Map<String, dynamic> json) {
  return _PdfRect.fromJson(json);
}

/// @nodoc
mixin _$PdfRect {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height => throw _privateConstructorUsedError;

  /// Serializes this PdfRect to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfRect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfRectCopyWith<PdfRect> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfRectCopyWith<$Res> {
  factory $PdfRectCopyWith(PdfRect value, $Res Function(PdfRect) then) =
      _$PdfRectCopyWithImpl<$Res, PdfRect>;
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class _$PdfRectCopyWithImpl<$Res, $Val extends PdfRect>
    implements $PdfRectCopyWith<$Res> {
  _$PdfRectCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfRect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _value.copyWith(
            x: null == x
                ? _value.x
                : x // ignore: cast_nullable_to_non_nullable
                      as double,
            y: null == y
                ? _value.y
                : y // ignore: cast_nullable_to_non_nullable
                      as double,
            width: null == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as double,
            height: null == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfRectImplCopyWith<$Res> implements $PdfRectCopyWith<$Res> {
  factory _$$PdfRectImplCopyWith(
    _$PdfRectImpl value,
    $Res Function(_$PdfRectImpl) then,
  ) = __$$PdfRectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double width, double height});
}

/// @nodoc
class __$$PdfRectImplCopyWithImpl<$Res>
    extends _$PdfRectCopyWithImpl<$Res, _$PdfRectImpl>
    implements _$$PdfRectImplCopyWith<$Res> {
  __$$PdfRectImplCopyWithImpl(
    _$PdfRectImpl _value,
    $Res Function(_$PdfRectImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfRect
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
  }) {
    return _then(
      _$PdfRectImpl(
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        width: null == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as double,
        height: null == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfRectImpl implements _PdfRect {
  const _$PdfRectImpl({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory _$PdfRectImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfRectImplFromJson(json);

  @override
  final double x;
  @override
  final double y;
  @override
  final double width;
  @override
  final double height;

  @override
  String toString() {
    return 'PdfRect(x: $x, y: $y, width: $width, height: $height)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfRectImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, width, height);

  /// Create a copy of PdfRect
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfRectImplCopyWith<_$PdfRectImpl> get copyWith =>
      __$$PdfRectImplCopyWithImpl<_$PdfRectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfRectImplToJson(this);
  }
}

abstract class _PdfRect implements PdfRect {
  const factory _PdfRect({
    required final double x,
    required final double y,
    required final double width,
    required final double height,
  }) = _$PdfRectImpl;

  factory _PdfRect.fromJson(Map<String, dynamic> json) = _$PdfRectImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height;

  /// Create a copy of PdfRect
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfRectImplCopyWith<_$PdfRectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

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
    String? capturedImagePath,
  });

  $PdfRectCopyWith<$Res>? get textRect;
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
            capturedImagePath: freezed == capturedImagePath
                ? _value.capturedImagePath
                : capturedImagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of PdfMarker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PdfRectCopyWith<$Res>? get textRect {
    if (_value.textRect == null) {
      return null;
    }

    return $PdfRectCopyWith<$Res>(_value.textRect!, (value) {
      return _then(_value.copyWith(textRect: value) as $Val);
    });
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
    String? capturedImagePath,
  });

  @override
  $PdfRectCopyWith<$Res>? get textRect;
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
    this.capturedImagePath,
  });

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
  @override
  final String? capturedImagePath;

  @override
  String toString() {
    return 'PdfMarker(id: $id, pageNumber: $pageNumber, color: $color, selectedText: $selectedText, textRect: $textRect, capturedImagePath: $capturedImagePath)';
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
  String? get capturedImagePath;

  /// Create a copy of PdfMarker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfMarkerImplCopyWith<_$PdfMarkerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
