import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gma_frontend/app.dart';
import 'dart:io';

void main() {
  setUpAll(() async {
    // Initialize Hive with a temporary directory for tests
    final testDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(testDir.path);
  });

  tearDownAll(() async {
    // Clean up Hive after all tests
    await Hive.close();
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GmaApp(),
      ),
    );
  });
}
