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
      debugPrint('[ScrapNotePageStore._box] BAD STATE: $e');
      rethrow;
    }
  }

  @override
  int build() {
    debugPrint('[ScrapNotePageStore.build] initialized');
    return 0;
  }

  void _bump() => state = state + 1;

  /// Create a new page with optional name. Returns the page.
  ScrapNotePage createPage({String? name}) {
    debugPrint('[ScrapNotePageStore.createPage] name: $name');
    try {
      final page = ScrapNotePage(
        id: const Uuid().v4(),
        name: name ?? 'Page ${_box.length + 1}',
        createdAt: DateTime.now(),
      );
      _box.put(page.id, jsonEncode(page.toJson()));
      debugPrint('[ScrapNotePageStore.createPage] created id: ${page.id}, name: ${page.name}, totalPages: ${_box.length}');
      _bump();
      return page;
    } catch (e) {
      debugPrint('[ScrapNotePageStore.createPage] Hive error: $e');
      rethrow;
    }
  }

  /// Get a page by ID.
  ScrapNotePage? getById(String id) {
    debugPrint('[ScrapNotePageStore.getById] id: $id');
    try {
      final raw = _box.get(id);
      if (raw == null) {
        debugPrint('[ScrapNotePageStore.getById] not found: $id');
        return null;
      }
      final page = ScrapNotePage.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      debugPrint('[ScrapNotePageStore.getById] found: ${page.name}, elements: ${page.elementIds.length}');
      return page;
    } catch (e) {
      debugPrint('[ScrapNotePageStore.getById] Hive error: $e');
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
      debugPrint('[ScrapNotePageStore.all] found ${results.length} pages');
      return results;
    } catch (e) {
      debugPrint('[ScrapNotePageStore.all] Hive error: $e');
      return [];
    }
  }

  /// Add an element ID to a page.
  void addElement(String pageId, String elementId) {
    debugPrint('[ScrapNotePageStore.addElement] pageId: $pageId, elementId: $elementId');
    try {
      final page = getById(pageId);
      if (page == null) {
        debugPrint('[ScrapNotePageStore.addElement] page not found: $pageId');
        return;
      }
      if (page.elementIds.contains(elementId)) {
        debugPrint('[ScrapNotePageStore.addElement] element already in page, skipping');
        return;
      }
      final updated = page.copyWith(
        elementIds: [...page.elementIds, elementId],
      );
      _box.put(pageId, jsonEncode(updated.toJson()));
      debugPrint('[ScrapNotePageStore.addElement] added, new count: ${updated.elementIds.length}');
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.addElement] Hive error: $e');
    }
  }

  /// Remove an element ID from a page.
  void removeElement(String pageId, String elementId) {
    debugPrint('[ScrapNotePageStore.removeElement] pageId: $pageId, elementId: $elementId');
    try {
      final page = getById(pageId);
      if (page == null) {
        debugPrint('[ScrapNotePageStore.removeElement] page not found: $pageId');
        return;
      }
      final updated = page.copyWith(
        elementIds: page.elementIds.where((id) => id != elementId).toList(),
      );
      _box.put(pageId, jsonEncode(updated.toJson()));
      debugPrint('[ScrapNotePageStore.removeElement] removed, new count: ${updated.elementIds.length}');
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.removeElement] Hive error: $e');
    }
  }

  /// Move an element from one page to another.
  void moveElement(String elementId, String fromPageId, String toPageId) {
    debugPrint('[ScrapNotePageStore.moveElement] elementId: $elementId, from: $fromPageId, to: $toPageId');
    removeElement(fromPageId, elementId);
    addElement(toPageId, elementId);
  }

  /// Rename a page.
  void renamePage(String pageId, String newName) {
    debugPrint('[ScrapNotePageStore.renamePage] pageId: $pageId, newName: $newName');
    try {
      final page = getById(pageId);
      if (page == null) {
        debugPrint('[ScrapNotePageStore.renamePage] page not found: $pageId');
        return;
      }
      debugPrint('[ScrapNotePageStore.renamePage] renaming from "${page.name}" to "$newName"');
      final updated = page.copyWith(name: newName);
      _box.put(pageId, jsonEncode(updated.toJson()));
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.renamePage] Hive error: $e');
    }
  }

  /// Reorder elements within a page.
  void reorderElements(String pageId, int oldIndex, int newIndex) {
    debugPrint('[ScrapNotePageStore.reorderElements] pageId: $pageId, oldIndex: $oldIndex, newIndex: $newIndex');
    try {
      final page = getById(pageId);
      if (page == null) {
        debugPrint('[ScrapNotePageStore.reorderElements] page not found: $pageId');
        return;
      }
      final ids = List<String>.from(page.elementIds);
      if (oldIndex < 0 || oldIndex >= ids.length) {
        debugPrint('[ScrapNotePageStore.reorderElements] oldIndex out of bounds: $oldIndex, length: ${ids.length}');
        return;
      }
      if (newIndex < 0 || newIndex > ids.length) {
        debugPrint('[ScrapNotePageStore.reorderElements] newIndex out of bounds: $newIndex, length: ${ids.length}');
        return;
      }
      if (newIndex > oldIndex) newIndex--;
      final item = ids.removeAt(oldIndex);
      ids.insert(newIndex, item);
      final updated = page.copyWith(elementIds: ids);
      _box.put(pageId, jsonEncode(updated.toJson()));
      debugPrint('[ScrapNotePageStore.reorderElements] moved element $item from $oldIndex to $newIndex');
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.reorderElements] Hive error: $e');
    }
  }

  /// Delete a page.
  void deletePage(String pageId) {
    debugPrint('[ScrapNotePageStore.deletePage] pageId: $pageId');
    try {
      final page = getById(pageId);
      debugPrint('[ScrapNotePageStore.deletePage] page name: ${page?.name}, elements: ${page?.elementIds.length ?? 0}');
      _box.delete(pageId);
      debugPrint('[ScrapNotePageStore.deletePage] deleted, remaining pages: ${_box.length}');
      _bump();
    } catch (e) {
      debugPrint('[ScrapNotePageStore.deletePage] Hive error: $e');
    }
  }

  /// Ensure at least one default page exists. Returns the first page.
  ScrapNotePage ensureDefaultPage() {
    debugPrint('[ScrapNotePageStore.ensureDefaultPage] checking...');
    try {
      final pages = all();
      if (pages.isNotEmpty) {
        debugPrint('[ScrapNotePageStore.ensureDefaultPage] found ${pages.length} pages, returning first: ${pages.first.id}');
        return pages.first;
      }
      debugPrint('[ScrapNotePageStore.ensureDefaultPage] no pages, creating default');
      return createPage(name: 'Page 1');
    } catch (e) {
      debugPrint('[ScrapNotePageStore.ensureDefaultPage] Hive error: $e');
      rethrow;
    }
  }
}
