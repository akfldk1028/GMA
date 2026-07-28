import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

import 'dart:convert';

import 'app.dart';
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'features/pdf_structure/services/pdf_structure_service.dart';

/// Global talker instance for logging.
final talker = TalkerFlutter.init();

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }

  // Mirror Flutter framework / async errors to debugPrint so they show
  // up in `adb logcat` with the flutter tag. Without this hook, talker's
  // observer only sees Riverpod state changes and silent assertion
  // failures (e.g., Riverpod's `_dependents.isEmpty`) end up only on the
  // red-screen overlay — invisible to logcat triage.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    debugPrint('[FlutterError] ${details.exceptionAsString()}');
    if (details.stack != null) {
      debugPrint(details.stack.toString());
    }
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[PlatformError] $error');
    debugPrint(stack.toString());
    return true;
  };
  if (kIsWeb) {
    // Web: IndexedDB-backed storage, no filesystem path needed
    await Hive.initFlutter();
  } else {
    // Native: use local AppData (avoids OneDrive .lock conflicts on Windows)
    final appDataDir = await getApplicationSupportDirectory();
    Hive.init(appDataDir.path);
    // Clean stale Hive lock files that prevent box opening after crash
    await _cleanStaleLockFiles(appDataDir.path);
    // pdfrx requires an explicit cache directory or thumbnail/page renders
    // throw "Pdfrx.getCacheDirectory is not set". Point it at AppData so
    // the cache lives outside Documents (away from user-visible files).
    Pdfrx.getCacheDirectory = () async => appDataDir.path;
  }

  // Open app settings box for theme persistence
  final appSettingsBox = await Hive.openBox('app_settings');
  // Set default theme on first run only
  if (appSettingsBox.get('theme_mode') == null) {
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

  // Open workspace_data box for session persistence (avoids lazy-open race condition)
  await Hive.openBox('workspace_data');

  // Open pdf_markers box for marker persistence (avoids lazy-open race condition)
  await Hive.openBox<Map<dynamic, dynamic>>('pdf_markers');

  // Log PDF toolchain availability (non-blocking, native only — Java/Process not available on web)
  if (!kIsWeb) {
    _logPdfToolchainStatus();
  }

  runApp(
    ProviderScope(
      observers: [
        TalkerRiverpodObserver(talker: talker),
      ],
      child: const GmaApp(),
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

/// Log PDF toolchain (Java + jar) status at startup.
void _logPdfToolchainStatus() async {
  try {
    final javaOk = await PdfStructureService.isJavaAvailable();
    debugPrint('[Startup] Java available: $javaOk');

    final jarPath = await PdfStructureService.ensureJarExtracted();
    debugPrint('[Startup] opendataloader-pdf jar: $jarPath');
  } catch (e) {
    debugPrint('[Startup] opendataloader-pdf jar NOT found: $e');
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
