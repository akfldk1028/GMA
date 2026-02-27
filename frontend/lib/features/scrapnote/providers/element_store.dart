import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/element_model.dart';

part 'element_store.g.dart';

/// Persistent store for ScrapElements using Hive.
/// Follows the same JSON-in-Box pattern as PdfRegistry.
@Riverpod(keepAlive: true)
class ElementStore extends _$ElementStore {
  static const String _boxName = 'element_store';

  Box<String> get _box => Hive.box<String>(_boxName);

  @override
  void build() {
    // No async init needed — box is opened in main.dart
  }

  /// Add (or overwrite) an element.
  void add(ScrapElement element) {
    _box.put(element.id, jsonEncode(element.toJson()));
    debugPrint('ElementStore.add: ${element.id} (${element.type.name})');
  }

  /// Look up a single element by ID.
  ScrapElement? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    try {
      return ScrapElement.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('ElementStore.getById($id) decode error: $e');
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
    _box.delete(id);
    debugPrint('ElementStore.delete: $id');
  }

  /// Return every stored element.
  List<ScrapElement> all() {
    final results = <ScrapElement>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        results.add(
          ScrapElement.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // skip corrupt entries
      }
    }
    return results;
  }
}
