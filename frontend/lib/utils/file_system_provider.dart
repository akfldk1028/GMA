import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_system_provider.g.dart';

@riverpod
Future<Directory> notesRootDirectory(Ref ref) async {
  final appDir = await getApplicationDocumentsDirectory();
  final notesDir = Directory('${appDir.path}/GMA_Notes');
  if (!await notesDir.exists()) {
    await notesDir.create(recursive: true);
  }
  return notesDir;
}

@riverpod
Future<Directory> assetsDirectory(Ref ref) async {
  final root = await ref.watch(notesRootDirectoryProvider.future);
  final dir = Directory('${root.path}/assets');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

@riverpod
Future<Directory> capturesDirectory(Ref ref) async {
  final root = await ref.watch(notesRootDirectoryProvider.future);
  final dir = Directory('${root.path}/captures');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}
