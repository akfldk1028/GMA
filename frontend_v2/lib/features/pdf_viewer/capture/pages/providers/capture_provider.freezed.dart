// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'capture_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CaptureState {
  bool get isCapturing => throw _privateConstructorUsedError;
  Rect? get selectedRect => throw _privateConstructorUsedError;
  Uint8List? get previewImageBytes => throw _privateConstructorUsedError;
  bool get showConfirmation => throw _privateConstructorUsedError;

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CaptureStateCopyWith<CaptureState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CaptureStateCopyWith<$Res> {
  factory $CaptureStateCopyWith(
    CaptureState value,
    $Res Function(CaptureState) then,
  ) = _$CaptureStateCopyWithImpl<$Res, CaptureState>;
  @useResult
  $Res call({
    bool isCapturing,
    Rect? selectedRect,
    Uint8List? previewImageBytes,
    bool showConfirmation,
  });
}

/// @nodoc
class _$CaptureStateCopyWithImpl<$Res, $Val extends CaptureState>
    implements $CaptureStateCopyWith<$Res> {
  _$CaptureStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCapturing = null,
    Object? selectedRect = freezed,
    Object? previewImageBytes = freezed,
    Object? showConfirmation = null,
  }) {
    return _then(
      _value.copyWith(
            isCapturing: null == isCapturing
                ? _value.isCapturing
                : isCapturing // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectedRect: freezed == selectedRect
                ? _value.selectedRect
                : selectedRect // ignore: cast_nullable_to_non_nullable
                      as Rect?,
            previewImageBytes: freezed == previewImageBytes
                ? _value.previewImageBytes
                : previewImageBytes // ignore: cast_nullable_to_non_nullable
                      as Uint8List?,
            showConfirmation: null == showConfirmation
                ? _value.showConfirmation
                : showConfirmation // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CaptureStateImplCopyWith<$Res>
    implements $CaptureStateCopyWith<$Res> {
  factory _$$CaptureStateImplCopyWith(
    _$CaptureStateImpl value,
    $Res Function(_$CaptureStateImpl) then,
  ) = __$$CaptureStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isCapturing,
    Rect? selectedRect,
    Uint8List? previewImageBytes,
    bool showConfirmation,
  });
}

/// @nodoc
class __$$CaptureStateImplCopyWithImpl<$Res>
    extends _$CaptureStateCopyWithImpl<$Res, _$CaptureStateImpl>
    implements _$$CaptureStateImplCopyWith<$Res> {
  __$$CaptureStateImplCopyWithImpl(
    _$CaptureStateImpl _value,
    $Res Function(_$CaptureStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isCapturing = null,
    Object? selectedRect = freezed,
    Object? previewImageBytes = freezed,
    Object? showConfirmation = null,
  }) {
    return _then(
      _$CaptureStateImpl(
        isCapturing: null == isCapturing
            ? _value.isCapturing
            : isCapturing // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectedRect: freezed == selectedRect
            ? _value.selectedRect
            : selectedRect // ignore: cast_nullable_to_non_nullable
                  as Rect?,
        previewImageBytes: freezed == previewImageBytes
            ? _value.previewImageBytes
            : previewImageBytes // ignore: cast_nullable_to_non_nullable
                  as Uint8List?,
        showConfirmation: null == showConfirmation
            ? _value.showConfirmation
            : showConfirmation // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$CaptureStateImpl implements _CaptureState {
  const _$CaptureStateImpl({
    this.isCapturing = false,
    this.selectedRect,
    this.previewImageBytes,
    this.showConfirmation = false,
  });

  @override
  @JsonKey()
  final bool isCapturing;
  @override
  final Rect? selectedRect;
  @override
  final Uint8List? previewImageBytes;
  @override
  @JsonKey()
  final bool showConfirmation;

  @override
  String toString() {
    return 'CaptureState(isCapturing: $isCapturing, selectedRect: $selectedRect, previewImageBytes: $previewImageBytes, showConfirmation: $showConfirmation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CaptureStateImpl &&
            (identical(other.isCapturing, isCapturing) ||
                other.isCapturing == isCapturing) &&
            (identical(other.selectedRect, selectedRect) ||
                other.selectedRect == selectedRect) &&
            const DeepCollectionEquality().equals(
              other.previewImageBytes,
              previewImageBytes,
            ) &&
            (identical(other.showConfirmation, showConfirmation) ||
                other.showConfirmation == showConfirmation));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isCapturing,
    selectedRect,
    const DeepCollectionEquality().hash(previewImageBytes),
    showConfirmation,
  );

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CaptureStateImplCopyWith<_$CaptureStateImpl> get copyWith =>
      __$$CaptureStateImplCopyWithImpl<_$CaptureStateImpl>(this, _$identity);
}

abstract class _CaptureState implements CaptureState {
  const factory _CaptureState({
    final bool isCapturing,
    final Rect? selectedRect,
    final Uint8List? previewImageBytes,
    final bool showConfirmation,
  }) = _$CaptureStateImpl;

  @override
  bool get isCapturing;
  @override
  Rect? get selectedRect;
  @override
  Uint8List? get previewImageBytes;
  @override
  bool get showConfirmation;

  /// Create a copy of CaptureState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CaptureStateImplCopyWith<_$CaptureStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
