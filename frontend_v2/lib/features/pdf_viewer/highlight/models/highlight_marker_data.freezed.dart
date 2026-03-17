// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'highlight_marker_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

HighlightMarkerData _$HighlightMarkerDataFromJson(Map<String, dynamic> json) {
  return _HighlightMarkerData.fromJson(json);
}

/// @nodoc
mixin _$HighlightMarkerData {
  int get pageNumber => throw _privateConstructorUsedError;
  List<ElementRect> get normalizedRects => throw _privateConstructorUsedError;
  int get colorValue => throw _privateConstructorUsedError;
  String get elementId => throw _privateConstructorUsedError;

  /// Serializes this HighlightMarkerData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HighlightMarkerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HighlightMarkerDataCopyWith<HighlightMarkerData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HighlightMarkerDataCopyWith<$Res> {
  factory $HighlightMarkerDataCopyWith(
    HighlightMarkerData value,
    $Res Function(HighlightMarkerData) then,
  ) = _$HighlightMarkerDataCopyWithImpl<$Res, HighlightMarkerData>;
  @useResult
  $Res call({
    int pageNumber,
    List<ElementRect> normalizedRects,
    int colorValue,
    String elementId,
  });
}

/// @nodoc
class _$HighlightMarkerDataCopyWithImpl<$Res,
        $Val extends HighlightMarkerData>
    implements $HighlightMarkerDataCopyWith<$Res> {
  _$HighlightMarkerDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HighlightMarkerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageNumber = null,
    Object? normalizedRects = null,
    Object? colorValue = null,
    Object? elementId = null,
  }) {
    return _then(
      _value.copyWith(
            pageNumber: null == pageNumber
                ? _value.pageNumber
                : pageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            normalizedRects: null == normalizedRects
                ? _value.normalizedRects
                : normalizedRects // ignore: cast_nullable_to_non_nullable
                      as List<ElementRect>,
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
abstract class _$$HighlightMarkerDataImplCopyWith<$Res>
    implements $HighlightMarkerDataCopyWith<$Res> {
  factory _$$HighlightMarkerDataImplCopyWith(
    _$HighlightMarkerDataImpl value,
    $Res Function(_$HighlightMarkerDataImpl) then,
  ) = __$$HighlightMarkerDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int pageNumber,
    List<ElementRect> normalizedRects,
    int colorValue,
    String elementId,
  });
}

/// @nodoc
class __$$HighlightMarkerDataImplCopyWithImpl<$Res>
    extends _$HighlightMarkerDataCopyWithImpl<$Res, _$HighlightMarkerDataImpl>
    implements _$$HighlightMarkerDataImplCopyWith<$Res> {
  __$$HighlightMarkerDataImplCopyWithImpl(
    _$HighlightMarkerDataImpl _value,
    $Res Function(_$HighlightMarkerDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HighlightMarkerData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? pageNumber = null,
    Object? normalizedRects = null,
    Object? colorValue = null,
    Object? elementId = null,
  }) {
    return _then(
      _$HighlightMarkerDataImpl(
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        normalizedRects: null == normalizedRects
            ? _value._normalizedRects
            : normalizedRects // ignore: cast_nullable_to_non_nullable
                  as List<ElementRect>,
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
class _$HighlightMarkerDataImpl implements _HighlightMarkerData {
  const _$HighlightMarkerDataImpl({
    required this.pageNumber,
    required final List<ElementRect> normalizedRects,
    required this.colorValue,
    required this.elementId,
  }) : _normalizedRects = normalizedRects;

  factory _$HighlightMarkerDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$HighlightMarkerDataImplFromJson(json);

  @override
  final int pageNumber;
  final List<ElementRect> _normalizedRects;
  @override
  List<ElementRect> get normalizedRects {
    if (_normalizedRects is EqualUnmodifiableListView) return _normalizedRects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_normalizedRects);
  }

  @override
  final int colorValue;
  @override
  final String elementId;

  @override
  String toString() {
    return 'HighlightMarkerData(pageNumber: $pageNumber, normalizedRects: $normalizedRects, colorValue: $colorValue, elementId: $elementId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HighlightMarkerDataImpl &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            const DeepCollectionEquality().equals(
              other._normalizedRects,
              _normalizedRects,
            ) &&
            (identical(other.colorValue, colorValue) ||
                other.colorValue == colorValue) &&
            (identical(other.elementId, elementId) ||
                other.elementId == elementId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    pageNumber,
    const DeepCollectionEquality().hash(_normalizedRects),
    colorValue,
    elementId,
  );

  /// Create a copy of HighlightMarkerData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HighlightMarkerDataImplCopyWith<_$HighlightMarkerDataImpl> get copyWith =>
      __$$HighlightMarkerDataImplCopyWithImpl<_$HighlightMarkerDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$HighlightMarkerDataImplToJson(this);
  }
}

abstract class _HighlightMarkerData implements HighlightMarkerData {
  const factory _HighlightMarkerData({
    required final int pageNumber,
    required final List<ElementRect> normalizedRects,
    required final int colorValue,
    required final String elementId,
  }) = _$HighlightMarkerDataImpl;

  factory _HighlightMarkerData.fromJson(Map<String, dynamic> json) =
      _$HighlightMarkerDataImpl.fromJson;

  @override
  int get pageNumber;
  @override
  List<ElementRect> get normalizedRects;
  @override
  int get colorValue;
  @override
  String get elementId;

  /// Create a copy of HighlightMarkerData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HighlightMarkerDataImplCopyWith<_$HighlightMarkerDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
