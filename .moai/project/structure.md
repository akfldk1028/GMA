# GMA Project Structure

## Directory Hierarchy

```
GMA/
├── .moai/                               # MoAI configuration and project metadata
│   ├── config/
│   │   ├── sections/
│   │   │   ├── workflow.yaml           # Workflow configuration
│   │   │   ├── quality.yaml            # Development mode (TDD) and quality gates
│   │   │   ├── user.yaml               # User preferences
│   │   │   └── language.yaml           # Language settings (English)
│   │   └── project.json                # Project metadata
│   ├── project/                        # Generated documentation
│   │   ├── product.md                  # Product overview
│   │   ├── structure.md                # This file
│   │   ├── tech.md                     # Technology stack
│   │   └── codemaps/
│   │       ├── overview.md             # Architecture overview
│   │       ├── modules.md              # Feature module descriptions
│   │       ├── dependencies.md         # Dependency graph
│   │       ├── entry-points.md         # Application entry points
│   │       └── data-flow.md            # Data flow diagrams
│   └── specs/                          # SPEC documents from /moai plan
│
├── frontend_v2/                        # Flutter application (GMA SecPlan v2)
│   ├── lib/
│   │   ├── main.dart                   # Entry point (Hive init, ProviderScope)
│   │   ├── app.dart                    # ShadApp router + theme configuration
│   │   ├── common_widgets/             # Shared widgets across features
│   │   │   ├── dual_panel_layout.dart  # Left/right panel container with divider
│   │   │   ├── header_bar.dart         # Top header with title and controls
│   │   │   ├── drawing_toolbar.dart    # Shared drawing tools (pen, highlighter, eraser)
│   │   │   └── responsive.dart         # Responsive layout utilities
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # ShadCN color palette
│   │   │   ├── app_theme.dart          # Light/dark theme definitions
│   │   │   └── ui_constants.dart       # Layout, spacing, sizing
│   │   ├── routing/
│   │   │   └── app_router.dart         # GoRouter with routes for workspace, note, etc.
│   │   ├── utils/
│   │   │   ├── file_system_provider.dart # Local file system access
│   │   │   ├── document_storage_service.dart # PDF and Note CRUD
│   │   │   └── coordinate_converter.dart   # Normalized 0-1 coordinate transforms
│   │   │
│   │   └── features/                   # Feature-first modules (11 features, ~120 files)
│   │       │
│   │       ├── workspace/              # ⭐ Main dual-panel editor (25 files)
│   │       │   ├── models/
│   │       │   │   ├── workspace_state.dart      # Dual-panel state
│   │       │   │   └── panel_layout_model.dart   # Panel config (swap, resize, maximize)
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── workspace_provider.dart   # Main orchestrator
│   │       │   │   │   ├── panel_layout_provider.dart # Panel state
│   │       │   │   │   └── workspace_provider.g.dart # Generated
│   │       │   │   ├── screens/
│   │       │   │   │   └── workspace_screen.dart     # Dual-panel layout
│   │       │   │   └── widgets/
│   │       │   │       ├── workspace_header.dart     # Title, controls, menu
│   │       │   │       ├── panel_divider.dart        # Resize divider
│   │       │   │       ├── left_panel_container.dart # PDF viewer wrapper
│   │       │   │       ├── right_panel_container.dart # Scrapnote wrapper
│   │       │   │       └── panel_control_bar.dart    # Swap, maximize buttons
│   │       │   └── models/
│   │       │
│   │       ├── pdf_viewer/             # PDF rendering with highlight and capture (NEW - SPEC-PDF-001, 22 files)
│   │       │   ├── models/
│   │       │   │   └── pdf_document_state.dart          # PdfDocumentState (freezed)
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── pdf_document_provider.dart   # Load/navigate/clear PDF
│   │       │   │   │   ├── capture_provider.dart        # Capture mode state (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   │   ├── capture_provider.freezed.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   │   └── capture_provider.g.dart      # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── screens/
│   │       │   │   │   └── pdf_viewer_screen.dart       # PdfViewer composition
│   │       │   │   └── widgets/
│   │       │   │       ├── pdf_page_overlay.dart        # Drawing + text layers
│   │       │   │       ├── capture_overlay.dart         # Drag-to-select region overlay (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │       └── capture_page_overlay.dart    # pdfrx overlay builder (NEW - SPEC-SCRAPNOTE-002)
│   │       │   ├── utils/
│   │       │   │   ├── pdf_text_extractor.dart          # Normalized coordinate conversion
│   │       │   │   └── capture_service.dart             # PDF region to PNG rendering (NEW - SPEC-SCRAPNOTE-002)
│   │       │   ├── highlight/
│   │       │   │   ├── models/
│   │       │   │   │   ├── highlight_marker_data.dart   # Highlight rendering data (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   │   ├── highlight_marker_data.freezed.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   │   └── highlight_marker_data.g.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── providers/
│   │       │   │   │   ├── highlight_provider.dart      # Per-document highlight data (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   │   └── highlight_provider.g.dart    # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   └── widgets/
│   │       │   │       └── highlight_overlay.dart       # PDF page highlight overlay (NEW - SPEC-SCRAPNOTE-002)
│   │       │   └── capture/
│   │       │       ├── pages/
│   │       │       │   ├── providers/
│   │       │       │   │   ├── capture_provider.dart    # Capture mode state (NEW - SPEC-SCRAPNOTE-002)
│   │       │       │   │   ├── capture_provider.freezed.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │       │   │   └── capture_provider.g.dart  # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │       ├── widgets/
│   │       │       │   ├── capture_overlay.dart         # Drag-to-select region overlay (NEW - SPEC-SCRAPNOTE-002)
│   │       │       │   └── capture_page_overlay.dart    # pdfrx overlay builder (NEW - SPEC-SCRAPNOTE-002)
│   │       │       └── utils/
│   │       │           └── capture_service.dart         # PDF region to PNG rendering (NEW - SPEC-SCRAPNOTE-002)
│   │       │
│   │       ├── drawing/                 # Drawing tools and overlay (NEW - SPEC-PDF-001, 10 files)
│   │       │   ├── models/
│   │       │   │   └── drawing_model.dart               # DrawingStroke, StrokePoint, DrawingData
│   │       │   ├── tools/
│   │       │   │   ├── drawing_tool_handler.dart        # Abstract tool plugin interface
│   │       │   │   ├── pen_tool.dart                    # Opaque pressure-sensitive strokes
│   │       │   │   ├── highlighter_tool.dart            # Semi-transparent wide strokes
│   │       │   │   ├── eraser_tool.dart                 # Hit-test stroke removal
│   │       │   │   └── tool_registry.dart               # Dynamic tool registration
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   └── drawing_provider.dart        # Drawing mode + strokes + undo/redo
│   │       │   │   └── widgets/
│   │       │   │       ├── drawing_canvas.dart          # Pointer input capture
│   │       │   │       ├── drawing_overlay.dart         # Per-page overlay builder
│   │       │   │       ├── drawing_toolbar.dart         # Panel-aware toolbar
│   │       │   │       └── stroke_painter.dart          # CustomPainter rendering
│   │       │   └── utils/
│   │       │       └── drawing_serializer.dart          # JSON persistence
│   │       │
│   │       ├── scrapnote/              # Pen-capable note canvas (47 files)
│   │       │   ├── models/
│   │       │   │   ├── scrapnote_model.dart        # @freezed Scrapnote document
│   │       │   │   ├── card_model.dart             # Capture/Highlight card model
│   │       │   │   ├── stroke_model.dart           # Drawing stroke data
│   │       │   │   ├── page_model.dart             # A4/infinite page definition
│   │       │   │   ├── element_model.dart          # ScrapElement, ElementRect (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── element_model.freezed.dart  # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── element_model.g.dart        # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── highlight_color.dart        # HighlightColors, LastUsedHighlightColor provider (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── highlight_color.g.dart      # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── scrapnote_canvas_model.dart # ScrapnoteCanvasData, CanvasElement (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── scrapnote_canvas_model.freezed.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   └── scrapnote_canvas_model.g.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── scrapnote_provider.dart      # Scrapnote state
│   │       │   │   │   ├── scrapnote_canvas_provider.dart # Canvas rendering
│   │       │   │   │   ├── scrapnote_provider.g.dart    # Generated
│   │       │   │   │   ├── scrapnote_canvas_provider.g.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── screens/
│   │       │   │   │   ├── scrapnote_panel.dart         # Embedded in workspace
│   │       │   │   │   └── scrapnote_screen.dart        # Full-screen canvas view (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   └── widgets/
│   │       │   │       ├── canvas_renderer.dart         # Render pages
│   │       │   │       ├── card_widget.dart             # Capture/Highlight card
│   │       │   │       ├── page_container.dart          # Single A4 page
│   │       │   │       ├── capture_card.dart            # Image card
│   │       │   │       ├── highlight_card.dart          # Text card
│   │       │   │       ├── text_block_widget.dart       # Free text area
│   │       │   │       ├── live_scraps_panel.dart       # Element list display (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │       ├── scrapnote_canvas.dart        # Canvas with drawing + elements (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │       └── confirm_scrap_popup.dart     # Floating confirmation popup (NEW - SPEC-SCRAPNOTE-002)
│   │       │   ├── providers/
│   │       │   │   ├── element_store.dart          # Hive-backed element persistence (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── element_store.g.dart        # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   ├── scrap_orchestrator_provider.dart # Central insertion orchestrator (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   └── scrap_orchestrator_provider.g.dart # Generated (NEW - SPEC-SCRAPNOTE-002)
│   │       │   ├── drawing/
│   │       │   │   └── (shares tools from pdf_viewer)
│   │       │   ├── services/
│   │       │   │   ├── scrapnote_service.dart      # Scrapnote lifecycle management (NEW - SPEC-SCRAPNOTE-002)
│   │       │   │   └── scrap_insertion_service.dart # Element positioning and insertion (NEW - SPEC-SCRAPNOTE-002)
│   │       │   └── utils/
│   │       │       ├── stroke_serializer.dart       # JSON persistence
│   │       │       ├── page_layout_calculator.dart  # A4 dimensions
│   │       │       └── scrapnote_serializer.dart    # .gma JSON serialization (NEW - SPEC-SCRAPNOTE-002)
│   │       │
│   │       ├── sidebar/                 # Item navigator (8 files)
│   │       │   ├── models/
│   │       │   │   └── sidebar_item_model.dart     # C-n, H-n, P-n items
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   └── sidebar_provider.dart   # Filter state
│   │       │   │   └── widgets/
│   │       │   │       ├── sidebar_panel.dart      # Left sidebar container
│   │       │   │       ├── filter_tabs.dart        # All/Capture/Highlight/Pen
│   │       │   │       ├── item_list.dart          # Item grid
│   │       │   │       └── item_thumbnail.dart     # Item preview
│   │       │   └── utils/
│   │       │       └── item_reference_parser.dart
│   │       │
│   │       ├── capture_confirmation/   # Capture popup (3 files)
│   │       │   ├── models/
│   │       │   │   └── capture_preview_model.dart
│   │       │   └── widgets/
│   │       │       └── capture_popup.dart
│   │       │
│   │       ├── document_menu/          # Kebab menu (4 files)
│   │       │   ├── providers/
│   │       │   │   └── menu_provider.dart
│   │       │   └── widgets/
│   │       │       └── document_menu.dart
│   │       │
│   │       ├── file_system/            # Document storage (6 files)
│   │       │   ├── models/
│   │       │   │   └── document_metadata_model.dart
│   │       │   ├── providers/
│   │       │   │   ├── document_store_provider.dart
│   │       │   │   └── file_system_provider.dart
│   │       │   └── services/
│   │       │       └── document_file_service.dart
│   │       │
│   │       ├── settings/               # App settings (2 files)
│   │       │   ├── pages/
│   │       │   │   └── screens/
│   │       │   │       └── settings_screen.dart
│   │       │   └── providers/
│   │       │       └── settings_provider.dart
│   │       │
│   │       └── splash/                 # Initialization (1 file)
│   │           └── pages/
│   │               └── screens/
│   │                   └── splash_screen.dart
│   │
│   ├── test/                           # Test files (42 files)
│   │   ├── e2e/                        # End-to-end tests (2 files)
│   │   │   ├── capture_workflow_test.dart        # PDF capture → scrapnote
│   │   │   └── highlight_workflow_test.dart      # PDF highlight → scrapnote
│   │   ├── integration/                # Integration tests (4 files)
│   │   │   ├── pdf_to_scrapnote_test.dart
│   │   │   ├── scrapnote_persistence_test.dart
│   │   │   ├── drawing_tools_test.dart
│   │   │   └── panel_management_test.dart
│   │   ├── features/                   # Unit tests (31 files)
│   │   │   ├── pdf_viewer/             # PDF viewer tests (8 files)
│   │   │   │   ├── pdf_document_state_test.dart
│   │   │   │   ├── pdf_document_provider_test.dart
│   │   │   │   ├── pdf_viewer_screen_test.dart
│   │   │   │   ├── pdf_page_overlay_test.dart
│   │   │   │   ├── pdf_text_extractor_test.dart
│   │   │   │   ├── highlight/
│   │   │   │   │   ├── highlight_marker_data_test.dart       # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   ├── highlight_provider_test.dart          # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   └── highlight_overlay_test.dart           # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   └── capture/
│   │   │   │       ├── capture_provider_test.dart            # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │       └── capture_service_test.dart             # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   ├── drawing/                # Drawing system tests (10 files)
│   │   │   │   ├── drawing_model_test.dart
│   │   │   │   ├── drawing_tool_handler_test.dart
│   │   │   │   ├── pen_tool_test.dart
│   │   │   │   ├── highlighter_tool_test.dart
│   │   │   │   ├── eraser_tool_test.dart
│   │   │   │   ├── tool_registry_test.dart
│   │   │   │   ├── drawing_provider_test.dart
│   │   │   │   ├── drawing_canvas_test.dart
│   │   │   │   ├── stroke_painter_test.dart
│   │   │   │   └── drawing_serializer_test.dart
│   │   │   ├── scrapnote/
│   │   │   │   ├── models/
│   │   │   │   │   ├── element_model_test.dart                     # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   ├── highlight_color_test.dart                  # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   ├── scrapnote_canvas_model_test.dart           # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   ├── card_model_test.dart
│   │   │   │   │   └── (other model tests)
│   │   │   │   ├── providers/
│   │   │   │   │   ├── element_store_test.dart                    # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   ├── scrap_orchestrator_provider_test.dart      # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   └── (other provider tests)
│   │   │   │   ├── utils/
│   │   │   │   │   ├── scrapnote_serializer_test.dart             # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   ├── stroke_serializer_test.dart
│   │   │   │   │   └── page_layout_test.dart
│   │   │   │   ├── services/
│   │   │   │   │   ├── scrap_insertion_service_test.dart          # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   │   └── scrapnote_service_test.dart               # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │   └── widgets/
│   │   │   │       ├── confirm_scrap_popup_test.dart              # (NEW - SPEC-SCRAPNOTE-002)
│   │   │   │       └── (other widget tests)
│   │   │   └── workspace/
│   │   │       └── workspace_provider_test.dart
│   │   └── TEST_COVERAGE.md
│   │
│   ├── android/                        # Android platform
│   │   ├── app/
│   │   │   └── src/
│   │   │       ├── main/
│   │   │       │   ├── AndroidManifest.xml
│   │   │       │   ├── kotlin/MainActivity.kt
│   │   │       │   └── res/
│   │   │       ├── debug/
│   │   │       └── profile/
│   │   └── settings.gradle.kts
│   │
│   ├── ios/                           # iOS platform
│   │   ├── Runner.xcworkspace/
│   │   ├── Runner.xcodeproj/
│   │   ├── Runner/
│   │   │   ├── Info.plist
│   │   │   ├── AppDelegate.swift
│   │   │   └── Assets.xcassets/
│   │   └── Podfile
│   │
│   ├── macos/                         # macOS platform
│   │   ├── Runner.xcworkspace/
│   │   ├── Runner.xcodeproj/
│   │   └── Runner/
│   │
│   ├── windows/                       # Windows platform
│   │   ├── runner/
│   │   │   ├── main.cpp
│   │   │   └── flutter_window.cpp
│   │   └── CMakeLists.txt
│   │
│   ├── linux/                         # Linux platform
│   │   ├── flutter/
│   │   └── CMakeLists.txt
│   │
│   ├── web/                           # Web platform
│   │   ├── index.html
│   │   └── manifest.json
│   │
│   ├── pubspec.yaml                   # Dependencies (22 packages)
│   ├── pubspec.lock                   # Lock file
│   ├── analysis_options.yaml           # Dart linting rules
│   ├── CLAUDE.md                       # Agent development guide
│   ├── README.md                       # Project readme (GMA SecPlan)
│   └── .metadata
│
├── docs/                               # Documentation (human-readable)
│   ├── secplan/
│   │   ├── SPEC-SECPLAN.md            # GMA SecPlan feature specification
│   │   └── ARCHITECTURE.md            # Dual-panel architecture guide
│   ├── layout/                        # UI layout documentation
│   │   ├── 01-dual-panel-layout.md
│   │   ├── 02-header-bar.md
│   │   ├── 03-pdf-panel.md
│   │   ├── 04-scrapnote-panel.md
│   │   ├── 05-sidebar-navigator.md
│   │   ├── 06-drawing-toolbar.md
│   │   └── README.md
│   └── development/
│       └── IMPLEMENTATION_GUIDE.md
│
├── .claude/                            # Claude Code configuration
│   ├── agents/                         # Custom agents
│   ├── skills/                         # Custom skills
│   │   └── moai-*.md                  # MoAI foundation skills
│   ├── rules/
│   │   └── moai/                      # MoAI rules
│   │       ├── core/
│   │       ├── development/
│   │       ├── languages/
│   │       └── workflow/
│   ├── hooks/                         # Event hooks
│   └── commands/                      # Custom slash commands
│
└── .git/                              # Git repository

```

## Key File Locations

### For Common Development Tasks

**Modify workspace layout**: `/mnt/d/project/GMA/frontend_v2/lib/features/workspace/pages/screens/workspace_screen.dart`

**Adjust dual-panel behavior**: `frontend_v2/lib/features/workspace/pages/providers/workspace_provider.dart`

**Implement drawing tool**:
1. Create tool: `frontend_v2/lib/features/pdf_viewer/drawing/tools/your_tool.dart`
2. Extend existing tool pattern
3. Used by both PDF viewer and Scrapnote

**Add capture workflow**:
1. Extend capture region model: `frontend_v2/lib/features/pdf_viewer/models/capture_region_model.dart`
2. Update capture provider: `frontend_v2/lib/features/pdf_viewer/pages/providers/capture_provider.dart`
3. Insert into scrapnote in workspace_provider

**Add scrapnote feature**:
1. Create model: `frontend_v2/lib/features/scrapnote/models/` with `@freezed` annotation
2. Add provider: `frontend_v2/lib/features/scrapnote/pages/providers/{name}_provider.dart`
3. Add widget: `frontend_v2/lib/features/scrapnote/pages/widgets/{name}_widget.dart`

### Data Persistence Locations

**Hive boxes**:
- `app_settings`: Theme, layout preferences
- `document_registry`: Metadata for PDFs and Scrapnotes
- `workspace_state`: Panel dimensions, active documents
- `element_store`: Scrapnote elements (captures, highlights, strokes) - NEW SPEC-SCRAPNOTE-002

**Filesystem**:
- `~/.local/share/gma_secplan/` (Linux/macOS)
- `%APPDATA%\gma_secplan\` (Windows)
- Contains: documents/, scrapnotes/, trash/, `.config/workspace.json`

### Configuration Files

- `.moai/config/sections/quality.yaml`: Development mode (TDD), coverage targets
- `.moai/config/sections/language.yaml`: Language settings (English)
- `frontend/analysis_options.yaml`: Dart linting rules
- `frontend/pubspec.yaml`: Dependencies and build configuration

## Code Generation Artifacts

After modifying `@freezed` models or `@riverpod` providers, run:

```bash
cd frontend
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `*.freezed.dart` from `@freezed` classes
- `*.g.dart` from json_serializable and riverpod_generator
- `app_router.g.dart` from go_router

## Summary

- **~175 Dart files**: Feature-first modular architecture with enhanced scrapnote capabilities
- **14 feature modules**: workspace (core), pdf_viewer (NEW - SPEC-PDF-001, enhanced with SPEC-SCRAPNOTE-002), drawing (NEW - SPEC-PDF-001), scrapnote (NEW - SPEC-SCRAPNOTE-002 with 21 new files including element management, highlight colors, canvas coordination, and services), sidebar, capture_confirmation, document_menu, file_system, settings, splash
- **42 test files**: 2 E2E, 4 integration, 36 unit (15 for pdf_viewer + drawing, 21 new for scrapnote SPEC-SCRAPNOTE-002)
- **App routes**: splash, workspace (main), settings
- **3 Hive boxes**: app_settings, document_registry, workspace_state, plus new Hive box for element_store (NEW - SPEC-SCRAPNOTE-002)
- **Multi-platform support**: Android, iOS, Windows, macOS, Linux
- **Design**: Dual-panel with auto-insertion, smart element orchestration, color-aware highlighting, Scrapnote canvas with live element panel, Samsung Notes-like A4 pages

