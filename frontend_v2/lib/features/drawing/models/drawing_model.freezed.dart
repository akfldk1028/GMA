// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drawing_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DrawingStroke _$DrawingStrokeFromJson(Map<String, dynamic> json) {
  return _DrawingStroke.fromJson(json);
}

/// @nodoc
mixin _$DrawingStroke {
  String get id => throw _privateConstructorUsedError;
  int get pageNumber => throw _privateConstructorUsedError;
  List<StrokePoint> get points => throw _privateConstructorUsedError;
  String get toolId => throw _privateConstructorUsedError;
  int get colorValue => throw _privateConstructorUsedError;
  double get size => throw _privateConstructorUsedError;

  /// Serializes this DrawingStroke to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DrawingStroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DrawingStrokeCopyWith<DrawingStroke> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrawingStrokeCopyWith<$Res> {
  factory $DrawingStrokeCopyWith(
    DrawingStroke value,
    $Res Function(DrawingStroke) then,
  ) = _$DrawingStrokeCopyWithImpl<$Res, DrawingStroke>;
  @useResult
  $Res call({
    String id,
    int pageNumber,
    List<StrokePoint> points,
    String toolId,
    int colorValue,
    double size,
  });
}

/// @nodoc
class _$DrawingStrokeCopyWithImpl<$Res, $Val extends DrawingStroke>
    implements $DrawingStrokeCopyWith<$Res> {
  _$DrawingStrokeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DrawingStroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageNumber = null,
    Object? points = null,
    Object? toolId = null,
    Object? colorValue = null,
    Object? size = null,
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
            points: null == points
                ? _value.points
                : points // ignore: cast_nullable_to_non_nullable
                      as List<StrokePoint>,
            toolId: null == toolId
                ? _value.toolId
                : toolId // ignore: cast_nullable_to_non_nullable
                      as String,
            colorValue: null == colorValue
                ? _value.colorValue
                : colorValue // ignore: cast_nullable_to_non_nullable
                      as int,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DrawingStrokeImplCopyWith<$Res>
    implements $DrawingStrokeCopyWith<$Res> {
  factory _$$DrawingStrokeImplCopyWith(
    _$DrawingStrokeImpl value,
    $Res Function(_$DrawingStrokeImpl) then,
  ) = __$$DrawingStrokeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int pageNumber,
    List<StrokePoint> points,
    String toolId,
    int colorValue,
    double size,
  });
}

/// @nodoc
class __$$DrawingStrokeImplCopyWithImpl<$Res>
    extends _$DrawingStrokeCopyWithImpl<$Res, _$DrawingStrokeImpl>
    implements _$$DrawingStrokeImplCopyWith<$Res> {
  __$$DrawingStrokeImplCopyWithImpl(
    _$DrawingStrokeImpl _value,
    $Res Function(_$DrawingStrokeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DrawingStroke
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? pageNumber = null,
    Object? points = null,
    Object? toolId = null,
    Object? colorValue = null,
    Object? size = null,
  }) {
    return _then(
      _$DrawingStrokeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        points: null == points
            ? _value._points
            : points // ignore: cast_nullable_to_non_nullable
                  as List<StrokePoint>,
        toolId: null == toolId
            ? _value.toolId
            : toolId // ignore: cast_nullable_to_non_nullable
                  as String,
        colorValue: null == colorValue
            ? _value.colorValue
            : colorValue // ignore: cast_nullable_to_non_nullable
                  as int,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DrawingStrokeImpl implements _DrawingStroke {
  const _$DrawingStrokeImpl({
    required this.id,
    required this.pageNumber,
    required final List<StrokePoint> points,
    required this.toolId,
    this.colorValue = 0xFF000000,
    this.size = 3.0,
  }) : _points = points;

  factory _$DrawingStrokeImpl.fromJson(Map<String, dynamic> json) =>
      _$$DrawingStrokeImplFromJson(json);

  @override
  final String id;
  @override
  final int pageNumber;
  final List<StrokePoint> _points;
  @override
  List<StrokePoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  final String toolId;
  @override
  @JsonKey()
  final int colorValue;
  @override
  @JsonKey()
  final double size;

  @override
  String toString() {
    return 'DrawingStroke(id: $id, pageNumber: $pageNumber, points: $points, toolId: $toolId, colorValue: $colorValue, size: $size)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrawingStrokeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            const DeepCollectionEquality().equals(other._points, _points) &&
            (identical(other.toolId, toolId) || other.toolId == toolId) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.size, size) || other.size == size));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    pageNumber,
    const DeepCollectionEquality().hash(_points),
    toolId,
    colorValue,
    size,
  );

  /// Create a copy of DrawingStroke
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DrawingStrokeImplCopyWith<_$DrawingStrokeImpl> get copyWith =>
      __$$DrawingStrokeImplCopyWithImpl<_$DrawingStrokeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DrawingStrokeImplToJson(this);
  }
}

abstract class _DrawingStroke implements DrawingStroke {
  const factory _DrawingStroke({
    required final String id,
    required final int pageNumber,
    required final List<StrokePoint> points,
    required final String toolId,
    final int colorValue,
    final double size,
  }) = _$DrawingStrokeImpl;

  factory _DrawingStroke.fromJson(Map<String, dynamic> json) =
      _$DrawingStrokeImpl.fromJson;

  @override
  String get id;
  @override
  int get pageNumber;
  @override
  List<StrokePoint> get points;
  @override
  String get toolId;
  @override
  int get colorValue;
  @override
  double get size;

  /// Create a copy of DrawingStroke
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DrawingStrokeImplCopyWith<_$DrawingStrokeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

StrokePoint _$StrokePointFromJson(Map<String, dynamic> json) {
  return _StrokePoint.fromJson(json);
}

/// @nodoc
mixin _$StrokePoint {
  double get x => throw _privateConstructorUsedError;
  double get y => throw _privateConstructorUsedError;
  double? get pressure => throw _privateConstructorUsedError;

  /// Serializes this StrokePoint to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StrokePointCopyWith<StrokePoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StrokePointCopyWith<$Res> {
  factory $StrokePointCopyWith(
    StrokePoint value,
    $Res Function(StrokePoint) then,
  ) = _$StrokePointCopyWithImpl<$Res, StrokePoint>;
  @useResult
  $Res call({double x, double y, double? pressure});
}

/// @nodoc
class _$StrokePointCopyWithImpl<$Res, $Val extends StrokePoint>
    implements $StrokePointCopyWith<$Res> {
  _$StrokePointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null, Object? pressure = freezed}) {
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
            pressure: freezed == pressure
                ? _value.pressure
                : pressure // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StrokePointImplCopyWith<$Res>
    implements $StrokePointCopyWith<$Res> {
  factory _$$StrokePointImplCopyWith(
    _$StrokePointImpl value,
    $Res Function(_$StrokePointImpl) then,
  ) = __$$StrokePointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double x, double y, double? pressure});
}

/// @nodoc
class __$$StrokePointImplCopyWithImpl<$Res>
    extends _$StrokePointCopyWithImpl<$Res, _$StrokePointImpl>
    implements _$$StrokePointImplCopyWith<$Res> {
  __$$StrokePointImplCopyWithImpl(
    _$StrokePointImpl _value,
    $Res Function(_$StrokePointImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? x = null, Object? y = null, Object? pressure = freezed}) {
    return _then(
      _$StrokePointImpl(
        x: null == x
            ? _value.x
            : x // ignore: cast_nullable_to_non_nullable
                  as double,
        y: null == y
            ? _value.y
            : y // ignore: cast_nullable_to_non_nullable
                  as double,
        pressure: freezed == pressure
            ? _value.pressure
            : pressure // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StrokePointImpl implements _StrokePoint {
  const _$StrokePointImpl({required this.x, required this.y, this.pressure});

  factory _$StrokePointImpl.fromJson(Map<String, dynamic> json) =>
      _$$StrokePointImplFromJson(json);

  @override
  final double x;
  @override
  final double y;
  @override
  final double? pressure;

  @override
  String toString() {
    return 'StrokePoint(x: $x, y: $y, pressure: $pressure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StrokePointImpl &&
            (identical(other.x, x) || other.x == x) &&
            (identical(other.y, y) || other.y == y) &&
            (identical(other.pressure, pressure) ||
                other.pressure == pressure));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, x, y, pressure);

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StrokePointImplCopyWith<_$StrokePointImpl> get copyWith =>
      __$$StrokePointImplCopyWithImpl<_$StrokePointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StrokePointImplToJson(this);
  }
}

abstract class _StrokePoint implements StrokePoint {
  const factory _StrokePoint({
    required final double x,
    required final double y,
    final double? pressure,
  }) = _$StrokePointImpl;

  factory _StrokePoint.fromJson(Map<String, dynamic> json) =
      _$StrokePointImpl.fromJson;

  @override
  double get x;
  @override
  double get y;
  @override
  double? get pressure;

  /// Create a copy of StrokePoint
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StrokePointImplCopyWith<_$StrokePointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DrawingToolState {
  bool get isActive => throw _privateConstructorUsedError;
  String get currentToolId => throw _privateConstructorUsedError;
  int get colorValue => throw _privateConstructorUsedError;
  double get strokeSize => throw _privateConstructorUsedError;

  /// Create a copy of DrawingToolState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DrawingToolStateCopyWith<DrawingToolState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrawingToolStateCopyWith<$Res> {
  factory $DrawingToolStateCopyWith(
    DrawingToolState value,
    $Res Function(DrawingToolState) then,
  ) = _$DrawingToolStateCopyWithImpl<$Res, DrawingToolState>;
  @useResult
  $Res call({
    bool isActive,
    String currentToolId,
    int colorValue,
    double strokeSize,
  });
}

/// @nodoc
class _$DrawingToolStateCopyWithImpl<$Res, $Val extends DrawingToolState>
    implements $DrawingToolStateCopyWith<$Res> {
  _$DrawingToolStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DrawingToolState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? currentToolId = null,
    Object? colorValue = null,
    Object? strokeSize = null,
  }) {
    return _then(
      _value.copyWith(
            isActive: null == isActive
                ? _value.isActive
                : isActive // ignore: cast_nullable_to_non_nullable
                      as bool,
            currentToolId: null == currentToolId
                ? _value.currentToolId
                : currentToolId // ignore: cast_nullable_to_non_nullable
                      as String,
            colorValue: null == colorValue
                ? _value.colorValue
                : colorValue // ignore: cast_nullable_to_non_nullable
                      as int,
            strokeSize: null == strokeSize
                ? _value.strokeSize
                : strokeSize // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DrawingToolStateImplCopyWith<$Res>
    implements $DrawingToolStateCopyWith<$Res> {
  factory _$$DrawingToolStateImplCopyWith(
    _$DrawingToolStateImpl value,
    $Res Function(_$DrawingToolStateImpl) then,
  ) = __$$DrawingToolStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isActive,
    String currentToolId,
    int colorValue,
    double strokeSize,
  });
}

/// @nodoc
class __$$DrawingToolStateImplCopyWithImpl<$Res>
    extends _$DrawingToolStateCopyWithImpl<$Res, _$DrawingToolStateImpl>
    implements _$$DrawingToolStateImplCopyWith<$Res> {
  __$$DrawingToolStateImplCopyWithImpl(
    _$DrawingToolStateImpl _value,
    $Res Function(_$DrawingToolStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DrawingToolState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isActive = null,
    Object? currentToolId = null,
    Object? colorValue = null,
    Object? strokeSize = null,
  }) {
    return _then(
      _$DrawingToolStateImpl(
        isActive: null == isActive
            ? _value.isActive
            : isActive // ignore: cast_nullable_to_non_nullable
                  as bool,
        currentToolId: null == currentToolId
            ? _value.currentToolId
            : currentToolId // ignore: cast_nullable_to_non_nullable
                  as String,
        colorValue: null == colorValue
            ? _value.colorValue
            : colorValue // ignore: cast_nullable_to_non_nullable
                  as int,
        strokeSize: null == strokeSize
            ? _value.strokeSize
            : strokeSize // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$DrawingToolStateImpl implements _DrawingToolState {
  const _$DrawingToolStateImpl({
    this.isActive = false,
    this.currentToolId = 'pen',
    this.colorValue = 0xFF000000,
    this.strokeSize = 3.0,
  });

  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final String currentToolId;
  @override
  @JsonKey()
  final int colorValue;
  @override
  @JsonKey()
  final double strokeSize;

  @override
  String toString() {
    return 'DrawingToolState(isActive: $isActive, currentToolId: $currentToolId, colorValue: $colorValue, strokeSize: $strokeSize)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrawingToolStateImpl &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.currentToolId, currentToolId) ||
                other.currentToolId == currentToolId) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.strokeSize, strokeSize) ||
                other.strokeSize == strokeSize));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, isActive, currentToolId, colorValue, strokeSize);

  /// Create a copy of DrawingToolState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DrawingToolStateImplCopyWith<_$DrawingToolStateImpl> get copyWith =>
      __$$DrawingToolStateImplCopyWithImpl<_$DrawingToolStateImpl>(
        this,
        _$identity,
      );
}

abstract class _DrawingToolState implements DrawingToolState {
  const factory _DrawingToolState({
    final bool isActive,
    final String currentToolId,
    final int colorValue,
    final double strokeSize,
  }) = _$DrawingToolStateImpl;

  @override
  bool get isActive;
  @override
  String get currentToolId;
  @override
  int get colorValue;
  @override
  double get strokeSize;

  /// Create a copy of DrawingToolState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DrawingToolStateImplCopyWith<_$DrawingToolStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$DrawingData {
  Map<int, List<DrawingStroke>> get pageStrokes =>
      throw _privateConstructorUsedError;
  List<DrawingStroke> get undoStack => throw _privateConstructorUsedError;

  /// Create a copy of DrawingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DrawingDataCopyWith<DrawingData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DrawingDataCopyWith<$Res> {
  factory $DrawingDataCopyWith(
    DrawingData value,
    $Res Function(DrawingData) then,
  ) = _$DrawingDataCopyWithImpl<$Res, DrawingData>;
  @useResult
  $Res call({
    Map<int, List<DrawingStroke>> pageStrokes,
    List<DrawingStroke> undoStack,
  });
}

/// @nodoc
class _$DrawingDataCopyWithImpl<$Res, $Val extends DrawingData>
    implements $DrawingDataCopyWith<$Res> {
  _$DrawingDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DrawingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pageStrokes = null, Object? undoStack = null}) {
    return _then(
      _value.copyWith(
            pageStrokes: null == pageStrokes
                ? _value.pageStrokes
                : pageStrokes // ignore: cast_nullable_to_non_nullable
                      as Map<int, List<DrawingStroke>>,
            undoStack: null == undoStack
                ? _value.undoStack
                : undoStack // ignore: cast_nullable_to_non_nullable
                      as List<DrawingStroke>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DrawingDataImplCopyWith<$Res>
    implements $DrawingDataCopyWith<$Res> {
  factory _$$DrawingDataImplCopyWith(
    _$DrawingDataImpl value,
    $Res Function(_$DrawingDataImpl) then,
  ) = __$$DrawingDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Map<int, List<DrawingStroke>> pageStrokes,
    List<DrawingStroke> undoStack,
  });
}

/// @nodoc
class __$$DrawingDataImplCopyWithImpl<$Res>
    extends _$DrawingDataCopyWithImpl<$Res, _$DrawingDataImpl>
    implements _$$DrawingDataImplCopyWith<$Res> {
  __$$DrawingDataImplCopyWithImpl(
    _$DrawingDataImpl _value,
    $Res Function(_$DrawingDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DrawingData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? pageStrokes = null, Object? undoStack = null}) {
    return _then(
      _$DrawingDataImpl(
        pageStrokes: null == pageStrokes
            ? _value._pageStrokes
            : pageStrokes // ignore: cast_nullable_to_non_nullable
                  as Map<int, List<DrawingStroke>>,
        undoStack: null == undoStack
            ? _value._undoStack
            : undoStack // ignore: cast_nullable_to_non_nullable
                  as List<DrawingStroke>,
      ),
    );
  }
}

/// @nodoc

class _$DrawingDataImpl implements _DrawingData {
  const _$DrawingDataImpl({
    final Map<int, List<DrawingStroke>> pageStrokes = const {},
    final List<DrawingStroke> undoStack = const [],
  }) : _pageStrokes = pageStrokes,
       _undoStack = undoStack;

  final Map<int, List<DrawingStroke>> _pageStrokes;
  @override
  @JsonKey()
  Map<int, List<DrawingStroke>> get pageStrokes {
    if (_pageStrokes is EqualUnmodifiableMapView) return _pageStrokes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_pageStrokes);
  }

  final List<DrawingStroke> _undoStack;
  @override
  @JsonKey()
  List<DrawingStroke> get undoStack {
    if (_undoStack is EqualUnmodifiableListView) return _undoStack;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_undoStack);
  }

  @override
  String toString() {
    return 'DrawingData(pageStrokes: $pageStrokes, undoStack: $undoStack)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DrawingDataImpl &&
            const DeepCollectionEquality().equals(
              other._pageStrokes,
              _pageStrokes,
            ) &&
            const DeepCollectionEquality().equals(
              other._undoStack,
              _undoStack,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_pageStrokes),
    const DeepCollectionEquality().hash(_undoStack),
  );

  /// Create a copy of DrawingData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DrawingDataImplCopyWith<_$DrawingDataImpl> get copyWith =>
      __$$DrawingDataImplCopyWithImpl<_$DrawingDataImpl>(this, _$identity);
}

abstract class _DrawingData implements DrawingData {
  const factory _DrawingData({
    final Map<int, List<DrawingStroke>> pageStrokes,
    final List<DrawingStroke> undoStack,
  }) = _$DrawingDataImpl;

  @override
  Map<int, List<DrawingStroke>> get pageStrokes;
  @override
  List<DrawingStroke> get undoStack;

  /// Create a copy of DrawingData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DrawingDataImplCopyWith<_$DrawingDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
