import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/element_model.dart';

part 'element_store.g.dart';

const _boxName = 'element_store';

/// Maximum allowed size for a single JSON element entry (10 MB).
const _maxElementJsonSize = 10 * 1024 * 1024;

// @MX:ANCHOR: Primary element persistence provider — accessed by ScrapOrchestrator, LiveScrapsPanel
// @MX:REASON: fan_in >= 3 callers across scrapnote UI and orchestration layers
/// Hive-backed persistent store for all ScrapElement instances.
/// State is a flat list of all elements across all PDFs and types.
@Riverpod(keepAlive: true)
class ElementStoreNotifier extends _$ElementStoreNotifier {
  @override
  List<ScrapElement> build() => const [];

  /// Loads all elements from Hive into memory.
  Future<void> loadElements() async {
    final box = await _openBox();
    final elements = <ScrapElement>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is String) {
        if (raw.length > _maxElementJsonSize) {
          debugPrint(
            'ElementStore: skipping key "$key" — exceeds max size '
            '(${raw.length} bytes)',
          );
          continue;
        }
        try {
          final decoded = jsonDecode(raw);
          if (decoded is! Map<String, dynamic>) {
            debugPrint(
              'ElementStore: skipping key "$key" — expected JSON object, '
              'got ${decoded.runtimeType}',
            );
            continue;
          }
          elements.add(ScrapElement.fromJson(decoded));
        } on FormatException catch (e) {
          debugPrint('ElementStore: malformed JSON for key "$key": $e');
        } on TypeError catch (e) {
          debugPrint('ElementStore: type error for key "$key": $e');
        }
      }
    }
    state = elements;
  }

  /// Adds a new element and persists it to Hive.
  Future<void> addElement(ScrapElement element) async {
    final box = await _openBox();
    await box.put(element.id, jsonEncode(element.toJson()));
    state = [...state, element];
  }

  /// Removes an element by ID and deletes it from Hive.
  Future<void> removeElement(String id) async {
    final box = await _openBox();
    await box.delete(id);
    state = state.where((e) => e.id != id).toList();
  }

  /// Returns all elements associated with the given PDF path.
  List<ScrapElement> getElementsByPdf(String pdfPath) {
    return state.where((e) => e.pdfPath == pdfPath).toList();
  }

  /// Returns all elements of the given type.
  List<ScrapElement> getElementsByType(ScrapElementType type) {
    return state.where((e) => e.type == type).toList();
  }

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(_boxName)) return Hive.box(_boxName);
    return Hive.openBox(_boxName);
  }
}
