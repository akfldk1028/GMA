// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pdf_document_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

PdfDocumentState _$PdfDocumentStateFromJson(Map<String, dynamic> json) {
  return _PdfDocumentState.fromJson(json);
}

/// @nodoc
mixin _$PdfDocumentState {
  @_PdfDocumentConverter()
  PdfDocument? get document => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  int get totalPages => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Serializes this PdfDocumentState to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PdfDocumentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PdfDocumentStateCopyWith<PdfDocumentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PdfDocumentStateCopyWith<$Res> {
  factory $PdfDocumentStateCopyWith(
    PdfDocumentState value,
    $Res Function(PdfDocumentState) then,
  ) = _$PdfDocumentStateCopyWithImpl<$Res, PdfDocumentState>;
  @useResult
  $Res call({
    @_PdfDocumentConverter() PdfDocument? document,
    int currentPage,
    int totalPages,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class _$PdfDocumentStateCopyWithImpl<$Res, $Val extends PdfDocumentState>
    implements $PdfDocumentStateCopyWith<$Res> {
  _$PdfDocumentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PdfDocumentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? document = freezed,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _value.copyWith(
            document: freezed == document
                ? _value.document
                : document // ignore: cast_nullable_to_non_nullable
                      as PdfDocument?,
            currentPage: null == currentPage
                ? _value.currentPage
                : currentPage // ignore: cast_nullable_to_non_nullable
                      as int,
            totalPages: null == totalPages
                ? _value.totalPages
                : totalPages // ignore: cast_nullable_to_non_nullable
                      as int,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            error: freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PdfDocumentStateImplCopyWith<$Res>
    implements $PdfDocumentStateCopyWith<$Res> {
  factory _$$PdfDocumentStateImplCopyWith(
    _$PdfDocumentStateImpl value,
    $Res Function(_$PdfDocumentStateImpl) then,
  ) = __$$PdfDocumentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @_PdfDocumentConverter() PdfDocument? document,
    int currentPage,
    int totalPages,
    bool isLoading,
    String? error,
  });
}

/// @nodoc
class __$$PdfDocumentStateImplCopyWithImpl<$Res>
    extends _$PdfDocumentStateCopyWithImpl<$Res, _$PdfDocumentStateImpl>
    implements _$$PdfDocumentStateImplCopyWith<$Res> {
  __$$PdfDocumentStateImplCopyWithImpl(
    _$PdfDocumentStateImpl _value,
    $Res Function(_$PdfDocumentStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PdfDocumentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? document = freezed,
    Object? currentPage = null,
    Object? totalPages = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(
      _$PdfDocumentStateImpl(
        document: freezed == document
            ? _value.document
            : document // ignore: cast_nullable_to_non_nullable
                  as PdfDocument?,
        currentPage: null == currentPage
            ? _value.currentPage
            : currentPage // ignore: cast_nullable_to_non_nullable
                  as int,
        totalPages: null == totalPages
            ? _value.totalPages
            : totalPages // ignore: cast_nullable_to_non_nullable
                  as int,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        error: freezed == error
            ? _value.error
            : error // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PdfDocumentStateImpl implements _PdfDocumentState {
  const _$PdfDocumentStateImpl({
    @_PdfDocumentConverter() this.document,
    this.currentPage = 1,
    this.totalPages = 0,
    this.isLoading = false,
    this.error,
  });

  factory _$PdfDocumentStateImpl.fromJson(Map<String, dynamic> json) =>
      _$$PdfDocumentStateImplFromJson(json);

  @override
  @_PdfDocumentConverter()
  final PdfDocument? document;
  @override
  @JsonKey()
  final int currentPage;
  @override
  @JsonKey()
  final int totalPages;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'PdfDocumentState(document: $document, currentPage: $currentPage, totalPages: $totalPages, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PdfDocumentStateImpl &&
            (identical(other.document, document) ||
                other.document == document) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.totalPages, totalPages) ||
                other.totalPages == totalPages) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    document,
    currentPage,
    totalPages,
    isLoading,
    error,
  );

  /// Create a copy of PdfDocumentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PdfDocumentStateImplCopyWith<_$PdfDocumentStateImpl> get copyWith =>
      __$$PdfDocumentStateImplCopyWithImpl<_$PdfDocumentStateImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$PdfDocumentStateImplToJson(this);
  }
}

abstract class _PdfDocumentState implements PdfDocumentState {
  const factory _PdfDocumentState({
    @_PdfDocumentConverter() final PdfDocument? document,
    final int currentPage,
    final int totalPages,
    final bool isLoading,
    final String? error,
  }) = _$PdfDocumentStateImpl;

  factory _PdfDocumentState.fromJson(Map<String, dynamic> json) =
      _$PdfDocumentStateImpl.fromJson;

  @override
  @_PdfDocumentConverter()
  PdfDocument? get document;
  @override
  int get currentPage;
  @override
  int get totalPages;
  @override
  bool get isLoading;
  @override
  String? get error;

  /// Create a copy of PdfDocumentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PdfDocumentStateImplCopyWith<_$PdfDocumentStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
