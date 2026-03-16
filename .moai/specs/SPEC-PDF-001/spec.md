# SPEC-PDF-001: PDF Viewer and Drawing System

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-PDF-001                                  |
| Title       | PDF Viewer and Drawing System                 |
| Created     | 2026-03-15                                    |
| Status      | Approved                                      |
| Priority    | High                                          |
| Lifecycle   | spec-anchored                                 |
| Depends On  | SPEC-SP-001 (Workspace Layout), SPEC-SP-000 (Design System) |

---

## Problem Statement

The GMA frontend_v2 workspace needs a working PDF viewer with drawing capabilities for the left panel. SPEC-SP-001 provides the dual-panel layout with a placeholder slot for the left panel. This SPEC defines the PDF rendering, drawing overlay system, shared drawing toolbar, and text selection functionality that fills that slot.

The v1 frontend (`frontend/lib/features/pdf_viewer/`) has a proven implementation with 28 Dart files covering PDF rendering, freehand drawing with tool plugins, and text extraction. The v1 codebase serves as an implementation reference (not a specification source) for porting patterns to the v2 architecture.

### Scope Boundary

**In Scope (SPEC-PDF-001):**
- R-01: PDF Document Management (open, render, navigate, zoom via pdfrx)
- R-02: Drawing System (strokes, tools, canvas overlay, persistence)
- R-03: Drawing Toolbar (shared between panels, panel-aware)
- R-04: Text Selection (select text on PDF, extract text + coordinates)

**Out of Scope:**
- Capture region selection and capture service (SPEC-CAPTURE-001)
- Highlight insertion into scrapnote (SPEC-CAPTURE-001)
- Scrapnote canvas (SPEC-SCRAP-001)
- Multi-PDF tab bar (SPEC-SP-001)
- Left sidebar / item navigator (SPEC-SP-001)
- Kebab menu (SPEC-SP-001)
- Panel management (SPEC-SP-001)
- File system / file picker (SPEC-FS-001)

---

## Environment

- Flutter 3.24+ / Dart 3.5+
- PDF rendering: pdfrx ^2.2.0
- Drawing: perfect_freehand ^2.5.2
- State management: flutter_riverpod + riverpod_annotation
- Models: freezed + json_serializable
- Local storage: hive_flutter
- UI framework: shadcn_ui ^0.45.1
- Design tokens: AppColors, AppSpacing, AppLayout, AppAnimation, AppTypography (SPEC-SP-000)
- Package name: gma_app

---

## Assumptions

- A-01: SPEC-SP-001 panel management is implemented, providing a left panel slot and `focusedPanel` state
- A-02: pdfrx ^2.2.0 PdfViewerController supports page navigation, zoom, and per-page overlay builders
- A-03: perfect_freehand ^2.5.2 `getStroke()` converts StrokePoint lists to outline paths suitable for CustomPainter
- A-04: Drawing stroke coordinates are normalized to 0.0-1.0 range relative to page dimensions for resolution independence
- A-05: The v2 design token system (SPEC-SP-000) is available and stable
- A-06: The drawing toolbar is shared across both panels; `focusedPanel` from SPEC-SP-001 determines which panel receives tool actions
- A-07: Text selection and drawing are mutually exclusive modes on the same page

---

## Requirements

### R-01: PDF Document Management

**R-01.1** (Ubiquitous): The PDF viewer system shall maintain a PdfDocumentState provider that holds the current PdfDocument reference, loading status, error state, and active PdfViewerController instance.

**R-01.2** (Event-Driven): **When** a PDF file path is provided to the document provider, **then** the system shall load the PDF using pdfrx, transition state from loading to loaded, and make the document available for rendering.

**R-01.3** (Event-Driven): **When** the user scrolls or pinch-zooms on the PDF viewer, **then** the PdfViewerController shall update the visible page range and zoom level accordingly.

**R-01.4** (Event-Driven): **When** a page number is programmatically requested via the document provider, **then** the viewer shall scroll to display that page with smooth animation.

**R-01.5** (Unwanted): The PDF viewer shall **not** hold more than one PdfDocument instance per viewer widget to prevent memory leaks.

**R-01.6** (State-Driven): **While** the PDF document is in a loading state, **then** the viewer shall display a loading indicator styled with v2 design tokens.

**R-01.7** (State-Driven): **While** the PDF document is in an error state, **then** the viewer shall display an error message with a retry action.

### R-02: Drawing System

**R-02.1** (Ubiquitous): The drawing system shall use DrawingStroke and StrokePoint freezed models where coordinates are normalized to 0.0-1.0 range relative to the PDF page dimensions.

**R-02.2** (Ubiquitous): The drawing system shall maintain a DrawingData model (freezed) containing a list of DrawingStroke objects per page, serializable to JSON for persistence.

**R-02.3** (Event-Driven): **When** the user performs a pointer-down, pointer-move, pointer-up sequence on a PDF page while a drawing tool is active, **then** the system shall capture a new DrawingStroke with tool type, color, stroke width, and normalized StrokePoint coordinates.

**R-02.4** (Event-Driven): **When** a pen or highlighter stroke is completed, **then** the system shall use perfect_freehand `getStroke()` to generate a smooth outline path and render it via CustomPainter on the page overlay.

**R-02.5** (Event-Driven): **When** the eraser tool intersects an existing stroke during pointer movement, **then** the system shall remove that stroke from the page's stroke list.

**R-02.6** (Event-Driven): **When** the user triggers undo, **then** the system shall remove the most recently added stroke. **When** the user triggers redo, **then** the system shall restore the most recently undone stroke.

**R-02.7** (Ubiquitous): The drawing provider shall persist strokes per-page using JSON serialization via the DrawingSerializer utility.

**R-02.8** (State-Driven): **While** no drawing tool is active (DrawingMode is none/select), **then** the drawing canvas shall pass through all pointer events to the underlying PDF viewer for scroll and zoom.

### R-03: Drawing Toolbar

**R-03.1** (Ubiquitous): The drawing toolbar shall be a single shared instance visible when a document is loaded, positioned according to the workspace layout defined by SPEC-SP-001 (Section 3.6).

**R-03.2** (Ubiquitous): The toolbar shall be active-panel-aware: tools apply to whichever panel (left or right) is currently focused, as determined by the `focusedPanel` state from SPEC-SP-001.

**R-03.3** (Event-Driven): **When** the user taps a tool button (Pen, Highlighter, Eraser), **then** the DrawingMode provider shall update to the selected tool and the toolbar shall visually indicate the active tool.

**R-03.4** (Event-Driven): **When** the user selects a color from the palette (minimum: Red, Blue, Black), **then** the active color shall update and subsequent strokes shall use the new color.

**R-03.5** (Event-Driven): **When** the user adjusts the thickness control (3 sizes minimum), **then** the active stroke width shall update and subsequent strokes shall use the new width.

**R-03.6** (Ubiquitous): The toolbar shall include Undo and Redo buttons whose enabled/disabled state reflects the current undo/redo stack availability.

**R-03.7** (Ubiquitous): The toolbar shall use the ToolRegistry pattern to dynamically register available tools, enabling future tool extensions without modifying the toolbar widget.

**R-03.8** (Ubiquitous): The toolbar shall render using v2 design tokens (AppColors for icon tints, AppSpacing for padding, AppTypography for labels).

### R-04: Text Selection

**R-04.1** (Event-Driven): **When** the user long-presses or drag-selects text on a PDF page while no drawing tool is active, **then** the PdfTextExtractor shall identify the selected text content and its normalized bounding coordinates.

**R-04.2** (Ubiquitous): The PdfTextExtractor utility shall convert between PDF coordinate space and normalized (0.0-1.0) coordinate space for consistent cross-resolution positioning.

**R-04.3** (State-Driven): **While** text is selected, **then** the system shall visually highlight the selected region and expose the extracted text string and normalized bounds to downstream consumers (clipboard copy, future highlight/capture features).

---

## Specifications

### State Architecture

```
PdfDocumentProvider (Riverpod AsyncNotifier)
  +-- PdfDocument (from pdfrx)
  +-- PdfViewerController
  +-- loadingState: AsyncValue<PdfDocument>

DrawingProvider (Riverpod Notifier, keepAlive)
  +-- DrawingMode (none | pen | highlighter | eraser)
  +-- activeColor: Color
  +-- activeStrokeWidth: double
  +-- strokesPerPage: Map<int, List<DrawingStroke>>
  +-- undoStack / redoStack

ToolRegistry (singleton)
  +-- registeredTools: Map<DrawingMode, DrawingToolHandler>
  +-- register() / getHandler()
```

### File Impact Analysis

**New Files (~17):**

| File | Purpose |
|------|---------|
| `pdf_viewer/models/pdf_document_state.dart` | Freezed: document ref + controller state |
| `pdf_viewer/pages/providers/pdf_document_provider.dart` | Riverpod: load, clear, navigate |
| `pdf_viewer/pages/screens/pdf_viewer_screen.dart` | PdfViewer composition with overlays |
| `pdf_viewer/pages/widgets/pdf_page_overlay.dart` | Per-page overlay (drawing layers) |
| `pdf_viewer/utils/pdf_text_extractor.dart` | Text selection + coordinate conversion |
| `drawing/models/drawing_model.dart` | Freezed: DrawingStroke, StrokePoint, DrawingData |
| `drawing/tools/drawing_tool_handler.dart` | Abstract interface for tool plugins |
| `drawing/tools/pen_tool.dart` | Pen: getStroke() path generation |
| `drawing/tools/highlighter_tool.dart` | Highlighter: semi-transparent strokes |
| `drawing/tools/eraser_tool.dart` | Eraser: hit-test and stroke removal |
| `drawing/tools/tool_registry.dart` | Dynamic tool registration singleton |
| `drawing/pages/providers/drawing_provider.dart` | DrawingMode + strokes + undo/redo state |
| `drawing/pages/widgets/drawing_canvas.dart` | Pointer input capture (down/move/up) |
| `drawing/pages/widgets/drawing_overlay.dart` | Per-page overlay builder for drawing |
| `drawing/pages/widgets/stroke_painter.dart` | CustomPainter rendering strokes |
| `drawing/pages/widgets/drawing_toolbar.dart` | Tool buttons, color, thickness, undo/redo |
| `drawing/utils/drawing_serializer.dart` | JSON persistence for DrawingData |

**Modified Files (~1):**

| File | Change |
|------|--------|
| `workspace/pages/screens/workspace_screen.dart` | Replace left panel placeholder with PdfViewerScreen |

### Key Design Decisions

**D-01: Normalized Coordinates (0.0-1.0)**
All drawing strokes, text selection bounds, and overlay positions use normalized coordinates relative to page dimensions. This ensures resolution independence across screen sizes and zoom levels. Proven pattern from v1.

**D-02: Tool Plugin Architecture**
Drawing tools implement a DrawingToolHandler abstract class with `onPointerDown`, `onPointerMove`, `onPointerUp`, and `buildPath` methods. The ToolRegistry dynamically registers tools, enabling future extensions (Rectangle Select, Capture, Highlight tools in later SPECs) without modifying existing code.

**D-03: Per-Page Stroke Storage**
Strokes are stored as `Map<int, List<DrawingStroke>>` keyed by page number. Only strokes for visible pages are processed during rendering, enabling efficient performance.

**D-04: Overlay Layering Order**
Page overlays render bottom to top:
1. PDF page content (rendered by pdfrx)
2. Completed drawing strokes (R-02)
3. Active stroke being drawn (R-02)
4. Text selection highlight (R-04)

**D-05: Freezed + Riverpod Annotation Pattern**
All models use `@freezed` for immutability and generated equality/copyWith. All providers use `@riverpod` annotation for code generation consistency with the v2 codebase.

**D-06: Shared Toolbar, Panel-Aware**
The drawing toolbar is a single widget instance positioned in the workspace layout (Section 3.6 of SPEC-SECPLAN). It reads `focusedPanel` state to determine which panel's drawing provider receives tool actions. This supports both left panel (PDF) and right panel (Scrapnote) drawing with one toolbar.

---

## Traceability

| Requirement | Plan Milestone | Acceptance Criteria |
|-------------|----------------|---------------------|
| R-01 | M1 (Core PDF Viewing) | AC-01 through AC-05 |
| R-02 | M2 (Drawing System) | AC-06 through AC-13 |
| R-03 | M2 (Drawing System) | AC-14 through AC-18 |
| R-04 | M3 (Text Selection) | AC-19 through AC-21 |
