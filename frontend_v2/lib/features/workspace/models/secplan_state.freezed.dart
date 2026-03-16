// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'secplan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$SecPlanPanelState {
  double get panelRatio => throw _privateConstructorUsedError;
  bool get isSwapped => throw _privateConstructorUsedError;
  MaximizedPanel get maximizedPanel => throw _privateConstructorUsedError;
  FocusedPanel get focusedPanel => throw _privateConstructorUsedError;
  bool get isRightPanelVisible => throw _privateConstructorUsedError;

  /// Create a copy of SecPlanPanelState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SecPlanPanelStateCopyWith<SecPlanPanelState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SecPlanPanelStateCopyWith<$Res> {
  factory $SecPlanPanelStateCopyWith(
    SecPlanPanelState value,
    $Res Function(SecPlanPanelState) then,
  ) = _$SecPlanPanelStateCopyWithImpl<$Res, SecPlanPanelState>;
  @useResult
  $Res call({
    double panelRatio,
    bool isSwapped,
    MaximizedPanel maximizedPanel,
    FocusedPanel focusedPanel,
    bool isRightPanelVisible,
  });
}

/// @nodoc
class _$SecPlanPanelStateCopyWithImpl<$Res, $Val extends SecPlanPanelState>
    implements $SecPlanPanelStateCopyWith<$Res> {
  _$SecPlanPanelStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SecPlanPanelState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? panelRatio = null,
    Object? isSwapped = null,
    Object? maximizedPanel = null,
    Object? focusedPanel = null,
    Object? isRightPanelVisible = null,
  }) {
    return _then(
      _value.copyWith(
            panelRatio: null == panelRatio
                ? _value.panelRatio
                : panelRatio // ignore: cast_nullable_to_non_nullable
                      as double,
            isSwapped: null == isSwapped
                ? _value.isSwapped
                : isSwapped // ignore: cast_nullable_to_non_nullable
                      as bool,
            maximizedPanel: null == maximizedPanel
                ? _value.maximizedPanel
                : maximizedPanel // ignore: cast_nullable_to_non_nullable
                      as MaximizedPanel,
            focusedPanel: null == focusedPanel
                ? _value.focusedPanel
                : focusedPanel // ignore: cast_nullable_to_non_nullable
                      as FocusedPanel,
            isRightPanelVisible: null == isRightPanelVisible
                ? _value.isRightPanelVisible
                : isRightPanelVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SecPlanPanelStateImplCopyWith<$Res>
    implements $SecPlanPanelStateCopyWith<$Res> {
  factory _$$SecPlanPanelStateImplCopyWith(
    _$SecPlanPanelStateImpl value,
    $Res Function(_$SecPlanPanelStateImpl) then,
  ) = __$$SecPlanPanelStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double panelRatio,
    bool isSwapped,
    MaximizedPanel maximizedPanel,
    FocusedPanel focusedPanel,
    bool isRightPanelVisible,
  });
}

/// @nodoc
class __$$SecPlanPanelStateImplCopyWithImpl<$Res>
    extends _$SecPlanPanelStateCopyWithImpl<$Res, _$SecPlanPanelStateImpl>
    implements _$$SecPlanPanelStateImplCopyWith<$Res> {
  __$$SecPlanPanelStateImplCopyWithImpl(
    _$SecPlanPanelStateImpl _value,
    $Res Function(_$SecPlanPanelStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SecPlanPanelState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? panelRatio = null,
    Object? isSwapped = null,
    Object? maximizedPanel = null,
    Object? focusedPanel = null,
    Object? isRightPanelVisible = null,
  }) {
    return _then(
      _$SecPlanPanelStateImpl(
        panelRatio: null == panelRatio
            ? _value.panelRatio
            : panelRatio // ignore: cast_nullable_to_non_nullable
                  as double,
        isSwapped: null == isSwapped
            ? _value.isSwapped
            : isSwapped // ignore: cast_nullable_to_non_nullable
                  as bool,
        maximizedPanel: null == maximizedPanel
            ? _value.maximizedPanel
            : maximizedPanel // ignore: cast_nullable_to_non_nullable
                  as MaximizedPanel,
        focusedPanel: null == focusedPanel
            ? _value.focusedPanel
            : focusedPanel // ignore: cast_nullable_to_non_nullable
                  as FocusedPanel,
        isRightPanelVisible: null == isRightPanelVisible
            ? _value.isRightPanelVisible
            : isRightPanelVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc

class _$SecPlanPanelStateImpl implements _SecPlanPanelState {
  const _$SecPlanPanelStateImpl({
    this.panelRatio = 0.5,
    this.isSwapped = false,
    this.maximizedPanel = MaximizedPanel.none,
    this.focusedPanel = FocusedPanel.left,
    this.isRightPanelVisible = true,
  });

  @override
  @JsonKey()
  final double panelRatio;
  @override
  @JsonKey()
  final bool isSwapped;
  @override
  @JsonKey()
  final MaximizedPanel maximizedPanel;
  @override
  @JsonKey()
  final FocusedPanel focusedPanel;
  @override
  @JsonKey()
  final bool isRightPanelVisible;

  @override
  String toString() {
    return 'SecPlanPanelState(panelRatio: $panelRatio, isSwapped: $isSwapped, maximizedPanel: $maximizedPanel, focusedPanel: $focusedPanel, isRightPanelVisible: $isRightPanelVisible)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SecPlanPanelStateImpl &&
            (identical(other.panelRatio, panelRatio) ||
                other.panelRatio == panelRatio) &&
            (identical(other.isSwapped, isSwapped) ||
                other.isSwapped == isSwapped) &&
            (identical(other.maximizedPanel, maximizedPanel) ||
                other.maximizedPanel == maximizedPanel) &&
            (identical(other.focusedPanel, focusedPanel) ||
                other.focusedPanel == focusedPanel) &&
            (identical(other.isRightPanelVisible, isRightPanelVisible) ||
                other.isRightPanelVisible == isRightPanelVisible));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    panelRatio,
    isSwapped,
    maximizedPanel,
    focusedPanel,
    isRightPanelVisible,
  );

  /// Create a copy of SecPlanPanelState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SecPlanPanelStateImplCopyWith<_$SecPlanPanelStateImpl> get copyWith =>
      __$$SecPlanPanelStateImplCopyWithImpl<_$SecPlanPanelStateImpl>(
        this,
        _$identity,
      );
}

abstract class _SecPlanPanelState implements SecPlanPanelState {
  const factory _SecPlanPanelState({
    final double panelRatio,
    final bool isSwapped,
    final MaximizedPanel maximizedPanel,
    final FocusedPanel focusedPanel,
    final bool isRightPanelVisible,
  }) = _$SecPlanPanelStateImpl;

  @override
  double get panelRatio;
  @override
  bool get isSwapped;
  @override
  MaximizedPanel get maximizedPanel;
  @override
  FocusedPanel get focusedPanel;
  @override
  bool get isRightPanelVisible;

  /// Create a copy of SecPlanPanelState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SecPlanPanelStateImplCopyWith<_$SecPlanPanelStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
