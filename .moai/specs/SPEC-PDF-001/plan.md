# SPEC-PDF-001: Implementation Plan

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-PDF-001                                  |
| Title       | PDF Viewer and Drawing System                 |
| Created     | 2026-03-15                                    |
| Status      | Approved                                      |
| Depends On  | SPEC-SP-001 (Workspace Layout), SPEC-SP-000 (Design System) |

---

## Implementation Strategy

### Approach

Build for v2 architecture, reference v1 patterns. The v1 codebase (`frontend/lib/features/pdf_viewer/`) provides proven implementations for PDF rendering, normalized-coordinate drawing, tool plugin architecture, and text extraction. We port these patterns while adapting to v2 conventions:

1. **Freezed models** replace manual data classes (DrawingStroke, StrokePoint)
2. **Riverpod annotation** (`@riverpod`) replaces manual provider declarations
3. **v2 design tokens** (AppColors, AppSpacing, AppTypography, AppAnimation from SPEC-SP-000) replace hardcoded values
4. **Feature directory structure** follows v2 conventions (`models/`, `pages/providers/`, `pages/screens/`, `pages/widgets/`, `utils/`)
5. **Drawing feature is separate** from pdf_viewer feature, enabling toolbar sharing with scrapnote panel

### Development Methodology

Per `quality.yaml`, development mode is **hybrid**:
- New files (all ~17 new Dart files): **TDD** (RED-GREEN-REFACTOR)
- Modified file (workspace_screen.dart): **DDD** (ANALYZE-PRESERVE-IMPROVE)

### Expert Consultation

- **expert-frontend**: Recommended for Flutter CustomPainter optimization, pointer event handling across overlay layers, and pdfrx overlay builder integration

---

## Milestone 1: Core PDF Viewing (Priority High)

**Goal:** Load, display, navigate, and zoom a PDF document in the left panel slot provided by SPEC-SP-001.

### Tasks

**M1-T1: PDF Document State Model**
- Create `pdf_viewer/models/pdf_document_state.dart`
- Freezed model: `PdfDocumentState` with `document` (PdfDocument?), `currentPage` (int), `totalPages` (int), `isLoading` (bool), `error` (String?)

**M1-T2: PDF Document Provider**
- Create `pdf_viewer/pages/providers/pdf_document_provider.dart`
- `@riverpod` AsyncNotifier with `loadDocument(String path)`, `goToPage(int page)`, `clearDocument()`
- Wire PdfViewerController creation and disposal
- Transition states: initial -> loading -> loaded/error

**M1-T3: PDF Viewer Screen**
- Create `pdf_viewer/pages/screens/pdf_viewer_screen.dart`
- Compose pdfrx `PdfViewer` widget with controller from provider
- Configure page overlay builder slot (empty initially, filled in M2)
- Loading state: spinner/shimmer using AppAnimation
- Error state: retry button using shadcn_ui components

**M1-T4: Workspace Integration**
- Modify `workspace/pages/screens/workspace_screen.dart`
- Replace left panel placeholder with `PdfViewerScreen` widget
- Wire document path from workspace state (SPEC-SP-001)

### Architecture

```
workspace_screen.dart
  +-- PanelManager (from SPEC-SP-001)
       +-- Left Panel
       |    +-- PdfViewerScreen
       |         +-- PdfViewer (pdfrx)
       |              +-- pageOverlayBuilder (per page)
       +-- Right Panel
            +-- (Scrapnote placeholder / SPEC-SCRAP-001)
```

### Files

| File | Action | Methodology |
|------|--------|-------------|
| `pdf_viewer/models/pdf_document_state.dart` | Create | TDD |
| `pdf_viewer/pages/providers/pdf_document_provider.dart` | Create | TDD |
| `pdf_viewer/pages/screens/pdf_viewer_screen.dart` | Create | TDD |
| `workspace/pages/screens/workspace_screen.dart` | Modify | DDD |

---

## Milestone 2: Drawing System (Priority High)

**Goal:** Full drawing capability with pen, highlighter, eraser tools, stroke persistence, undo/redo, and a shared toolbar.

### Tasks

**M2-T1: Drawing Models**
- Create `drawing/models/drawing_model.dart`
- Freezed models: `StrokePoint` (x, y, pressure, timestamp), `DrawingStroke` (id, tool, color, strokeWidth, points, pageNumber), `DrawingData` (strokes list)
- Normalized 0.0-1.0 coordinates
- JSON serialization via `json_serializable`

**M2-T2: Drawing Tool Handler Interface**
- Create `drawing/tools/drawing_tool_handler.dart`
- Abstract class: `onPointerDown(StrokePoint)`, `onPointerMove(StrokePoint)`, `onPointerUp()`, `buildPath(List<StrokePoint>) -> Path`
- Tool metadata: name, icon, default color, default width

**M2-T3: Tool Implementations**
- `drawing/tools/pen_tool.dart`: Uses perfect_freehand `getStroke()` for smooth outlines
- `drawing/tools/highlighter_tool.dart`: Semi-transparent strokes (opacity ~0.3), wider default width
- `drawing/tools/eraser_tool.dart`: Hit-test against existing strokes using bounding box + point proximity

**M2-T4: Tool Registry**
- Create `drawing/tools/tool_registry.dart`
- Singleton: `register(DrawingMode, DrawingToolHandler)`, `getHandler(DrawingMode)`
- Auto-register pen, highlighter, eraser on initialization

**M2-T5: Drawing Provider**
- Create `drawing/pages/providers/drawing_provider.dart`
- `@riverpod` keepAlive notifier managing:
  - `DrawingMode` enum (none, pen, highlighter, eraser)
  - `activeColor`, `activeStrokeWidth`
  - `strokesPerPage`: `Map<int, List<DrawingStroke>>`
  - Undo/redo stacks (max depth 50)
- Methods: `setMode()`, `setColor()`, `setStrokeWidth()`, `addStroke()`, `removeStroke()`, `undo()`, `redo()`

**M2-T6: Drawing Canvas**
- Create `drawing/pages/widgets/drawing_canvas.dart`
- `Listener` widget capturing pointer events (down, move, up, cancel)
- Convert screen coordinates to normalized page coordinates
- Delegate to active DrawingToolHandler
- When DrawingMode is none: `HitTestBehavior.translucent` to pass events through

**M2-T7: Stroke Painter**
- Create `drawing/pages/widgets/stroke_painter.dart`
- `CustomPainter` rendering `List<DrawingStroke>` via ToolHandler.buildPath()
- Optimized `shouldRepaint` checking stroke list identity

**M2-T8: Drawing Overlay**
- Create `drawing/pages/widgets/drawing_overlay.dart`
- Per-page overlay builder composing StrokePainter + DrawingCanvas
- Registered as pdfrx page overlay via PdfViewerScreen

**M2-T9: Drawing Toolbar**
- Create `drawing/pages/widgets/drawing_toolbar.dart`
- Tool buttons from ToolRegistry (Pen, Highlighter, Eraser)
- Color palette: Red, Blue, Black minimum (preset dots using AppColors)
- Thickness selector: 3 sizes (thin, medium, thick)
- Undo/Redo buttons with disabled state based on stack availability
- Panel-aware: reads `focusedPanel` to direct actions to correct panel's provider
- Styled with v2 design tokens (SPEC-SP-000)

**M2-T10: Drawing Serializer**
- Create `drawing/utils/drawing_serializer.dart`
- `toJson(DrawingData) -> String`, `fromJson(String) -> DrawingData`
- Per-document persistence keyed by document path + page number

### Architecture

```
PdfViewerScreen
  +-- PdfViewer (pdfrx)
       +-- pageOverlayBuilder (per page):
            +-- PdfPageOverlay
                 +-- DrawingOverlay
                 |    +-- StrokePainter (completed strokes)
                 |    +-- DrawingCanvas (active input)

DrawingToolbar (outside PdfViewer, in workspace toolbar area)
  +-- Tool buttons -> DrawingProvider
  +-- Color/Thickness controls -> DrawingProvider
  +-- Undo/Redo -> DrawingProvider
  +-- Reads focusedPanel -> routes to correct provider
```

### Provider Dependency Graph

```
DrawingProvider (keepAlive)
  <-- DrawingCanvas (reads mode, writes strokes)
  <-- DrawingToolbar (reads/writes mode, color, width)
  <-- StrokePainter (reads strokes for current page)
  <-- DrawingSerializer (reads/writes strokes)

ToolRegistry (singleton)
  <-- DrawingCanvas (gets active handler)
  <-- DrawingToolbar (lists available tools)
  <-- StrokePainter (gets path builder)
```

### Files

| File | Methodology |
|------|-------------|
| `drawing/models/drawing_model.dart` | TDD |
| `drawing/tools/drawing_tool_handler.dart` | TDD |
| `drawing/tools/pen_tool.dart` | TDD |
| `drawing/tools/highlighter_tool.dart` | TDD |
| `drawing/tools/eraser_tool.dart` | TDD |
| `drawing/tools/tool_registry.dart` | TDD |
| `drawing/pages/providers/drawing_provider.dart` | TDD |
| `drawing/pages/widgets/drawing_canvas.dart` | TDD |
| `drawing/pages/widgets/stroke_painter.dart` | TDD |
| `drawing/pages/widgets/drawing_overlay.dart` | TDD |
| `drawing/pages/widgets/drawing_toolbar.dart` | TDD |
| `drawing/utils/drawing_serializer.dart` | TDD |

---

## Milestone 3: Text Selection (Priority Medium)

**Goal:** Enable text selection on PDF pages with coordinate extraction for downstream consumers.

### Tasks

**M3-T1: Text Extractor Utility**
- Create `pdf_viewer/utils/pdf_text_extractor.dart`
- Convert PDF text coordinates to normalized (0.0-1.0) coordinates and back
- Extract text content within a given normalized bounding rect
- Integrate with pdfrx page text extraction API

**M3-T2: Page Overlay Integration**
- Create `pdf_viewer/pages/widgets/pdf_page_overlay.dart`
- Compose drawing overlay + text selection highlight layer
- Text selection highlight renders above drawing strokes

**M3-T3: Text Selection Gesture Handling**
- Add long-press / drag-select gesture handling to page overlay
- Visual highlight of selected text region
- Expose selected text string and normalized bounds to consumers (clipboard, future marker/capture features)
- Text selection is active only when DrawingMode is none

### Files

| File | Methodology |
|------|-------------|
| `pdf_viewer/utils/pdf_text_extractor.dart` | TDD |
| `pdf_viewer/pages/widgets/pdf_page_overlay.dart` | TDD |

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| pdfrx overlay API changes between versions | Low | High | Pin pdfrx ^2.2.0; verify overlay builder API in tests |
| perfect_freehand path quality differs from v1 | Low | Medium | Port v1 freehand configuration values exactly |
| Pointer event conflicts between drawing canvas and PDF scroll | Medium | High | `HitTestBehavior.translucent` when no tool active; absorb events only in drawing mode |
| Normalized coordinate precision loss at extreme zoom | Low | Medium | Use double precision throughout; test at 500% zoom |
| Drawing performance with many strokes per page | Medium | Medium | `shouldRepaint` optimization; only repaint when stroke list changes; consider rasterizing completed strokes |
| Toolbar panel-awareness routing errors | Low | Medium | Unit test focusedPanel state routing; integration test with both panels |

---

## Traceability

| Requirement | Milestone | Tasks | Acceptance Criteria |
|-------------|-----------|-------|---------------------|
| R-01 | M1 | M1-T1, M1-T2, M1-T3, M1-T4 | AC-01 to AC-05 |
| R-02 | M2 | M2-T1 to M2-T8, M2-T10 | AC-06 to AC-13 |
| R-03 | M2 | M2-T4, M2-T5, M2-T9 | AC-14 to AC-18 |
| R-04 | M3 | M3-T1, M3-T2, M3-T3 | AC-19 to AC-21 |
