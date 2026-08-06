# SPEC-SCRAPNOTE-002: Acceptance Criteria

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-SCRAPNOTE-002                            |
| Title       | Auto-Insertion Pipeline and Visual Highlight   |
| Status      | Planned                                       |

---

## Phase 1: Text Highlight Auto-Insertion

### AC-1.1: Auto-highlight on text selection

**Given** the user has a PDF open in the left panel
**When** the user selects text on a PDF page via long-press/drag gesture and confirms the selection
**Then** a highlight marker is created immediately with the default yellow color
**And** a ScrapElement of type "highlight" is created in ElementStore
**And** a highlight card appears in the LiveScrapsPanel
**And** no modal dialog (MarkerEditModal) is displayed at any point

### AC-1.2: Selected text preserved in marker

**Given** the user selects the text "Important finding about neural networks" on PDF page 3
**When** the highlight marker is auto-created
**Then** the ScrapElement contains selectedText = "Important finding about neural networks"
**And** the ScrapElement contains sourcePageNumber = 3
**And** the ScrapElement contains sourceRect matching the selection bounding box
**And** the ScrapElement contains colorValue matching the default yellow

### AC-1.3: Default color applied

**Given** the user has not changed the highlight color in this session
**When** a text highlight is auto-created
**Then** the highlight uses yellow color (0xFFFFEB3B at 40% opacity)

### AC-1.4: Existing capture flow unbroken

**Given** the user uses the capture region tool on a PDF
**When** the user drags to select a rectangular region
**Then** the existing capture flow continues to work (region selection, PNG rendering, element creation)
**And** no regression in capture behavior

---

## Phase 2: Visual Highlight on PDF

### AC-2.1: Highlight overlay appears on PDF

**Given** a text highlight marker exists for PDF page 5 at a specific text location
**When** the user navigates to page 5
**Then** a semi-transparent colored rectangle is visible at the highlighted text location
**And** the rectangle color matches the marker's highlight color at 30-40% opacity

### AC-2.2: Overlay persists across navigation

**Given** a highlight overlay is visible on page 5
**When** the user scrolls to page 10 and then scrolls back to page 5
**Then** the highlight overlay is still visible at the same location

### AC-2.3: Multiple highlights on same page

**Given** the user creates 3 text highlights on the same PDF page
**When** the page is displayed
**Then** all 3 highlight overlays are visible simultaneously
**And** each uses its respective color

### AC-2.4: Highlight deletion removes overlay

**Given** a highlight overlay is visible on a PDF page
**When** the user deletes the corresponding highlight marker (via LiveScrapsPanel or other mechanism)
**Then** the overlay disappears from the PDF page immediately

### AC-2.5: Drawing tools work over highlights

**Given** highlight overlays are displayed on a PDF page
**When** the user activates the pen tool and draws over the highlighted area
**Then** the pen stroke renders normally above the highlight overlay
**And** the highlight overlay is not affected

### AC-2.6: Text selection works over highlights

**Given** highlight overlays are displayed on a PDF page
**When** the user long-presses on text within a highlighted area
**Then** text selection activates normally
**And** the user can create a new highlight on different text in the same area

---

## Phase 3: Capture Confirmation Popup

### AC-3.1: Floating popup appears after capture

**Given** the user has the capture tool active
**When** the user drags to select a region on the PDF and releases
**Then** a floating popup appears showing a preview of the captured image
**And** the popup has an accept (check) button and a reject (x) button
**And** the popup is positioned at the bottom-right area of the workspace

### AC-3.2: Accept creates element

**Given** the capture confirmation popup is displayed with a preview
**When** the user taps the accept (check) button
**Then** the captured image is saved as a PNG
**And** a ScrapElement of type "capture" is created in ElementStore
**And** the popup dismisses
**And** the capture card appears in LiveScrapsPanel

### AC-3.3: Reject discards capture

**Given** the capture confirmation popup is displayed
**When** the user taps the reject (x) button
**Then** the temporary capture PNG is discarded
**And** no ScrapElement is created
**And** the popup dismisses

### AC-3.4: Auto-dismiss on timeout

**Given** the capture confirmation popup is displayed
**When** 30 seconds pass without user interaction
**Then** the popup auto-dismisses
**And** the capture is NOT inserted (same as reject)

### AC-3.5: PDF interaction not blocked

**Given** the capture confirmation popup is displayed
**When** the user scrolls the PDF or selects text
**Then** the PDF interaction works normally
**And** the popup remains visible (non-modal)

### AC-3.6: No inline buttons in capture overlay

**Given** the user drags to select a capture region
**When** the region selection is active
**Then** the CaptureOverlay shows the selection rectangle with visual feedback
**And** no inline confirm/cancel buttons appear within the overlay itself

---

## Phase 4: Scrapnote Canvas Basics

### AC-4.1: ScrapnoteCanvasData model

**Given** a ScrapnoteCanvasData instance is created
**When** it is serialized to JSON and deserialized back
**Then** all fields are preserved: id, linkedPdfPath, canvasMode, strokes, elements, layerOrder
**And** the JSON format matches SPEC-SCRAPNOTE-001 S1 `.gma` schema

### AC-4.2: `.gma` file creation

**Given** a PDF is open and no scrapnote exists for it
**When** the first capture or highlight is confirmed for that PDF
**Then** a `.gma` file is created in the scrapnotes directory
**And** the file contains valid JSON matching the ScrapnoteCanvasData schema
**And** the linkedPdfPath field references the source PDF

### AC-4.3: Canvas renders elements

**Given** a scrapnote has 2 capture elements and 1 highlight element
**When** the user opens the ScrapnoteScreen for that scrapnote
**Then** the canvas displays 2 image widgets (capture thumbnails) at their stored positions
**And** the canvas displays 1 text card widget (highlight text) at its stored position

### AC-4.4: Pen drawing on canvas

**Given** the ScrapnoteCanvas is displayed
**When** the user selects the pen tool and draws a stroke on the canvas
**Then** the stroke renders using StrokePainter with perfect_freehand
**And** the stroke is added to the ScrapnoteCanvasData strokes list

### AC-4.5: Undo/redo on canvas

**Given** the user has drawn 3 strokes on the scrapnote canvas
**When** the user triggers undo
**Then** the last stroke is removed from the canvas
**When** the user triggers redo
**Then** the removed stroke reappears

### AC-4.6: Auto-save on canvas

**Given** the user draws a stroke on the scrapnote canvas
**When** 500ms pass after the last modification
**Then** the `.gma` file is updated with the new stroke data

### AC-4.7: Element auto-positioning

**Given** a scrapnote canvas has elements at y-positions 0, 300, and 600
**When** a new capture or highlight is inserted
**Then** the new element is placed below the last element (approximately y=900 with padding)

### AC-4.8: LiveScrapsPanel opens canvas

**Given** elements exist in the LiveScrapsPanel for the current PDF
**When** the user taps an element in the LiveScrapsPanel
**Then** the ScrapnoteScreen opens showing the scrapnote canvas for that PDF

### AC-4.9: Infinite scroll

**Given** the scrapnote canvas has elements extending beyond the viewport height
**When** the user scrolls vertically on the canvas
**Then** the canvas scrolls smoothly to reveal additional content
**And** no page boundary is visible (infinite scroll mode)

---

## Cross-Cutting Acceptance Criteria

### AC-BC-1: PDF drawing backward compatibility

**Given** the user opens a PDF with existing drawing strokes
**When** the user views and edits those strokes
**Then** all existing strokes render correctly
**And** the DrawingOverlay and per-page stroke system work unchanged

### AC-BC-2: ElementStore data backward compatibility

**Given** the ElementStore contains legacy ScrapElement entries (without canvas position data)
**When** the ScrapsLibrary or LiveScrapsPanel loads elements
**Then** legacy elements display correctly
**And** no data corruption occurs

### AC-BC-3: Capture region selection backward compatibility

**Given** the capture tool is active
**When** the user drags to select a region on the PDF
**Then** the capture service renders a PNG at 2x resolution (existing behavior)
**And** the PNG quality and accuracy are unchanged

---

## Definition of Done

- [ ] All acceptance criteria pass manual testing
- [ ] Unit tests cover new models, serializers, and services (85%+ coverage)
- [ ] Widget tests cover new widgets (ConfirmScrapPopup, HighlightOverlay, ScrapnoteCanvas)
- [ ] Characterization tests for modified files (pdf_viewer_screen.dart, workspace_provider.dart, capture_overlay.dart)
- [ ] No dart analyze errors or warnings
- [ ] No regression in existing capture, drawing, or element store functionality
- [ ] `.gma` file format matches SPEC-SCRAPNOTE-001 S1 schema
- [ ] Auto-save debounce working correctly (no excessive writes)
