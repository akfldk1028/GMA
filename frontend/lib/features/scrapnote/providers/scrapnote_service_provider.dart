import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utils/file_system_provider.dart';
import '../services/scrapnote_service.dart';

part 'scrapnote_service_provider.g.dart';

@Riverpod(keepAlive: true)
Future<ScrapnoteService> scrapnoteServiceProv(Ref ref) async {
  final notesDir = await ref.watch(notesRootDirectoryProvider.future);
  return ScrapnoteService(notesDir: notesDir.path);
}
