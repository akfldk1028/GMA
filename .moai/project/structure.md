# GMA Project Structure

## Directory Hierarchy Overview

```
GMA/
├── .moai/                                    # MoAI framework configuration and project metadata
│   ├── config/
│   │   ├── sections/
│   │   │   ├── workflow.yaml                # Workflow and execution configuration
│   │   │   ├── quality.yaml                 # Development mode and quality gates
│   │   │   ├── user.yaml                    # User preferences and settings
│   │   │   └── language.yaml                # Language configuration (English)
│   │   └── project.json                     # Project metadata and settings
│   ├── project/                             # Generated project documentation
│   │   ├── product.md                       # Product overview and features
│   │   ├── structure.md                     # This file
│   │   ├── tech.md                          # Technology stack and architecture
│   │   └── codemaps/
│   │       ├── overview.md                  # Architecture overview diagrams
│   │       ├── modules.md                   # Feature module descriptions
│   │       ├── dependencies.md              # Module dependency graphs
│   │       ├── entry-points.md              # Application entry points
│   │       └── data-flow.md                 # Data flow and state management
│   └── specs/                               # SPEC documents from /moai plan
│       ├── SPEC-SP-000/                     # Apple HIG Design System (Planned)
│       ├── SPEC-SCRAPNOTE-001/              # Pen-Based Scrapnote Canvas (Implemented)
│       ├── SPEC-SP-001/                     # SecPlan Workspace Transformation (Completed)
│       ├── SPEC-PDF-001/                    # PDF Viewer and Drawing System (Completed)
│       └── SPEC-SCRAPNOTE-002/              # Auto-Insertion Pipeline and Visual Highlight (Implemented)
│
├── frontend_v2/                             # Flutter application (GMA SecPlan v2)
│   │
│   ├── lib/                                 # Source code directory (60 non-generated files)
│   │   ├── main.dart                        # Application entry point (Hive initialization, ProviderScope setup)
│   │   ├── app.dart                         # ShadApp router configuration and theme setup
│   │   │
│   │   ├── constants/                       # Design system constants (5 files)
│   │   │   ├── app_colors.dart              # ShadCN color palette and color definitions
│   │   │   ├── app_theme.dart               # Light and dark theme configurations
│   │   │   ├── app_typography.dart          # Font definitions and text styles
│   │   │   ├── app_spacing.dart             # Spacing and padding constants
│   │   │   └── design_tokens.dart           # Design tokens and breakpoints
│   │   │
│   │   ├── routing/                         # Navigation and routing (1 file)
│   │   │   └── app_router.dart              # GoRouter configuration with routes for workspace, dashboard, file_manager
│   │   │
│   │   ├── utils/                           # Utility functions and helpers (1 file + generated)
│   │   │   └── file_system_provider.dart    # Local file system access and platform-specific paths
│   │   │   └── file_system_provider.g.dart  # Generated Riverpod provider
│   │   │
│   │   ├── common_widgets/                  # Shared UI components across features (available but minimal)
│   │   │   └── (shared components and layouts)
│   │   │
│   │   └── features/                        # Feature-first modular architecture (7 feature modules, ~86 lib files)
│   │       │
│   │       ├── workspace/                   # Main dual-panel editor orchestration (16 lib files)
│   │       │   ├── models/
│   │       │   │   ├── secplan_state.dart                  # Main workspace state container
│   │       │   │   ├── secplan_state.freezed.dart          # Generated immutable state
│   │       │   │   ├── open_pdf_tab.dart                   # PDF tab data model
│   │       │   │   ├── open_pdf_tab.freezed.dart           # Generated immutable model
│   │       │   │   └── open_pdf_tab.g.dart                 # Generated JSON serialization
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── panel_provider.dart             # Left/right panel state and layout
│   │       │   │   │   ├── panel_provider.g.dart           # Generated Riverpod provider
│   │       │   │   │   ├── tab_provider.dart               # PDF tab management (open/close/switch)
│   │       │   │   │   └── tab_provider.g.dart             # Generated Riverpod provider
│   │       │   │   ├── screens/
│   │       │   │   │   └── workspace_screen.dart           # Main dual-panel layout screen composition
│   │       │   │   └── widgets/
│   │       │   │       ├── panel_divider.dart              # Draggable center divider for resizing
│   │       │   │       ├── panel_manager.dart              # Panel swap, maximize, restore logic
│   │       │   │       ├── kebab_menu.dart                 # Three-dot menu for document actions
│   │       │   │       ├── pdf_tab_bar.dart                # Tab bar for multiple open PDFs
│   │       │   │       ├── secplan_header.dart             # Header bar with title and controls
│   │       │   │       └── scrapnote_panel.dart            # Right panel container for scrapnote
│   │       │
│   │       ├── pdf_viewer/                  # PDF rendering, highlighting, and capture (20 lib files)
│   │       │   ├── models/
│   │       │   │   ├── pdf_document_state.dart             # PDF document state container
│   │       │   │   ├── pdf_document_state.freezed.dart     # Generated immutable state
│   │       │   │   └── pdf_document_state.g.dart           # Generated JSON serialization
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── pdf_document_provider.dart      # Load, navigate, and clear PDF
│   │       │   │   │   ├── pdf_document_provider.g.dart    # Generated Riverpod provider
│   │       │   │   │   ├── highlight_provider.dart         # Per-document highlight data storage
│   │       │   │   │   └── highlight_provider.g.dart       # Generated Riverpod provider
│   │       │   │   ├── screens/
│   │       │   │   │   └── pdf_viewer_screen.dart          # PDF viewer composition and layout
│   │       │   │   └── widgets/
│   │       │   │       └── pdf_page_overlay.dart           # Drawing and text layers on PDF pages
│   │       │   ├── utils/
│   │       │   │   ├── pdf_text_extractor.dart             # Text extraction and coordinate normalization
│   │       │   │   └── pdf_reader_utils.dart               # PDF document utilities
│   │       │   ├── highlight/                              # Text highlighting system (6 files)
│   │       │   │   ├── models/
│   │       │   │   │   ├── highlight_marker_data.dart      # Highlight marker data structure
│   │       │   │   │   ├── highlight_marker_data.freezed.dart # Generated immutable model
│   │       │   │   │   └── highlight_marker_data.g.dart    # Generated JSON serialization
│   │       │   │   ├── providers/
│   │       │   │   │   ├── highlight_provider.dart         # Highlight state per document
│   │       │   │   │   └── highlight_provider.g.dart       # Generated Riverpod provider
│   │       │   │   └── widgets/
│   │       │   │       └── highlight_overlay.dart          # Visual highlight rendering on PDF
│   │       │   └── capture/                                # Region capture system (8 files)
│   │       │       ├── pages/
│   │       │       │   ├── providers/
│   │       │       │   │   ├── capture_provider.dart       # Capture mode and region selection state
│   │       │       │   │   ├── capture_provider.freezed.dart # Generated immutable state
│   │       │       │   │   └── capture_provider.g.dart     # Generated Riverpod provider
│   │       │       │   └── widgets/
│   │       │       │       ├── capture_overlay.dart        # Drag-to-select region overlay
│   │       │       │       └── capture_page_overlay.dart   # pdfrx overlay builder
│   │       │       └── utils/
│   │       │           └── capture_service.dart            # PDF region to PNG rendering
│   │       │
│   │       ├── scrapnote/                   # Scrapnote canvas and note management (21 lib files)
│   │       │   ├── models/
│   │       │   │   ├── element_model.dart                  # Card and element data model
│   │       │   │   ├── element_model.freezed.dart          # Generated immutable model
│   │       │   │   ├── element_model.g.dart                # Generated JSON serialization
│   │       │   │   ├── highlight_color.dart                # Highlight color enumeration
│   │       │   │   ├── highlight_color.g.dart              # Generated JSON serialization
│   │       │   │   ├── scrapnote_canvas_model.dart         # Canvas and page data structure
│   │       │   │   ├── scrapnote_canvas_model.freezed.dart # Generated immutable model
│   │       │   │   └── scrapnote_canvas_model.g.dart       # Generated JSON serialization
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── scrapnote_canvas_provider.dart  # Canvas state and operations
│   │       │   │   │   └── scrapnote_canvas_provider.g.dart # Generated Riverpod provider
│   │       │   │   ├── screens/
│   │       │   │   │   └── scrapnote_screen.dart           # Main scrapnote canvas screen
│   │       │   │   └── widgets/
│   │       │   │       ├── scrapnote_canvas.dart           # Canvas rendering and interaction
│   │       │   │       ├── live_scraps_panel.dart          # Live preview of scrapnote items
│   │       │   │       └── confirm_scrap_popup.dart        # Confirmation dialog for inserts
│   │       │   ├── providers/
│   │       │   │   ├── element_store.dart                  # Global card registry (Hive-backed)
│   │       │   │   ├── element_store.g.dart                # Generated Riverpod provider
│   │       │   │   ├── scrap_orchestrator_provider.dart    # Card insertion and positioning logic
│   │       │   │   └── scrap_orchestrator_provider.g.dart  # Generated Riverpod provider
│   │       │   ├── services/
│   │       │   │   ├── scrapnote_service.dart              # File I/O and persistence
│   │       │   │   └── scrap_insertion_service.dart        # Card insertion business logic
│   │       │   └── utils/
│   │       │       └── scrapnote_serializer.dart           # JSON serialization and deserialization
│   │       │
│   │       ├── drawing/                     # Drawing tools and stroke system (15 lib files)
│   │       │   ├── models/
│   │       │   │   ├── drawing_model.dart                  # Stroke data structure
│   │       │   │   ├── drawing_model.freezed.dart          # Generated immutable model
│   │       │   │   └── drawing_model.g.dart                # Generated JSON serialization
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── drawing_provider.dart           # Drawing state and tool selection
│   │       │   │   │   └── drawing_provider.g.dart         # Generated Riverpod provider
│   │       │   │   └── widgets/
│   │       │   │       ├── drawing_canvas.dart             # Canvas for drawing operations
│   │       │   │       ├── drawing_overlay.dart            # Drawing overlay composition
│   │       │   │       ├── drawing_toolbar.dart            # Tool selection UI (pen, highlighter, eraser)
│   │       │   │       └── stroke_painter.dart             # Custom painter for stroke rendering
│   │       │   ├── tools/
│   │       │   │   ├── drawing_tool_handler.dart           # Base tool handler interface
│   │       │   │   ├── pen_tool.dart                       # Pen drawing implementation
│   │       │   │   ├── highlighter_tool.dart               # Highlighter implementation with transparency
│   │       │   │   ├── eraser_tool.dart                    # Eraser implementation
│   │       │   │   └── tool_registry.dart                  # Tool registry and factory
│   │       │   └── utils/
│   │       │       └── drawing_serializer.dart             # Stroke serialization and deserialization
│   │       │
│   │       ├── sidebar/                     # Item navigator and filtering (3 lib files)
│   │       │   ├── models/
│   │       │   │   └── (sidebar data models if any)
│   │       │   ├── pages/
│   │       │   │   ├── providers/
│   │       │   │   │   ├── sidebar_provider.dart           # Sidebar item state and filtering
│   │       │   │   │   └── sidebar_provider.g.dart         # Generated Riverpod provider
│   │       │   │   └── widgets/
│   │       │   │       └── item_sidebar.dart               # Sidebar UI with filter tabs
│   │       │
│   │       ├── dashboard/                   # Landing page (1 lib file)
│   │       │   └── pages/
│   │       │       └── screens/
│   │       │           └── dashboard_screen.dart           # Dashboard and file browser screen
│   │       │
│   │       └── file_manager/                # File operations (placeholder, 6 lib files available)
│   │           ├── models/
│   │           │   └── (file manager data models)
│   │           ├── pages/
│   │           │   ├── providers/
│   │           │   │   └── (file manager providers)
│   │           │   ├── screens/
│   │           │   │   └── (file manager screens)
│   │           │   └── widgets/
│   │           │       └── (file manager widgets)
│   │
│   ├── test/                                # Test suite (34 test files)
│   │   ├── widget_test.dart                 # Widget test example
│   │   ├── constants/
│   │   │   ├── app_colors_test.dart         # Color constant tests
│   │   │   ├── app_typography_test.dart     # Typography tests
│   │   │   ├── app_spacing_test.dart        # Spacing constant tests
│   │   │   └── app_theme_test.dart          # Theme configuration tests
│   │   ├── features/
│   │   │   ├── workspace/
│   │   │   │   └── (workspace feature tests)
│   │   │   ├── pdf_viewer/
│   │   │   │   ├── models/
│   │   │   │   │   └── pdf_document_state_test.dart
│   │   │   │   ├── pages/
│   │   │   │   │   ├── providers/
│   │   │   │   │   │   └── pdf_document_provider_test.dart
│   │   │   │   │   ├── screens/
│   │   │   │   │   │   └── pdf_viewer_screen_test.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       └── pdf_page_overlay_test.dart
│   │   │   │   ├── utils/
│   │   │   │   │   └── pdf_text_extractor_test.dart
│   │   │   │   ├── highlight/
│   │   │   │   │   ├── models/
│   │   │   │   │   │   └── highlight_marker_data_test.dart
│   │   │   │   │   ├── providers/
│   │   │   │   │   │   └── highlight_provider_test.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       └── highlight_overlay_test.dart
│   │   │   │   └── capture/
│   │   │   │       ├── pages/
│   │   │   │       │   ├── providers/
│   │   │   │       │   │   └── capture_provider_test.dart
│   │   │   │       └── utils/
│   │   │   │           └── capture_service_test.dart
│   │   │   ├── scrapnote/
│   │   │   │   ├── models/
│   │   │   │   │   ├── element_model_test.dart
│   │   │   │   │   ├── highlight_color_test.dart
│   │   │   │   │   └── scrapnote_canvas_model_test.dart
│   │   │   │   ├── providers/
│   │   │   │   │   ├── element_store_test.dart
│   │   │   │   │   └── scrap_orchestrator_provider_test.dart
│   │   │   │   ├── pages/
│   │   │   │   │   └── widgets/
│   │   │   │   │       └── confirm_scrap_popup_test.dart
│   │   │   │   ├── services/
│   │   │   │   │   ├── scrap_insertion_service_test.dart
│   │   │   │   │   └── scrapnote_service_test.dart
│   │   │   │   └── utils/
│   │   │   │       └── scrapnote_serializer_test.dart
│   │   │   ├── drawing/
│   │   │   │   ├── models/
│   │   │   │   │   └── drawing_model_test.dart
│   │   │   │   ├── tools/
│   │   │   │   │   ├── tool_registry_test.dart
│   │   │   │   │   ├── highlighter_tool_test.dart
│   │   │   │   │   ├── pen_tool_test.dart
│   │   │   │   │   └── eraser_tool_test.dart
│   │   │   │   ├── pages/
│   │   │   │   │   ├── providers/
│   │   │   │   │   │   └── drawing_provider_test.dart
│   │   │   │   │   └── widgets/
│   │   │   │   │       ├── stroke_painter_test.dart
│   │   │   │   │       ├── drawing_canvas_test.dart
│   │   │   │   │       └── drawing_toolbar_test.dart
│   │   │   │   └── utils/
│   │   │   │       └── drawing_serializer_test.dart
│   │   │   ├── sidebar/
│   │   │   │   └── (sidebar feature tests)
│   │   │   └── file_manager/
│   │   │       └── (file manager feature tests)
│   │
│   ├── assets/
│   │   └── sample.pdf                       # Sample PDF for testing
│   │
│   ├── android/                             # Android platform configuration
│   ├── ios/                                 # iOS platform configuration
│   ├── macos/                               # macOS platform configuration
│   ├── windows/                             # Windows platform configuration
│   ├── linux/                               # Linux platform configuration
│   ├── web/                                 # Web platform configuration
│   │
│   ├── pubspec.yaml                         # Dart package dependencies and configuration
│   ├── pubspec.lock                         # Locked dependency versions
│   ├── analysis_options.yaml                # Dart linter configuration
│   └── .dart_tool/                          # Generated build artifacts
│
├── frontend/                                # Previous version (v1) - deprecated
├── docs/                                    # Additional documentation (if any)
└── (other project files)
```

## File Count Summary

| Category | Count | Purpose |
|----------|-------|---------|
| **Source Files** (lib/) | 60 | Non-generated Dart source code |
| **Generated Files** | 26 | .freezed.dart and .g.dart files |
| **Test Files** | 34 | Test suite for all features |
| **Feature Modules** | 7 | workspace, pdf_viewer, scrapnote, drawing, sidebar, dashboard, file_manager |
| **Total Dart Files** | 120+ | All Dart files in lib/ and test/ |

## Feature Module Organization

### workspace/ (16 files)
Main orchestrator for dual-panel layout, panel management (swap/resize/maximize), and PDF tab bar. Coordinates between pdf_viewer and scrapnote features. Entry point for most user interactions.

### pdf_viewer/ (20 files)
PDF document rendering, page navigation, text extraction, and drawing overlay. Includes sub-modules for highlighting and capture functionality. Manages per-document state with providers.

### scrapnote/ (21 files)
Canvas implementation for note-taking with A4 page or infinite scroll modes. Handles card insertion from PDF captures/highlights, stroke persistence, and card positioning. Core auto-insertion logic.

### drawing/ (15 files)
Tool system for pen, highlighter, and eraser. Stroke data model and serialization. Tool registry and handler abstraction. Used by both PDF viewer and scrapnote features.

### sidebar/ (3 files)
Item navigator for C-n (Capture), H-n (Highlight), and P-n (Pen) references. Filtering by type and document. Navigation back to source locations.

### dashboard/ (1 file)
Landing page with file browser and recent document list. Entry point for application after splash screen.

### file_manager/ (6 files available)
Placeholder structure for file operations (create, open, save, delete, rename). Ready for implementation.

## Key File Locations for Common Tasks

### Running the Application
- **Entry Point**: `/mnt/d/project/GMA/frontend_v2/lib/main.dart`
- **App Configuration**: `/mnt/d/project/GMA/frontend_v2/lib/app.dart`
- **Router Setup**: `/mnt/d/project/GMA/frontend_v2/lib/routing/app_router.dart`

### Modifying Design System
- **Colors**: `/mnt/d/project/GMA/frontend_v2/lib/constants/app_colors.dart`
- **Typography**: `/mnt/d/project/GMA/frontend_v2/lib/constants/app_typography.dart`
- **Spacing**: `/mnt/d/project/GMA/frontend_v2/lib/constants/app_spacing.dart`
- **Theme**: `/mnt/d/project/GMA/frontend_v2/lib/constants/app_theme.dart`
- **Design Tokens**: `/mnt/d/project/GMA/frontend_v2/lib/constants/design_tokens.dart`

### Adding Drawing Features
- **Tool System**: `/mnt/d/project/GMA/frontend_v2/lib/features/drawing/tools/`
- **Tool Handlers**: `/mnt/d/project/GMA/frontend_v2/lib/features/drawing/tools/drawing_tool_handler.dart`
- **Tool Registry**: `/mnt/d/project/GMA/frontend_v2/lib/features/drawing/tools/tool_registry.dart`
- **Stroke Model**: `/mnt/d/project/GMA/frontend_v2/lib/features/drawing/models/drawing_model.dart`

### Modifying PDF Functionality
- **PDF State**: `/mnt/d/project/GMA/frontend_v2/lib/features/pdf_viewer/models/pdf_document_state.dart`
- **PDF Provider**: `/mnt/d/project/GMA/frontend_v2/lib/features/pdf_viewer/pages/providers/pdf_document_provider.dart`
- **PDF Screen**: `/mnt/d/project/GMA/frontend_v2/lib/features/pdf_viewer/pages/screens/pdf_viewer_screen.dart`
- **Text Extraction**: `/mnt/d/project/GMA/frontend_v2/lib/features/pdf_viewer/utils/pdf_text_extractor.dart`

### Working with Scrapnote Canvas
- **Canvas Model**: `/mnt/d/project/GMA/frontend_v2/lib/features/scrapnote/models/scrapnote_canvas_model.dart`
- **Canvas Provider**: `/mnt/d/project/GMA/frontend_v2/lib/features/scrapnote/pages/providers/scrapnote_canvas_provider.dart`
- **Canvas Widget**: `/mnt/d/project/GMA/frontend_v2/lib/features/scrapnote/pages/widgets/scrapnote_canvas.dart`
- **Serialization**: `/mnt/d/project/GMA/frontend_v2/lib/features/scrapnote/utils/scrapnote_serializer.dart`

### Data Persistence
- **File System Access**: `/mnt/d/project/GMA/frontend_v2/lib/utils/file_system_provider.dart`
- **Hive Configuration**: `pubspec.yaml` (hive_flutter dependency)
- **Scrapnote File I/O**: `/mnt/d/project/GMA/frontend_v2/lib/features/scrapnote/services/scrapnote_service.dart`

### Testing
- **Test Directory**: `/mnt/d/project/GMA/frontend_v2/test/`
- **Widget Tests**: `/mnt/d/project/GMA/frontend_v2/test/widget_test.dart`
- **Feature Tests**: `/mnt/d/project/GMA/frontend_v2/test/features/` (organized by feature)

## Code Generation Instructions

### Generate All Code
```bash
cd frontend_v2
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Continuous Generation)
```bash
cd frontend_v2
flutter pub run build_runner watch
```

### Generated File Types

| File Pattern | Generator | Purpose |
|--------------|-----------|---------|
| `*.freezed.dart` | freezed | Immutable model code generation |
| `*.g.dart` | json_serializable + riverpod_generator | JSON serialization and Riverpod providers |

### Troubleshooting Generation Issues
- Delete `.dart_tool/` and run `flutter clean && flutter pub get`
- Check for analyzer errors with `flutter analyze`
- Ensure pubspec.yaml specifies correct versions for code generators
- Run with `--delete-conflicting-outputs` flag if conflicts occur

## Data Persistence Architecture

### Hive Storage (Key-Value Database)
- Located in: Platform-specific app directory via path_provider
- Used for: Settings, registries, cached data
- Boxes:
  - workspace_settings: Panel layout, app preferences
  - element_store: Card registry (captures, highlights)
  - (Additional boxes as needed)

### File System Storage
- Note Files: Custom JSON format stored in app documents directory
- PDF Files: Read as-is from filesystem
- Captured Images: PNG files in app cache directory
- Strokes: Embedded in scrapnote JSON format

### JSON Serialization
- Framework: json_annotation + json_serializable
- Usage: All freezed models include JSON serialization
- Format: Dart object → JSON via `toJson()` → File storage

## Platform-Specific Configuration

### Android
- Configuration: `android/app/build.gradle`
- Min SDK: Supports current Android versions
- Permissions: File access, camera (for capture)

### iOS
- Configuration: `ios/Runner.xcodeproj`
- Min iOS: Version based on Flutter requirements
- Permissions: File access, camera

### macOS
- Configuration: `macos/Runner.xcodeproj`
- Features: Entitlements for file access

### Windows
- Configuration: `windows/CMakeLists.txt`
- Build: MSVC compiler

### Linux
- Configuration: `linux/CMakeLists.txt`
- Dependencies: GTK3 and other system libraries

### Web
- Configuration: `web/index.html`
- Limitations: Sandboxed file system access
