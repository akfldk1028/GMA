// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workspace_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PanelSizes _$PanelSizesFromJson(Map<String, dynamic> json) {
  return _PanelSizes.fromJson(json);
}

/// @nodoc
mixin _$PanelSizes {
  double get left =>
      throw _privateConstructorUsedError; // File manager sidebar (default 20%)
  double get center =>
      throw _privateConstructorUsedError; // PDF viewer (default 40%)
  double get right => throw _privateConstructorUsedError;

  /// Serializes this PanelSizes to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PanelSizes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PanelSizesCopyWith<PanelSizes> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PanelSizesCopyWith<$Res> {
  factory $PanelSizesCopyWith(
    PanelSizes value,
    $Res Function(PanelSizes) then,
  ) = _$PanelSizesCopyWithImpl<$Res, PanelSizes>;
  @useResult
  $Res call({double left, double center, double right});
}

/// @nodoc
class _$PanelSizesCopyWithImpl<$Res, $Val extends PanelSizes>
    implements $PanelSizesCopyWith<$Res> {
  _$PanelSizesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PanelSizes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? left = null,
    Object? center = null,
    Object? right = null,
  }) {
    return _then(
      _value.copyWith(
            left: null == left
                ? _value.left
                : left // ignore: cast_nullable_to_non_nullable
                      as double,
            center: null == center
                ? _value.center
                : center // ignore: cast_nullable_to_non_nullable
                      as double,
            right: null == right
                ? _value.right
                : right // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PanelSizesImplCopyWith<$Res>
    implements $PanelSizesCopyWith<$Res> {
  factory _$$PanelSizesImplCopyWith(
    _$PanelSizesImpl value,
    $Res Function(_$PanelSizesImpl) then,
  ) = __$$PanelSizesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double left, double center, double right});
}

/// @nodoc
class __$$PanelSizesImplCopyWithImpl<$Res>
    extends _$PanelSizesCopyWithImpl<$Res, _$PanelSizesImpl>
    implements _$$PanelSizesImplCopyWith<$Res> {
  __$$PanelSizesImplCopyWithImpl(
    _$PanelSizesImpl _value,
    $Res Function(_$PanelSizesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PanelSizes
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? left = null,
    Object? center = null,
    Object? right = null,
  }) {
    return _then(
      _$PanelSizesImpl(
        left: null == left
            ? _value.left
            : left // ignore: cast_nullable_to_non_nullable
                  as double,
        center: null == center
            ? _value.center
            : center // ignore: cast_nullable_to_non_nullable
                  as double,
        right: null == right
            ? _value.right
            : right // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PanelSizesImpl implements _PanelSizes {
  const _$PanelSizesImpl({
    this.left = 0.2,
    this.center = 0.4,
    this.right = 0.4,
  });

  factory _$PanelSizesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PanelSizesImplFromJson(json);

  @override
  @JsonKey()
  final double left;
  // File manager sidebar (default 20%)
  @override
  @JsonKey()
  final double center;
  // PDF viewer (default 40%)
  @override
  @JsonKey()
  final double right;

  @override
  String toString() {
    return 'PanelSizes(left: $left, center: $center, right: $right)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PanelSizesImpl &&
            (identical(other.left, left) || other.left == left) &&
            (identical(other.center, center) || other.center == center) &&
            (identical(other.right, right) || other.right == right));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, left, center, right);

  /// Create a copy of PanelSizes
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PanelSizesImplCopyWith<_$PanelSizesImpl> get copyWith =>
      __$$PanelSizesImplCopyWithImpl<_$PanelSizesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PanelSizesImplToJson(this);
  }
}

abstract class _PanelSizes implements PanelSizes {
  const factory _PanelSizes({
    final double left,
    final double center,
    final double right,
  }) = _$PanelSizesImpl;

  factory _PanelSizes.fromJson(Map<String, dynamic> json) =
      _$PanelSizesImpl.fromJson;

  @override
  double get left; // File manager sidebar (default 20%)
  @override
  double get center; // PDF viewer (default 40%)
  @override
  double get right;

  /// Create a copy of PanelSizes
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PanelSizesImplCopyWith<_$PanelSizesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkspaceState _$WorkspaceStateFromJson(Map<String, dynamic> json) {
  return _WorkspaceState.fromJson(json);
}

/// @nodoc
mixin _$WorkspaceState {
  String? get currentPdfPath => throw _privateConstructorUsedError;
  String? get currentNoteId => throw _privateConstructorUsedError;
  List<PdfMarker> get markers => throw _privateConstructorUsedError;

  /// List of currently open PDF paths (tab bar)
  List<String> get openPdfPaths => throw _privateConstructorUsedError;
  PanelSizes get panelSizes => throw _privateConstructorUsedError;
  SidebarMode get sidebarMode =>
      throw _privateConstructorUsedError; // Modal/drawer UI state
  bool get isEditorModalOpen => throw _privateConstructorUsedError;
  bool get isFileBrowserOpen => throw _privateConstructorUsedError;
  bool get isMarkerEditModalOpen => throw _privateConstructorUsedError;

  /// Whether the sticky note floating window is visible
  bool get isStickyNoteVisible => throw _privateConstructorUsedError;

  /// Whether the left page thumbnails panel is open
  bool get isPageNavOpen => throw _privateConstructorUsedError;

  /// Whether the right live scraps panel is open
  bool get isLiveScrapsOpen => throw _privateConstructorUsedError;

  /// ID of the marker currently being edited in the modal (null = new marker)
  String? get editingMarkerId => throw _privateConstructorUsedError;

  /// Pending marker data for the marker edit modal (from text selection)
  int? get pendingMarkerPageNumber => throw _privateConstructorUsedError;
  String? get pendingMarkerText => throw _privateConstructorUsedError;
  @PdfRectConverter()
  PdfRect? get pendingMarkerTextRect => throw _privateConstructorUsedError;

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
    String? currentPdfPath,
    String? currentNoteId,
    List<PdfMarker> markers,
    List<String> openPdfPaths,
    PanelSizes panelSizes,
    SidebarMode sidebarMode,
    bool isEditorModalOpen,
    bool isFileBrowserOpen,
    bool isMarkerEditModalOpen,
    bool isStickyNoteVisible,
    bool isPageNavOpen,
    bool isLiveScrapsOpen,
    String? editingMarkerId,
    int? pendingMarkerPageNumber,
    String? pendingMarkerText,
    @PdfRectConverter() PdfRect? pendingMarkerTextRect,
  });

  $PanelSizesCopyWith<$Res> get panelSizes;
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
    Object? currentPdfPath = freezed,
    Object? currentNoteId = freezed,
    Object? markers = null,
    Object? openPdfPaths = null,
    Object? panelSizes = null,
    Object? sidebarMode = null,
    Object? isEditorModalOpen = null,
    Object? isFileBrowserOpen = null,
    Object? isMarkerEditModalOpen = null,
    Object? isStickyNoteVisible = null,
    Object? isPageNavOpen = null,
    Object? isLiveScrapsOpen = null,
    Object? editingMarkerId = freezed,
    Object? pendingMarkerPageNumber = freezed,
    Object? pendingMarkerText = freezed,
    Object? pendingMarkerTextRect = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentPdfPath: freezed == currentPdfPath
                ? _value.currentPdfPath
                : currentPdfPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            currentNoteId: freezed == currentNoteId
                ? _value.currentNoteId
                : currentNoteId // ignore: cast_nullable_to_non_nullable
                      as String?,
            markers: null == markers
                ? _value.markers
                : markers // ignore: cast_nullable_to_non_nullable
                      as List<PdfMarker>,
            openPdfPaths: null == openPdfPaths
                ? _value.openPdfPaths
                : openPdfPaths // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            panelSizes: null == panelSizes
                ? _value.panelSizes
                : panelSizes // ignore: cast_nullable_to_non_nullable
                      as PanelSizes,
            sidebarMode: null == sidebarMode
                ? _value.sidebarMode
                : sidebarMode // ignore: cast_nullable_to_non_nullable
                      as SidebarMode,
            isEditorModalOpen: null == isEditorModalOpen
                ? _value.isEditorModalOpen
                : isEditorModalOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            isFileBrowserOpen: null == isFileBrowserOpen
                ? _value.isFileBrowserOpen
                : isFileBrowserOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            isMarkerEditModalOpen: null == isMarkerEditModalOpen
                ? _value.isMarkerEditModalOpen
                : isMarkerEditModalOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            isStickyNoteVisible: null == isStickyNoteVisible
                ? _value.isStickyNoteVisible
                : isStickyNoteVisible // ignore: cast_nullable_to_non_nullable
                      as bool,
            isPageNavOpen: null == isPageNavOpen
                ? _value.isPageNavOpen
                : isPageNavOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLiveScrapsOpen: null == isLiveScrapsOpen
                ? _value.isLiveScrapsOpen
                : isLiveScrapsOpen // ignore: cast_nullable_to_non_nullable
                      as bool,
            editingMarkerId: freezed == editingMarkerId
                ? _value.editingMarkerId
                : editingMarkerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            pendingMarkerPageNumber: freezed == pendingMarkerPageNumber
                ? _value.pendingMarkerPageNumber
                : pendingMarkerPageNumber // ignore: cast_nullable_to_non_nullable
                      as int?,
            pendingMarkerText: freezed == pendingMarkerText
                ? _value.pendingMarkerText
                : pendingMarkerText // ignore: cast_nullable_to_non_nullable
                      as String?,
            pendingMarkerTextRect: freezed == pendingMarkerTextRect
                ? _value.pendingMarkerTextRect
                : pendingMarkerTextRect // ignore: cast_nullable_to_non_nullable
                      as PdfRect?,
          )
          as $Val,
    );
  }

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PanelSizesCopyWith<$Res> get panelSizes {
    return $PanelSizesCopyWith<$Res>(_value.panelSizes, (value) {
      return _then(_value.copyWith(panelSizes: value) as $Val);
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
    String? currentPdfPath,
    String? currentNoteId,
    List<PdfMarker> markers,
    List<String> openPdfPaths,
    PanelSizes panelSizes,
    SidebarMode sidebarMode,
    bool isEditorModalOpen,
    bool isFileBrowserOpen,
    bool isMarkerEditModalOpen,
    bool isStickyNoteVisible,
    bool isPageNavOpen,
    bool isLiveScrapsOpen,
    String? editingMarkerId,
    int? pendingMarkerPageNumber,
    String? pendingMarkerText,
    @PdfRectConverter() PdfRect? pendingMarkerTextRect,
  });

  @override
  $PanelSizesCopyWith<$Res> get panelSizes;
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
    Object? currentPdfPath = freezed,
    Object? currentNoteId = freezed,
    Object? markers = null,
    Object? openPdfPaths = null,
    Object? panelSizes = null,
    Object? sidebarMode = null,
    Object? isEditorModalOpen = null,
    Object? isFileBrowserOpen = null,
    Object? isMarkerEditModalOpen = null,
    Object? isStickyNoteVisible = null,
    Object? isPageNavOpen = null,
    Object? isLiveScrapsOpen = null,
    Object? editingMarkerId = freezed,
    Object? pendingMarkerPageNumber = freezed,
    Object? pendingMarkerText = freezed,
    Object? pendingMarkerTextRect = freezed,
  }) {
    return _then(
      _$WorkspaceStateImpl(
        currentPdfPath: freezed == currentPdfPath
            ? _value.currentPdfPath
            : currentPdfPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        currentNoteId: freezed == currentNoteId
            ? _value.currentNoteId
            : currentNoteId // ignore: cast_nullable_to_non_nullable
                  as String?,
        markers: null == markers
            ? _value._markers
            : markers // ignore: cast_nullable_to_non_nullable
                  as List<PdfMarker>,
        openPdfPaths: null == openPdfPaths
            ? _value._openPdfPaths
            : openPdfPaths // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        panelSizes: null == panelSizes
            ? _value.panelSizes
            : panelSizes // ignore: cast_nullable_to_non_nullable
                  as PanelSizes,
        sidebarMode: null == sidebarMode
            ? _value.sidebarMode
            : sidebarMode // ignore: cast_nullable_to_non_nullable
                  as SidebarMode,
        isEditorModalOpen: null == isEditorModalOpen
            ? _value.isEditorModalOpen
            : isEditorModalOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        isFileBrowserOpen: null == isFileBrowserOpen
            ? _value.isFileBrowserOpen
            : isFileBrowserOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        isMarkerEditModalOpen: null == isMarkerEditModalOpen
            ? _value.isMarkerEditModalOpen
            : isMarkerEditModalOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        isStickyNoteVisible: null == isStickyNoteVisible
            ? _value.isStickyNoteVisible
            : isStickyNoteVisible // ignore: cast_nullable_to_non_nullable
                  as bool,
        isPageNavOpen: null == isPageNavOpen
            ? _value.isPageNavOpen
            : isPageNavOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLiveScrapsOpen: null == isLiveScrapsOpen
            ? _value.isLiveScrapsOpen
            : isLiveScrapsOpen // ignore: cast_nullable_to_non_nullable
                  as bool,
        editingMarkerId: freezed == editingMarkerId
            ? _value.editingMarkerId
            : editingMarkerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        pendingMarkerPageNumber: freezed == pendingMarkerPageNumber
            ? _value.pendingMarkerPageNumber
            : pendingMarkerPageNumber // ignore: cast_nullable_to_non_nullable
                  as int?,
        pendingMarkerText: freezed == pendingMarkerText
            ? _value.pendingMarkerText
            : pendingMarkerText // ignore: cast_nullable_to_non_nullable
                  as String?,
        pendingMarkerTextRect: freezed == pendingMarkerTextRect
            ? _value.pendingMarkerTextRect
            : pendingMarkerTextRect // ignore: cast_nullable_to_non_nullable
                  as PdfRect?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkspaceStateImpl implements _WorkspaceState {
  const _$WorkspaceStateImpl({
    this.currentPdfPath,
    this.currentNoteId,
    final List<PdfMarker> markers = const [],
    final List<String> openPdfPaths = const [],
    this.panelSizes = const PanelSizes(),
    this.sidebarMode = SidebarMode.fileBrowser,
    this.isEditorModalOpen = false,
    this.isFileBrowserOpen = false,
    this.isMarkerEditModalOpen = false,
    this.isStickyNoteVisible = true,
    this.isPageNavOpen = true,
    this.isLiveScrapsOpen = true,
    this.editingMarkerId,
    this.pendingMarkerPageNumber,
    this.pendingMarkerText,
    @PdfRectConverter() this.pendingMarkerTextRect,
  }) : _markers = markers,
       _openPdfPaths = openPdfPaths;

  factory _$WorkspaceStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkspaceStateImplFromJson(json);

  @override
  final String? currentPdfPath;
  @override
  final String? currentNoteId;
  final List<PdfMarker> _markers;
  @override
  @JsonKey()
  List<PdfMarker> get markers {
    if (_markers is EqualUnmodifiableListView) return _markers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_markers);
  }

  /// List of currently open PDF paths (tab bar)
  final List<String> _openPdfPaths;

  /// List of currently open PDF paths (tab bar)
  @override
  @JsonKey()
  List<String> get openPdfPaths {
    if (_openPdfPaths is EqualUnmodifiableListView) return _openPdfPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_openPdfPaths);
  }

  @override
  @JsonKey()
  final PanelSizes panelSizes;
  @override
  @JsonKey()
  final SidebarMode sidebarMode;
  // Modal/drawer UI state
  @override
  @JsonKey()
  final bool isEditorModalOpen;
  @override
  @JsonKey()
  final bool isFileBrowserOpen;
  @override
  @JsonKey()
  final bool isMarkerEditModalOpen;

  /// Whether the sticky note floating window is visible
  @override
  @JsonKey()
  final bool isStickyNoteVisible;

  /// Whether the left page thumbnails panel is open
  @override
  @JsonKey()
  final bool isPageNavOpen;

  /// Whether the right live scraps panel is open
  @override
  @JsonKey()
  final bool isLiveScrapsOpen;

  /// ID of the marker currently being edited in the modal (null = new marker)
  @override
  final String? editingMarkerId;

  /// Pending marker data for the marker edit modal (from text selection)
  @override
  final int? pendingMarkerPageNumber;
  @override
  final String? pendingMarkerText;
  @override
  @PdfRectConverter()
  final PdfRect? pendingMarkerTextRect;

  @override
  String toString() {
    return 'WorkspaceState(currentPdfPath: $currentPdfPath, currentNoteId: $currentNoteId, markers: $markers, openPdfPaths: $openPdfPaths, panelSizes: $panelSizes, sidebarMode: $sidebarMode, isEditorModalOpen: $isEditorModalOpen, isFileBrowserOpen: $isFileBrowserOpen, isMarkerEditModalOpen: $isMarkerEditModalOpen, isStickyNoteVisible: $isStickyNoteVisible, isPageNavOpen: $isPageNavOpen, isLiveScrapsOpen: $isLiveScrapsOpen, editingMarkerId: $editingMarkerId, pendingMarkerPageNumber: $pendingMarkerPageNumber, pendingMarkerText: $pendingMarkerText, pendingMarkerTextRect: $pendingMarkerTextRect)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkspaceStateImpl &&
            (identical(other.currentPdfPath, currentPdfPath) ||
                other.currentPdfPath == currentPdfPath) &&
            (identical(other.currentNoteId, currentNoteId) ||
                other.currentNoteId == currentNoteId) &&
            const DeepCollectionEquality().equals(other._markers, _markers) &&
            const DeepCollectionEquality().equals(
              other._openPdfPaths,
              _openPdfPaths,
            ) &&
            (identical(other.panelSizes, panelSizes) ||
                other.panelSizes == panelSizes) &&
            (identical(other.sidebarMode, sidebarMode) ||
                other.sidebarMode == sidebarMode) &&
            (identical(other.isEditorModalOpen, isEditorModalOpen) ||
                other.isEditorModalOpen == isEditorModalOpen) &&
            (identical(other.isFileBrowserOpen, isFileBrowserOpen) ||
                other.isFileBrowserOpen == isFileBrowserOpen) &&
            (identical(other.isMarkerEditModalOpen, isMarkerEditModalOpen) ||
                other.isMarkerEditModalOpen == isMarkerEditModalOpen) &&
            (identical(other.isStickyNoteVisible, isStickyNoteVisible) ||
                other.isStickyNoteVisible == isStickyNoteVisible) &&
            (identical(other.isPageNavOpen, isPageNavOpen) ||
                other.isPageNavOpen == isPageNavOpen) &&
            (identical(other.isLiveScrapsOpen, isLiveScrapsOpen) ||
                other.isLiveScrapsOpen == isLiveScrapsOpen) &&
            (identical(other.editingMarkerId, editingMarkerId) ||
                other.editingMarkerId == editingMarkerId) &&
            (identical(
                  other.pendingMarkerPageNumber,
                  pendingMarkerPageNumber,
                ) ||
                other.pendingMarkerPageNumber == pendingMarkerPageNumber) &&
            (identical(other.pendingMarkerText, pendingMarkerText) ||
                other.pendingMarkerText == pendingMarkerText) &&
            (identical(other.pendingMarkerTextRect, pendingMarkerTextRect) ||
                other.pendingMarkerTextRect == pendingMarkerTextRect));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentPdfPath,
    currentNoteId,
    const DeepCollectionEquality().hash(_markers),
    const DeepCollectionEquality().hash(_openPdfPaths),
    panelSizes,
    sidebarMode,
    isEditorModalOpen,
    isFileBrowserOpen,
    isMarkerEditModalOpen,
    isStickyNoteVisible,
    isPageNavOpen,
    isLiveScrapsOpen,
    editingMarkerId,
    pendingMarkerPageNumber,
    pendingMarkerText,
    pendingMarkerTextRect,
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
    final String? currentPdfPath,
    final String? currentNoteId,
    final List<PdfMarker> markers,
    final List<String> openPdfPaths,
    final PanelSizes panelSizes,
    final SidebarMode sidebarMode,
    final bool isEditorModalOpen,
    final bool isFileBrowserOpen,
    final bool isMarkerEditModalOpen,
    final bool isStickyNoteVisible,
    final bool isPageNavOpen,
    final bool isLiveScrapsOpen,
    final String? editingMarkerId,
    final int? pendingMarkerPageNumber,
    final String? pendingMarkerText,
    @PdfRectConverter() final PdfRect? pendingMarkerTextRect,
  }) = _$WorkspaceStateImpl;

  factory _WorkspaceState.fromJson(Map<String, dynamic> json) =
      _$WorkspaceStateImpl.fromJson;

  @override
  String? get currentPdfPath;
  @override
  String? get currentNoteId;
  @override
  List<PdfMarker> get markers;

  /// List of currently open PDF paths (tab bar)
  @override
  List<String> get openPdfPaths;
  @override
  PanelSizes get panelSizes;
  @override
  SidebarMode get sidebarMode; // Modal/drawer UI state
  @override
  bool get isEditorModalOpen;
  @override
  bool get isFileBrowserOpen;
  @override
  bool get isMarkerEditModalOpen;

  /// Whether the sticky note floating window is visible
  @override
  bool get isStickyNoteVisible;

  /// Whether the left page thumbnails panel is open
  @override
  bool get isPageNavOpen;

  /// Whether the right live scraps panel is open
  @override
  bool get isLiveScrapsOpen;

  /// ID of the marker currently being edited in the modal (null = new marker)
  @override
  String? get editingMarkerId;

  /// Pending marker data for the marker edit modal (from text selection)
  @override
  int? get pendingMarkerPageNumber;
  @override
  String? get pendingMarkerText;
  @override
  @PdfRectConverter()
  PdfRect? get pendingMarkerTextRect;

  /// Create a copy of WorkspaceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkspaceStateImplCopyWith<_$WorkspaceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
