# SPEC-SCRAPNOTE-002: Implementation Plan

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-SCRAPNOTE-002                            |
| Title       | Auto-Insertion Pipeline and Visual Highlight   |
| Status      | Planned                                       |

---

## Implementation Strategy

### Methodology

**Hybrid mode** (per quality.yaml):
- **DDD (ANALYZE-PRESERVE-IMPROVE)** for modified files: pdf_viewer_screen.dart, workspace_provider.dart, capture_overlay.dart, live_scraps_panel.dart
- **TDD (RED-GREEN-REFACTOR)** for new files: all scrapnote canvas components, highlight overlay, confirmation popup

### Approach: Incremental Gap Closure

Each phase closes one gap completely before moving to the next. This allows testing and validation at each boundary, reducing risk of cascading breakage.

---

## Milestone 1: Text Highlight Auto-Insertion (Priority High)

**Goal**: User selects text on PDF -> highlight card auto-inserts into scrapnote. No modal dialog.

### Tasks

**M1-T1: Characterize existing text selection flow (DDD: ANALYZE)**
- Read `pdf_viewer_screen.dart` text selection handler (lines 193-258)
- Read `workspace_provider.dart` `createMarker()` method (lines 241-338)
- Map all call sites of `MarkerEditModal`
- Document current flow: text selection -> button -> modal -> marker creation
- Write characterization tests for current `createMarker()` behavior

**M1-T2: Streamline text selection to auto-insert (DDD: IMPROVE)**
- Modify text selection handler in `pdf_viewer_screen.dart`:
  - Remove "Add Marker" button display
  - On selection complete: extract text, rects, page number
  - Call `createMarker()` directly with default color (yellow)
- Modify `createMarker()` in `workspace_provider.dart`:
  - Add optional `colorValue` parameter
  - Skip modal dialog when called from auto-highlight path
  - Preserve existing modal path for manual marker creation (if any)

**M1-T3: Add highlight color defaults (TDD: RED-GREEN-REFACTOR)**
- Define highlight color constants: yellow (default), green, blue, pink, orange
- Store last-used color in session state (Riverpod provider, not persisted)
- Write tests for color default selection and session persistence

**M1-T4: Verify backward compatibility**
- Run existing capture flow end-to-end
- Verify `ElementStore` data integrity
- Confirm `LiveScrapsPanel` still displays elements correctly

### Files Touched
- `pdf_viewer/pages/screens/pdf_viewer_screen.dart` (modify)
- `workspace/pages/providers/workspace_provider.dart` (modify)

### Success Criteria
- Text selection on PDF creates highlight marker without any modal
- Highlight card appears in LiveScrapsPanel immediately
- ScrapElement of type highlight exists in ElementStore
- Existing capture flow unchanged

---

## Milestone 2: Visual Highlight on PDF (Priority High)

**Goal**: Persistent colored rectangles appear on PDF at highlighted text locations.

### Tasks

**M2-T1: Create HighlightMarkerData model (TDD)**
- Define Freezed model: page number, normalized bounding rects, color value, element ID
- Write serialization tests

**M2-T2: Create HighlightOverlay widget (TDD)**
- New widget using pdfrx `pageOverlaysBuilder` pattern
- Query markers for current page from marker data
- Render semi-transparent colored rectangles at normalized coordinates
- Layer below drawing strokes, above PDF content
- Write widget tests with mock marker data

**M2-T3: Integrate HighlightOverlay with PDF viewer (DDD)**
- Add `HighlightOverlay` to pdfrx page overlay stack in `pdf_viewer_screen.dart`
- Ensure overlay reacts to marker additions and deletions
- Verify drawing tools still work over highlight overlays
- Verify text selection still works over highlight overlays

**M2-T4: Verify overlay rendering**
- Test with multiple highlights on same page
- Test with highlights across multiple pages
- Test highlight deletion removes overlay

### Files Touched
- `pdf_viewer/highlight/models/highlight_marker_data.dart` (new)
- `pdf_viewer/highlight/widgets/highlight_overlay.dart` (new)
- `pdf_viewer/pages/screens/pdf_viewer_screen.dart` (modify -- add overlay)

### Success Criteria
- Yellow semi-transparent rectangle appears on PDF where text was highlighted
- Overlay persists across page navigation (scroll away and back)
- Deleting a highlight removes the overlay
- Drawing and text selection unaffected by overlays

---

## Milestone 3: Capture Confirmation Popup (Priority Medium)

**Goal**: Replace inline capture buttons with floating non-modal popup.

### Tasks

**M3-T1: Create ConfirmScrapPopup widget (TDD)**
- Floating popup with image preview, accept/reject buttons
- 30-second auto-dismiss timer
- Returns `Future<bool>` via Completer
- Positioned at bottom-right of workspace
- Write widget tests for accept, reject, and timeout scenarios

**M3-T2: Modify CaptureOverlay (DDD: ANALYZE-PRESERVE-IMPROVE)**
- Characterize current inline button behavior
- Remove inline confirm/cancel buttons
- After region selection + PNG render: show ConfirmScrapPopup instead
- On accept: proceed with existing `createMarker()` flow
- On reject: discard temporary PNG

**M3-T3: Test capture flow end-to-end**
- Verify capture -> popup -> accept -> element created
- Verify capture -> popup -> reject -> no element
- Verify capture -> popup -> timeout (30s) -> no element
- Verify PDF interaction not blocked during popup display

### Files Touched
- `scrapnote/pages/widgets/confirm_scrap_popup.dart` (new)
- `pdf_viewer/capture/pages/widgets/capture_overlay.dart` (modify)

### Success Criteria
- Capture region selection shows floating popup instead of inline buttons
- Popup auto-dismisses after 30 seconds
- PDF remains interactive while popup is displayed
- Accept inserts element, reject discards it

---

## Milestone 4: Scrapnote Canvas Basics (Priority Medium)

**Goal**: Implement minimal viable scrapnote canvas from SPEC-SCRAPNOTE-001 architecture.

### Tasks

**M4-T1: Implement ScrapnoteCanvasData model (TDD)**
- Freezed model per SPEC-SCRAPNOTE-001 S2
- CanvasElement model with capture/highlight types
- CanvasMode enum (infinite only in this SPEC)
- Write JSON serialization tests

**M4-T2: Implement ScrapnoteSerializer (TDD)**
- `.gma` JSON read/write per SPEC-SCRAPNOTE-001 S1
- Reuse DrawingStroke.toJson()/fromJson()
- Version field for future migration
- Write round-trip serialization tests

**M4-T3: Implement ScrapnoteService (TDD)**
- getOrCreateScrapnote(pdfPath) lifecycle management
- findScrapnoteForPdf(pdfPath) scan
- load/save scrapnote data
- In-memory pdfPath-to-scrapnoteId index
- Write unit tests for all lifecycle operations

**M4-T4: Implement ScrapInsertionService (TDD)**
- proposeCapture/proposeHighlight with confirm popup
- insertCapture/insertHighlight adding elements to canvas data
- Auto-position calculation (below last element)
- Auto-create scrapnote if none exists
- Write unit tests for insertion logic

**M4-T5: Implement ScrapnoteCanvasProvider (TDD)**
- Load/save `.gma` via ScrapnoteSerializer
- Canvas state management (strokes, elements)
- Global undo/redo stack
- Debounced auto-save (500ms)
- Write provider tests

**M4-T6: Implement ScrapnoteCanvas widget (TDD)**
- InteractiveViewer with infinite scroll
- CustomPaint with StrokePainter for strokes
- Positioned widgets for capture (Image) and highlight (text card) elements
- Listener-based pen input
- Write widget tests

**M4-T7: Implement ScrapnoteScreen (TDD)**
- Full-screen canvas view with toolbar
- Navigation from LiveScrapsPanel
- Write integration tests

**M4-T8: Integrate with WorkspaceProvider**
- Wire `ScrapInsertionService` into `createMarker()` flow
- After ElementStore creation, route to ScrapInsertionService for canvas insertion
- Modify LiveScrapsPanel to open ScrapnoteScreen on element tap

### Files Touched
- `scrapnote/models/scrapnote_canvas_model.dart` (new)
- `scrapnote/utils/scrapnote_serializer.dart` (new)
- `scrapnote/services/scrapnote_service.dart` (new)
- `scrapnote/services/scrap_insertion_service.dart` (new)
- `scrapnote/pages/providers/scrapnote_canvas_provider.dart` (new)
- `scrapnote/pages/widgets/scrapnote_canvas.dart` (new)
- `scrapnote/pages/screens/scrapnote_screen.dart` (new)
- `workspace/pages/providers/workspace_provider.dart` (modify)
- `workspace/pages/widgets/live_scraps_panel.dart` (modify)

### Success Criteria
- Scrapnote `.gma` file created on first insertion for a PDF
- Canvas renders capture images and highlight text cards at correct positions
- Pen drawing works on canvas with undo/redo
- Auto-save persists canvas state
- LiveScrapsPanel tap opens ScrapnoteScreen

---

## Technical Approach

### Architecture Decisions

**Decision 1: Highlight overlay as separate widget layer**
- Highlight overlays are a new pdfrx `pageOverlaysBuilder` layer, not mixed into DrawingOverlay
- Rationale: Separation of concerns; highlights are data-driven (from markers), drawings are gesture-driven
- Trade-off: Slightly more complex overlay stack, but much cleaner code boundaries

**Decision 2: ConfirmScrapPopup uses Overlay widget**
- Use Flutter's `Overlay` system for the floating popup
- Rationale: True non-modal behavior; does not block gesture detection on PDF
- Trade-off: More complex positioning logic, but correct UX behavior

**Decision 3: Minimal canvas for Phase 4**
- No drag-to-reposition elements in this SPEC
- No fixed-page mode
- Rationale: Get the insertion pipeline working end-to-end first; polish later
- Trade-off: Canvas is read-only for element positions, but the architecture supports future enhancement

**Decision 4: Shared DrawingMode provider**
- Scrapnote canvas reuses the same DrawingMode provider as PDF drawing
- Rationale: Single toolbar controlling whichever panel is active (product.md principle)
- Trade-off: Active panel switching must be tracked; tool state applies to focused panel

### Dependency Graph

```
Phase 1 (Text Highlight Auto-Insert)
  |
  v
Phase 2 (Visual Highlight on PDF) -- depends on Phase 1 marker data
  |
Phase 3 (Capture Confirmation Popup) -- independent of Phases 1-2
  |
  v
Phase 4 (Scrapnote Canvas) -- depends on Phase 3 (uses ConfirmScrapPopup)
                            -- benefits from Phase 1 (highlight insertion data)
```

Phases 1-2 are sequential (Phase 2 needs highlight marker data from Phase 1).
Phase 3 can run in parallel with Phase 2.
Phase 4 depends on Phase 3 and benefits from Phase 1.

---

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| pdfrx text selection API may not provide reliable bounding rects | Investigate early in M1-T1; if unreliable, use approximate character-level positioning |
| MarkerEditModal removal may break non-highlight marker flows | Audit all modal call sites; keep modal for manual marker creation |
| Highlight overlay z-ordering conflicts with drawing overlay | Test overlay stacking order explicitly; adjust pdfrx `pageOverlaysBuilder` order |
| Auto-save race condition with rapid edits | Use same debounce pattern (500ms) as existing DrawingSerializer |
| Large number of canvas elements degrading scroll performance | RepaintBoundary per element; defer virtualization to future SPEC if needed |

---

## Out of Scope (Deferred)

| Item | Reason | Future SPEC |
|------|--------|-------------|
| Drag-to-reposition canvas elements | Gesture conflict complexity; get rendering right first | SPEC-SCRAPNOTE-003 |
| Fixed page mode (A4 pages) | Canvas mode switching + stroke relayout complexity | SPEC-SCRAPNOTE-003 |
| GMA-MD block elements on canvas | Markdown rendering decision needed | Future |
| LiveScrapsPanel canvas preview | Mini-canvas rendering performance TBD | Future |
| Inline color selector for highlights | Default color covers MVP; selector is polish | SPEC-SCRAPNOTE-003 |
| Element deletion from canvas | Requires gesture system not in this SPEC | SPEC-SCRAPNOTE-003 |
