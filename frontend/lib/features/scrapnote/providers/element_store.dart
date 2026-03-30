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
      debugPrint('[ElementStore] BAD STATE: $e');
      rethrow;
    }
  }

  @override
  int build() => 0;

  void _bump() => state = state + 1;

  /// Add (or overwrite) an element.
  void add(ScrapElement element) {
    try {
      _box.put(element.id, jsonEncode(element.toJson()));
      _bump();
    } catch (e) {
      debugPrint('[ElementStore.add] error: $e');
    }
  }

  /// Look up a single element by ID.
  ScrapElement? getById(String id) {
    try {
      final raw = _box.get(id);
      if (raw == null) return null;
      return ScrapElement.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ElementStore.getById] error for $id: $e');
      return null;
    }
  }

  /// Return all elements whose pdfId matches.
  List<ScrapElement> getByPdfId(String pdfId) {
    return all().where((e) => e.pdfId == pdfId).toList();
  }

  /// Batch lookup by a list of IDs (preserves order, skips missing).
  List<ScrapElement> getByIds(List<String> ids) {
    final results = <ScrapElement>[];
    for (final id in ids) {
      final el = getById(id);
      if (el != null) results.add(el);
    }
    return results;
  }

  /// Delete an element by ID.
  void delete(String id) {
    try {
      _box.delete(id);
      _bump();
    } catch (e) {
      debugPrint('[ElementStore.delete] error: $e');
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
        } catch (_) {}
      }
      return results;
    } catch (e) {
      debugPrint('[ElementStore.all] error: $e');
      return [];
    }
  }
}
