import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';

import 'app.dart';
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  // Use local AppData instead of OneDrive Documents to avoid lock conflicts
  final appDataDir = await getApplicationSupportDirectory();
  Hive.init(appDataDir.path);

  // Clean stale Hive lock files that prevent box opening after crash
  await _cleanStaleLockFiles(appDataDir.path);

  // Open app settings box for theme persistence
  final appSettingsBox = await Hive.openBox('app_settings');
  // Ensure light theme on first run or if corrupted
  if (appSettingsBox.get('theme_mode') == null ||
      appSettingsBox.get('theme_mode') == 'dark') {
    await appSettingsBox.put('theme_mode', 'light');
  }

  // Open pdf_registry box for PDF ID tracking
  await Hive.openBox<String>('pdf_registry');

  // Open element_store box for ScrapElement persistence
  final elementBox = await Hive.openBox<String>('element_store');

  // Migration: fix drawing elements that were incorrectly saved as capture
  await _migrateDrawingElements(elementBox);

  // Open scrap_annotations box for scrap drawing annotations
  await Hive.openBox<String>('scrap_annotations');

  // Open note_folders box for folder structure
  await Hive.openBox<String>('note_folders');

  // Open scrapnote_pages box for ScrapNote page management
  await Hive.openBox<String>('scrapnote_pages');

  runApp(
    const ProviderScope(
      child: GmaApp(),
    ),
  );
}

/// Fix drawing elements that were incorrectly saved as ElementType.capture.
///
/// Before the fix, createDrawingMarker rendered strokes to PNG and passed
/// capturedImagePath to createMarker, which classified them as capture.
/// Stroke PNGs have "_stroke_" in the filename; real captures don't.
Future<void> _migrateDrawingElements(Box<String> box) async {
  int fixed = 0;
  for (final key in box.keys) {
    final raw = box.get(key);
    if (raw == null) continue;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final type = map['type'] as String?;
      final imagePath = map['imagePath'] as String?;
      // Drawing strokes rendered to PNG have "_stroke_" in filename
      if (type == 'capture' && imagePath != null && imagePath.contains('_stroke_')) {
        map['type'] = 'drawing';
        box.put(key, jsonEncode(map));
        fixed++;
      }
    } catch (_) {}
  }
  if (fixed > 0) {
    debugPrint('[Migration] Fixed $fixed drawing elements (capture → drawing)');
  }
}

/// Delete stale .lock files from Hive storage directory.
/// These can be left behind after a crash and prevent re-opening boxes.
Future<void> _cleanStaleLockFiles(String hivePath) async {
  try {
    final dir = Directory(hivePath);
    if (!dir.existsSync()) return;

    for (final entity in dir.listSync()) {
      if (entity is File && entity.path.endsWith('.lock')) {
        try {
          entity.deleteSync();
        } catch (_) {
          // Ignore if file is still in use
        }
      }
    }
  } catch (_) {
    // Non-critical - proceed without cleanup
  }
}
