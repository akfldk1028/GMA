import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';

void main() async {
  Hive.init('C:/Users/User/Documents');
  final box = await Hive.openBox<String>('element_store');
  print('Total elements: ${box.length}');
  var withText = 0;
  var withRect = 0;
  var withImage = 0;
  for (final key in box.keys) {
    final raw = box.get(key);
    if (raw == null) continue;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final text = json['selectedText'] as String?;
    final rect = json['rect'];
    final img = json['imagePath'] as String?;
    if (text != null && text.isNotEmpty) withText++;
    if (rect != null) withRect++;
    if (img != null && img.isNotEmpty) withImage++;
  }
  print('With selectedText: $withText');
  print('With rect: $withRect');
  print('With imagePath: $withImage');

  // Show first 5 elements detail
  var count = 0;
  for (final key in box.keys) {
    if (count >= 5) break;
    final raw = box.get(key);
    if (raw == null) continue;
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final text = json['selectedText'] as String? ?? '';
    print('---');
    print('id: ${json["id"]}');
    print('type: ${json["type"]}');
    print('page: ${json["pageNumber"]}');
    print('text: ${text.substring(0, text.length.clamp(0, 100))}');
    print('hasRect: ${json["rect"] != null}');
    print('hasImage: ${json["imagePath"] != null && (json["imagePath"] as String).isNotEmpty}');
    count++;
  }
  await box.close();
}
