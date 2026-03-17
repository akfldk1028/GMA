import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() async {
  if (kDebugMode) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  await Hive.initFlutter();

  // Clean stale Hive lock files that prevent box opening after crash
  await _cleanStaleLockFiles();

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
  await Hive.openBox<String>('element_store');

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

/// Delete stale .lock files from Hive storage directory.
/// These can be left behind after a crash and prevent re-opening boxes.
Future<void> _cleanStaleLockFiles() async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(appDir.path);
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
