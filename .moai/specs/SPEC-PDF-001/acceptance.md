# SPEC-PDF-001: Acceptance Criteria

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-PDF-001                                  |
| Title       | PDF Viewer and Drawing System                 |
| Created     | 2026-03-15                                    |
| Status      | Approved                                      |

---

## Quality Gates

- All acceptance criteria verified
- `dart analyze --no-fatal-infos` passes with zero errors
- `flutter test` passes for all new and modified test files
- Code generation (`build_runner`) completes without errors
- No regressions in existing workspace functionality (SPEC-SP-001)
- 85%+ test coverage for new files

---

## R-01: PDF Document Management

### AC-01: PDF Document Loading

```gherkin
Given a valid PDF file path exists on disk
When the PdfDocumentProvider receives the file path
Then the provider transitions to loading state
And the PDF is loaded via pdfrx
And the provider transitions to loaded state with document reference
And totalPages reflects the actual page count
```

### AC-02: PDF Loading Error Handling

```gherkin
Given an invalid or missing PDF file path
When the PdfDocumentProvider attempts to load the file
Then the provider transitions to error state
And an error message is available in the state
And the viewer displays an error widget with retry action
```

### AC-03: PDF Page Display

```gherkin
Given a PDF document is loaded successfully
When the PdfViewerScreen renders
Then all pages are rendered via pdfrx PdfViewer widget
And the viewer supports vertical scrolling between pages
And the current page number updates as the user scrolls
```

### AC-04: PDF Zoom

```gherkin
Given a PDF document is displayed
When the user performs a pinch-to-zoom gesture
Then the page content zooms in or out proportionally
And the zoom level is reflected in the PdfViewerController
```

### AC-05: Programmatic Page Navigation

```gherkin
Given a PDF document with 10 pages is loaded
When goToPage(5) is called on the document provider
Then the viewer scrolls to display page 5
And the currentPage state updates to 5
```

---

## R-02: Drawing System

### AC-06: Drawing Stroke Capture (Pen)

```gherkin
Given a PDF page is displayed
And the drawing mode is set to pen
When the user performs pointer-down, pointer-move, pointer-up on the page
Then a DrawingStroke is created with tool type "pen"
And the stroke contains normalized StrokePoint coordinates (0.0-1.0)
And the stroke is added to the drawing provider's strokes for that page
```

### AC-07: Drawing Stroke Capture (Highlighter)

```gherkin
Given a PDF page is displayed
And the drawing mode is set to highlighter
When the user draws a stroke on the page
Then a DrawingStroke is created with tool type "highlighter"
And the stroke renders with semi-transparent opacity (~0.3)
And the stroke width is wider than the default pen width
```

### AC-08: Stroke Rendering with perfect_freehand

```gherkin
Given one or more completed strokes exist for a page
When the StrokePainter renders
Then each stroke is converted to a smooth outline path via getStroke()
And pen strokes render as opaque filled paths
And highlighter strokes render as semi-transparent filled paths
```

### AC-09: Eraser Tool

```gherkin
Given a PDF page has 3 existing drawing strokes
And the drawing mode is set to eraser
When the user drags the eraser across a stroke
Then the intersected stroke is removed from the page's stroke list
And the remaining 2 strokes continue to render
And the removal is reflected in the drawing provider state
```

### AC-10: Undo Operation

```gherkin
Given the user has drawn 3 strokes on a page
When the user triggers undo
Then the most recently added stroke is removed from display
And the undo stack decrements
And the redo stack contains the removed stroke
```

### AC-11: Redo Operation

```gherkin
Given the user has undone 1 stroke
When the user triggers redo
Then the undone stroke is restored to the page
And the redo stack decrements
And the undo stack contains the restored stroke
```

### AC-12: Drawing Persistence

```gherkin
Given the user has drawn strokes on pages 1 and 3 of a PDF
When the drawing data is serialized via DrawingSerializer
Then the output is valid JSON containing all strokes keyed by page number
And when the JSON is deserialized, the strokes match the originals exactly
```

### AC-13: Pass-Through When No Tool Active

```gherkin
Given the drawing mode is set to none (no tool active)
When the user scrolls or pinch-zooms on the PDF page
Then the pointer events pass through the drawing canvas
And the PDF viewer handles scroll and zoom normally
And no drawing input is captured
```

---

## R-03: Drawing Toolbar

### AC-14: Toolbar Visibility and Tool Selection

```gherkin
Given a PDF document is loaded
When the workspace renders
Then the drawing toolbar is visible
And the toolbar displays buttons for Pen, Highlighter, and Eraser
When the user taps the Pen button
Then the Pen button shows active state styling
And the drawing mode changes to pen
```

### AC-15: Color Selection

```gherkin
Given the drawing toolbar is displayed
When the user selects a different color from the color palette
Then the active color updates in the drawing provider
And subsequent strokes use the new color
And the palette offers at least Red, Blue, and Black
```

### AC-16: Thickness Selection

```gherkin
Given the drawing toolbar is displayed
When the user selects a different thickness level
Then the active stroke width updates in the drawing provider
And subsequent strokes use the new width
And at least 3 thickness sizes are available
```

### AC-17: Undo/Redo Button State

```gherkin
Given no strokes have been drawn
Then the undo button is disabled
And the redo button is disabled

Given the user has drawn 2 strokes
Then the undo button is enabled
And the redo button is disabled

Given the user has undone 1 stroke
Then the undo button is enabled
And the redo button is enabled
```

### AC-18: Panel-Aware Toolbar

```gherkin
Given the drawing toolbar is displayed
And the left panel (PDF viewer) is focused
When the user selects the Pen tool and draws a stroke
Then the stroke is added to the left panel's drawing provider

Given the right panel is focused
When the user selects the Pen tool and draws a stroke
Then the stroke is added to the right panel's drawing provider
And the toolbar instance remains the same shared widget
```

---

## R-04: Text Selection

### AC-19: Text Selection via Long-Press

```gherkin
Given a PDF page contains selectable text
And the drawing mode is set to none
When the user long-presses on a text region
Then the text under the press point is identified
And the selected text is visually highlighted
And the extracted text string is available to consumers
```

### AC-20: Coordinate Conversion

```gherkin
Given a PdfTextExtractor instance for a page with known dimensions
When converting PDF coordinates (100, 200) on a page of size (500, 1000) to normalized
Then the result is (0.2, 0.2)
When converting normalized coordinates (0.2, 0.2) back to PDF coordinates
Then the result is (100.0, 200.0)
```

### AC-21: Text Extraction Within Bounds

```gherkin
Given a PDF page contains text "Hello World" spanning a known region
When extractText() is called with a normalized bounding rect covering that region
Then the returned text contains "Hello World"
And the returned bounds match the text's normalized position
```

---

## Definition of Done

1. All 21 acceptance criteria pass their Gherkin scenarios
2. `dart analyze` reports zero errors and zero warnings on new files
3. `flutter test` passes with 85%+ coverage on all new files
4. `build_runner` generates freezed and riverpod code without errors
5. Drawing strokes persist across app restarts (serialization round-trip verified)
6. No pointer event conflicts between drawing canvas and PDF viewer scroll/zoom
7. Toolbar renders correctly with v2 design tokens (AppColors, AppSpacing, AppTypography)
8. Toolbar correctly routes tool actions based on focused panel
9. PdfViewerScreen integrates into SPEC-SP-001 workspace without regressions
10. Text selection works only when no drawing tool is active

---

## Verification Methods

| Method | Scope | Tools |
|--------|-------|-------|
| Unit Tests | Models, providers, serializer, tool handlers, text extractor | flutter_test, mockito |
| Widget Tests | PdfViewerScreen, DrawingToolbar, DrawingCanvas, PageOverlay | flutter_test, WidgetTester |
| Integration Tests | Full drawing flow (select tool, draw, persist, reload) | flutter_test, integration_test |
| Manual Verification | Visual rendering quality, gesture responsiveness, panel-aware toolbar | Manual QA on desktop |

---

## Traceability

| Acceptance Criteria | Requirement | Plan Milestone | Plan Tasks |
|---------------------|-------------|----------------|------------|
| AC-01 to AC-05 | R-01 | M1 | M1-T1, M1-T2, M1-T3, M1-T4 |
| AC-06 to AC-13 | R-02 | M2 | M2-T1 to M2-T8, M2-T10 |
| AC-14 to AC-18 | R-03 | M2 | M2-T4, M2-T5, M2-T9 |
| AC-19 to AC-21 | R-04 | M3 | M3-T1, M3-T2, M3-T3 |
