// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_state_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkspaceState _$WorkspaceStateFromJson(Map<String, dynamic> json) {
  return _WorkspaceState.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceState {
  Note? get currentNote => throw _privateConstructorUsedError;
  String? get currentPdf => throw _privateConstructorUsedError;
  Map<String, double> get panelSizes => throw _privateConstructorUsedError;

  /// Serializes this WorkspaceState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkspaceStateCopyWith<WorkspaceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkspaceStateCopyWith<$Res> {
  factory $WorkspaceStateCopyWith(
    WorkspaceState value,
    $Res Function(WorkspaceState) then,
  ) = _$WorkspaceStateCopyWithImpl<$Res, WorkspaceState>;
  @useResult
  $Res call({
    Note? currentNote,
    String? currentPdf,
    Map<String, double> panelSizes,
  });

  $NoteCopyWith<$Res>? get currentNote;
}

/// @nodoc
class _$WorkspaceStateCopyWithImpl<$Res, $Val extends WorkspaceState>
    implements $WorkspaceStateCopyWith<$Res> {
  _$WorkspaceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentNote = freezed,
    Object? currentPdf = freezed,
    Object? panelSizes = null,
  }) {
    return _then(
      _value.copyWith(
            currentNote: freezed == currentNote
                ? _value.currentNote
                : currentNote // ignore: cast_nullable_to_non_nullable
                      as Note?,
            currentPdf: freezed == currentPdf
                ? _value.currentPdf
                : currentPdf // ignore: cast_nullable_to_non_nullable
                      as String?,
            panelSizes: null == panelSizes
                ? _value.panelSizes
                : panelSizes // ignore: cast_nullable_to_non_nullable
                      as Map<String, double>,
          )
          as $Val,
    );
  }

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NoteCopyWith<$Res>? get currentNote {
    if (_value.currentNote == null) {
      return null;
    }

    return $NoteCopyWith<$Res>(_value.currentNote!, (value) {
      return _then(_value.copyWith(currentNote: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$WorkspaceStateImplCopyWith<$Res>
    implements $WorkspaceStateCopyWith<$Res> {
  factory _$$WorkspaceStateImplCopyWith(
    _$WorkspaceStateImpl value,
    $Res Function(_$WorkspaceStateImpl) then,
  ) = __$$WorkspaceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    Note? currentNote,
    String? currentPdf,
    Map<String, double> panelSizes,
  });

  @override
  $NoteCopyWith<$Res>? get currentNote;
}

/// @nodoc
class __$$WorkspaceStateImplCopyWithImpl<$Res>
    extends _$WorkspaceStateCopyWithImpl<$Res, _$WorkspaceStateImpl>
    implements _$$WorkspaceStateImplCopyWith<$Res> {
  __$$WorkspaceStateImplCopyWithImpl(
    _$WorkspaceStateImpl _value,
    $Res Function(_$WorkspaceStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentNote = freezed,
    Object? currentPdf = freezed,
    Object? panelSizes = null,
  }) {
    return _then(
      _$WorkspaceStateImpl(
        currentNote: freezed == currentNote
            ? _value.currentNote
            : currentNote // ignore: cast_nullable_to_non_nullable
                  as Note?,
        currentPdf: freezed == currentPdf
            ? _value.currentPdf
            : currentPdf // ignore: cast_nullable_to_non_nullable
                  as String?,
        panelSizes: null == panelSizes
            ? _value._panelSizes
            : panelSizes // ignore: cast_nullable_to_non_nullable
                  as Map<String, double>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceStateImpl implements _WorkspaceState {
  const _$WorkspaceStateImpl({
    this.currentNote,
    this.currentPdf,
    required final Map<String, double> panelSizes,
  }) : _panelSizes = panelSizes;

  factory _$WorkspaceStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceStateImplFromJson(json);

  @override
  final Note? currentNote;
  @override
  final String? currentPdf;
  final Map<String, double> _panelSizes;
  @override
  Map<String, double> get panelSizes {
    if (_panelSizes is EqualUnmodifiableMapView) return _panelSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_panelSizes);
  }

  @override
  String toString() {
    return 'WorkspaceState(currentNote: $currentNote, currentPdf: $currentPdf, panelSizes: $panelSizes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceStateImpl &&
            (identical(other.currentNote, currentNote) ||
                other.currentNote == currentNote) &&
            (identical(other.currentPdf, currentPdf) ||
                other.currentPdf == currentPdf) &&
            const DeepCollectionEquality().equals(
              other._panelSizes,
              _panelSizes,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentNote,
    currentPdf,
    const DeepCollectionEquality().hash(_panelSizes),
  );

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkspaceStateImplCopyWith<_$WorkspaceStateImpl> get copyWith =>
      __$$WorkspaceStateImplCopyWithImpl<_$WorkspaceStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkspaceStateImplToJson(this);
  }
}

abstract class _WorkspaceState implements WorkspaceState {
  const factory _WorkspaceState({
    final Note? currentNote,
    final String? currentPdf,
    required final Map<String, double> panelSizes,
  }) = _$WorkspaceStateImpl;

  factory _WorkspaceState.fromJson(Map<String, dynamic> json) =
      _$WorkspaceStateImpl.fromJson;

  @override
  Note? get currentNote;
  @override
  String? get currentPdf;
  @override
  Map<String, double> get panelSizes;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceStateImplCopyWith<_$WorkspaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
