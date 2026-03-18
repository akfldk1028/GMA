# GMA SecPlan Product Overview

## Project Identity

**Name**: GMA SecPlan (Secure Plan)
**Version**: 2.0.0-beta
**Type**: Cross-platform dual-panel document editor with PDF annotation and scrapnote integration
**Bundle ID**: com.clickaround.secplan
**Primary Platform**: Flutter for Android, iOS, Windows, macOS, Linux, and Web

## What is GMA SecPlan?

GMA SecPlan is a **dual-panel document editor** that unifies PDF annotation and pen-based note-taking in a single workspace. The core experience treats PDF and Note as equal-level documents, enabling seamless annotation of PDFs with synchronized note-taking, where PDF captures and text highlights automatically insert into linked scrapnotes.

### Core Concept

GMA SecPlan enables a unified annotation and note-taking workflow through:

- **Left panel**: PDF document viewer with page navigation, text extraction, and drawing overlay
- **Right panel**: Scrapnote canvas supporting A4 page mode (structured like Samsung Notes) or infinite vertical scroll (continuous notes)
- **Shared drawing toolbar**: Single pen, highlighter, and eraser toolbar controls whichever panel has active focus
- **Auto-insertion pipeline**: PDF capture regions and text highlights automatically insert as positioned cards into the linked scrapnote without manual steps
- **Panel management**: Swap positions, resize with draggable divider, maximize single panel to full width

When a user selects text in a PDF or captures a rectangular region, GMA SecPlan automatically creates a linked card in the associated scrapnote with the content preserved and positioned exactly where specified.

## Target Audience

- **Students**: Lecture annotation and textbook study with visual note-taking and manual markup
- **Professionals**: Document review and structured annotation with organized scrapnote collection
- **Researchers**: Paper analysis with highlighted passages and captured figures flowing into research notes
- **Visual learners**: Pen-capable drawing, region capture, and A4 page-based organization
- **Cross-platform users**: Desktop (Windows, macOS, Linux) and mobile (Android, iOS) with consistent experience

## Core Value Proposition

1. **Dual-Panel Document Editing**: PDF and Note are equal-level first-class documents, not viewer and editor
2. **Pen-Capable Canvas**: Scrapnote is a true drawing canvas supporting freehand strokes, not just a text editor
3. **Auto-Insertion Workflow**: PDF highlights and captures flow automatically into scrapnote without manual "Add" steps
4. **A4 Page Model**: Fixed A4 pages with optional infinite scroll, providing familiar structure without constraining visual thinking
5. **Shared Annotation Tools**: One toolbar with pen, highlighter, and eraser controls both panels based on active focus
6. **Local-First Privacy**: Zero cloud dependency, all data stored locally on device with no network transmission

## Core Features

### P0: PDF Viewer & Basic Rendering

**F-01: PDF Viewer**
- Open and render PDF documents with multi-page navigation
- Zoom and pan support with pinch gestures and scroll
- Text selection with extraction capability for highlighting
- Page metadata display (page numbers, document properties)
- Handles multiple simultaneous PDFs via tab-based switching

### P1: Drawing & Annotation Tools

**F-02: Shared Drawing Toolbar**
- Pen tool: Freehand drawing with configurable color and stroke thickness
- Highlighter tool: Semi-transparent wide strokes for text emphasis with opacity control
- Eraser tool: Remove individual strokes with precision
- Color selection: Red, Blue, Black, Yellow, Green, and custom colors
- Stroke thickness: At least 3 size options (thin, medium, thick)
- Undo/Redo support with full stroke history
- Active panel detection: Toolbar applies to whichever panel (PDF or Scrapnote) has focus

**F-03: PDF Region Capture**
- User draws rectangular selection on PDF page via mouse/touch drag
- Real-time preview of capture region with dashed border
- Confirmation popup with captured region thumbnail
- Auto-insert capture as image card into linked scrapnote with positioning preserved
- Add sidebar navigator entry (C-1, C-2, etc.) linked to capture source
- Show persistent capture marker on PDF (cyan dashed rectangle)
- User can delete or reposition capture card within scrapnote

**F-04: PDF Text Highlight**
- User selects text on PDF via long-press or drag gesture
- Auto-create colored highlight overlay on PDF text
- Auto-insert highlight card into scrapnote with selected text preserved
- Add sidebar navigator entry (H-1, H-2, etc.) linked to highlight source
- No manual confirmation required—automatic on selection completion
- Preserve color and text content in scrapnote card
- User can delete or reposition highlight card

### P2: Scrapnote Canvas & Auto-Insertion

**F-05: Scrapnote Canvas**
- Pen-capable note canvas supporting freehand drawing and text
- Multiple A4 pages by default (like Samsung Notes blank notebook)
- Optional infinite vertical scroll mode for continuous note-taking
- Support free pen drawing strokes with stroke persistence
- Receive and position capture cards from PDF (images with absolute pixel coordinates)
- Receive and position highlight cards from PDF (text with color and styling)
- Free text input areas for typed content
- Drag cards to reposition and reorganize layout
- Delete cards via swipe, long-press menu, or keyboard shortcut
- Linked to a specific PDF document with preserved reference

**F-06: Auto-Insertion Pipeline**
- Automatic card creation on PDF capture/highlight without user confirmation
- Card positioning based on user-specified location in scrapnote
- Metadata preservation: source page, source rectangle, highlight color
- Card type labeling (Capture vs Highlight) for visual distinction
- Integration with sidebar navigator for source tracking

### P3: Navigation & Document Management

**F-07: Left Sidebar Item Navigator**
- Filter tabs: All Items / Capture / Highlight / Pen
- Default view: Shows items from currently active PDF
- Item types: C-n (Capture with thumbnail), H-n (Highlight with text preview), P-n (Pen stroke groups)
- Click item to jump to source location in PDF
- Document info mode: Triggered from scrapnote, shows items linked to that note
- Visual indicators for item type (icons, colors)

**F-08: Capture Confirmation Popup**
- Show modal with preview of captured region thumbnail
- Confirmation button to accept and insert into scrapnote
- Cancel button or auto-timeout (30 seconds) to reject capture
- On confirm: Insert into scrapnote, add to sidebar, create persistent marker on PDF
- Optional: Prompt for card positioning or use default

**F-09: Panel Management**
- Swap: Switch left and right panel positions with one click
- Resize: Drag center divider to adjust panel width ratio dynamically
- Maximize: Expand one panel to full workspace width (hide other)
- Restore: Return to dual-panel view from maximized state
- Smooth animation on all transitions
- Remember last layout preference per document pair
- Keyboard shortcuts for panel operations

### Supporting Features (P4+)

**F-10: Kebab Menu (Document Actions)**
- Three-dot menu with options:
  - Search in PDF text
  - Document settings (cover, template, page layout)
  - Save as file (export: PDF, Image, JSON format)
  - Document info and metadata
- Bottom action bar: Bookmark, Share, Export, Delete

**F-11: Document File System**
- Unified file system treating PDF and Note as equal documents
- Note files: Custom JSON format with strokes, cards, positions, metadata
- File operations: Create, Open, Save, Delete, Rename
- Note file stores: Canvas strokes, inserted cards, card positions/layout, page mode, linked PDF path, timestamps
- PDF files: Read-only, stored as-is with path reference

## Data Model

### ScrapnoteFile Structure

ScrapnoteFile represents a complete note document with the following structure:

- **Core Metadata**:
  - id: Unique identifier (UUID)
  - title: Note display name
  - createdAt: Creation timestamp
  - modifiedAt: Last modification timestamp

- **Layout Configuration**:
  - pageMode: "a4" for fixed A4 pages or "infinite" for vertical scroll
  - canvasWidth: Page width in points (typically 595 for A4)
  - canvasHeight: Page height in points (null for infinite scroll)
  - linkedPdfPath: Path to associated PDF document

- **Content Structure**:
  - pages: Array of page objects, each containing:
    - pageNumber: Integer index
    - strokes: Array of pen drawing strokes with point data
    - cards: Array of capture and highlight cards with:
      - id: Unique card identifier
      - type: "capture" or "highlight"
      - x, y: Absolute pixel position on page
      - width, height: Card dimensions
      - imagePath: Path to captured image (for captures)
      - sourcePageNumber: PDF page number source
      - sourceRect: Original location on PDF
      - selectedText: Text content (for highlights)
      - colorValue: Color code (for highlights)
    - textBlocks: Array of text input areas

### Sidebar Item Reference

Sidebar items reference content for navigation:

- id: Unique identifier
- type: "capture", "highlight", or "pen"
- label: Display label (C-1, H-2, P-3)
- sourcePageNumber: PDF page number
- sourceRect: Location bounds on PDF
- linkedCardId: Reference to card in scrapnote

## Use Cases

### PDF Study Session
1. Open textbook PDF in left panel
2. Select text or capture diagram region → automatically creates card in scrapnote (right panel)
3. Draw annotations and notes on PDF with pen tool
4. Continue drawing in scrapnote canvas as captures accumulate
5. Switch between A4 pages as scrapnote fills with content
6. Use sidebar to navigate between captured items and review context

### Research Paper Annotation
1. Load academic paper PDF in left panel
2. Highlight key passages and equations → automatically insert as highlight cards in scrapnote
3. Capture important figures, tables, and diagrams → appear as image cards in scrapnote
4. Add handwritten annotations and comments in scrapnote using pen tool
5. Review all captured elements and highlights via sidebar navigator
6. Save scrapnote with linked PDF reference for future study sessions

### Visual Note-Taking Session
1. Enable pen tool for freehand drawing and sketching
2. Capture complex diagrams and charts from PDF
3. Use A4 page structure to organize notes with visual hierarchy
4. Switch to infinite scroll mode for continuous note-taking session
5. Reposition captured cards and resize text blocks as needed
6. Export completed scrapnote as image or PDF for sharing

## Design Principles

1. **Equal Documents**: PDF and Note are first-class documents with equivalent importance and features
2. **Pen-Capable**: Scrapnote is a true drawing canvas supporting freehand strokes, not a text editor
3. **Auto-Insertion**: User actions (highlight, capture) automatically flow to scrapnote without extra confirmation
4. **Familiar Structure**: A4 page model with optional infinite scroll provides Samsung Notes-like experience
5. **Unified Toolbar**: One drawing tool set applies to both panels based on active focus
6. **Local-First Privacy**: All data persists locally with zero cloud dependency or network transmission
7. **Seamless Workflow**: Annotation and note-taking happen in single unified workspace without switching apps

## Technical Foundation

### State Management Architecture
- Riverpod providers for declarative, composable state management
- Family modifiers for parameterized provider queries per document
- AsyncValue handling for asynchronous operations and loading states
- Immutable state models with freezed code generation

### Data Persistence Strategy
- Hive embedded database for settings, registries, and metadata (3 boxes)
- Local filesystem for note files (JSON), PDFs, and captured images
- JSON serialization for scrapnote custom format with JSON Serializable
- Platform-specific app directories for secure, sandboxed storage
- Auto-save with 500ms debounce on drawing strokes and canvas changes

### PDF Rendering & Coordinate System
- pdfrx library for PDF rendering, navigation, and text extraction
- Normalized 0-1 coordinate system for resolution-independent operations
- Drawing overlay on top of PDF pages with proper coordinate transformation
- Text extraction with character-level position mapping for highlight creation

### Scrapnote Canvas Implementation
- Custom canvas rendering for A4 page grid or infinite scroll mode
- Stroke serialization with complete drawing data preservation
- Card positioning and absolute pixel coordinate management
- Integration with drawing tool system for unified pen/highlighter/eraser
- Smooth scrolling and page navigation with viewport management

## Current Implementation Status

**Version**: 2.0.0-beta (Core architecture and P0-P2 features completed)

**Completed SPECs**:
- SPEC-SCRAPNOTE-001: Pen-Based Scrapnote Canvas (Implemented)
- SPEC-SP-001: SecPlan Workspace Transformation (Completed)
- SPEC-PDF-001: PDF Viewer and Drawing System (Completed)
- SPEC-SCRAPNOTE-002: Auto-Insertion Pipeline and Visual Highlight (Implemented)

**Architecture Implemented**:
- Dual-panel workspace with resizable divider
- PDF viewer with page navigation and text extraction
- Scrapnote canvas with A4 page and infinite scroll modes
- Drawing tools (pen, highlighter, eraser) with color and thickness options
- Auto-insertion pipeline for captures and highlights
- Sidebar item navigator with filtering
- Local persistence with Hive and JSON serialization

**In Progress**:
- P3 features (File system improvements, Panel maximize/swap animations)
- P4 features (Kebab menu, Document metadata, Search functionality)

**Planned for Future Releases**:
- Advanced panel management (docking, floating panels)
- Multi-document workspaces
- Collaboration features (requires rethinking local-first approach)
- Templates and page designs
- Advanced export formats (PDF with annotations, HTML)

## Out of Scope (v2.0)

- Cloud synchronization or backup
- Real-time collaborative editing
- OCR and automated text extraction
- Markdown rendering or LaTeX support
- Wiki-links or knowledge graph features
- Audio and video embedding
- Print functionality with CMYK support
- Database backend or server infrastructure

## Next Development Steps

1. Complete P3 features (file system, export, panel animations)
2. Polish animation and transition timing across all panels
3. Implement comprehensive test coverage for drawing and scrapnote systems
4. Add keyboard shortcuts for power user workflows
5. Optimize performance for large PDF files and dense scrapnotes
6. Implement search functionality across PDF text and scrapnote content
7. Add document tagging and filtering capabilities
8. Create settings panel for user preferences and defaults
