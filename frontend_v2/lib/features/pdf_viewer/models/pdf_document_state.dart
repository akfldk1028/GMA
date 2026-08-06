import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pdfrx/pdfrx.dart';

part 'pdf_document_state.freezed.dart';
part 'pdf_document_state.g.dart';

// @MX:NOTE: PdfDocument is excluded from JSON serialization as it holds native resources.
// Only serializable metadata fields (currentPage, totalPages, isLoading, error) are persisted.

/// State model for the PDF document viewer.
/// Holds document reference (not serialized) and serializable metadata.
@freezed
class PdfDocumentState with _$PdfDocumentState {
  const factory PdfDocumentState({
    @_PdfDocumentConverter() PdfDocument? document,
    @Default(1) int currentPage,
    @Default(0) int totalPages,
    @Default(false) bool isLoading,
    String? error,
  }) = _PdfDocumentState;

  factory PdfDocumentState.fromJson(Map<String, dynamic> json) =>
      _$PdfDocumentStateFromJson(json);
}

/// Custom converter that excludes PdfDocument from JSON serialization.
/// PdfDocument holds native file handles and cannot be serialized.
class _PdfDocumentConverter
    implements JsonConverter<PdfDocument?, Map<String, dynamic>?> {
  const _PdfDocumentConverter();

  @override
  PdfDocument? fromJson(Map<String, dynamic>? json) => null;

  @override
  Map<String, dynamic>? toJson(PdfDocument? document) => null;
}
