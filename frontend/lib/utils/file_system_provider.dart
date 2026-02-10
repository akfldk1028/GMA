import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'file_system_provider.g.dart';

@riverpod
Future<Directory> notesRootDirectory(NotesRootDirectoryRef ref) async {
  final appDir = await getApplicationDocumentsDirectory();
  final notesDir = Directory('${appDir.path}/GMA_Notes');
  if (!await notesDir.exists()) {
    await notesDir.create(recursive: true);
  }
  return notesDir;
}

@riverpod
Future<Directory> assetsDirectory(AssetsDirectoryRef ref) async {
  final root = await ref.watch(notesRootDirectoryProvider.future);
  final dir = Directory('${root.path}/assets');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}

@riverpod
Future<Directory> capturesDirectory(CapturesDirectoryRef ref) async {
  final root = await ref.watch(notesRootDirectoryProvider.future);
  final dir = Directory('${root.path}/captures');
  if (!await dir.exists()) {
    await dir.create(recursive: true);
  }
  return dir;
}
