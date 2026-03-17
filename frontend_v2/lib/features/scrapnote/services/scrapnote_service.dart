import 'package:uuid/uuid.dart';

import '../models/scrapnote_canvas_model.dart';
import '../utils/scrapnote_serializer.dart';

const _uuid = Uuid();

/// Lifecycle management for scrapnote canvas files.
/// Provides get-or-create semantics for PDF-linked canvas data.
class ScrapnoteService {
  /// Returns the existing scrapnote canvas for [pdfPath], or creates a new one.
  ///
  /// The canvas file is stored inside [scrapnotesDir] as a .gma file whose
  /// name is derived from the sanitized [pdfPath].
  static Future<ScrapnoteCanvasData> getOrCreate({
    required String scrapnotesDir,
    required String pdfPath,
  }) async {
    final filePath =
        ScrapnoteSerializer.buildFilePath(scrapnotesDir, pdfPath);
    final existing = await ScrapnoteSerializer.load(filePath: filePath);
    if (existing != null) return existing;

    final now = DateTime.now();
    final newData = ScrapnoteCanvasData(
      id: _uuid.v4(),
      linkedPdfPath: pdfPath,
      createdAt: now,
      modifiedAt: now,
    );
    await ScrapnoteSerializer.save(filePath: filePath, data: newData);
    return newData;
  }
}
