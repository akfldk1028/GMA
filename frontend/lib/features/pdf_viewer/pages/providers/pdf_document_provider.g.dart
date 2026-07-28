// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_document_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isPdfLoadedHash() => r'155534d3a6f6d0f5362baa913c2b3fc67005a0de';

/// Helper provider to check if a document is loaded.
///
/// Copied from [isPdfLoaded].
@ProviderFor(isPdfLoaded)
final isPdfLoadedProvider = AutoDisposeProvider<bool>.internal(
  isPdfLoaded,
  name: r'isPdfLoadedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPdfLoadedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPdfLoadedRef = AutoDisposeProviderRef<bool>;
String _$currentPdfPageHash() => r'62e1af8803535073ff24a3f29942d93a415146fe';

/// Helper provider to get the current page number.
///
/// Copied from [currentPdfPage].
@ProviderFor(currentPdfPage)
final currentPdfPageProvider = AutoDisposeProvider<int?>.internal(
  currentPdfPage,
  name: r'currentPdfPageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentPdfPageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentPdfPageRef = AutoDisposeProviderRef<int?>;
String _$pdfDocumentHash() => r'a86b2453363355c25174b7f308807ce11097e212';

/// Provider for managing PDF document loading state and PdfViewerController.
/// Handles PDF file loading and controller lifecycle.
/// Caches PdfDocumentRef per file path to avoid re-parsing on tab switch.
///
/// Copied from [PdfDocument].
@ProviderFor(PdfDocument)
final pdfDocumentProvider =
    NotifierProvider<PdfDocument, PdfDocumentState>.internal(
      PdfDocument.new,
      name: r'pdfDocumentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pdfDocumentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PdfDocument = Notifier<PdfDocumentState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
