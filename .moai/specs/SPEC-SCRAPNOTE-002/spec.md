# SPEC-SCRAPNOTE-002: Auto-Insertion Pipeline and Visual Highlight

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-SCRAPNOTE-002                            |
| Title       | Auto-Insertion Pipeline and Visual Highlight   |
| Created     | 2026-03-17                                    |
| Status      | Implemented                                   |
| Priority    | High                                          |
| Lifecycle   | spec-anchored                                 |
| Depends On  | SPEC-SCRAPNOTE-001 (Implemented)              |

---

## Problem Statement

SPEC-SCRAPNOTE-001 established the pen-based scrapnote canvas architecture and defined the insertion pipeline. However, the current implementation has four critical gaps that break the product's core value proposition of **auto-insertion without manual steps** (product.md Design Principle 3).

### GAP 1: Text Highlight Requires Manual Modal Step (SPEC F-05 Violation)

**Current flow**: User selects text on PDF -> "Add Marker" button appears -> user clicks -> MarkerEditModal opens -> user picks color -> marker is created.

**Required flow (F-05)**: User selects text -> auto-create highlight overlay on PDF -> auto-insert highlight card into scrapnote. No manual "Add" step.

This is a direct violation of product.md F-05: "No manual 'Add' step -- automatic on text selection confirmation."

### GAP 2: No Confirmation Popup for Captures (SPEC-SCRAPNOTE-001 R8 Violation)

**Current**: CaptureOverlay has inline confirm/cancel buttons within the overlay itself.

**Required (R8)**: A floating non-modal popup with preview, accept/reject buttons, and 30-second auto-dismiss timer. The current inline buttons work but do not match the SPEC-SCRAPNOTE-001 R8.1-R8.3 requirements.

### GAP 3: No Visual Highlight Indicator on PDF

After text is highlighted, there is no persistent colored overlay or underline shown on the PDF page. The highlighter drawing tool exists but is for freehand drawing, not text-based highlights. Product.md F-05 requires "auto-create colored highlight overlay on PDF."

### GAP 4: No Scrapnote Canvas for Element Management

Elements are currently displayed as markdown cards in the note editor. The ScrapnoteCanvasData model, ScrapnoteCanvas widget, and ScrapInsertionService specified in SPEC-SCRAPNOTE-001 (S2, S3, S6) do not exist yet. Elements cannot be positioned, dragged, or managed on a canvas.

### Incremental Strategy

This SPEC addresses gaps in priority order, building on what works:
- **Keep**: Capture region selection (80% working), drawing stroke system, ElementStore, LiveScrapsPanel
- **Fix**: Text highlight flow, capture confirmation popup, visual highlight on PDF
- **Add**: Scrapnote canvas basics from SPEC-SCRAPNOTE-001

---

## Environment

- **Platform**: Flutter 3.24+ / Dart 3.5+
- **Architecture**: Feature-First + Riverpod + Freezed + GoRouter + shadcn_ui
- **Storage**: Filesystem (JSON-based `.gma` format), Hive (element metadata, PDF registry)
- **Drawing Engine**: `perfect_freehand` for smooth pressure-sensitive strokes
- **PDF Engine**: pdfrx 1.0.98+
- **Methodology**: Hybrid (TDD for new code, DDD for legacy modifications)
- **Target Coverage**: 85%+

---

## Assumptions

1. The existing capture region selection flow (CaptureOverlay -> CaptureService -> PNG rendering) is correct and should not be redesigned.
2. The existing `WorkspaceProvider.createMarker()` is the central orchestration point for all insertion flows.
3. `ElementStore` (Hive) remains the persistence layer for scrap element metadata.
4. Text selection events from pdfrx provide selected text content and bounding rectangles on the PDF page.
5. Highlight overlays on the PDF are visual-only indicators (not modifying the actual PDF file).
6. The MarkerEditModal can be removed from the text highlight flow without breaking other features.
7. SPEC-SCRAPNOTE-001 S2-S9 specifications remain the target architecture for the scrapnote canvas.
8. The scrapnote canvas in this SPEC is a minimal viable version -- infinite scroll with element rendering and basic positioning.
9. Backward compatibility with existing capture flow and ElementStore data is mandatory.

---

## Requirements

### Phase 1: Text Highlight Auto-Insertion (Priority High -- GAP 1)

#### R1: Auto-Highlight on Text Selection (Event-Driven)

**R1.1**: WHEN the user completes a text selection on a PDF page, THEN the system shall immediately create a highlight marker with a default color (yellow) without opening any modal dialog.

**R1.2**: WHEN a text highlight is created, THEN the system shall insert a highlight card into the scrapnote via the existing `WorkspaceProvider.createMarker()` pipeline.

**R1.3**: WHEN a text highlight is created, THEN the system shall create a `ScrapElement` of type `highlight` in `ElementStore` with the selected text, source page number, source rectangle, and color value.

**R1.4**: The system shall NOT display the MarkerEditModal during the text highlight auto-insertion flow.

#### R2: Highlight Color Selection (Optional)

**R2.1**: Where the user wants to change highlight color, the system shall provide a compact color selector (inline toolbar or floating pill) that appears near the text selection.

**R2.2**: The default highlight color shall be yellow (0xFFFFEB3B at 40% opacity). Available colors shall include yellow, green, blue, pink, and orange.

**R2.3**: The last-used highlight color shall persist across selections within the same session.

### Phase 2: Visual Highlight on PDF (Priority High -- GAP 3)

#### R3: Persistent Highlight Overlay on PDF (Event-Driven)

**R3.1**: WHEN a text highlight marker exists for a PDF page, THEN the system shall render a semi-transparent colored rectangle overlay on the PDF at the highlighted text location.

**R3.2**: The highlight overlay shall use the marker's color value at 30-40% opacity, drawn as a filled rectangle behind the PDF text.

**R3.3**: WHILE a PDF page is displayed, the system shall render all highlight overlays for that page from the existing marker data.

**R3.4**: WHEN a highlight marker is deleted, THEN the corresponding overlay on the PDF shall be removed immediately.

#### R4: Highlight Overlay Rendering (Ubiquitous)

**R4.1**: The highlight overlay system shall use normalized coordinates (0-1 range) consistent with the existing drawing overlay coordinate system.

**R4.2**: The highlight overlay shall render as a separate layer below drawing strokes but above the PDF content.

**R4.3**: The highlight overlay shall NOT interfere with text selection or drawing tool input on the PDF page.

### Phase 3: Capture Confirmation Popup (Priority Medium -- GAP 2)

#### R5: Floating Confirmation Popup (Event-Driven)

**R5.1**: WHEN the user completes a capture region selection on a PDF, THEN the system shall display a floating non-modal popup with a preview of the captured image, an accept button (check icon), and a reject button (x icon).

**R5.2**: WHEN the confirmation popup is displayed, THEN it shall auto-dismiss after 30 seconds if no action is taken. On timeout, the capture is NOT inserted.

**R5.3**: The confirmation popup shall not block PDF interaction (non-modal). The user can continue scrolling or selecting text while the popup is visible.

**R5.4**: WHEN the user accepts via the popup, THEN the system shall proceed with the existing capture insertion flow via `WorkspaceProvider.createMarker()`.

**R5.5**: WHEN the user rejects via the popup, THEN the capture data and temporary PNG shall be discarded.

#### R6: Capture Overlay Simplification (Event-Driven)

**R6.1**: WHEN the user drags to select a capture region, THEN the CaptureOverlay shall display the selection rectangle with visual feedback (dashed border, semi-transparent fill).

**R6.2**: WHEN the user releases the drag gesture, THEN the CaptureOverlay shall immediately render the PNG and trigger the confirmation popup (R5.1). The inline confirm/cancel buttons within CaptureOverlay are replaced by the floating popup.

### Phase 4: Scrapnote Canvas Basics (Priority Medium -- GAP 4)

#### R7: ScrapnoteCanvasData Model (Ubiquitous)

**R7.1**: The system shall implement the `ScrapnoteCanvasData` Freezed model as specified in SPEC-SCRAPNOTE-001 S2, containing canvas metadata, strokes, elements, and layer ordering.

**R7.2**: The system shall implement the `CanvasElement` Freezed model as specified in SPEC-SCRAPNOTE-001 S2, containing position, size, type, and content data.

#### R8: ScrapnoteCanvas Widget (Event-Driven)

**R8.1**: WHEN the user opens a scrapnote (from LiveScrapsPanel or file browser), THEN the system shall display a `ScrapnoteCanvas` widget with infinite scroll mode.

**R8.2**: The `ScrapnoteCanvas` shall render capture elements as positioned image widgets and highlight elements as positioned text card widgets.

**R8.3**: The `ScrapnoteCanvas` shall support pen, highlighter, and eraser tools from the existing `ToolRegistry`.

**R8.4**: WHEN a new scrap is inserted, THEN the element shall appear on the canvas at an auto-calculated position (below the last element).

#### R9: ScrapnoteCanvasProvider (Event-Driven)

**R9.1**: WHEN a scrapnote is loaded, THEN the `ScrapnoteCanvasProvider` shall load the `.gma` file and provide the `ScrapnoteCanvasData` state.

**R9.2**: WHEN a canvas element or stroke is modified, THEN the provider shall trigger a debounced auto-save (500ms) to the `.gma` file.

**R9.3**: The provider shall support global undo/redo across all strokes and element operations.

#### R10: Scrapnote Serialization (Ubiquitous)

**R10.1**: The `ScrapnoteSerializer` shall serialize `ScrapnoteCanvasData` to and from the `.gma` JSON format as specified in SPEC-SCRAPNOTE-001 S1.

**R10.2**: The serializer shall reuse `DrawingStroke.toJson()` / `fromJson()` for stroke data without modification.

#### R11: ScrapInsertionService (Event-Driven)

**R11.1**: WHEN a capture or highlight is confirmed, THEN the `ScrapInsertionService` shall calculate the insertion position and add the element to the `ScrapnoteCanvasData`.

**R11.2**: WHEN no scrapnote exists for the current PDF, THEN the `ScrapInsertionService` shall auto-create a scrapnote `.gma` file linked to that PDF before inserting the element.

### Cross-Cutting Requirements

#### R12: Backward Compatibility (Unwanted)

**R12.1**: The system shall NOT break existing PDF drawing functionality. The `DrawingOverlay` and per-page stroke system shall continue working unchanged.

**R12.2**: The system shall NOT break existing `ElementStore` data. Legacy `ScrapElement` entries shall remain accessible.

**R12.3**: The system shall NOT break the existing capture region selection gesture and PNG rendering pipeline.

**R12.4**: The system shall NOT require changes to the pdfrx library integration or PDF rendering pipeline.

---

## Specifications

### S1: Text Highlight Auto-Insertion Flow

**Modified File**: `frontend/lib/features/pdf_viewer/pages/screens/pdf_viewer_screen.dart`

**Change**: Replace the current text selection handler (lines 193-258 area) that shows "Add Marker" button and opens MarkerEditModal with a streamlined flow:
1. On text selection complete: Extract selected text, bounding rectangles, page number
2. Apply default highlight color (yellow, or last-used color)
3. Call `WorkspaceProvider.createMarker()` with type `highlight` directly
4. Skip MarkerEditModal entirely

**Modified File**: `frontend/lib/features/workspace/pages/providers/workspace_provider.dart`

**Change**: Modify `createMarker()` (lines 241-338 area) to:
1. Accept an optional `colorValue` parameter for highlight color
2. When called with highlight type, proceed directly without modal confirmation
3. Store highlight marker data including source rectangles for PDF overlay rendering

### S2: Highlight Overlay Renderer

**New File**: `frontend/lib/features/pdf_viewer/highlight/widgets/highlight_overlay.dart`

A widget that integrates with pdfrx's `pageOverlaysBuilder` (same pattern as `DrawingOverlay`):
- Queries markers for the current PDF page from the marker data store
- Renders semi-transparent colored rectangles at normalized coordinates for each highlight marker
- Updates reactively when markers are added or removed
- Renders below drawing strokes but above PDF content (z-order managed by overlay stacking)

**New File**: `frontend/lib/features/pdf_viewer/highlight/models/highlight_marker_data.dart`

A Freezed model storing highlight metadata for PDF overlay rendering:
- Page number, normalized bounding rectangles, color value
- Reference to ScrapElement ID for deletion sync

### S3: Capture Confirmation Popup (ConfirmScrapPopup)

**New File**: `frontend/lib/features/scrapnote/pages/widgets/confirm_scrap_popup.dart`

As specified in SPEC-SCRAPNOTE-001 S7:
- Floating non-modal popup with image/text preview
- Accept (check) and reject (x) buttons
- 30-second auto-dismiss timer using `Timer`
- Positioned at bottom-right of workspace, does not block PDF interaction
- Returns `Future<bool>` for accept/reject result

**Modified File**: `frontend/lib/features/pdf_viewer/capture/pages/widgets/capture_overlay.dart`

**Change**: Remove inline confirm/cancel buttons. After region selection and PNG render, delegate to `ConfirmScrapPopup` instead.

### S4: ScrapnoteCanvasData Model

As specified in SPEC-SCRAPNOTE-001 S2.

**New File**: `frontend/lib/features/scrapnote/models/scrapnote_canvas_model.dart`

### S5: ScrapnoteCanvas Widget

As specified in SPEC-SCRAPNOTE-001 S3.

**New File**: `frontend/lib/features/scrapnote/pages/widgets/scrapnote_canvas.dart`

Minimal viable version for this SPEC:
- InteractiveViewer with infinite vertical scroll
- CustomPaint layer with StrokePainter for strokes
- Positioned element widgets for captures (Image) and highlights (text card)
- Listener-based input for pen drawing (same pattern as DrawingCanvas)
- No drag-to-reposition in this SPEC (deferred to future enhancement)

### S6: ScrapnoteCanvasProvider

As specified in SPEC-SCRAPNOTE-001 S4.

**New File**: `frontend/lib/features/scrapnote/pages/providers/scrapnote_canvas_provider.dart`

### S7: ScrapnoteSerializer

As specified in SPEC-SCRAPNOTE-001 S5.

**New File**: `frontend/lib/features/scrapnote/utils/scrapnote_serializer.dart`

### S8: ScrapInsertionService

As specified in SPEC-SCRAPNOTE-001 S6.

**New File**: `frontend/lib/features/scrapnote/services/scrap_insertion_service.dart`

### S9: ScrapnoteService

As specified in SPEC-SCRAPNOTE-001 S9.

**New File**: `frontend/lib/features/scrapnote/services/scrapnote_service.dart`

---

## File Impact Analysis

### New Files (10)

| File | Purpose | Phase |
|------|---------|-------|
| `pdf_viewer/highlight/widgets/highlight_overlay.dart` | Render highlight overlays on PDF pages | Phase 2 |
| `pdf_viewer/highlight/models/highlight_marker_data.dart` | Highlight marker data model for overlay rendering | Phase 2 |
| `scrapnote/pages/widgets/confirm_scrap_popup.dart` | Floating confirmation popup for captures and highlights | Phase 3 |
| `scrapnote/models/scrapnote_canvas_model.dart` | ScrapnoteCanvasData + CanvasElement Freezed models | Phase 4 |
| `scrapnote/pages/widgets/scrapnote_canvas.dart` | Main scrapnote canvas widget | Phase 4 |
| `scrapnote/pages/providers/scrapnote_canvas_provider.dart` | Canvas state management with undo/redo and auto-save | Phase 4 |
| `scrapnote/utils/scrapnote_serializer.dart` | `.gma` JSON serialization | Phase 4 |
| `scrapnote/services/scrap_insertion_service.dart` | Insertion flow orchestration | Phase 4 |
| `scrapnote/services/scrapnote_service.dart` | Scrapnote lifecycle management | Phase 4 |
| `scrapnote/pages/screens/scrapnote_screen.dart` | Full-screen scrapnote canvas view | Phase 4 |

### Modified Files (4)

| File | Change | Impact | Phase |
|------|--------|--------|-------|
| `pdf_viewer/pages/screens/pdf_viewer_screen.dart` | Replace text selection handler to auto-insert highlight without modal | High -- core flow change | Phase 1 |
| `workspace/pages/providers/workspace_provider.dart` | Add colorValue param to createMarker(), remove modal dependency for highlights | Medium -- parameter addition | Phase 1 |
| `pdf_viewer/capture/pages/widgets/capture_overlay.dart` | Remove inline confirm/cancel, delegate to floating popup | Medium -- UI change | Phase 3 |
| `workspace/pages/widgets/live_scraps_panel.dart` | Add tap-to-open scrapnote canvas action | Low -- minor UI addition | Phase 4 |

### Shared Files (Reused Without Modification)

| File | Reason |
|------|--------|
| `pdf_viewer/drawing/models/drawing_model.dart` | DrawingStroke, StrokePoint reused in canvas |
| `pdf_viewer/drawing/tools/*.dart` | All tools reused for scrapnote canvas |
| `pdf_viewer/drawing/pages/widgets/stroke_painter.dart` | StrokePainter reused for canvas rendering |
| `pdf_viewer/drawing/pages/providers/drawing_provider.dart` | DrawingMode provider shared |
| `pdf_viewer/capture/utils/capture_service.dart` | PNG rendering unchanged |
| `scrapnote/models/element_model.dart` | ScrapElement unchanged |
| `scrapnote/providers/element_store.dart` | Element persistence unchanged |

---

## Risk Assessment

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| Text selection events from pdfrx may not provide reliable bounding rectangles for highlight overlay rendering | High | Medium | Investigate pdfrx text selection API during Phase 1; fall back to approximate word-level rectangles if needed |
| Removing MarkerEditModal may break other marker creation flows (e.g., manual marker creation from menu) | Medium | Low | Audit all call sites of MarkerEditModal before removal; keep modal available for non-auto-insertion paths |
| Highlight overlay rendering performance with many highlights per page | Medium | Low | Use RepaintBoundary per page overlay; lazy-render only visible pages |
| Capture confirmation popup may overlap with other UI elements (toolbar, panels) | Low | Medium | Use Overlay widget with explicit positioning; test with various screen sizes |
| `.gma` file format compatibility if SPEC-SCRAPNOTE-001 S1 schema evolves | Medium | Low | Implement version field and migration support from the start |
| Scrapnote canvas scroll performance with many elements and strokes | High | Medium | Use RepaintBoundary per element; virtualize off-screen strokes; limit repaint regions |
| Coordinate system mismatch between PDF normalized (0-1) and canvas absolute (pixels) | Medium | Medium | Clear documentation and conversion utilities; scrapnote uses absolute pixels, PDF overlays use normalized |

---

## Expert Consultation Recommendations

### Frontend Expert Consultation (Recommended)

This SPEC involves significant UI component work:
- Custom canvas widget with pen input and element rendering
- Floating non-modal popup with auto-dismiss timer
- PDF overlay integration with pdfrx's `pageOverlaysBuilder`
- Gesture handling coordination (text selection vs drawing vs element drag)

Consulting with **expert-frontend** would help validate:
- Widget tree structure for the scrapnote canvas
- Performance optimization for CustomPaint with many strokes
- Gesture conflict resolution strategy
- pdfrx overlay integration patterns

---

## Traceability

| Requirement | Specification | Product Feature | SCRAPNOTE-001 Ref |
|-------------|--------------|-----------------|---------------------|
| R1.1-R1.4 | S1 | F-05 (Text Highlight) | R4.1-R4.4 |
| R2.1-R2.3 | S1 | F-05 | -- |
| R3.1-R3.4 | S2 | F-05 | -- (new) |
| R4.1-R4.3 | S2 | F-05 | -- (new) |
| R5.1-R5.5 | S3 | F-08 (Capture Confirm) | R8.1-R8.3 |
| R6.1-R6.2 | S3 | F-04 (Region Capture) | R3.1 |
| R7.1-R7.2 | S4 | F-06 (Scrapnote Canvas) | S2 |
| R8.1-R8.4 | S5 | F-06 | S3 |
| R9.1-R9.3 | S6 | F-06 | S4 |
| R10.1-R10.2 | S7 | F-06 | S5 |
| R11.1-R11.2 | S8, S9 | F-06 | S6, S9 |
| R12.1-R12.4 | All | -- (backward compat) | R12.1-R12.3 |
