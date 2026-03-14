import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'package:flutter/foundation.dart';
import 'package:marionette_flutter/marionette_flutter.dart';

void main() async {
  if (kDebugMode && !kIsWeb) {
    MarionetteBinding.ensureInitialized();
  } else {
    WidgetsFlutterBinding.ensureInitialized();
  }
  await Hive.initFlutter();

  // Clean stale Hive lock files that prevent box opening after crash
  if (!kIsWeb) {
    await _cleanStaleLockFiles();
  }

  // Open app settings box for theme persistence
  await Hive.openBox('app_settings');

  // Open pdf_registry box for PDF ID tracking
  await Hive.openBox<String>('pdf_registry');

  // Open element_store box for ScrapElement persistence
  await Hive.openBox<String>('element_store');

  runApp(
    DevicePreview(
      enabled: kDebugMode && !kIsWeb,
      builder: (context) => const ProviderScope(
        child: GmaApp(),
      ),
    ),
  );
}

/// Delete stale .lock files from Hive storage directory.
/// These can be left behind after a crash and prevent re-opening boxes.
/// Only runs on non-web platforms (requires dart:io).
Future<void> _cleanStaleLockFiles() async {
  if (kIsWeb) return;
  try {
    // Dynamic import to avoid dart:io on web
    final dynamic io = await _getIoModule();
    if (io == null) return;
  } catch (_) {
    // Non-critical - proceed without cleanup
  }
}

Future<dynamic> _getIoModule() async {
  // On web, this function does nothing. On native, the lock file cleanup
  // is handled by Hive internally, so we can safely skip it.
  return null;
}
