import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralized persistence service for all workspace data.
/// Single point of truth for Hive read/write — no scattered box access.
class WorkspacePersistence {
  static const _boxName = 'workspace_data';
  static const _legacySettingsBoxName = 'workspace_settings';

  /// Get the pre-opened workspace_data box.
  /// Box is opened in main.dart at startup to avoid lazy-open race conditions.
  static Future<Box> _getBox() async {
    if (Hive.isBoxOpen(_boxName)) {
      return Hive.box(_boxName);
    }
    // Fallback: open if not yet open (e.g. in tests)
    return await Hive.openBox(_boxName);
  }

  // ─── Last session ─────────────────────────────────

  static Future<void> saveLastSession({
    String? noteId,
    String? pdfPath,
  }) async {
    final box = await _getBox();
    if (noteId != null) await box.put('last_note_id', noteId);
    if (pdfPath != null) await box.put('last_pdf_path', pdfPath);
  }

  static Future<({String? noteId, String? pdfPath})> loadLastSession() async {
    final box = await _getBox();
    final noteId = box.get('last_note_id') as String?;
    final pdfPath = box.get('last_pdf_path') as String?;
    return (
      noteId: (noteId != null && noteId.isNotEmpty) ? noteId : null,
      pdfPath: (pdfPath != null && pdfPath.isNotEmpty) ? pdfPath : null,
    );
  }

  // ─── Groups ───────────────────────────────────────

  static String _groupsKey(String noteId) => 'scrap_groups_$noteId';

  static Future<void> saveGroups(String noteId, List<List<String>> groups) async {
    final box = await _getBox();
    await box.put(_groupsKey(noteId), groups);
  }

  static Future<List<List<String>>> loadGroups(String noteId) async {
    final box = await _getBox();
    final saved = box.get(_groupsKey(noteId));
    if (saved is! List) return [];
    return saved
        .whereType<List>()
        .map((g) => g.cast<String>().toList())
        .toList();
  }

  // ─── Canvas layout (per note) ─────────────────────

  static String _layoutKey(String noteId) => 'canvas_layout_$noteId';

  static Future<void> saveCanvasLayout(
    String noteId,
    Map<String, Map<String, double>> layout,
  ) async {
    final box = await _getBox();
    await box.put(_layoutKey(noteId), jsonEncode(layout));
  }

  static Future<Map<String, Map<String, double>>> loadCanvasLayout(
      String noteId) async {
    final box = await _getBox();
    final raw = box.get(_layoutKey(noteId));
    if (raw is! String) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(
          k,
          (v as Map<String, dynamic>)
              .map((k2, v2) => MapEntry(k2, (v2 as num).toDouble()))));
    } catch (e) {
      debugPrint('[WorkspacePersistence] layout parse error: $e');
      return {};
    }
  }

  // ─── Canvas rotations (per note) ──────────────────

  static String _rotationKey(String noteId) => 'canvas_rotations_$noteId';

  static Future<void> saveCanvasRotations(
    String noteId,
    Map<String, double> rotations,
  ) async {
    final box = await _getBox();
    await box.put(_rotationKey(noteId), jsonEncode(rotations));
  }

  static Future<Map<String, double>> loadCanvasRotations(
      String noteId) async {
    final box = await _getBox();
    final raw = box.get(_rotationKey(noteId));
    if (raw is! String) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded
          .map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (e) {
      debugPrint('[WorkspacePersistence] rotation parse error: $e');
      return {};
    }
  }

  // ─── Group edit data (strokes + notes) ────────────

  static String _groupEditKey(String groupKey) => 'group_edit_$groupKey';

  static Future<void> saveGroupEdit(
      String groupKey, Map<String, dynamic> data) async {
    final box = await _getBox();
    await box.put(_groupEditKey(groupKey), jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadGroupEdit(
      String groupKey) async {
    final box = await _getBox();
    final raw = box.get(_groupEditKey(groupKey));
    if (raw is! String) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, Map<String, dynamic>>> loadAllGroupEdits() async {
    final box = await _getBox();
    final results = <String, Map<String, dynamic>>{};
    for (final key in box.keys) {
      if (key is String && key.startsWith('group_edit_')) {
        final groupKey = key.substring('group_edit_'.length);
        final raw = box.get(key);
        if (raw is String) {
          try {
            results[groupKey] = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {}
        }
      }
    }
    return results;
  }

  // ─── Canvas strokes (per note) ─────────────────────

  static String _strokesKey(String noteId) => 'canvas_strokes_$noteId';

  static Future<void> saveCanvasStrokes(
    String noteId,
    List<Map<String, dynamic>> strokes,
  ) async {
    final box = await _getBox();
    await box.put(_strokesKey(noteId), jsonEncode(strokes));
  }

  static Future<List<Map<String, dynamic>>> loadCanvasStrokes(
      String noteId) async {
    final box = await _getBox();
    final raw = box.get(_strokesKey(noteId));
    if (raw is! String) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ─── Notebook card props (per note) ───────────────
  // Per-card width ratio (0..1 of panel), height (px), rotation (radians).
  // Used by NotebookScrapPanel for in-slot scale/rotate.

  static String _notebookCardKey(String noteId) => 'notebook_card_props_$noteId';

  static Future<void> saveNotebookCardProps(
    String noteId,
    Map<String, Map<String, double>> props,
  ) async {
    final box = await _getBox();
    await box.put(_notebookCardKey(noteId), jsonEncode(props));
  }

  static Future<Map<String, Map<String, double>>> loadNotebookCardProps(
      String noteId) async {
    final box = await _getBox();
    final raw = box.get(_notebookCardKey(noteId));
    if (raw is! String) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(
          k,
          (v as Map<String, dynamic>)
              .map((k2, v2) => MapEntry(k2, (v2 as num).toDouble()))));
    } catch (e) {
      debugPrint('[WorkspacePersistence] notebook card props parse error: $e');
      return {};
    }
  }

  // ─── Panel sizes ──────────────────────────────────

  static Future<void> savePanelSizes(Map<String, dynamic> sizes) async {
    final box = await _getBox();
    await box.put('panel_sizes', sizes);
  }

  static Future<Map<String, dynamic>?> loadPanelSizes() async {
    final box = await _getBox();
    final saved = box.get('panel_sizes');
    if (saved is Map) return Map<String, dynamic>.from(saved);

    // v1.0.9 and older stored panel sizes in a separate box. Keep this
    // fallback so existing users and older tests retain their layout.
    final legacyBox = Hive.isBoxOpen(_legacySettingsBoxName)
        ? Hive.box(_legacySettingsBoxName)
        : await Hive.openBox(_legacySettingsBoxName);
    final legacySaved = legacyBox.get('panel_sizes');
    if (legacySaved is Map) {
      final migrated = Map<String, dynamic>.from(legacySaved);
      await box.put('panel_sizes', migrated);
      return migrated;
    }
    return null;
  }
}
