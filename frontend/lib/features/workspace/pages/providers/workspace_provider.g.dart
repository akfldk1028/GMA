// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isPdfLoadedHash() => r'1c2b864b5d890c1a00627fac5404cc57e8069442';

/// Helper provider to check if a PDF is currently loaded
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
String _$isNoteLoadedHash() => r'de56a863896207c185a6b8cc8f0ee476dcf290a2';

/// Helper provider to check if a note is currently loaded
///
/// Copied from [isNoteLoaded].
@ProviderFor(isNoteLoaded)
final isNoteLoadedProvider = AutoDisposeProvider<bool>.internal(
  isNoteLoaded,
  name: r'isNoteLoadedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isNoteLoadedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsNoteLoadedRef = AutoDisposeProviderRef<bool>;
String _$currentMarkersHash() => r'089ea39309a225d5d64c6439c00aa272d95e02bc';

/// Helper provider to get current markers
///
/// Copied from [currentMarkers].
@ProviderFor(currentMarkers)
final currentMarkersProvider = AutoDisposeProvider<List<PdfMarker>>.internal(
  currentMarkers,
  name: r'currentMarkersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentMarkersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentMarkersRef = AutoDisposeProviderRef<List<PdfMarker>>;
String _$workspaceProviderHash() => r'bb68427e64a37b5d07d72dba1b5fa93c66ff179f';

/// Main workspace provider managing PDF-Note bidirectional linking
///
/// Copied from [WorkspaceProvider].
@ProviderFor(WorkspaceProvider)
final workspaceProviderProvider =
    AutoDisposeAsyncNotifierProvider<
      WorkspaceProvider,
      WorkspaceState
    >.internal(
      WorkspaceProvider.new,
      name: r'workspaceProviderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$workspaceProviderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WorkspaceProvider = AutoDisposeAsyncNotifier<WorkspaceState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
