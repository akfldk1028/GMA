// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'marker_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Marker _$MarkerFromJson(Map<String, dynamic> json) {
  return _Marker.fromJson(json);
}

/// @nodoc
mixin _$Marker {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson)
  MarkerColor get color => throw _privateConstructorUsedError;
  int get pageNumber => throw _privateConstructorUsedError;
  String? get selectedText => throw _privateConstructorUsedError;
  @JsonKey(includeFromJson: false, includeToJson: false)
  PdfRect? get rect => throw _privateConstructorUsedError;

  /// Serializes this Marker to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Marker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MarkerCopyWith<Marker> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MarkerCopyWith<$Res> {
  factory $MarkerCopyWith(Marker value, $Res Function(Marker) then) =
      _$MarkerCopyWithImpl<$Res, Marker>;
  @useResult
  $Res call({
    String id,
    @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson)
    MarkerColor color,
    int pageNumber,
    String? selectedText,
    @JsonKey(includeFromJson: false, includeToJson: false) PdfRect? rect,
  });
}

/// @nodoc
class _$MarkerCopyWithImpl<$Res, $Val extends Marker>
    implements $MarkerCopyWith<$Res> {
  _$MarkerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Marker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? color = null,
    Object? pageNumber = null,
    Object? selectedText = freezed,
    Object? rect = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as MarkerColor,
            pageNumber: null == pageNumber
                ? _value.pageNumber
                : pageNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            selectedText: freezed == selectedText
                ? _value.selectedText
                : selectedText // ignore: cast_nullable_to_non_nullable
                      as String?,
            rect: freezed == rect
                ? _value.rect
                : rect // ignore: cast_nullable_to_non_nullable
                      as PdfRect?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MarkerImplCopyWith<$Res> implements $MarkerCopyWith<$Res> {
  factory _$$MarkerImplCopyWith(
    _$MarkerImpl value,
    $Res Function(_$MarkerImpl) then,
  ) = __$$MarkerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson)
    MarkerColor color,
    int pageNumber,
    String? selectedText,
    @JsonKey(includeFromJson: false, includeToJson: false) PdfRect? rect,
  });
}

/// @nodoc
class __$$MarkerImplCopyWithImpl<$Res>
    extends _$MarkerCopyWithImpl<$Res, _$MarkerImpl>
    implements _$$MarkerImplCopyWith<$Res> {
  __$$MarkerImplCopyWithImpl(
    _$MarkerImpl _value,
    $Res Function(_$MarkerImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Marker
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? color = null,
    Object? pageNumber = null,
    Object? selectedText = freezed,
    Object? rect = freezed,
  }) {
    return _then(
      _$MarkerImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as MarkerColor,
        pageNumber: null == pageNumber
            ? _value.pageNumber
            : pageNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        selectedText: freezed == selectedText
            ? _value.selectedText
            : selectedText // ignore: cast_nullable_to_non_nullable
                  as String?,
        rect: freezed == rect
            ? _value.rect
            : rect // ignore: cast_nullable_to_non_nullable
                  as PdfRect?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MarkerImpl implements _Marker {
  const _$MarkerImpl({
    required this.id,
    @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson)
    required this.color,
    required this.pageNumber,
    this.selectedText,
    @JsonKey(includeFromJson: false, includeToJson: false) this.rect,
  });

  factory _$MarkerImpl.fromJson(Map<String, dynamic> json) =>
      _$$MarkerImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson)
  final MarkerColor color;
  @override
  final int pageNumber;
  @override
  final String? selectedText;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final PdfRect? rect;

  @override
  String toString() {
    return 'Marker(id: $id, color: $color, pageNumber: $pageNumber, selectedText: $selectedText, rect: $rect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MarkerImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.pageNumber, pageNumber) ||
                other.pageNumber == pageNumber) &&
            (identical(other.selectedText, selectedText) ||
                other.selectedText == selectedText) &&
            (identical(other.rect, rect) || other.rect == rect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, color, pageNumber, selectedText, rect);

  /// Create a copy of Marker
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MarkerImplCopyWith<_$MarkerImpl> get copyWith =>
      __$$MarkerImplCopyWithImpl<_$MarkerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MarkerImplToJson(this);
  }
}

abstract class _Marker implements Marker {
  const factory _Marker({
    required final String id,
    @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson)
    required final MarkerColor color,
    required final int pageNumber,
    final String? selectedText,
    @JsonKey(includeFromJson: false, includeToJson: false) final PdfRect? rect,
  }) = _$MarkerImpl;

  factory _Marker.fromJson(Map<String, dynamic> json) = _$MarkerImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(fromJson: _markerColorFromJson, toJson: _markerColorToJson)
  MarkerColor get color;
  @override
  int get pageNumber;
  @override
  String? get selectedText;
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  PdfRect? get rect;

  /// Create a copy of Marker
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MarkerImplCopyWith<_$MarkerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
