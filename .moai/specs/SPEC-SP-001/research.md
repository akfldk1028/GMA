# SPEC-SP-001 Research: SecPlan Workspace Transformation

## Research Date: 2026-03-15
## Branch: secplan

---

## 1. Context: What SecPlan Changes

### Source Document
`docs/secplan/SPEC-SECPLAN.md` - Complete product specification with UI wireframes and 4 reference screenshots.

### Current GMA Architecture
- **Left panel**: Page thumbnails (180px) + Marker pills strip (72px) + PDF Viewer (flex)
- **Right panel**: Live Scraps Panel (280px) with element list
- **Modals**: Note editor, marker edit, file browser, element navigator
- **State**: WorkspaceProvider (602 lines, 25+ methods) orchestrates all features

### Target SecPlan Architecture
- **Header**: Back button, Title, Panel controls (Swap/Resize/Maximize), Note view icon, Kebab menu
- **Drawing Toolbar**: Shared across both panels (Pen, Highlighter, Eraser, Rectangle, Colors, Thickness, Undo/Redo, Capture, Highlight)
- **Tab Bar**: Multi-PDF tabs with close (X) and add (+) buttons
- **Left Sidebar**: Filter tabs (All/Capture/Highlight/Pen), item navigator (C-1, H-1, P-1)
- **Left Panel**: PDF Viewer with drawing overlay
- **Right Panel**: Scrapnote Canvas (pen-capable, cards for captures/highlights)

---

## 2. SPEC-SCRAPNOTE-001 Coverage Analysis

SPEC-SCRAPNOTE-001 (Status: Implemented) covers:
- R1: Scrapnote Canvas Core (pen drawing, strokes, undo/redo)
- R2: Canvas Mode (infinite scroll)
- R3: Capture insertion with confirm/reject popup
- R4: Highlight insertion with confirm/reject popup
- R5: Canvas element management (drag to reposition)
- R6: Pen writing around elements
- R7: Scrapnote lifecycle
- R8: Confirm/reject insertion UI
- R9: Drawing toolbar (reused from PDF)
- R10: LiveScrapsPanel integration
- R11: .gma storage format
- R12: Backward compatibility

### Remaining SecPlan Features NOT in SPEC-SCRAPNOTE-001

| Feature | SPEC-SECPLAN Ref | Priority | Description |
|---------|-----------------|----------|-------------|
| Multi-PDF Tab Bar | F-02 | P2 | Multiple PDF tabs with switch/close/add |
| Left Sidebar (Item Navigator) | F-07 | P2 | Filter tabs (All/Capture/Highlight/Pen) with item list |
| Panel Management | F-10 | P0 | Swap, Resize, Maximize dual panels |
| Header Bar Redesign | Section 3.1 | P0 | New header with panel controls and kebab menu |
| Kebab Menu | F-09 | P3 | Search, Cover, Template, Settings, Export, Info |
| Document File System | F-11 | P3 | Unified file system for PDF and Note files |
| Drawing Toolbar Unification | F-03 | P1 | Shared toolbar controlling active panel |
| Scrapnote as Right Panel | Section 3.5 | P0 | Replace LiveScrapsPanel with full canvas |

---

## 3. Codebase Analysis for Remaining Features

### 3.1 Workspace Screen (workspace_screen.dart)
- Desktop layout: 3 panels (PageThumbnails + MarkerPills + PdfViewer + LiveScraps)
- Mobile layout: Sheets replace sidebars
- Needs transformation to: Header + Toolbar + TabBar + Sidebar + LeftPanel + RightPanel
- Key widget tree at lines 333-599

### 3.2 WorkspaceProvider (workspace_provider.dart, 602 lines)
- Manages: PDF loading, note linking, marker creation, modal toggles
- Current panel toggles: `isPageNavOpen`, `isLiveScrapsOpen`, `isEditorModalOpen`
- Needs new state: `openPdfs` list, `activePdfIndex`, `panelRatio`, `isSwapped`, `sidebarFilter`
- High fan-in: `createMarker()` (called from PDF viewer, OCR, marker edit modal)

### 3.3 WorkspaceHeaderV3 (workspace_header_v3.dart)
- Current: Toggle buttons for thumbnails, editor, file browser, live scraps
- Needs redesign: Back button, Title, Panel controls, Note view, Kebab menu

### 3.4 Drawing Toolbar (drawing_toolbar.dart, 145 lines)
- Currently shows only when `isActive=true`
- Built from `drawingTools` registry dynamically
- Needs: Always visible, panel-aware (active panel receives tool input)
- Needs: Add Capture and Highlight buttons to toolbar

### 3.5 LiveScrapsPanel (live_scraps_panel.dart, 200+ lines)
- Currently: 280px sidebar showing ScrapElement list
- Needs replacement: Full Scrapnote Canvas as right panel (from SPEC-SCRAPNOTE-001)

### 3.6 Drawing System (drawing/)
- DrawingMode provider: Global tool state (keepAlive)
- DrawingStrokes provider: Per-note, per-page strokes
- Needs: Panel-aware context (which panel receives input)
- Needs: Shared tool state between PDF and Scrapnote panels

---

## 4. Data Flow Changes

### Current Flow
```
PDF Text Select → MarkerEditModal → WorkspaceProvider.createMarker() → NoteEditor.insertMarker()
                                                                     → ElementStore.add()
```

### Target Flow (with SPEC-SCRAPNOTE-001)
```
PDF Text Select → ConfirmScrapPopup → ScrapInsertionService → ScrapnoteCanvas.insertElement()
                                                             → ElementStore.add()
PDF Capture     → ConfirmScrapPopup → ScrapInsertionService → ScrapnoteCanvas.insertElement()
                                                             → ElementStore.add()
```

### Tab Bar Flow (new)
```
Tab Click → WorkspaceProvider.switchPdf(index) → pdfDocumentProvider.loadFromFile()
                                                → scrapnoteCanvasProvider.loadForPdf()
                                                → sidebarProvider.refreshItems()
Tab Close → WorkspaceProvider.closePdf(index) → cleanup resources
Tab Add   → FilePicker → WorkspaceProvider.openPdf(path) → add to tab list
```

---

## 5. Key Patterns to Preserve

- Riverpod `@riverpod` for all state management
- Freezed `@freezed` for immutable models
- Normalized (0-1) coordinates for PDF operations
- Plugin registry pattern (tools, OCR backends, blocks)
- GoRouter with ShellRoute for navigation
- shadcn_ui for consistent design system
- Hive for local persistence
- Debounced auto-save (500ms) pattern

---

## 6. Reference Screenshots Analysis

### Screenshot 1 (Main Layout)
- Full dual-panel layout with all components visible
- Tab bar showing 7+ NNN tabs with X and + buttons
- Left sidebar: 전체/캡처/펜 filter tabs, C-1..C-4, P-1..P-2 items
- Shared drawing toolbar at top
- PDF in left panel, Scrapnote canvas in right panel

### Screenshot 2 (Kebab Menu)
- Menu items: 검색, 표지 설정, 페이지 템플릿, 페이지 설정, 파일로 저장, 정보
- Bottom actions: Bookmark, Share, Export, Delete

### Screenshot 3 (Capture Flow)
- Dashed rectangle selection on PDF
- C-1 confirmation popup with text preview and 확인 button
- Scrapnote canvas shows existing content

### Screenshot 4 (Working State)
- Captures and highlights inserted in scrapnote
- Cyan highlight on PDF text
- Multiple cards with extracted text in right panel
- Sidebar shows C-1, P-1 items

---

## 7. Recommendations

### SPEC-SP-001 Scope
Focus on workspace-level UI transformation that wraps around SPEC-SCRAPNOTE-001:
1. **Panel Management** (P0): Dual-panel layout with swap/resize/maximize
2. **Header Redesign** (P0): New header with panel controls
3. **Multi-PDF Tab Bar** (P2): Tab management for multiple PDFs
4. **Left Sidebar** (P2): Item navigator with filters
5. **Toolbar Unification** (P1): Shared toolbar with panel awareness
6. **Kebab Menu** (P3): Document actions menu

### Excluded from SPEC-SP-001
- Scrapnote Canvas core (SPEC-SCRAPNOTE-001, already implemented)
- Document File System (separate SPEC recommended: SPEC-FS-001)
- Infinite/Fixed page mode switching (deferred per SPEC-SCRAPNOTE-001)
