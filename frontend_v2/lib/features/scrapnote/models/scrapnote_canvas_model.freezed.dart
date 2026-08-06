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

CanvasElement _$CanvasElementFromJson(Map<String, dynamic> json) {
  return _CanvasElement.fromJson(json);
}

/// @nodoc
mixin _$CanvasElement {
  String get id => throw _privateConstructorUsedError;
  CanvasElementType get type => throw _privateConstructorUsedError;

  /// Absolute pixel X position on the canvas.
  double get x => throw _privateConstructorUsedError;

  /// Absolute pixel Y position on the canvas.
  double get y => throw _privateConstructorUsedError;

  /// Width in pixels.
  double get width => throw _privateConstructorUsedError;

  /// Height in pixels.
  double get height => throw _privateConstructorUsedError;

  /// Absolute path to capture image file. Only set for capture elements.
  String? get imagePath => throw _privateConstructorUsedError;

  /// Highlighted text content. Only set for highlight elements.
  String? get selectedText => throw _privateConstructorUsedError;

  /// Source PDF page number (1-based).
  int? get sourcePageNumber => throw _privateConstructorUsedError;

  /// ARGB color value for highlight elements.
  int get colorValue => throw _privateConstructorUsedError;

  /// Reference to the originating ScrapElement ID.
  String get elementId => throw _privateConstructorUsedError;

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
    int? sourcePageNumber,
    int colorValue,
    String elementId,
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
    Object? sourcePageNumber = freezed,
    Object? colorValue = null,
    Object? elementId = null,
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
            sourcePageNumber: freezed == sourcePageNumber
                ? _value.sourcePageNumber
                : sourcePageNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            colorValue: null == colorValue
                ? _value.colorValue
                : colorValue // ignore: cast_nullable_to_non_nullable
                      as int,
            elementId: null == elementId
                ? _value.elementId
                : elementId // ignore: cast_nullable_to_non_nullable
                      as String,
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
    int? sourcePageNumber,
    int colorValue,
    String elementId,
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
    Object? sourcePageNumber = freezed,
    Object? colorValue = null,
    Object? elementId = null,
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
        sourcePageNumber: freezed == sourcePageNumber
            ? _value.sourcePageNumber
            : sourcePageNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        colorValue: null == colorValue
            ? _value.colorValue
            : colorValue // ignore: cast_nullable_to_non_nullable
                  as int,
        elementId: null == elementId
            ? _value.elementId
            : elementId // ignore: cast_nullable_to_non_nullable
                  as String,
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
    this.sourcePageNumber,
    this.colorValue = 0xFFFFEB3B,
    required this.elementId,
  });

  factory _$CanvasElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$CanvasElementImplFromJson(json);

  @override
  final String id;
  @override
  final CanvasElementType type;

  /// Absolute pixel X position on the canvas.
  @override
  final double x;

  /// Absolute pixel Y position on the canvas.
  @override
  final double y;

  /// Width in pixels.
  @override
  final double width;

  /// Height in pixels.
  @override
  final double height;

  /// Absolute path to capture image file. Only set for capture elements.
  @override
  final String? imagePath;

  /// Highlighted text content. Only set for highlight elements.
  @override
  final String? selectedText;

  /// Source PDF page number (1-based).
  @override
  final int? sourcePageNumber;

  /// ARGB color value for highlight elements.
  @override
  @JsonKey()
  final int colorValue;

  /// Reference to the originating ScrapElement ID.
  @override
  final String elementId;

  @override
  String toString() {
    return 'CanvasElement(id: $id, type: $type, x: $x, y: $y, width: $width, height: $height, imagePath: $imagePath, selectedText: $selectedText, sourcePageNumber: $sourcePageNumber, colorValue: $colorValue, elementId: $elementId)';
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
            (identical(other.sourcePageNumber, sourcePageNumber) ||
                other.sourcePageNumber == sourcePageNumber) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.elementId, elementId) ||
                other.elementId == elementId));
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
    sourcePageNumber,
    colorValue,
    elementId,
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
    final int? sourcePageNumber,
    final int colorValue,
    required final String elementId,
  }) = _$CanvasElementImpl;

  factory _CanvasElement.fromJson(Map<String, dynamic> json) =
      _$CanvasElementImpl.fromJson;

  @override
  String get id;
  @override
  CanvasElementType get type;

  /// Absolute pixel X position on the canvas.
  @override
  double get x;

  /// Absolute pixel Y position on the canvas.
  @override
  double get y;

  /// Width in pixels.
  @override
  double get width;

  /// Height in pixels.
  @override
  double get height;

  /// Absolute path to capture image file. Only set for capture elements.
  @override
  String? get imagePath;

  /// Highlighted text content. Only set for highlight elements.
  @override
  String? get selectedText;

  /// Source PDF page number (1-based).
  @override
  int? get sourcePageNumber;

  /// ARGB color value for highlight elements.
  @override
  int get colorValue;

  /// Reference to the originating ScrapElement ID.
  @override
  String get elementId;

  /// Create a copy of CanvasElement
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CanvasElementImplCopyWith<_$CanvasElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScrapnoteCanvasData _$ScrapnoteCanvasDataFromJson(Map<String, dynamic> json) {
  return _ScrapnoteCanvasData.fromJson(json);
}

/// @nodoc
mixin _$ScrapnoteCanvasData {
  String get id => throw _privateConstructorUsedError;

  /// Absolute path to the linked PDF file.
  String get linkedPdfPath => throw _privateConstructorUsedError;

  /// Canvas layout mode: 'infinite' (default) or 'a4'.
  String get canvasMode => throw _privateConstructorUsedError;

  /// All freehand strokes drawn on the canvas.
  List<DrawingStroke> get strokes => throw _privateConstructorUsedError;

  /// All elements placed on the canvas.
  List<CanvasElement> get elements => throw _privateConstructorUsedError;

  /// Element IDs in z-order (bottom to top).
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
    String canvasMode,
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
                      as String,
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
    String canvasMode,
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
                  as String,
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
    this.canvasMode = 'infinite',
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

  /// Absolute path to the linked PDF file.
  @override
  final String linkedPdfPath;

  /// Canvas layout mode: 'infinite' (default) or 'a4'.
  @override
  @JsonKey()
  final String canvasMode;

  /// All freehand strokes drawn on the canvas.
  final List<DrawingStroke> _strokes;

  /// All freehand strokes drawn on the canvas.
  @override
  @JsonKey()
  List<DrawingStroke> get strokes {
    if (_strokes is EqualUnmodifiableListView) return _strokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_strokes);
  }

  /// All elements placed on the canvas.
  final List<CanvasElement> _elements;

  /// All elements placed on the canvas.
  @override
  @JsonKey()
  List<CanvasElement> get elements {
    if (_elements is EqualUnmodifiableListView) return _elements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_elements);
  }

  /// Element IDs in z-order (bottom to top).
  final List<String> _layerOrder;

  /// Element IDs in z-order (bottom to top).
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
    return 'ScrapnoteCanvasData(id: $id, linkedPdfPath: $linkedPdfPath, canvasMode: $canvasMode, strokes: $strokes, elements: $elements, layerOrder: $layerOrder, createdAt: $createdAt, modifiedAt: $modifiedAt)';
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
    final String canvasMode,
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

  /// Absolute path to the linked PDF file.
  @override
  String get linkedPdfPath;

  /// Canvas layout mode: 'infinite' (default) or 'a4'.
  @override
  String get canvasMode;

  /// All freehand strokes drawn on the canvas.
  @override
  List<DrawingStroke> get strokes;

  /// All elements placed on the canvas.
  @override
  List<CanvasElement> get elements;

  /// Element IDs in z-order (bottom to top).
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
