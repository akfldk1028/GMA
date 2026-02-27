import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/pdf_registry.dart';

part 'pdf_registry_provider.g.dart';

/// Riverpod wrapper around PdfRegistry for PDF-to-UUID mapping.
/// Box is opened in main.dart, so no async init needed.
@Riverpod(keepAlive: true)
class PdfRegistryProv extends _$PdfRegistryProv {
  late final PdfRegistry _registry;
  bool _initialized = false;

  @override
  void build() {
    // Sync init — box already opened in main.dart.
    // We still need a PdfRegistry instance for its register() logic.
    _registry = PdfRegistry();
    // Manually assign the already-opened box via init()
    _initRegistry();
  }

  void _initRegistry() {
    if (_initialized) return;
    // PdfRegistry.init() calls Hive.openBox which returns the already-opened box.
    // We call it to populate _registry._box, but it's essentially a no-op since
    // the box is already open from main.dart.
    _registry.init();
    _initialized = true;
  }

  /// Register a PDF path and return its stable UUID.
  /// Idempotent — same path always yields the same ID.
  Future<String> register(String path) async {
    final id = await _registry.register(path);
    debugPrint('PdfRegistryProv.register: $path → $id');
    return id;
  }

  /// Look up UUID for a given file path.
  String? getIdByPath(String path) => _registry.getIdByPath(path);

  /// Look up file path for a given UUID.
  String? getPathById(String id) => _registry.getPathById(id);
}
