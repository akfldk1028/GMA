import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/scrapnote_page_model.dart';

part 'scrapnote_page_store.g.dart';

/// Persistent store for ScrapNote pages using Hive.
///
/// State is an int revision counter (same pattern as ElementStore).
@Riverpod(keepAlive: true)
class ScrapNotePageStore extends _$ScrapNotePageStore {
  static const String _boxName = 'scrapnote_pages';

  Box<String> get _box {
    try {
      return Hive.box<String>(_boxName);
    } catch (e) {
      debugPrint('[ScrapNotePageStore] BAD STATE: $e');
      rethrow;
    }
  }

  @override
  int build() => 0;

  void _bump() => state = state + 1;

  /// Create a new page with optional name. Returns the page.
  ScrapNotePage createPage({String? name}) {
    try {
      final page = ScrapNotePage(
        id: const Uuid().v4(),
        name: name ?? 'Page ${_box.length + 1}',
        createdAt: DateTime.now(),
      );
      _box.put(page.id, jsonEncode(page.toJson()));
      _bump();
      return page;
    } catch (e) {
      debugPrint('[ScrapNotePageStore.createPage] error: $e');
      rethrow;
    }
  }

  /// Get a page by ID.
  ScrapNotePage? getById(String id) {
    try {
      final raw = _box.get(id);
      if (raw == null) return null;
      return ScrapNotePage.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[ScrapNotePageStore.getById] error: $e');
      return null;
    }
  }

  /// Get all pages sorted by creation date.
  List<ScrapNotePage> all() {
    try {
      final results = <ScrapNotePage>[];
      for (final key in _box.keys) {
        final raw = _box.get(key);
        if (raw == null) continue;
        try {
          results.add(
            ScrapNotePage.fromJson(jsonDecode(raw) as Map<String, dynamic>),
          );
        } catch (_) {}
      }
      results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return results;
    } catch (e) {
      debugPrint('[ScrapNotePageStore.all] error: $e');
      return [];
    }
  }

  /// Add an element ID to a page.
  void addElement(String pageId, String elementId) {
    try {
      final page = getById(pageId);
      if (page == null) return;
      if (page.elementIds.contains(elementId)) return;
      final updated = page.copyWith(
        elementIds: [...page.elementIds, elementId],
      );
      _box.put(pageId, jsonEncode(updated.toJson()));
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.addElement] error: $e');
    }
  }

  /// Remove an element ID from a page.
  void removeElement(String pageId, String elementId) {
    try {
      final page = getById(pageId);
      if (page == null) return;
      final updated = page.copyWith(
        elementIds: page.elementIds.where((id) => id != elementId).toList(),
      );
      _box.put(pageId, jsonEncode(updated.toJson()));
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.removeElement] error: $e');
    }
  }

  /// Move an element from one page to another.
  void moveElement(String elementId, String fromPageId, String toPageId) {
    removeElement(fromPageId, elementId);
    addElement(toPageId, elementId);
  }

  /// Rename a page.
  void renamePage(String pageId, String newName) {
    try {
      final page = getById(pageId);
      if (page == null) return;
      final updated = page.copyWith(name: newName);
      _box.put(pageId, jsonEncode(updated.toJson()));
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.renamePage] error: $e');
    }
  }

  /// Reorder elements within a page.
  void reorderElements(String pageId, int oldIndex, int newIndex) {
    try {
      final page = getById(pageId);
      if (page == null) return;
      final ids = List<String>.from(page.elementIds);
      if (oldIndex < 0 || oldIndex >= ids.length) return;
      if (newIndex < 0 || newIndex > ids.length) return;
      if (newIndex > oldIndex) newIndex--;
      final item = ids.removeAt(oldIndex);
      ids.insert(newIndex, item);
      final updated = page.copyWith(elementIds: ids);
      _box.put(pageId, jsonEncode(updated.toJson()));
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.reorderElements] error: $e');
    }
  }

  /// Delete a page.
  void deletePage(String pageId) {
    try {
      _box.delete(pageId);
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.deletePage] error: $e');
    }
  }

  /// Ensure at least one default page exists. Returns the first page.
  ScrapNotePage ensureDefaultPage() {
    final pages = all();
    if (pages.isNotEmpty) return pages.first;
    return createPage(name: 'Page 1');
  }
}
