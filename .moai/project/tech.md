# GMA SecPlan Technology Stack & Architecture

## Core Technology Stack

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| **Application Framework** | Flutter | 3.41.4+ | Cross-platform UI framework with Material 3 |
| **Programming Language** | Dart | 3.11.1+ | Type-safe language with null safety |
| **UI Component Library** | shadcn_ui | ^0.45.1 | Apple HIG-compliant design system |
| **State Management** | flutter_riverpod | ^2.6.1 | Declarative provider pattern for state |
| **Provider Generation** | riverpod_annotation | ^2.6.1 | Annotation-based provider codegen |
| **Navigation/Routing** | go_router | ^14.6.2 | Declarative URL-based routing |
| **PDF Rendering** | pdfrx | ^2.2.0 | PDF viewer with text extraction and overlay |
| **Local Storage** | hive_flutter | ^1.1.0 | NoSQL embedded database for settings |
| **Model Generation** | freezed_annotation | ^2.4.4 | Immutable model and copyWith codegen |
| **JSON Serialization** | json_annotation | ^4.9.0 | JSON encode/decode codegen |
| **Drawing Library** | perfect_freehand | ^2.5.2+1 | Normalized freehand stroke algorithm |
| **File System** | path_provider | ^2.1.4 | Platform-specific app directory access |
| **File Picking** | file_picker | ^8.1.6 | Native file selection dialogs |
| **HTTP Client** | http | ^1.2.0 | Async HTTP requests |
| **Utilities** | uuid | ^4.5.1 | UUID generation for unique IDs |
| **Path Operations** | path | ^1.9.0 | Cross-platform path manipulation |
| **Internationalization** | intl | ^0.20.2 | Date/time/number formatting and i18n |
| **Debug Overlay** | marionette_flutter | ^0.3.0 | Development debug overlay tool |
| **Code Generation** | build_runner | ^2.4.13 | Dart code generation framework |
| **Model Codegen** | freezed | ^2.5.7 | Freezed model code generator |
| **Serialization Codegen** | json_serializable | ^6.8.0 | JSON serialization codegen |
| **Provider Codegen** | riverpod_generator | ^2.6.2 | Riverpod provider code generator |

## Version Requirements

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Flutter SDK** | 3.41.4+ | Supports Material 3 and latest dart features |
| **Dart SDK** | 3.11.1+ | Null safety enabled, records and patterns |
| **Android SDK** | API 24+ | Minimum API level for Android support |
| **iOS Deployment** | 12.0+ | Minimum iOS version for app deployment |
| **Build Tools** | gradle 7.0+ | Android build tools version |

## Development Tools

| Tool | Purpose |
|------|---------|
| flutter_lints | Linting and code quality checks |
| flutter_test | Widget and unit testing framework |
| dart analyze | Static analysis tool |
| build_runner | Code generation orchestration |

## Architecture Overview

### Layered Architecture

GMA SecPlan follows a feature-first modular architecture with clear separation of concerns:

**Presentation Layer** (Features)
- Screens: Top-level UI compositions that display content
- Widgets: Reusable UI components for specific interactions
- Providers: State management for feature-specific data

**Domain Layer** (Models)
- Data models with freezed for immutability and copyWith
- JSON serialization for persistence
- Type-safe structures with Dart records and patterns

**Data Layer** (Services & Utils)
- File system access via path_provider
- Hive embedded database for settings and registries
- JSON serialization with json_serializable
- Platform-specific file operations

### Feature Module Structure

Each feature module follows this standard structure:

```
feature/
├── models/           # Data models (@freezed, JSON serializable)
├── pages/
│   ├── providers/    # Riverpod providers (@riverpod annotation)
│   ├── screens/      # Full-screen UI compositions
│   └── widgets/      # Reusable feature-specific components
├── services/         # Business logic and file I/O
└── utils/           # Helper functions and utilities
```

## Architectural Decisions & Rationale

### 1. Dual-Panel Architecture

**Pattern**: Two independent document viewers (PDF and Scrapnote) sharing a workspace

**Design**:
- Left Panel: PDF Viewer with page navigation and drawing overlay
- Right Panel: Scrapnote Canvas with A4 pages or infinite scroll
- Shared Drawing Toolbar: Single pen/highlighter/eraser toolbar applies to active panel
- Resizable Divider: Drag center to adjust panel width ratio
- Panel Controls: Swap positions, maximize single panel, restore dual-panel

**Implementation Files**:
- `workspace/pages/providers/panel_provider.dart` - Panel state and layout
- `workspace/pages/widgets/panel_divider.dart` - Resizable divider
- `workspace/pages/widgets/panel_manager.dart` - Swap/maximize logic
- `workspace/pages/screens/workspace_screen.dart` - Main dual-panel composition

**Benefits**:
- Seamless annotation workflow without app switching
- Equal document status: PDF and Note are both first-class
- Visual feedback shows both annotation and note-taking simultaneously
- Familiar UI pattern from Samsung Notes

**Technical Considerations**:
- Both panels update independently via separate providers
- Shared toolbar state watches which panel has focus
- Panel layout persisted in Hive for consistency across sessions
- Smooth animations on layout transitions

### 2. Auto-Insertion Workflow for PDF Captures and Highlights

**Pattern**: PDF captures and text highlights automatically create cards in linked scrapnote

**Design Flow**:
1. User captures region or selects text on PDF
2. Capture/highlight provider creates card object with metadata
3. Workspace provider triggers insertion into active scrapnote
4. Sidebar provider adds item reference (C-1, H-2, etc.)
5. Optional: 30-second confirmation popup (can dismiss)

**Implementation Files**:
- `pdf_viewer/capture/utils/capture_service.dart` - Region to PNG rendering
- `pdf_viewer/highlight/providers/highlight_provider.dart` - Highlight data
- `scrapnote/providers/scrap_orchestrator_provider.dart` - Insertion orchestration
- `scrapnote/services/scrap_insertion_service.dart` - Card positioning logic
- `sidebar/pages/providers/sidebar_provider.dart` - Item registry

**Benefits**:
- Reduces friction: no manual "Add" dialog required
- Maintains context: source page and location preserved as metadata
- Flexible: user can reorder, delete, or reposition cards after insertion
- Navigable: sidebar provides quick jump back to source

**Technical Considerations**:
- Capture service renders PDF region to PNG using pdfrx coordinate system
- Highlight uses text extraction with normalized 0-1 coordinates
- Cards stored with absolute pixel coordinates in scrapnote
- Insertion service handles page-aware positioning (A4 vs infinite scroll)

### 3. State Management: Riverpod with Riverpod Generator Annotations

**Pattern**: Declarative provider pattern with annotation-based code generation

**Design**:
- Feature providers use @riverpod annotations for auto-generated code
- Family modifiers for parameterized queries per document
- AsyncValue handling for async operations
- keepAlive for global state that persists across navigation

**Implementation**:
- `@riverpod` providers in each feature's `pages/providers/` directory
- `.g.dart` files auto-generated by riverpod_generator
- Consumers (ConsumerWidget, ConsumerStatefulWidget, Consumer) for UI binding
- StateNotifier for mutable state (drawing operations, canvas updates)

**Example Architecture**:
```
pdf_document_provider.dart
├── Creates providers for:
│   ├── Loading PDF documents
│   ├── Navigating pages
│   ├── Clearing document state
│   └── Per-document state access via family
```

**Benefits**:
- Type-safe state access via auto-generated code
- Composable providers enable complex state logic
- AsyncValue handles loading/error/data states
- Scoped providers prevent memory leaks
- Testable: providers are pure functions

**Technical Considerations**:
- Build runner required for code generation
- Provider dependencies tracked automatically
- Override for testing via ProviderContainer
- Lazy evaluation prevents unnecessary computation

### 4. Immutable Models with Freezed

**Pattern**: Code-generated immutable models with copyWith and equality

**Design**:
- All data models use @freezed annotation
- Automatic JSON serialization via json_serializable
- copyWith for immutable updates
- Pattern matching support via union types

**Example Model**:
```
DrawingModel
├── Required: id, points, color, thickness, toolType
├── Generated: ==, hashCode, copyWith, toJson, fromJson
└── Used by: drawing provider, stroke painter, serializer
```

**Implementation**:
- Models defined in `features/*/models/*.dart`
- `.freezed.dart` auto-generated by freezed
- `.g.dart` auto-generated by json_serializable
- TypeScript-like union types for variants

**Benefits**:
- Eliminates boilerplate (copyWith, equality, toString)
- Runtime safety: immutability enforced by type system
- Easy state updates: `state.copyWith(field: newValue)`
- JSON support built-in
- Pattern matching enables exhaustive checks

### 5. Normalized 0-1 Coordinate System for PDF Operations

**Pattern**: Resolution-independent coordinates for PDF rendering and text extraction

**Design**:
- PDF pages normalized to 0-1 coordinate space (0,0 = top-left, 1,1 = bottom-right)
- Text selection uses normalized coordinates
- Highlight markers stored as normalized rects
- Conversion to pixel coordinates only at render time

**Implementation Files**:
- `pdf_viewer/utils/pdf_text_extractor.dart` - Coordinate normalization
- `pdf_viewer/highlight/providers/highlight_provider.dart` - Highlight rects
- `drawing/tools/drawing_tool_handler.dart` - Stroke coordinate handling

**Benefits**:
- Zoom-independent: same coordinates work at any zoom level
- Page-independent: coordinates consistent across different page sizes
- Serialization-friendly: normalized values are human-readable
- Future-proof: easy to support different PDF libraries

**Technical Considerations**:
- pdfrx provides native coordinate system
- Conversion functions: normalized ↔ pixel coordinates
- Text extraction returns character-level positions
- Drawing strokes stored in pixel coordinates (in-page reference)

### 6. Drawing System with perfect_freehand

**Pattern**: Normalized freehand stroke algorithm for smooth drawing

**Design**:
- perfect_freehand library provides point smoothing and interpolation
- Tool system abstracts pen, highlighter, and eraser implementations
- Strokes stored with complete point sequence for reproduction
- Tool registry enables runtime tool switching

**Implementation**:
- `drawing/tools/drawing_tool_handler.dart` - Tool interface
- `drawing/tools/pen_tool.dart` - Pen implementation with point collection
- `drawing/tools/highlighter_tool.dart` - Highlighter with transparency
- `drawing/tools/eraser_tool.dart` - Eraser with stroke removal
- `drawing/tools/tool_registry.dart` - Tool factory and registry

**Benefits**:
- Smooth strokes without manual point filtering
- Consistent rendering across platforms
- Extensible: new tools added via interface implementation
- Serializable: strokes stored as point arrays

**Technical Considerations**:
- perfect_freehand accepts stream of (x, y, pressure) points
- Pressure optional for desktop, available on stylus input
- Stroke painter renders interpolated points
- Eraser works by removing overlapping strokes

### 7. Scrapnote Canvas with Absolute Coordinates and Card-Based Layout

**Pattern**: Absolute pixel positioning for cards and strokes on infinite scroll or A4 pages

**Design**:
- Canvas uses absolute (x, y) positioning for all elements
- A4 page mode: fixed 595×841 point pages (letter size)
- Infinite scroll mode: continuous vertical canvas
- Cards embedded with positioning metadata (type, position, size)
- Strokes stored per-page in pixel coordinates

**Implementation Files**:
- `scrapnote/models/scrapnote_canvas_model.dart` - Canvas structure
- `scrapnote/pages/widgets/scrapnote_canvas.dart` - Canvas rendering
- `scrapnote/services/scrap_insertion_service.dart` - Card insertion logic
- `scrapnote/utils/scrapnote_serializer.dart` - Persistence

**Benefits**:
- Full control over element positioning
- No conflicting layout constraints
- Familiar to Samsung Notes users
- Supports arbitrary card arrangement
- Easy serialization to JSON

**Technical Considerations**:
- Page bounds calculated based on mode (A4 vs infinite)
- Scroll offset tracked separately from absolute coordinates
- Card hit detection via rectangle intersection
- Viewport clipping for performance

### 8. Data Persistence: Hive + JSON Files

**Pattern**: Hive for metadata and registries, JSON files for document data

**Design**:
- Hive boxes store: workspace settings, element registry, app preferences
- JSON files store: scrapnote canvas data with complete structure
- Platform paths via path_provider for sandboxed app directories
- No cloud sync: local-only persistence

**Implementation**:
- Hive initialization in `main.dart`
- `scrapnote/services/scrapnote_service.dart` - File I/O
- `scrapnote/providers/element_store.dart` - Hive-backed registry
- `scrapnote/utils/scrapnote_serializer.dart` - JSON conversion

**Directory Structure**:
- iOS/macOS: `/Library/Application Support/<bundle_id>/`
- Android: `/data/data/<package_name>/files/`
- Windows/Linux: `AppData/Local/<app_name>/` or `~/.local/share/<app_name>/`
- Web: Browser LocalStorage (limited)

**Benefits**:
- Instant app launch: no cloud sync wait
- Privacy: all data stays on device
- Offline-first: works without internet
- Fast reads: Hive is indexed key-value store

**Technical Considerations**:
- Hive requires registration of custom types
- JSON serialization handles nested structures
- File naming conventions for document tracking
- Backup/export functionality for user data portability

### 9. Sidebar Item Navigator with Filtering

**Pattern**: Dynamic filtering and grouping of PDF captures, highlights, and pen strokes

**Design**:
- Sidebar displays items from current PDF or scrapnote
- Filter tabs: All / Capture / Highlight / Pen
- Item labels: C-1 (first capture), H-2 (second highlight), P-3 (third pen group)
- Click item to jump to source location in PDF or card in scrapnote
- Visual indicators: icons, thumbnails, text previews

**Implementation**:
- `sidebar/pages/providers/sidebar_provider.dart` - Filter state and item list
- `sidebar/pages/widgets/item_sidebar.dart` - Sidebar UI

**Benefits**:
- Quick navigation between captures and highlights
- Reduces need to scroll through PDF or scrapnote
- Visual categorization helps organize thoughts
- Source context preserved in labels

**Technical Considerations**:
- Item references maintained in registry (Hive-backed)
- Filtering logic in provider (pure function)
- Thumbnail generation for capture previews
- Real-time updates as items added/removed

## Design Patterns

### Provider Pattern (Riverpod)

All state is declared as providers, making the dependency graph explicit and testable.

```
workspaceProvider (top-level orchestrator)
├── pdfDocumentProvider (per-document state)
├── scrapnoteProvider (per-document state)
├── drawingProvider (tool state)
└── panelProvider (layout state)
```

### Model-View-ViewModel (Implicit)

Models define data structure, providers implement state logic, widgets render the view.

### Repository Pattern (Implicit)

Services (ScrapnoteService, PdfTextExtractor) hide data source details from providers.

### Factory Pattern (Tools)

ToolRegistry creates tool instances based on type enum, decoupling tool selection from implementation.

## Performance Optimization Notes

### Rendering Optimization
- Repaint boundaries on canvas widgets to limit re-renders
- Listener for stroke point updates (not rebuilds) to maintain 60fps
- Lazy-load PDF pages: only render visible pages
- Thumbnail caching for sidebar preview images

### Memory Management
- Provider caching via keepAlive for frequently accessed state
- Dispose providers when leaving feature screens
- Image caching for PDF and captured images
- Stroke point deduplication during rendering

### Search and Filtering
- Index-based quick access to items in sidebar
- Filter operations run in isolate for large datasets
- Incremental search with debounce for user input

### File I/O
- Async file operations via isolate
- Batch writes for multiple card insertions
- Compression for large scrapnote files

## Security Considerations

### Input Validation
- File paths validated before access
- PDF file size limits to prevent memory exhaustion
- Coordinate values clamped to valid ranges
- User input sanitized before serialization

### Data Privacy
- No analytics or telemetry
- No cloud transmission (local-only persistence)
- Sensitive data not logged in debug mode
- Temporary files cleaned up after use

### Platform Security
- Uses platform file picker for file selection
- Respects platform permission model
- No hardcoded credentials or API keys
- Follows Flutter security best practices

## Testing Strategy

### Unit Testing
- Model serialization/deserialization (json tests)
- Coordinate conversion functions
- Tool implementations and state updates
- Provider business logic

### Widget Testing
- Individual widget rendering and interaction
- Provider state updates via ProviderContainer
- Widget composition and layout
- Gesture handling (tap, drag, long-press)

### Integration Testing
- Full feature workflows (capture → insertion → sidebar update)
- Multi-panel interactions
- File I/O operations
- Cross-feature provider dependencies

### Test Coverage Target
- Minimum 85% code coverage per feature
- 100% coverage for models and utilities
- Critical paths (drawing, capture, insertion) require integration tests

## Build Configuration

### Platform-Specific Build Steps

**Android** (Android Studio or CLI)
```bash
flutter build apk --release
flutter build appbundle --release
```

**iOS** (Xcode or CLI)
```bash
flutter build ios --release
flutter build ipa --release
```

**macOS** (Xcode or CLI)
```bash
flutter build macos --release
flutter build dmg  # Creates installer
```

**Windows** (Visual Studio or CLI)
```bash
flutter build windows --release
flutter build msix --release  # Creates installer
```

**Linux** (Build tools or CLI)
```bash
flutter build linux --release
flutter build appimage --release  # Creates AppImage
```

**Web** (Browser)
```bash
flutter build web --release --dart2js-optimization O4
```

### Code Generation Before Build
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze  # Check for issues
flutter test     # Run tests
flutter build <platform> --release
```

## Version Management

### Semantic Versioning
- Major.Minor.Patch (e.g., 2.0.0-beta)
- Beta versions indicate feature-complete but not production-ready
- Stable releases require all SPEC features completed and tested

### Dependency Management
- pubspec.yaml pins all packages to compatible versions
- pubspec.lock ensures reproducible builds
- Upgrade strategy: test minor/patch upgrades before major
- Security updates applied immediately

### Release Checklist
1. Update version in pubspec.yaml
2. Update CHANGELOG.md with changes
3. Run full test suite
4. Code review and approval
5. Build all platform targets
6. Tag git commit with version
7. Create release notes
8. Push to app stores

## API Endpoints (If Applicable)

Currently: None. GMA SecPlan is fully local-first with no backend requirements.

Future considerations for collaboration features would introduce:
- Authentication endpoints
- Document sync endpoints
- Collaboration endpoints

## External Services (If Applicable)

Currently: None. GMA SecPlan operates entirely offline.

## Common Development Workflows

### Adding a New Feature Module
1. Create `features/new_feature/` directory structure
2. Define models with @freezed in `models/`
3. Create providers with @riverpod in `pages/providers/`
4. Build screens in `pages/screens/`
5. Create reusable widgets in `pages/widgets/`
6. Run `flutter pub run build_runner build`
7. Add tests in `test/features/new_feature/`

### Modifying Drawing Tools
1. Implement DrawingToolHandler interface in `drawing/tools/`
2. Add tool case to ToolRegistry
3. Update DrawingProvider to support new tool
4. Add tests in `test/features/drawing/tools/`
5. Update toolbar UI if needed

### Changing Coordinate System
1. Update PDF coordinate conversion in `pdf_viewer/utils/`
2. Update stroke serialization in `drawing/utils/`
3. Update scrapnote card positioning in `scrapnote/services/`
4. Run full test suite
5. Manual regression testing on all platforms

### Adding Platform Support
1. Add platform-specific configuration (android/, ios/, etc.)
2. Update file_system_provider.dart for platform paths
3. Update pubspec.yaml for platform-specific dependencies
4. Build and test on target platform
5. Update CI/CD pipeline

## Continuous Integration/Deployment

Recommended GitHub Actions workflow:
- Trigger: Pull requests and commits to main
- Steps:
  1. Checkout code
  2. Setup Flutter
  3. Get dependencies
  4. Generate code
  5. Run linter
  6. Run tests
  7. Build for target platforms
  8. Upload artifacts
