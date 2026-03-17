import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/element_model.dart';

part 'element_store.g.dart';

/// Persistent store for ScrapElements using Hive.
/// Follows the same JSON-in-Box pattern as PdfRegistry.
///
/// State is an int revision counter that increments on every mutation,
/// so widgets using `ref.watch(elementStoreProvider)` rebuild on changes.
@Riverpod(keepAlive: true)
class ElementStore extends _$ElementStore {
  static const String _boxName = 'element_store';

  Box<String> get _box {
    try {
      return Hive.box<String>(_boxName);
    } catch (e) {
      debugPrint('[ElementStore._box] BAD STATE: $e');
      rethrow;
    }
  }

  @override
  int build() {
    debugPrint('[ElementStore.build] initialized');
    return 0;
  }

  void _bump() => state = state + 1;

  /// Add (or overwrite) an element.
  void add(ScrapElement element) {
    try {
      _box.put(element.id, jsonEncode(element.toJson()));
      debugPrint('[ElementStore.add] id: ${element.id}, type: ${element.type.name}, pdfId: ${element.pdfId}, page: ${element.pageNumber}');
      _bump();
    } catch (e) {
      debugPrint('[ElementStore.add] Hive error: $e');
    }
  }

  /// Look up a single element by ID.
  ScrapElement? getById(String id) {
    try {
      final raw = _box.get(id);
      if (raw == null) {
        debugPrint('[ElementStore.getById] not found: $id');
        return null;
      }
      final element = ScrapElement.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      debugPrint('[ElementStore.getById] found: $id, type: ${element.type.name}');
      return element;
    } catch (e) {
      debugPrint('[ElementStore.getById] Hive error for $id: $e');
      return null;
    }
  }

  /// Return all elements whose pdfId matches.
  List<ScrapElement> getByPdfId(String pdfId) {
    final results = all().where((e) => e.pdfId == pdfId).toList();
    debugPrint('[ElementStore.getByPdfId] pdfId: $pdfId, found: ${results.length}');
    return results;
  }

  /// Batch lookup by a list of IDs (preserves order, skips missing).
  List<ScrapElement> getByIds(List<String> ids) {
    debugPrint('[ElementStore.getByIds] requested: ${ids.length} ids');
    final results = <ScrapElement>[];
    for (final id in ids) {
      final el = getById(id);
      if (el != null) results.add(el);
    }
    debugPrint('[ElementStore.getByIds] found: ${results.length}/${ids.length}');
    return results;
  }

  /// Delete an element by ID.
  void delete(String id) {
    try {
      debugPrint('[ElementStore.delete] id: $id');
      final existing = getById(id);
      debugPrint('[ElementStore.delete] element type: ${existing?.type.name}, page: ${existing?.pageNumber}');
      _box.delete(id);
      debugPrint('[ElementStore.delete] deleted, remaining: ${_box.length}');
      _bump();
    } catch (e) {
      debugPrint('[ElementStore.delete] Hive error: $e');
    }
  }

  /// Return every stored element.
  List<ScrapElement> all() {
    try {
      final results = <ScrapElement>[];
      for (final key in _box.keys) {
        final raw = _box.get(key);
        if (raw == null) continue;
        try {
          results.add(
            ScrapElement.fromJson(jsonDecode(raw) as Map<String, dynamic>),
          );
        } catch (e) {
          debugPrint('[ElementStore.all] corrupt entry key=$key: $e');
        }
      }
      debugPrint('[ElementStore.all] total elements: ${results.length}');
      return results;
    } catch (e) {
      debugPrint('[ElementStore.all] Hive error: $e');
      return [];
    }
  }
}
