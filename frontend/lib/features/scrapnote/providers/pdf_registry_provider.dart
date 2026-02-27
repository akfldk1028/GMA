import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/pdf_registry.dart';

part 'pdf_registry_provider.g.dart';

/// Riverpod wrapper around PdfRegistry for PDF-to-UUID mapping.
@Riverpod(keepAlive: true)
class PdfRegistryProv extends _$PdfRegistryProv {
  late final PdfRegistry _registry;

  @override
  Future<void> build() async {
    _registry = PdfRegistry();
    await _registry.init();
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
