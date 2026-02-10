// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pdf_document_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isPdfLoadedHash() => r'0aadfe4c21e173b964530657fbde022ab0cd5442';

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
String _$currentPdfPageHash() => r'082dd99b891689bc86396d384e26369fdcd666d3';

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
String _$pdfDocumentHash() => r'b0ef00bbe3a32e96b15427182e1f93b80a8cd4dc';

/// Provider for managing PDF document loading state and PdfViewerController.
/// Handles PDF file loading and controller lifecycle.
///
/// Copied from [PdfDocument].
@ProviderFor(PdfDocument)
final pdfDocumentProvider =
    AutoDisposeNotifierProvider<PdfDocument, PdfDocumentState>.internal(
      PdfDocument.new,
      name: r'pdfDocumentProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pdfDocumentHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PdfDocument = AutoDisposeNotifier<PdfDocumentState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
