# SPEC-SP-001: SecPlan Workspace Transformation

## Metadata

| Field       | Value                                         |
|-------------|-----------------------------------------------|
| SPEC ID     | SPEC-SP-001                                   |
| Title       | SecPlan Workspace Transformation              |
| Created     | 2026-03-15                                    |
| Status      | Completed                                     |
| Priority    | High                                          |
| Lifecycle   | spec-anchored                                 |
| Depends On  | SPEC-SCRAPNOTE-001 (Implemented)              |

---

## Problem Statement

GMA's current workspace is a 3-panel layout (Page Thumbnails + Marker Pills + PDF Viewer + Live Scraps Panel) with modal-based note editing. The SecPlan vision transforms this into a dual-panel document editor where PDF and Scrapnote Canvas are equal-level panels with shared tooling, multi-PDF tab management, and flexible panel controls.

### Current State

| Component | Current | Target |
|-----------|---------|--------|
| Layout | 3-panel (thumbnails + markers + PDF + scraps sidebar) | Dual-panel (PDF + Scrapnote Canvas) |
| Header | Toggle buttons for panels, file browser, editor | Back, Title, Panel controls, Note view, Kebab menu |
| Right Panel | LiveScrapsPanel (280px element list) | Full Scrapnote Canvas (from SPEC-SCRAPNOTE-001) |
| Left Panel | PDF + Page Thumbnails + Marker Pills | PDF Viewer with drawing overlay |
| Navigation | Single PDF at a time | Multi-PDF Tab Bar |
| Item Browser | ElementNavigatorDrawer (modal drawer) | Left Sidebar with filter tabs |
| Toolbar | Drawing tools only, hidden when inactive | Shared toolbar with Capture/Highlight actions |
| Panel Control | Fixed layout | Swap, Resize, Maximize, Restore |

### Scope Boundary

**In Scope (SPEC-SP-001):**
- F-02: Multi-PDF Tab Bar
- F-07: Left Sidebar (Item Navigator)
- F-10: Panel Management (Swap, Resize, Maximize, Restore)
- Header Bar Redesign (Section 3.1)
- F-09: Kebab Menu
- Drawing Toolbar Unification (panel-aware shared toolbar)
- Right panel replacement (LiveScrapsPanel to ScrapnoteCanvas integration)

**Out of Scope:**
- Scrapnote Canvas core engine (SPEC-SCRAPNOTE-001, already implemented)
- Pen drawing, stroke management, undo/redo (SPEC-SCRAPNOTE-001)
- Capture/Highlight confirm/reject popup (SPEC-SCRAPNOTE-001)
- .gma file format and persistence (SPEC-SCRAPNOTE-001)
- Document File System (F-11, future SPEC-FS-001)
- Infinite/Fixed page mode switching (deferred)

---

## Environment

- Flutter 3.24+ / Dart 3.5+
- State management: flutter_riverpod + riverpod_generator
- Models: freezed + json_serializable
- UI framework: shadcn_ui
- PDF rendering: pdfrx
- Local storage: hive_flutter
- Routing: go_router
- Existing Scrapnote Canvas from SPEC-SCRAPNOTE-001

---

## Assumptions

- A-01: SPEC-SCRAPNOTE-001 is fully implemented and the Scrapnote Canvas widget is available for embedding as the right panel
- A-02: The existing DrawingMode provider (keepAlive) can serve as shared tool state for both panels
- A-03: pdfrx PdfViewerController supports multiple independent instances for tab switching
- A-04: shadcn_ui provides sufficient components for Tab Bar, Sidebar, and Kebab Menu UI
- A-05: Panel resize can be implemented with Flutter's native GestureDetector on a divider widget
- A-06: WorkspaceProvider (602 lines) will need significant restructuring but can be extended incrementally
- A-07: The Hive `workspace_settings` box can store per-document panel layout preferences

---

## Requirements

### R-01: Panel Management (Priority High)

**R-01.1 Dual Panel Layout (Ubiquitous)**
The workspace shall always render as a dual-panel layout with a left panel (default: PDF Viewer) and a right panel (default: Scrapnote Canvas) separated by a draggable divider.

**R-01.2 Panel Swap (Event-Driven)**
WHEN the user taps the Swap button, THEN the system shall switch the left and right panel positions with smooth animation (200ms duration).

**R-01.3 Panel Resize (Event-Driven)**
WHEN the user drags the panel divider, THEN the system shall adjust the width ratio between left and right panels, constrained to a minimum of 25% and maximum of 75% per panel.

**R-01.4 Panel Maximize (Event-Driven)**
WHEN the user taps the Maximize button for a panel, THEN the system shall expand that panel to full width, hiding the other panel with smooth animation (200ms duration).

**R-01.5 Panel Restore (Event-Driven)**
WHEN a panel is maximized AND the user taps the Restore button, THEN the system shall return to the dual-panel layout at the previous width ratio.

**R-01.6 Layout Persistence (Ubiquitous)**
The system shall always persist the last panel layout preference (ratio, swap state, maximize state) per document using Hive storage.

**R-01.7 Right Panel Integration (Ubiquitous)**
The right panel shall always render the Scrapnote Canvas widget (from SPEC-SCRAPNOTE-001), replacing the current LiveScrapsPanel.

### R-02: Header Bar Redesign (Priority High)

**R-02.1 Back Navigation (Event-Driven)**
WHEN the user taps the Back button, THEN the system shall navigate to the dashboard using GoRouter.

**R-02.2 Document Title (Event-Driven)**
WHEN the user taps the title text, THEN the system shall enable inline editing of the document title.

**R-02.3 Panel Controls Display (Ubiquitous)**
The header shall always display panel control buttons: Swap, Resize indicator, and Maximize/Restore toggle.

**R-02.4 Note View Toggle (Event-Driven)**
WHEN the user taps the Note View icon, THEN the system shall toggle the scrapnote view mode (showing/hiding the right panel).

**R-02.5 Kebab Menu Trigger (Event-Driven)**
WHEN the user taps the kebab (3-dot) icon, THEN the system shall open the document actions menu (R-05).

### R-03: Multi-PDF Tab Bar (Priority Medium)

**R-03.1 Tab Display (State-Driven)**
IF one or more PDFs are open, THEN the tab bar shall display a tab for each open PDF showing the filename, positioned below the header bar in the left panel area.

**R-03.2 Tab Switching (Event-Driven)**
WHEN the user taps a tab, THEN the system shall switch the PDF Viewer to display that PDF and load the associated scrapnote.

**R-03.3 Tab Close (Event-Driven)**
WHEN the user taps the close (X) button on a tab, THEN the system shall close that PDF, remove the tab, and switch to the nearest remaining tab.

**R-03.4 Tab Add (Event-Driven)**
WHEN the user taps the add (+) button, THEN the system shall open a file picker to select a new PDF file and add it as a new tab.

**R-03.5 Single Tab Behavior (Unwanted)**
The system shall not display the tab bar when only one PDF is open, to avoid unnecessary UI clutter.

### R-04: Left Sidebar - Item Navigator (Priority Medium)

**R-04.1 Filter Tabs (Ubiquitous)**
The sidebar shall always display filter tabs: All, Capture, Highlight, Pen.

**R-04.2 Item List (State-Driven)**
IF a PDF is loaded, THEN the sidebar shall display items extracted from the current PDF with labels (C-1, C-2 for captures; H-1, H-2 for highlights; P-1, P-2 for pen groups).

**R-04.3 Capture Thumbnails (State-Driven)**
IF the filter is All or Capture, THEN capture items shall display a thumbnail preview of the captured region.

**R-04.4 Highlight Snippets (State-Driven)**
IF the filter is All or Highlight, THEN highlight items shall display a text snippet of the highlighted content.

**R-04.5 Item Navigation (Event-Driven)**
WHEN the user taps a sidebar item, THEN the system shall navigate the PDF viewer to the source page and scroll to the source location.

**R-04.6 Sidebar Toggle (Event-Driven)**
WHEN the user taps the sidebar toggle, THEN the system shall show or hide the left sidebar with animation.

### R-05: Kebab Menu (Priority Low)

**R-05.1 Menu Display (Event-Driven)**
WHEN the kebab menu is triggered, THEN the system shall display a popup menu with items: Search, Cover Settings, Page Template, Page Settings, Save as File, Info.

**R-05.2 Bottom Action Bar (Event-Driven)**
WHEN the kebab menu is open, THEN the system shall display bottom action icons: Bookmark, Share, Export, Delete.

**R-05.3 Search Action (Event-Driven)**
WHEN the user selects Search, THEN the system shall activate PDF text search within the current document.

**R-05.4 Menu Item Stubs (Optional)**
Where possible, provide stub implementations for Cover Settings, Page Template, Page Settings, and Info for future development.

### R-06: Drawing Toolbar Unification (Priority Medium)

**R-06.1 Shared Toolbar (Ubiquitous)**
The drawing toolbar shall always be visible below the header bar, shared between both panels.

**R-06.2 Panel Awareness (State-Driven)**
IF the user focuses on the left panel, THEN the toolbar actions shall apply to the PDF Viewer. IF the user focuses on the right panel, THEN the toolbar actions shall apply to the Scrapnote Canvas.

**R-06.3 Capture Button (Event-Driven)**
WHEN the user taps the Capture button in the toolbar, THEN the system shall activate capture mode in the PDF Viewer (rectangle region selection).

**R-06.4 Highlight Button (Event-Driven)**
WHEN the user taps the Highlight button in the toolbar, THEN the system shall activate text highlight mode in the PDF Viewer.

**R-06.5 Active Panel Indicator (State-Driven)**
IF a panel is focused, THEN the toolbar shall visually indicate which panel is currently active.

---

## Specifications

### S-01: State Architecture

New state fields required in workspace state model:

```
SecPlanWorkspaceState:
  # Panel Management
  panelRatio: double (0.25-0.75, default 0.5)
  isSwapped: bool (default false)
  maximizedPanel: enum (none, left, right)

  # Multi-PDF Tabs
  openPdfs: List<OpenPdfTab> (path, title, scrollPosition)
  activePdfIndex: int

  # Sidebar
  sidebarFilter: enum (all, capture, highlight, pen)
  isSidebarOpen: bool (default true)

  # Panel Focus
  focusedPanel: enum (left, right)
```

### S-02: File Impact Analysis

**New Files (estimated 12-15):**
- `workspace/models/secplan_state.dart` - Extended workspace state with panel/tab/sidebar fields
- `workspace/pages/widgets/panel_manager.dart` - Dual panel layout with divider
- `workspace/pages/widgets/pdf_tab_bar.dart` - Multi-PDF tab bar widget
- `workspace/pages/widgets/item_sidebar.dart` - Left sidebar with filter tabs
- `workspace/pages/widgets/secplan_header.dart` - Redesigned header bar
- `workspace/pages/widgets/kebab_menu.dart` - Document actions popup menu
- `workspace/pages/widgets/panel_divider.dart` - Draggable divider widget
- `workspace/pages/providers/panel_provider.dart` - Panel management state
- `workspace/pages/providers/tab_provider.dart` - Multi-PDF tab state
- `workspace/pages/providers/sidebar_provider.dart` - Sidebar filter and items state
- `workspace/models/open_pdf_tab.dart` - Freezed model for open PDF tab

**Modified Files (estimated 8-10):**
- `workspace/pages/screens/workspace_screen.dart` - Major layout restructure
- `workspace/pages/providers/workspace_provider.dart` - Decompose and extend
- `workspace/models/workspace_state.dart` - Add new fields
- `pdf_viewer/drawing/pages/widgets/drawing_toolbar.dart` - Add Capture/Highlight buttons, panel awareness
- `pdf_viewer/pages/providers/drawing_provider.dart` - Panel-aware focus tracking
- `routing/app_router.dart` - Update workspace route params (if needed)
- `workspace/pages/widgets/workspace_header_v3.dart` - Replace with secplan_header
- `workspace/pages/widgets/live_scraps_panel.dart` - Deprecated, replaced by ScrapnoteCanvas

**Deprecated Files:**
- `workspace/pages/widgets/live_scraps_panel.dart` - Replaced by ScrapnoteCanvas in right panel
- `workspace/pages/widgets/page_thumbnails_panel.dart` - Replaced by left sidebar
- `workspace/pages/widgets/marker_pills_strip.dart` - Replaced by sidebar items

### S-03: Key Design Decisions

**D-01: Provider Decomposition**
The current WorkspaceProvider (602 lines) should be decomposed into focused providers:
- `panelProvider` - Panel ratio, swap, maximize state
- `tabProvider` - Open PDFs list, active index, tab operations
- `sidebarProvider` - Filter state, item list, navigation
- Keep `workspaceProvider` as orchestrator for cross-cutting concerns

**D-02: Panel Focus Tracking**
Use a `FocusNode` approach where each panel (PDF Viewer, Scrapnote Canvas) has a focus listener. The drawing toolbar reads `focusedPanel` state to route tool actions.

**D-03: Tab-PDF-Scrapnote Linking**
Each open PDF tab maps to a scrapnote via the existing PDF Registry (UUID mapping). Tab switching triggers both PDF reload and scrapnote reload.

**D-04: Layout Persistence Strategy**
Store panel layout (ratio, swap, maximize) per-document in Hive `workspace_settings` box, keyed by PDF path hash.

---

## Traceability

| Requirement | Source | Acceptance Criteria |
|-------------|--------|-------------------|
| R-01 | SPEC-SECPLAN F-10 | AC-01 through AC-07 |
| R-02 | SPEC-SECPLAN Section 3.1 | AC-08 through AC-12 |
| R-03 | SPEC-SECPLAN F-02 | AC-13 through AC-17 |
| R-04 | SPEC-SECPLAN F-07 | AC-18 through AC-23 |
| R-05 | SPEC-SECPLAN F-09 | AC-24 through AC-27 |
| R-06 | SPEC-SECPLAN F-03 (partial) | AC-28 through AC-32 |
