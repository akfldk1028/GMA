import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Centralized persistence service for all workspace data.
/// Single point of truth for Hive read/write — no scattered box access.
class WorkspacePersistence {
  static const _boxName = 'workspace_data';
  static Box? _box;

  static Future<Box> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
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
    return (
      noteId: box.get('last_note_id') as String?,
      pdfPath: box.get('last_pdf_path') as String?,
    );
  }

  // ─── Groups ───────────────────────────────────────

  static Future<void> saveGroups(List<List<String>> groups) async {
    final box = await _getBox();
    await box.put('scrap_groups', groups);
  }

  static Future<List<List<String>>> loadGroups() async {
    final box = await _getBox();
    final saved = box.get('scrap_groups');
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

  // ─── Panel sizes ──────────────────────────────────

  static Future<void> savePanelSizes(Map<String, dynamic> sizes) async {
    final box = await _getBox();
    await box.put('panel_sizes', sizes);
  }

  static Future<Map<String, dynamic>?> loadPanelSizes() async {
    final box = await _getBox();
    final saved = box.get('panel_sizes');
    if (saved is Map) return Map<String, dynamic>.from(saved);
    return null;
  }
}
