// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scrapnote_canvas_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ScrapnoteCanvasData _$ScrapnoteCanvasDataFromJson(Map<String, dynamic> json) {
  return _ScrapnoteCanvasData.fromJson(json);
}

/// @nodoc
mixin _$ScrapnoteCanvasData {
  String get id => throw _privateConstructorUsedError;
  String get linkedPdfPath => throw _privateConstructorUsedError;
  CanvasMode get canvasMode => throw _privateConstructorUsedError;
  double get canvasWidth =>
      throw _privateConstructorUsedError; // null means infinite height
  double? get canvasHeight => throw _privateConstructorUsedError;
  List<DrawingStroke> get strokes => throw _privateConstructorUsedError;
  List<CanvasElement> get elements => throw _privateConstructorUsedError;
  List<String> get layerOrder => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get modifiedAt => throw _privateConstructorUsedError;

  /// Serializes this ScrapnoteCanvasData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScrapnoteCanvasData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScrapnoteCanvasDataCopyWith<ScrapnoteCanvasData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScrapnoteCanvasDataCopyWith<$Res> {
  factory $ScrapnoteCanvasDataCopyWith(
    ScrapnoteCanvasData value,
    $Res Function(ScrapnoteCanvasData) then,
  ) = _$ScrapnoteCanvasDataCopyWithImpl<$Res, ScrapnoteCanvasData>;
  @useResult
  $Res call({
    String id,
    String linkedPdfPath,
    CanvasMode canvasMode,
    double canvasWidth,
    double? canvasHeight,
    List<DrawingStroke> strokes,
    List<CanvasElement> elements,
    List<String> layerOrder,
    DateTime createdAt,
    DateTime modifiedAt,
  });
}

/// @nodoc
class _$ScrapnoteCanvasDataCopyWithImpl<$Res, $Val extends ScrapnoteCanvasData>
    implements $ScrapnoteCanvasDataCopyWith<$Res> {
  _$ScrapnoteCanvasDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScrapnoteCanvasData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? linkedPdfPath = null,
    Object? canvasMode = null,
    Object? canvasWidth = null,
    Object? canvasHeight = freezed,
    Object? strokes = null,
    Object? elements = null,
    Object? layerOrder = null,
    Object? createdAt = null,
    Object? modifiedAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            linkedPdfPath: null == linkedPdfPath
                ? _value.linkedPdfPath
                : linkedPdfPath // ignore: cast_nullable_to_non_nullable
                      as String,
            canvasMode: null == canvasMode
                ? _value.canvasMode
                : canvasMode // ignore: cast_nullable_to_non_nullable
                      as CanvasMode,
            canvasWidth: null == canvasWidth
                ? _value.canvasWidth
                : canvasWidth // ignore: cast_nullable_to_non_nullable
                      as double,
            canvasHeight: freezed == canvasHeight
                ? _value.canvasHeight
                : canvasHeight // ignore: cast_nullable_to_non_nullable
                      as double?,
            strokes: null == strokes
                ? _value.strokes
                : strokes // ignore: cast_nullable_to_non_nullable
                      as List<DrawingStroke>,
            elements: null == elements
                ? _value.elements
                : elements // ignore: cast_nullable_to_non_nullable
                      as List<CanvasElement>,
            layerOrder: null == layerOrder
                ? _value.layerOrder
                : layerOrder // ignore: cast_nullable_to_non_nullable
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
abstract class _$$ScrapnoteCanvasDataImplCopyWith<$Res>
    implements $ScrapnoteCanvasDataCopyWith<$Res> {
  factory _$$ScrapnoteCanvasDataImplCopyWith(
    _$ScrapnoteCanvasDataImpl value,
    $Res Function(_$ScrapnoteCanvasDataImpl) then,
  ) = __$$ScrapnoteCanvasDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String linkedPdfPath,
    CanvasMode canvasMode,
    double canvasWidth,
    double? canvasHeight,
    List<DrawingStroke> strokes,
    List<CanvasElement> elements,
    List<String> layerOrder,
    DateTime createdAt,
    DateTime modifiedAt,
  });
}

/// @nodoc
class __$$ScrapnoteCanvasDataImplCopyWithImpl<$Res>
    extends _$ScrapnoteCanvasDataCopyWithImpl<$Res, _$ScrapnoteCanvasDataImpl>
    implements _$$ScrapnoteCanvasDataImplCopyWith<$Res> {
  __$$ScrapnoteCanvasDataImplCopyWithImpl(
    _$ScrapnoteCanvasDataImpl _value,
    $Res Function(_$ScrapnoteCanvasDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ScrapnoteCanvasData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? linkedPdfPath = null,
    Object? canvasMode = null,
    Object? canvasWidth = null,
    Object? canvasHeight = freezed,
    Object? strokes = null,
    Object? elements = null,
    Object? layerOrder = null,
    Object? createdAt = null,
    Object? modifiedAt = null,
  }) {
    return _then(
      _$ScrapnoteCanvasDataImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        linkedPdfPath: null == linkedPdfPath
            ? _value.linkedPdfPath
            : linkedPdfPath // ignore: cast_nullable_to_non_nullable
                  as String,
        canvasMode: null == canvasMode
            ? _value.canvasMode
            : canvasMode // ignore: cast_nullable_to_non_nullable
                  as CanvasMode,
        canvasWidth: null == canvasWidth
            ? _value.canvasWidth
            : canvasWidth // ignore: cast_nullable_to_non_nullable
                  as double,
        canvasHeight: freezed == canvasHeight
            ? _value.canvasHeight
            : canvasHeight // ignore: cast_nullable_to_non_nullable
                  as double?,
        strokes: null == strokes
            ? _value._strokes
            : strokes // ignore: cast_nullable_to_non_nullable
                  as List<DrawingStroke>,
        elements: null == elements
            ? _value._elements
            : elements // ignore: cast_nullable_to_non_nullable
                  as List<CanvasElement>,
        layerOrder: null == layerOrder
            ? _value._layerOrder
            : layerOrder // ignore: cast_nullable_to_non_nullable
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
class _$ScrapnoteCanvasDataImpl implements _ScrapnoteCanvasData {
  const _$ScrapnoteCanvasDataImpl({
    required this.id,
    required this.linkedPdfPath,
    this.canvasMode = CanvasMode.infinite,
    this.canvasWidth = 1080.0,
    this.canvasHeight,
    final List<DrawingStroke> strokes = const [],
    final List<CanvasElement> elements = const [],
    final List<String> layerOrder = const [],
    required this.createdAt,
    required this.modifiedAt,
  }) : _strokes = strokes,
       _elements = elements,
       _layerOrder = layerOrder;

  factory _$ScrapnoteCanvasDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScrapnoteCanvasDataImplFromJson(json);

  @override
  final String id;
  @override
  final String linkedPdfPath;
  @override
  @JsonKey()
  final CanvasMode canvasMode;
  @override
  @JsonKey()
  final double canvasWidth;
  // null means infinite height
  @override
  final double? canvasHeight;
  final List<DrawingStroke> _strokes;
  @override
  @JsonKey()
  List<DrawingStroke> get strokes {
    if (_strokes is EqualUnmodifiableListView) return _strokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strokes);
  }

  final List<CanvasElement> _elements;
  @override
  @JsonKey()
  List<CanvasElement> get elements {
    if (_elements is EqualUnmodifiableListView) return _elements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elements);
  }

  final List<String> _layerOrder;
  @override
  @JsonKey()
  List<String> get layerOrder {
    if (_layerOrder is EqualUnmodifiableListView) return _layerOrder;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_layerOrder);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime modifiedAt;

  @override
  String toString() {
    return 'ScrapnoteCanvasData(id: $id, linkedPdfPath: $linkedPdfPath, canvasMode: $canvasMode, canvasWidth: $canvasWidth, canvasHeight: $canvasHeight, strokes: $strokes, elements: $elements, layerOrder: $layerOrder, createdAt: $createdAt, modifiedAt: $modifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScrapnoteCanvasDataImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.linkedPdfPath, linkedPdfPath) ||
                other.linkedPdfPath == linkedPdfPath) &&
            (identical(other.canvasMode, canvasMode) ||
                other.canvasMode == canvasMode) &&
            (identical(other.canvasWidth, canvasWidth) ||
                other.canvasWidth == canvasWidth) &&
            (identical(other.canvasHeight, canvasHeight) ||
                other.canvasHeight == canvasHeight) &&
            const DeepCollectionEquality().equals(other._strokes, _strokes) &&
            const DeepCollectionEquality().equals(other._elements, _elements) &&
            const DeepCollectionEquality().equals(
              other._layerOrder,
              _layerOrder,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.modifiedAt, modifiedAt) ||
                other.modifiedAt == modifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    linkedPdfPath,
    canvasMode,
    canvasWidth,
    canvasHeight,
    const DeepCollectionEquality().hash(_strokes),
    const DeepCollectionEquality().hash(_elements),
    const DeepCollectionEquality().hash(_layerOrder),
    createdAt,
    modifiedAt,
  );

  /// Create a copy of ScrapnoteCanvasData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScrapnoteCanvasDataImplCopyWith<_$ScrapnoteCanvasDataImpl> get copyWith =>
      __$$ScrapnoteCanvasDataImplCopyWithImpl<_$ScrapnoteCanvasDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ScrapnoteCanvasDataImplToJson(this);
  }
}

abstract class _ScrapnoteCanvasData implements ScrapnoteCanvasData {
  const factory _ScrapnoteCanvasData({
    required final String id,
    required final String linkedPdfPath,
    final CanvasMode canvasMode,
    final double canvasWidth,
    final double? canvasHeight,
    final List<DrawingStroke> strokes,
    final List<CanvasElement> elements,
    final List<String> layerOrder,
    required final DateTime createdAt,
    required final DateTime modifiedAt,
  }) = _$ScrapnoteCanvasDataImpl;

  factory _ScrapnoteCanvasData.fromJson(Map<String, dynamic> json) =
      _$ScrapnoteCanvasDataImpl.fromJson;

  @override
  String get id;
  @override
  String get linkedPdfPath;
  @override
  CanvasMode get canvasMode;
  @override
  double get canvasWidth; // null means infinite height
  @override
  double? get canvasHeight;
  @override
  List<DrawingStroke> get strokes;
  @override
  List<CanvasElement> get elements;
  @override
  List<String> get layerOrder;
  @override
  DateTime get createdAt;
  @override
  DateTime get modifiedAt;

  /// Create a copy of ScrapnoteCanvasData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScrapnoteCanvasDataImplCopyWith<_$ScrapnoteCanvasDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CanvasElement _$CanvasElementFromJson(Map<String, dynamic> json) {
  return _CanvasElement.fromJson(json);
}

/// @nodoc
mixin _$CanvasElement {
  String get id => throw _privateConstructorUsedError;
  CanvasElementType get type => throw _privateConstructorUsedError;
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double get width => throw _privateConstructorUsedError;
  double get height =>
      throw _privateConstructorUsedError; // Path to a captured image file (for capture-type elements)
  String? get imagePath =>
      throw _privateConstructorUsedError; // Highlighted or selected text from the PDF
  String? get selectedText =>
      throw _privateConstructorUsedError; // Color as ARGB int (e.g., 0xFFFFFF00 for yellow)
  int? get colorValue =>
      throw _privateConstructorUsedError; // Source PDF page number (1-indexed), null if unknown
  int? get sourcePageNumber =>
      throw _privateConstructorUsedError; // Path of the source PDF from which this element was extracted
  String? get sourcePdfPath =>
      throw _privateConstructorUsedError; // Source region on the PDF page (for rendering highlight rectangles on PDF)
  @PdfRectConverter()
  PdfRect? get sourceRect => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this CanvasElement to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CanvasElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CanvasElementCopyWith<CanvasElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CanvasElementCopyWith<$Res> {
  factory $CanvasElementCopyWith(
    CanvasElement value,
    $Res Function(CanvasElement) then,
  ) = _$CanvasElementCopyWithImpl<$Res, CanvasElement>;
  @useResult
  $Res call({
    String id,
    CanvasElementType type,
    double x,
    double y,
    double width,
    double height,
    String? imagePath,
    String? selectedText,
    int? colorValue,
    int? sourcePageNumber,
    String? sourcePdfPath,
    @PdfRectConverter() PdfRect? sourceRect,
    DateTime createdAt,
  });
}

/// @nodoc
class _$CanvasElementCopyWithImpl<$Res, $Val extends CanvasElement>
    implements $CanvasElementCopyWith<$Res> {
  _$CanvasElementCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CanvasElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? imagePath = freezed,
    Object? selectedText = freezed,
    Object? colorValue = freezed,
    Object? sourcePageNumber = freezed,
    Object? sourcePdfPath = freezed,
    Object? sourceRect = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as CanvasElementType,
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
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            selectedText: freezed == selectedText
                ? _value.selectedText
                : selectedText // ignore: cast_nullable_to_non_nullable
                      as String?,
            colorValue: freezed == colorValue
                ? _value.colorValue
                : colorValue // ignore: cast_nullable_to_non_nullable
                      as int?,
            sourcePageNumber: freezed == sourcePageNumber
                ? _value.sourcePageNumber
                : sourcePageNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            sourcePdfPath: freezed == sourcePdfPath
                ? _value.sourcePdfPath
                : sourcePdfPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourceRect: freezed == sourceRect
                ? _value.sourceRect
                : sourceRect // ignore: cast_nullable_to_non_nullable
                      as PdfRect?,
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
abstract class _$$CanvasElementImplCopyWith<$Res>
    implements $CanvasElementCopyWith<$Res> {
  factory _$$CanvasElementImplCopyWith(
    _$CanvasElementImpl value,
    $Res Function(_$CanvasElementImpl) then,
  ) = __$$CanvasElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    CanvasElementType type,
    double x,
    double y,
    double width,
    double height,
    String? imagePath,
    String? selectedText,
    int? colorValue,
    int? sourcePageNumber,
    String? sourcePdfPath,
    @PdfRectConverter() PdfRect? sourceRect,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$CanvasElementImplCopyWithImpl<$Res>
    extends _$CanvasElementCopyWithImpl<$Res, _$CanvasElementImpl>
    implements _$$CanvasElementImplCopyWith<$Res> {
  __$$CanvasElementImplCopyWithImpl(
    _$CanvasElementImpl _value,
    $Res Function(_$CanvasElementImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CanvasElement
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? x = null,
    Object? y = null,
    Object? width = null,
    Object? height = null,
    Object? imagePath = freezed,
    Object? selectedText = freezed,
    Object? colorValue = freezed,
    Object? sourcePageNumber = freezed,
    Object? sourcePdfPath = freezed,
    Object? sourceRect = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$CanvasElementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as CanvasElementType,
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
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        selectedText: freezed == selectedText
            ? _value.selectedText
            : selectedText // ignore: cast_nullable_to_non_nullable
                  as String?,
        colorValue: freezed == colorValue
            ? _value.colorValue
            : colorValue // ignore: cast_nullable_to_non_nullable
                  as int?,
        sourcePageNumber: freezed == sourcePageNumber
            ? _value.sourcePageNumber
            : sourcePageNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        sourcePdfPath: freezed == sourcePdfPath
            ? _value.sourcePdfPath
            : sourcePdfPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourceRect: freezed == sourceRect
            ? _value.sourceRect
            : sourceRect // ignore: cast_nullable_to_non_nullable
                  as PdfRect?,
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
class _$CanvasElementImpl implements _CanvasElement {
  const _$CanvasElementImpl({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.imagePath,
    this.selectedText,
    this.colorValue,
    this.sourcePageNumber,
    this.sourcePdfPath,
    @PdfRectConverter() this.sourceRect,
    required this.createdAt,
  });

  factory _$CanvasElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$CanvasElementImplFromJson(json);

  @override
  final String id;
  @override
  final CanvasElementType type;
  @override
  final double x;
  @override
  final double y;
  @override
  final double width;
  @override
  final double height;
  // Path to a captured image file (for capture-type elements)
  @override
  final String? imagePath;
  // Highlighted or selected text from the PDF
  @override
  final String? selectedText;
  // Color as ARGB int (e.g., 0xFFFFFF00 for yellow)
  @override
  final int? colorValue;
  // Source PDF page number (1-indexed), null if unknown
  @override
  final int? sourcePageNumber;
  // Path of the source PDF from which this element was extracted
  @override
  final String? sourcePdfPath;
  // Source region on the PDF page (for rendering highlight rectangles on PDF)
  @override
  @PdfRectConverter()
  final PdfRect? sourceRect;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'CanvasElement(id: $id, type: $type, x: $x, y: $y, width: $width, height: $height, imagePath: $imagePath, selectedText: $selectedText, colorValue: $colorValue, sourcePageNumber: $sourcePageNumber, sourcePdfPath: $sourcePdfPath, sourceRect: $sourceRect, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CanvasElementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.selectedText, selectedText) ||
                other.selectedText == selectedText) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.sourcePageNumber, sourcePageNumber) ||
                other.sourcePageNumber == sourcePageNumber) &&
            (identical(other.sourcePdfPath, sourcePdfPath) ||
                other.sourcePdfPath == sourcePdfPath) &&
            (identical(other.sourceRect, sourceRect) ||
                other.sourceRect == sourceRect) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    x,
    y,
    width,
    height,
    imagePath,
    selectedText,
    colorValue,
    sourcePageNumber,
    sourcePdfPath,
    sourceRect,
    createdAt,
  );

  /// Create a copy of CanvasElement
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CanvasElementImplCopyWith<_$CanvasElementImpl> get copyWith =>
      __$$CanvasElementImplCopyWithImpl<_$CanvasElementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CanvasElementImplToJson(this);
  }
}

abstract class _CanvasElement implements CanvasElement {
  const factory _CanvasElement({
    required final String id,
    required final CanvasElementType type,
    required final double x,
    required final double y,
    required final double width,
    required final double height,
    final String? imagePath,
    final String? selectedText,
    final int? colorValue,
    final int? sourcePageNumber,
    final String? sourcePdfPath,
    @PdfRectConverter() final PdfRect? sourceRect,
    required final DateTime createdAt,
  }) = _$CanvasElementImpl;

  factory _CanvasElement.fromJson(Map<String, dynamic> json) =
      _$CanvasElementImpl.fromJson;

  @override
  String get id;
  @override
  CanvasElementType get type;
  @override
  double get x;
  @override
  double get y;
  @override
  double get width;
  @override
  double get height; // Path to a captured image file (for capture-type elements)
  @override
  String? get imagePath; // Highlighted or selected text from the PDF
  @override
  String? get selectedText; // Color as ARGB int (e.g., 0xFFFFFF00 for yellow)
  @override
  int? get colorValue; // Source PDF page number (1-indexed), null if unknown
  @override
  int? get sourcePageNumber; // Path of the source PDF from which this element was extracted
  @override
  String? get sourcePdfPath; // Source region on the PDF page (for rendering highlight rectangles on PDF)
  @override
  @PdfRectConverter()
  PdfRect? get sourceRect;
  @override
  DateTime get createdAt;

  /// Create a copy of CanvasElement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CanvasElementImplCopyWith<_$CanvasElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
