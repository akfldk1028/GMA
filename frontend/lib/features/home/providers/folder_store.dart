import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../models/folder_model.dart';

part 'folder_store.g.dart';

@Riverpod(keepAlive: true)
class FolderStore extends _$FolderStore {
  static const String _boxName = 'note_folders';

  Box<String> get _box => Hive.box<String>(_boxName);

  @override
  int build() => 0;

  void _bump() => state = state + 1;

  FolderModel create({required String name, String? parentId}) {
    const uuid = Uuid();
    final folder = FolderModel(
      id: uuid.v4(),
      name: name,
      parentId: parentId,
      order: _box.length,
      createdAt: DateTime.now(),
    );
    _box.put(folder.id, jsonEncode(folder.toJson()));
    debugPrint('FolderStore.create: ${folder.id} ($name)');
    _bump();
    return folder;
  }

  void rename(String id, String newName) {
    final folder = getById(id);
    if (folder == null) return;
    final updated = folder.copyWith(name: newName);
    _box.put(id, jsonEncode(updated.toJson()));
    _bump();
  }

  void delete(String id) {
    _box.delete(id);
    // Also delete child folders
    for (final child in getChildren(id)) {
      delete(child.id);
    }
    debugPrint('FolderStore.delete: $id');
    _bump();
  }

  void reorder(String id, int newOrder) {
    final folder = getById(id);
    if (folder == null) return;
    final updated = folder.copyWith(order: newOrder);
    _box.put(id, jsonEncode(updated.toJson()));
    _bump();
  }

  FolderModel? getById(String id) {
    final raw = _box.get(id);
    if (raw == null) return null;
    try {
      return FolderModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      debugPrint('FolderStore.getById($id) decode error: $e');
      return null;
    }
  }

  List<FolderModel> getChildren(String? parentId) {
    return all()
        .where((f) => f.parentId == parentId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  /// Returns ancestor chain from root to the given folder (inclusive).
  List<FolderModel> getAncestors(String folderId) {
    final ancestors = <FolderModel>[];
    String? currentId = folderId;
    while (currentId != null) {
      final folder = getById(currentId);
      if (folder == null) break;
      ancestors.insert(0, folder);
      currentId = folder.parentId;
    }
    return ancestors;
  }

  List<FolderModel> all() {
    final results = <FolderModel>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        results.add(
          FolderModel.fromJson(jsonDecode(raw) as Map<String, dynamic>),
        );
      } catch (_) {}
    }
    return results;
  }
}
