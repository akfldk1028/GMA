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
  late final Future<void> _initFuture;

  @override
  void build() {
    _registry = PdfRegistry();
    // init() is async (opens Hive box), but the box is already opened in
    // main.dart so Hive.openBox returns immediately. We still need to await
    // it to populate _registry._box.
    _initFuture = _doInit();
  }

  Future<void> _doInit() async {
    await _registry.init();
    _initialized = true;
  }

  /// Callers that need guaranteed init can await this.
  Future<void> ensureReady() => _initFuture;

  /// Register a PDF path and return its stable UUID.
  /// Idempotent — same path always yields the same ID.
  Future<String> register(String path) async {
    await _initFuture;
    final id = await _registry.register(path);
    debugPrint('PdfRegistryProv.register: $path → $id');
    return id;
  }

  /// Look up UUID for a given file path.
  /// Returns null if registry is not yet initialized.
  String? getIdByPath(String path) {
    if (!_initialized) return null;
    return _registry.getIdByPath(path);
  }

  /// Look up file path for a given UUID.
  /// Returns null if registry is not yet initialized.
  String? getPathById(String id) {
    if (!_initialized) return null;
    return _registry.getPathById(id);
  }
}
