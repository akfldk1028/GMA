// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'element_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ElementRect _$ElementRectFromJson(Map<String, dynamic> json) {
  return _ElementRect.fromJson(json);
}

/// @nodoc
mixin _$ElementRect {
  double get left => throw _privateConstructorUsedError;
  double get top => throw _privateConstructorUsedError;
  double get right => throw _privateConstructorUsedError;
  double get bottom => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $ElementRectCopyWith<ElementRect> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ElementRectCopyWith<$Res> {
  factory $ElementRectCopyWith(
    ElementRect value,
    $Res Function(ElementRect) then,
  ) = _$ElementRectCopyWithImpl<$Res, ElementRect>;
  @useResult
  $Res call({double left, double top, double right, double bottom});
}

/// @nodoc
class _$ElementRectCopyWithImpl<$Res, $Val extends ElementRect>
    implements $ElementRectCopyWith<$Res> {
  _$ElementRectCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? left = null,
    Object? top = null,
    Object? right = null,
    Object? bottom = null,
  }) {
    return _then(
      _value.copyWith(
            left: null == left
                ? _value.left
                : left // ignore: cast_nullable_to_non_nullable
                      as double,
            top: null == top
                ? _value.top
                : top // ignore: cast_nullable_to_non_nullable
                      as double,
            right: null == right
                ? _value.right
                : right // ignore: cast_nullable_to_non_nullable
                      as double,
            bottom: null == bottom
                ? _value.bottom
                : bottom // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ElementRectImplCopyWith<$Res>
    implements $ElementRectCopyWith<$Res> {
  factory _$$ElementRectImplCopyWith(
    _$ElementRectImpl value,
    $Res Function(_$ElementRectImpl) then,
  ) = __$$ElementRectImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double left, double top, double right, double bottom});
}

/// @nodoc
class __$$ElementRectImplCopyWithImpl<$Res>
    extends _$ElementRectCopyWithImpl<$Res, _$ElementRectImpl>
    implements _$$ElementRectImplCopyWith<$Res> {
  __$$ElementRectImplCopyWithImpl(
    _$ElementRectImpl _value,
    $Res Function(_$ElementRectImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? left = null,
    Object? top = null,
    Object? right = null,
    Object? bottom = null,
  }) {
    return _then(
      _$ElementRectImpl(
        left: null == left
            ? _value.left
            : left // ignore: cast_nullable_to_non_nullable
                  as double,
        top: null == top
            ? _value.top
            : top // ignore: cast_nullable_to_non_nullable
                  as double,
        right: null == right
            ? _value.right
            : right // ignore: cast_nullable_to_non_nullable
                  as double,
        bottom: null == bottom
            ? _value.bottom
            : bottom // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ElementRectImpl implements _ElementRect {
  const _$ElementRectImpl({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory _$ElementRectImpl.fromJson(Map<String, dynamic> json) =>
      _$$ElementRectImplFromJson(json);

  @override
  final double left;
  @override
  final double top;
  @override
  final double right;
  @override
  final double bottom;

  @override
  String toString() {
    return 'ElementRect(left: $left, top: $top, right: $right, bottom: $bottom)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ElementRectImpl &&
            (identical(other.left, left) || other.left == left) &&
            (identical(other.top, top) || other.top == top) &&
            (identical(other.right, right) || other.right == right) &&
            (identical(other.bottom, bottom) || other.bottom == bottom));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, left, top, right, bottom);

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ElementRectImplCopyWith<_$ElementRectImpl> get copyWith =>
      __$$ElementRectImplCopyWithImpl<_$ElementRectImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ElementRectImplToJson(this);
  }
}

abstract class _ElementRect implements ElementRect {
  const factory _ElementRect({
    required final double left,
    required final double top,
    required final double right,
    required final double bottom,
  }) = _$ElementRectImpl;

  factory _ElementRect.fromJson(Map<String, dynamic> json) =
      _$ElementRectImpl.fromJson;

  @override
  double get left;
  @override
  double get top;
  @override
  double get right;
  @override
  double get bottom;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ElementRectImplCopyWith<_$ElementRectImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScrapElement _$ScrapElementFromJson(Map<String, dynamic> json) {
  return _ScrapElement.fromJson(json);
}

/// @nodoc
mixin _$ScrapElement {
  String get id => throw _privateConstructorUsedError;
  ScrapElementType get type => throw _privateConstructorUsedError;
  String get pdfPath => throw _privateConstructorUsedError;
  String? get selectedText => throw _privateConstructorUsedError;
  String? get imagePath => throw _privateConstructorUsedError;
  int get sourcePageNumber => throw _privateConstructorUsedError;
  ElementRect get sourceRect => throw _privateConstructorUsedError;
  int get colorValue => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScrapElementCopyWith<ScrapElement> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScrapElementCopyWith<$Res> {
  factory $ScrapElementCopyWith(
    ScrapElement value,
    $Res Function(ScrapElement) then,
  ) = _$ScrapElementCopyWithImpl<$Res, ScrapElement>;
  @useResult
  $Res call({
    String id,
    ScrapElementType type,
    String pdfPath,
    String? selectedText,
    String? imagePath,
    int sourcePageNumber,
    ElementRect sourceRect,
    int colorValue,
    DateTime createdAt,
  });

  $ElementRectCopyWith<$Res> get sourceRect;
}

/// @nodoc
class _$ScrapElementCopyWithImpl<$Res, $Val extends ScrapElement>
    implements $ScrapElementCopyWith<$Res> {
  _$ScrapElementCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? pdfPath = null,
    Object? selectedText = freezed,
    Object? imagePath = freezed,
    Object? sourcePageNumber = null,
    Object? sourceRect = null,
    Object? colorValue = null,
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
                      as ScrapElementType,
            pdfPath: null == pdfPath
                ? _value.pdfPath
                : pdfPath // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedText: freezed == selectedText
                ? _value.selectedText
                : selectedText // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            sourcePageNumber: null == sourcePageNumber
                ? _value.sourcePageNumber
                : sourcePageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            sourceRect: null == sourceRect
                ? _value.sourceRect
                : sourceRect // ignore: cast_nullable_to_non_nullable
                      as ElementRect,
            colorValue: null == colorValue
                ? _value.colorValue
                : colorValue // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  @override
  @pragma('vm:prefer-inline')
  $ElementRectCopyWith<$Res> get sourceRect {
    return $ElementRectCopyWith<$Res>(_value.sourceRect, (value) {
      return _then(_value.copyWith(sourceRect: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScrapElementImplCopyWith<$Res>
    implements $ScrapElementCopyWith<$Res> {
  factory _$$ScrapElementImplCopyWith(
    _$ScrapElementImpl value,
    $Res Function(_$ScrapElementImpl) then,
  ) = __$$ScrapElementImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    ScrapElementType type,
    String pdfPath,
    String? selectedText,
    String? imagePath,
    int sourcePageNumber,
    ElementRect sourceRect,
    int colorValue,
    DateTime createdAt,
  });

  @override
  $ElementRectCopyWith<$Res> get sourceRect;
}

/// @nodoc
class __$$ScrapElementImplCopyWithImpl<$Res>
    extends _$ScrapElementCopyWithImpl<$Res, _$ScrapElementImpl>
    implements _$$ScrapElementImplCopyWith<$Res> {
  __$$ScrapElementImplCopyWithImpl(
    _$ScrapElementImpl _value,
    $Res Function(_$ScrapElementImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? pdfPath = null,
    Object? selectedText = freezed,
    Object? imagePath = freezed,
    Object? sourcePageNumber = null,
    Object? sourceRect = null,
    Object? colorValue = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$ScrapElementImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ScrapElementType,
        pdfPath: null == pdfPath
            ? _value.pdfPath
            : pdfPath // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedText: freezed == selectedText
            ? _value.selectedText
            : selectedText // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        sourcePageNumber: null == sourcePageNumber
            ? _value.sourcePageNumber
            : sourcePageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        sourceRect: null == sourceRect
            ? _value.sourceRect
            : sourceRect // ignore: cast_nullable_to_non_nullable
                  as ElementRect,
        colorValue: null == colorValue
            ? _value.colorValue
            : colorValue // ignore: cast_nullable_to_non_nullable
                  as int,
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
class _$ScrapElementImpl implements _ScrapElement {
  const _$ScrapElementImpl({
    required this.id,
    required this.type,
    required this.pdfPath,
    this.selectedText,
    this.imagePath,
    required this.sourcePageNumber,
    required this.sourceRect,
    this.colorValue = 0xFFFFEB3B,
    required this.createdAt,
  });

  factory _$ScrapElementImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScrapElementImplFromJson(json);

  @override
  final String id;
  @override
  final ScrapElementType type;
  @override
  final String pdfPath;
  @override
  final String? selectedText;
  @override
  final String? imagePath;
  @override
  final int sourcePageNumber;
  @override
  final ElementRect sourceRect;
  @override
  @JsonKey()
  final int colorValue;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ScrapElement(id: $id, type: $type, pdfPath: $pdfPath, selectedText: $selectedText, imagePath: $imagePath, sourcePageNumber: $sourcePageNumber, sourceRect: $sourceRect, colorValue: $colorValue, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScrapElementImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.pdfPath, pdfPath) || other.pdfPath == pdfPath) &&
            (identical(other.selectedText, selectedText) ||
                other.selectedText == selectedText) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.sourcePageNumber, sourcePageNumber) ||
                other.sourcePageNumber == sourcePageNumber) &&
            (identical(other.sourceRect, sourceRect) ||
                other.sourceRect == sourceRect) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    pdfPath,
    selectedText,
    imagePath,
    sourcePageNumber,
    sourceRect,
    colorValue,
    createdAt,
  );

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScrapElementImplCopyWith<_$ScrapElementImpl> get copyWith =>
      __$$ScrapElementImplCopyWithImpl<_$ScrapElementImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScrapElementImplToJson(this);
  }
}

abstract class _ScrapElement implements ScrapElement {
  const factory _ScrapElement({
    required final String id,
    required final ScrapElementType type,
    required final String pdfPath,
    final String? selectedText,
    final String? imagePath,
    required final int sourcePageNumber,
    required final ElementRect sourceRect,
    final int colorValue,
    required final DateTime createdAt,
  }) = _$ScrapElementImpl;

  factory _ScrapElement.fromJson(Map<String, dynamic> json) =
      _$ScrapElementImpl.fromJson;

  @override
  String get id;
  @override
  ScrapElementType get type;
  @override
  String get pdfPath;
  @override
  String? get selectedText;
  @override
  String? get imagePath;
  @override
  int get sourcePageNumber;
  @override
  ElementRect get sourceRect;
  @override
  int get colorValue;
  @override
  DateTime get createdAt;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScrapElementImplCopyWith<_$ScrapElementImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
