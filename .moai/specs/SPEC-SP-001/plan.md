# SPEC-SP-001: Implementation Plan

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-SP-001                                   |
| Title       | SecPlan Workspace Transformation              |
| Created     | 2026-03-15                                    |
| Status      | Approved                                      |
| Depends On  | SPEC-SCRAPNOTE-001 (Implemented)              |

---

## Implementation Strategy

### Approach: Incremental Transformation

The workspace transformation will follow an incremental strategy rather than a Big Bang rewrite. Each milestone builds on the previous, keeping the app functional at every stage. The current 3-panel layout will be progressively replaced.

### Development Methodology

Per `quality.yaml`, development mode is **hybrid** (TDD for new code, DDD for legacy modifications):
- New widgets (tab bar, sidebar, panel manager): TDD (RED-GREEN-REFACTOR)
- Modified files (workspace_screen, workspace_provider): DDD (ANALYZE-PRESERVE-IMPROVE)

---

## Milestone 1: Panel Management Foundation (Priority High)

**Goal:** Replace the current fixed 3-panel layout with a dual-panel layout supporting resize, swap, maximize, and restore.

### Tasks

**M1-T1: State Model Extension**
- Create `secplan_state.dart` with new Freezed fields: `panelRatio`, `isSwapped`, `maximizedPanel`, `focusedPanel`
- Add `OpenPdfTab` model with path, title, scrollPosition fields
- Run `build_runner` for code generation

**M1-T2: Panel Provider**
- Create `panel_provider.dart` with Riverpod notifier
- Methods: `setRatio()`, `swap()`, `maximize(panel)`, `restore()`
- Persist layout per-document to Hive `workspace_settings`

**M1-T3: Panel Divider Widget**
- Create `panel_divider.dart` with `GestureDetector` for horizontal drag
- Visual feedback: 4px divider line, cursor change on hover
- Constraint enforcement: min 25%, max 75% per panel

**M1-T4: Panel Manager Widget**
- Create `panel_manager.dart` composing left panel, divider, right panel
- Support swap state (reverse children order)
- Support maximize state (show only one panel at full width)
- Smooth 200ms animation on transitions

**M1-T5: Scrapnote Canvas Integration**
- Replace `LiveScrapsPanel` in workspace_screen with Scrapnote Canvas widget
- Wire `focusedPanel` state to both panels
- Verify drawing tool input routing based on focused panel

**M1-T6: Workspace Screen Restructure**
- Modify `workspace_screen.dart` to use `PanelManager` instead of fixed Row layout
- Remove `PageThumbnailsPanel` and `MarkerPillsStrip` from main layout
- Preserve mobile layout with bottom sheet fallbacks

### Technical Constraints
- Maintain backward compatibility with existing workspace state
- Keep `WorkspaceProvider` functional during transition
- Ensure `PdfViewerController` works in the new panel structure

### Risks
- **Risk:** Panel resize performance with heavy PDF rendering
  - Mitigation: Use `RepaintBoundary` around each panel, debounce resize updates
- **Risk:** Focus tracking conflicts between panels
  - Mitigation: Use `FocusScope` with explicit focus management

---

## Milestone 2: Header Bar Redesign (Priority High)

**Goal:** Replace the current toggle-based header with the SecPlan header design.

### Tasks

**M2-T1: SecPlan Header Widget**
- Create `secplan_header.dart` with: Back button, editable Title, Panel controls, Note View toggle, Kebab trigger
- Use shadcn_ui components: `ShadButton`, `ShadInput` (for title editing)
- 48px fixed height

**M2-T2: Panel Control Buttons**
- Swap button: triggers `panelProvider.swap()`
- Resize indicator: shows current ratio (e.g., "50:50")
- Maximize/Restore toggle: context-aware icon

**M2-T3: Title Editing**
- Inline edit: tap to enter edit mode, Enter/blur to save
- Update document title in workspace state and persist

**M2-T4: Replace Header in Workspace Screen**
- Swap `WorkspaceHeaderV3` with `SecPlanHeader` in workspace_screen.dart
- Preserve essential functionality (PDF open, navigation)

### Risks
- **Risk:** Header height change affects layout calculations
  - Mitigation: Use fixed 48px with no overflow assumptions

---

## Milestone 3: Drawing Toolbar Unification (Priority Medium)

**Goal:** Make the drawing toolbar always visible, shared between panels, with Capture and Highlight buttons.

### Tasks

**M3-T1: Toolbar Always Visible**
- Remove conditional visibility (currently hidden when `isActive=false`)
- Show toolbar below header bar at all times
- Expand/collapse secondary options (colors, thickness) on tool activation

**M3-T2: Panel Awareness**
- Read `focusedPanel` from panel provider
- Route tool input to the correct panel
- Show visual indicator of active panel in toolbar

**M3-T3: Capture Button**
- Add Capture action button to toolbar
- On tap: activate rectangle selection mode in PDF Viewer
- Integrate with SPEC-SCRAPNOTE-001 capture flow

**M3-T4: Highlight Button**
- Add Highlight action button to toolbar
- On tap: activate text highlight mode in PDF Viewer
- Integrate with SPEC-SCRAPNOTE-001 highlight flow

### Technical Constraints
- Drawing tools must work on both PDF (normalized 0-1 per page) and Scrapnote Canvas (canvas-relative)
- Tool registry must remain intact (plugin pattern)

### Risks
- **Risk:** Coordinate system mismatch between panels
  - Mitigation: Each panel transforms toolbar tool state to its own coordinate system internally

---

## Milestone 4: Multi-PDF Tab Bar (Priority Medium)

**Goal:** Support multiple open PDFs with tab switching, close, and add functionality.

### Tasks

**M4-T1: Tab Provider**
- Create `tab_provider.dart` with Riverpod notifier
- State: `List<OpenPdfTab>`, `activePdfIndex`
- Methods: `addTab(path)`, `switchTab(index)`, `closeTab(index)`, `reorderTabs()`

**M4-T2: Tab Bar Widget**
- Create `pdf_tab_bar.dart` showing tabs for all open PDFs
- Each tab: filename text + close (X) button
- Add (+) button at end opening file picker
- Scrollable horizontally when many tabs

**M4-T3: Tab-PDF-Scrapnote Synchronization**
- Tab switch triggers `pdfDocumentProvider.loadFromFile()`
- Tab switch triggers scrapnote reload via PDF Registry UUID mapping
- Tab switch triggers sidebar item refresh

**M4-T4: Tab Close Cleanup**
- Close tab removes PDF from list
- Switch to adjacent tab or show empty state
- Clean up associated provider state

**M4-T5: Single Tab Suppression**
- Hide tab bar when only 1 PDF is open
- Show tab bar automatically when 2+ PDFs are open

### Risks
- **Risk:** Memory pressure with multiple large PDFs loaded
  - Mitigation: Only keep active PDF fully loaded; cache page thumbnails for inactive tabs
- **Risk:** PdfViewerController state leak on tab switch
  - Mitigation: Dispose controller on tab close, create new on tab open

---

## Milestone 5: Left Sidebar (Priority Medium)

**Goal:** Implement the Item Navigator sidebar with filter tabs and item list.

### Tasks

**M5-T1: Sidebar Provider**
- Create `sidebar_provider.dart` with Riverpod notifier
- State: `sidebarFilter` (all/capture/highlight/pen), `isSidebarOpen`, computed item list
- Methods: `setFilter()`, `toggleSidebar()`
- Derived from element store and current PDF

**M5-T2: Sidebar Widget**
- Create `item_sidebar.dart` with filter tabs at top
- Item list below with type-specific rendering:
  - Captures: thumbnail + "C-n" label
  - Highlights: text snippet + "H-n" label
  - Pen groups: stroke preview + "P-n" label
- Scrollable item list

**M5-T3: Item Navigation**
- Tap item: navigate PDF viewer to source page
- Scroll PDF to source rect location
- Highlight source region briefly (flash animation)

**M5-T4: Sidebar Layout Integration**
- Position sidebar to the left of the left panel
- Collapsible width (200px expanded, 0px collapsed)
- Smooth slide animation on toggle

### Risks
- **Risk:** Pen stroke grouping logic complexity
  - Mitigation: Group strokes by page number initially; defer advanced grouping

---

## Milestone 6: Kebab Menu (Priority Low)

**Goal:** Implement the 3-dot document actions menu.

### Tasks

**M6-T1: Kebab Menu Widget**
- Create `kebab_menu.dart` using shadcn_ui `ShadPopover` or `ShadSheet`
- Menu items: Search, Cover Settings, Page Template, Page Settings, Save as File, Info
- Bottom action bar: Bookmark, Share, Export, Delete icons

**M6-T2: Search Integration**
- Search action opens a search bar overlay on the PDF viewer
- Use pdfrx text search capabilities

**M6-T3: Stub Implementations**
- Cover Settings, Page Template, Page Settings, Info: show "Coming Soon" toast
- Save as File: implement basic PDF export
- Bookmark, Share, Delete: implement basic functionality

### Risks
- **Risk:** Feature scope creep from menu items
  - Mitigation: Strict stub-only for non-essential items in this SPEC

---

## Architecture Design

### Provider Dependency Graph (Target)

```
workspaceProvider (orchestrator, reduced scope)
  +-- panelProvider (ratio, swap, maximize, focus)
  +-- tabProvider (open PDFs, active index)
  +-- sidebarProvider (filter, items, navigation)
  +-- pdfDocumentProvider (existing, pdfrx)
  +-- drawingModeProvider (existing, shared tool state)
  +-- elementStoreProvider (existing, scrap elements)
  +-- scrapnoteProvider (existing, from SPEC-SCRAPNOTE-001)
  +-- pdfRegistryProvider (existing, UUID mapping)
```

### Widget Tree (Target)

```
WorkspaceScreen
  +-- SecPlanHeader (48px)
  +-- DrawingToolbar (always visible)
  +-- Row
  |   +-- ItemSidebar (200px, collapsible)
  |   +-- Expanded
  |       +-- Column
  |           +-- PdfTabBar (conditional, when 2+ tabs)
  |           +-- Expanded
  |               +-- PanelManager
  |                   +-- LeftPanel (PDF Viewer)
  |                   +-- PanelDivider
  |                   +-- RightPanel (Scrapnote Canvas)
```

### Data Flow: Tab Switch

```
User taps tab
  -> tabProvider.switchTab(index)
  -> pdfDocumentProvider.loadFromFile(tab.path)
  -> pdfRegistryProvider.getIdByPath(tab.path)
  -> scrapnoteProvider.loadForPdf(pdfId)
  -> sidebarProvider.refreshItems(pdfId)
  -> panelProvider.restoreLayout(tab.path)
```

### Data Flow: Capture Insertion

```
User taps Capture in toolbar
  -> drawingModeProvider.activateCaptureMode()
  -> PDF Viewer enters rectangle selection
  -> User drags rectangle
  -> ConfirmScrapPopup (SPEC-SCRAPNOTE-001)
  -> On confirm: elementStoreProvider.add(capture)
  -> scrapnoteProvider.insertElement(capture)
  -> sidebarProvider.addItem(C-n)
```

---

## Dependencies

| Dependency | Type | Status | Risk |
|------------|------|--------|------|
| SPEC-SCRAPNOTE-001 | Implementation | Implemented | Low - already available |
| pdfrx PdfViewerController | Library | v2.2.0+ | Low - well-tested |
| shadcn_ui popover/sheet | Library | v0.45.1+ | Low - available components |
| Hive workspace_settings | Storage | Existing box | Low - established pattern |
| DrawingMode provider | Existing code | Active | Medium - needs panel awareness |
| ElementStore provider | Existing code | Active | Low - stable interface |

---

## Risk Assessment

| Risk | Severity | Probability | Mitigation |
|------|----------|-------------|------------|
| WorkspaceProvider decomposition breaks existing flows | High | Medium | Incremental extraction with characterization tests |
| Panel resize janky with PDF rendering | Medium | Medium | RepaintBoundary, debounced updates |
| Multiple PDF memory pressure | Medium | Low | Lazy load inactive tabs, dispose controllers |
| Focus tracking between panels | Medium | Medium | FocusScope with explicit management |
| Drawing coordinate mismatch | Low | Low | Each panel handles its own coordinate transform |
| Tab switch latency with large PDFs | Medium | Medium | Show loading indicator, cache page thumbnails |

---

## Milestone Priority Summary

| Milestone | Priority | Dependencies | Scope |
|-----------|----------|-------------|-------|
| M1: Panel Management | Primary Goal | None | R-01 |
| M2: Header Redesign | Primary Goal | M1 | R-02 |
| M3: Toolbar Unification | Secondary Goal | M1 | R-06 |
| M4: Multi-PDF Tab Bar | Secondary Goal | M1 | R-03 |
| M5: Left Sidebar | Secondary Goal | M4 | R-04 |
| M6: Kebab Menu | Optional Goal | M2 | R-05 |

---

## Traceability

| Tag | Requirement | Milestone | Files |
|-----|------------|-----------|-------|
| SPEC-SP-001-R01 | Panel Management | M1 | panel_provider, panel_manager, panel_divider, workspace_screen |
| SPEC-SP-001-R02 | Header Redesign | M2 | secplan_header, workspace_screen |
| SPEC-SP-001-R03 | Multi-PDF Tab Bar | M4 | tab_provider, pdf_tab_bar |
| SPEC-SP-001-R04 | Left Sidebar | M5 | sidebar_provider, item_sidebar |
| SPEC-SP-001-R05 | Kebab Menu | M6 | kebab_menu |
| SPEC-SP-001-R06 | Toolbar Unification | M3 | drawing_toolbar, drawing_provider |
