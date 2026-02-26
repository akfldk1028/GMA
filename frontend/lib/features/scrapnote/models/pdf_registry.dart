import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

part 'pdf_registry.freezed.dart';
part 'pdf_registry.g.dart';

/// PDF Registry Entry model
@freezed
class PdfRegistryEntry with _$PdfRegistryEntry {
  const factory PdfRegistryEntry({
    required String id,
    required String path,
    required DateTime registeredAt,
  }) = _PdfRegistryEntry;

  factory PdfRegistryEntry.fromJson(Map<String, dynamic> json) =>
      _$PdfRegistryEntryFromJson(json);
}

/// PDF Registry for managing PDF file registrations
class PdfRegistry {
  static const String _boxName = 'pdf_registry';
  static const Uuid _uuid = Uuid();

  Box<String>? _box;

  /// Initialize the PDF registry
  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Get the Hive box, throws if not initialized
  Box<String> get _safeBox {
    if (_box == null) {
      throw StateError('PdfRegistry not initialized. Call init() first.');
    }
    return _box!;
  }

  /// Register a PDF file path and return its ID
  /// If the path is already registered, returns the existing ID
  /// Otherwise, creates a new UUID and registers the path
  Future<String> register(String path) async {
    // Check if path already exists
    final existingId = getIdByPath(path);
    if (existingId != null) {
      return existingId;
    }

    // Create new entry
    final id = _uuid.v4();
    final entry = PdfRegistryEntry(
      id: id,
      path: path,
      registeredAt: DateTime.now(),
    );

    // Store as JSON string
    await _safeBox.put(id, jsonEncode(entry.toJson()));
    return id;
  }

  /// Get PDF ID by file path
  String? getIdByPath(String path) {
    final entries = allEntries();
    for (final entry in entries) {
      if (entry.path == path) {
        return entry.id;
      }
    }
    return null;
  }

  /// Get PDF file path by ID
  String? getPathById(String id) {
    final jsonString = _safeBox.get(id);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final entry = PdfRegistryEntry.fromJson(json);
      return entry.path;
    } catch (e) {
      return null;
    }
  }

  /// Get all registry entries
  List<PdfRegistryEntry> allEntries() {
    final entries = <PdfRegistryEntry>[];

    for (final key in _safeBox.keys) {
      final jsonString = _safeBox.get(key);
      if (jsonString != null) {
        try {
          final json = jsonDecode(jsonString) as Map<String, dynamic>;
          entries.add(PdfRegistryEntry.fromJson(json));
        } catch (e) {
          // Skip invalid entries
          continue;
        }
      }
    }

    return entries;
  }

  /// Close the Hive box
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  /// Clear all entries (for testing)
  Future<void> clear() async {
    await _safeBox.clear();
  }
}
