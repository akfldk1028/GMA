import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'package:gma_frontend/features/file_manager/models/note_metadata_model.dart';
import 'package:gma_frontend/features/file_manager/pages/screens/file_browser_screen.dart';
import 'package:gma_frontend/features/file_manager/pages/widgets/note_list_item.dart';
import 'package:gma_frontend/features/file_manager/pages/widgets/file_tree_widget.dart';
import 'package:gma_frontend/constants/app_theme.dart';

void main() {

  group('File Manager Widget Tests', () {
    testWidgets('NoteListItem renders correctly', (WidgetTester tester) async {
      // Create a test note
      final testNote = NoteMetadata(
        id: 'test-123',
        title: 'Test Note',
        filePath: '/path/to/test.md',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        previewText: 'This is a preview of the test note content.',
      );

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: ShadApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: NoteListItem(
                note: testNote,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify note title is displayed
      expect(find.text('Test Note'), findsOneWidget);

      // Verify preview text is displayed (truncated to 50 chars)
      expect(find.textContaining('This is a preview'), findsOneWidget);
    });

    testWidgets('NoteListItem shows PDF indicator when hasLinkedPdf is true',
        (WidgetTester tester) async {
      // Create a test note with linked PDF
      final testNote = NoteMetadata(
        id: 'test-123',
        title: 'Test Note with PDF',
        filePath: '/path/to/test.md',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        linkedPdfPath: '/path/to/document.pdf',
        previewText: 'Test note with PDF',
      );

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: ShadApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: NoteListItem(
                note: testNote,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Verify PDF indicator icon is displayed
      expect(find.byIcon(Icons.picture_as_pdf), findsOneWidget);
    });

    testWidgets('FileTreeWidget renders note list correctly',
        (WidgetTester tester) async {
      // Create test notes with simple paths in root
      final testNotes = [
        NoteMetadata(
          id: 'note-1',
          title: 'Note 1',
          filePath: 'note1.md',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
        NoteMetadata(
          id: 'note-2',
          title: 'Note 2',
          filePath: 'note2.md',
          createdAt: DateTime.now(),
          modifiedAt: DateTime.now(),
        ),
      ];

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: ShadApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: FileTreeWidget(
                notes: testNotes,
                onNoteSelected: (note) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify notes are displayed - FileTreeWidget displays note.title, not filename
      expect(find.text('Note 1'), findsOneWidget);
      expect(find.text('Note 2'), findsOneWidget);
    });
  });

  group('File Manager Models', () {
    test('NoteMetadata hasLinkedPdf returns true when linkedPdfPath is set',
        () {
      final note = NoteMetadata(
        id: 'test',
        title: 'Test',
        filePath: '/test.md',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        linkedPdfPath: '/test.pdf',
      );

      expect(note.hasLinkedPdf, isTrue);
    });

    test('NoteMetadata hasLinkedPdf returns false when linkedPdfPath is null',
        () {
      final note = NoteMetadata(
        id: 'test',
        title: 'Test',
        filePath: '/test.md',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      );

      expect(note.hasLinkedPdf, isFalse);
    });
  });
}
