import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';

import '../models/scrapnote_canvas_model.dart';
import '../utils/scrapnote_serializer.dart';

// @MX:ANCHOR: [AUTO] ScrapnoteService — single lifecycle manager for .gma files. Used by workspace provider and canvas provider.
// @MX:REASON: High fan_in — ScrapnoteCanvasProvider and workspace integration both depend on this service.

/// Manages the lifecycle of scrapnote `.gma` files.
///
/// Maintains an in-memory index mapping PDF paths to scrapnote IDs,
/// built lazily on first access by scanning existing `.gma` files.
class ScrapnoteService {
  static const _uuid = Uuid();

  ScrapnoteService({required this.notesDir});

  /// Directory where `.gma` files are stored.
  final String notesDir;

  // In-memory index: pdfPath -> scrapnoteId
  Map<String, String>? _index;

  /// Find the scrapnote ID associated with [pdfPath].
  ///
  /// Returns `null` if no scrapnote exists for this PDF.
  Future<String?> findScrapnoteForPdf(String pdfPath) async {
    final index = await _ensureIndex();
    return index[pdfPath];
  }

  /// Get the scrapnote ID for [pdfPath], creating a new `.gma` file if needed.
  Future<String> getOrCreateScrapnote(String pdfPath) async {
    final existing = await findScrapnoteForPdf(pdfPath);
    if (existing != null) return existing;

    // Create new scrapnote
    final id = _uuid.v4();
    final now = DateTime.now();
    final data = ScrapnoteCanvasData(
      id: id,
      linkedPdfPath: pdfPath,
      strokes: const [],
      elements: const [],
      createdAt: now,
      modifiedAt: now,
    );

    final filePath = ScrapnoteSerializer.buildFilePath(notesDir, id);
    await ScrapnoteSerializer.save(filePath: filePath, data: data);

    // Update index
    final index = await _ensureIndex();
    index[pdfPath] = id;

    return id;
  }

  /// Load [ScrapnoteCanvasData] for [scrapnoteId] from its `.gma` file.
  ///
  /// Returns `null` if the file does not exist.
  Future<ScrapnoteCanvasData?> loadScrapnote(String scrapnoteId) async {
    final filePath = ScrapnoteSerializer.buildFilePath(notesDir, scrapnoteId);
    return ScrapnoteSerializer.load(filePath: filePath);
  }

  /// Save [data] to the `.gma` file for [data.id].
  Future<void> saveScrapnote(ScrapnoteCanvasData data) async {
    final filePath = ScrapnoteSerializer.buildFilePath(notesDir, data.id);
    await ScrapnoteSerializer.save(filePath: filePath, data: data);

    // Ensure index is up to date
    final index = await _ensureIndex();
    if (data.linkedPdfPath.isNotEmpty) {
      index[data.linkedPdfPath] = data.id;
    }
  }

  /// Build the pdfPath -> scrapnoteId index by scanning all `.gma` files.
  Future<Map<String, String>> _ensureIndex() async {
    if (_index != null) return _index!;

    final index = <String, String>{};

    if (!kIsWeb) {
      final dir = Directory(notesDir);

      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File && entity.path.endsWith('.gma')) {
            try {
              final data =
                  await ScrapnoteSerializer.load(filePath: entity.path);
              if (data != null && data.linkedPdfPath.isNotEmpty) {
                index[data.linkedPdfPath] = data.id;
              }
            } catch (_) {
              // Skip corrupted files
            }
          }
        }
      }
    }

    _index = index;
    return index;
  }
}
