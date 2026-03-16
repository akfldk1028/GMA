# GMA SecPlan Technology Stack & Architecture

## Technology Stack Summary

| Category | Package | Version | Purpose |
|----------|---------|---------|---------|
| **UI Framework** | Flutter | 3.24+ | Cross-platform application framework |
| **UI Components** | shadcn_ui | ^0.45.1 | ShadCN design system |
| **State Management** | flutter_riverpod | ^2.6.1 | Declarative, composable provider pattern |
| **State Gen** | riverpod_annotation | ^2.6.1 | Annotation-based provider generation |
| **Routing** | go_router | ^14.6.2 | Declarative router |
| **PDF Rendering** | pdfrx | ^2.2.0 | PDF viewer with text extraction |
| **Local Storage** | hive_flutter | ^1.1.0 | NoSQL embedded database (3 boxes) |
| **Model Framework** | freezed_annotation | ^2.4.4 | Immutable model generation |
| **JSON Serialization** | json_annotation | ^4.9.0 | JSON serialization codegen |
| **Drawing** | perfect_freehand | ^2.5.2 | Normalized freehand stroke algorithm |
| **File Access** | path_provider | ^2.1.4 | Application directory paths |
| **File Picking** | file_picker | ^8.1.6 | Platform file selection |
| **HTTP** | http | ^1.2.0 | HTTP client for API calls |
| **UUID** | uuid | ^4.5.1 | Unique identifier generation |
| **Path Manipulation** | path | ^1.9.0 | Cross-platform path handling |
| **Debug Tools** | marionette_flutter | ^0.3.0 | Debug overlay (dev only) |
| **Code Gen** | build_runner | ^2.4.13 | Code generation framework |
| **Freezed Gen** | freezed | ^2.5.7 | Model code generation |
| **Serialization Gen** | json_serializable | ^6.8.0 | JSON codegen |
| **Riverpod Gen** | riverpod_generator | ^2.6.2 | Provider codegen |

## Dart Ecosystem Details

**Dart SDK**: ^3.10.8 (null safety, records, patterns enabled)
**Flutter SDK**: 3.24+ with Material 3 support
**Build System**: pub (package manager), build_runner (code generation)

## Architecture Decisions & Rationale

### 1. Dual-Panel Architecture

**Design Pattern**: Two independent document viewers in a single workspace with a resizable divider

**Structure**:
- Left Panel (default): PDF Viewer with drawing overlay
- Right Panel (default): Scrapnote Canvas (A4 pages or infinite scroll)
- Shared Toolbar: One drawing toolbar applies to whichever panel has focus
- Panel Controls: Swap positions, resize with divider, maximize single panel

**Benefits**:
- Seamless annotation workflow without context switching
- Equal document status: PDF and Note are both first-class
- Auto-insertion: Captures and highlights flow automatically to scrapnote
- Familiar UI: Samsung Notes experience with A4 pages

**Implementation**:
- workspaceProvider orchestrates both panels
- Each panel has dedicated providers (pdfDocumentProvider, scrapnoteProvider)
- Shared drawing toolbar managed at workspace level
- Panel layout state persisted in Hive

### 2. Auto-Insertion Workflow

**Pattern**: PDF capture/highlight operations automatically create cards in linked scrapnote

**Flow**:
1. User captures region or selects text on PDF
2. Capture/highlight provider creates card object
3. Workspace provider inserts card into active scrapnote
4. Sidebar provider adds item reference (C-n, H-n)
5. No confirmation dialog needed (or minimal 30s popup)

**Benefits**:
- Reduces friction in annotation workflow
- Maintains context (source page and rect preserved)
- Cards can be reordered/deleted in scrapnote
- Sidebar provides navigation back to source

**Implementation Files**:
- `pdf_viewer/pages/providers/capture_provider.dart`
- `workspace/pages/providers/workspace_provider.dart`
- `scrapnote/pages/providers/scrapnote_provider.dart`

### 3. State Management: Riverpod with Annotations

**Why Riverpod?**
- Immutable, testable provider pattern
- Type-safe dependency injection
- Declarative async handling with AsyncValue
- Family modifiers for parameterized state

**Provider Architecture**:
- Main Orchestrator: `workspaceProvider` coordinates both panels
- Feature Providers:
  - `pdfDocumentProvider` - PDF state (document, current page, zoom)
  - `drawingProvider` - Drawing state (tool, color, thickness, strokes)
  - `captureProvider` - Capture state (selection rect, preview)
  - `scrapnoteProvider` - Scrapnote state (pages, cards, strokes)
  - `sidebarProvider` - Sidebar filter state (All/Capture/Highlight/Pen)

**Pattern Example**:
```dart
@riverpod
Future<PdfDocument> pdfDocument(PdfDocumentRef ref) async {
  // Load PDF document
  return await pdfrx.loadPdf(filePath);
}

@riverpod
class Drawing extends _$Drawing {
  @override
  DrawingState build() => DrawingState.initial();

  void addStroke(Stroke stroke) {
    state = state.copyWith(strokes: [...state.strokes, stroke]);
  }
}
```

### 4. Scrapnote Canvas: A4 Pages with Drawing

**Page Model**:
- Default: A4 fixed pages (210mm × 297mm)
- Option: Infinite vertical scroll
- Per-note setting (stored in scrapnote file)

**Canvas Elements**:
- Strokes: Free pen drawing data (normalized 0-1 coordinates)
- Cards: Capture (image) and Highlight (text) cards with positioning
- Text blocks: Free text areas with editable content

**Drawing on Scrapnote**:
- Shared pen/highlighter/eraser tools
- Strokes normalized to 0-1 coordinates
- Serialized as JSON in scrapnote file
- Independent from PDF drawing (separate layer)

**Rendering**:
- CustomPaint for A4 page backgrounds
- Card widgets for inserted content
- Stroke painter for drawing strokes
- Page break at A4 boundary (optional)

### 5. PDF Coordinate System: Normalized (0-1)

**All coordinate operations use 0-1 range**:
- PDF text selection: `textRect` normalized to page dimensions
- Drawing strokes: `point.dx` and `point.dy` in range [0, 1]
- Region captures: Bounding box stored as normalized coordinates
- Text highlight: Stored with normalized position on page

**Benefits**:
- Resolution independent (works across screen sizes)
- Portable (coordinates valid after PDF rendering at any resolution)
- Prevents precision loss from pixel-based coordinates
- Easy to scale to different screen densities

**Implementation**:
- `pdf_viewer/utils/coordinate_converter.dart` handles conversion
- `DrawingModel` stores strokes with normalized points
- `CaptureRegion` bounding box in normalized coordinates

### 6. Drawing System: Normalized Strokes with perfect_freehand

**Workflow (v2 Architecture)**:
1. User draws on screen → raw pixels captured by gesture detector
2. Stroke collection: Raw points accumulated via DrawingCanvas.onPointerMove
3. Normalization: Transform to 0-1 range via coordinate converter
4. Tool Processing: DrawingToolHandler (pen, highlighter, eraser) processes points
5. Path Generation: perfect_freehand `getStroke()` creates smooth outline path
6. Serialization: `DrawingSerializer.toJson()` creates JSON
7. Rendering: `StrokePainter.paint()` via CustomPainter at target resolution
8. Storage: JSON serialization for persistence

**Drawing Feature (Separate Module - NEW SPEC-PDF-001)**:
- `drawing/models/drawing_model.dart` - DrawingStroke, StrokePoint (freezed, immutable)
- `drawing/tools/drawing_tool_handler.dart` - Abstract base class for tool plugins
- `drawing/tools/pen_tool.dart` - Opaque pressure-sensitive pen strokes
- `drawing/tools/highlighter_tool.dart` - Semi-transparent wide strokes
- `drawing/tools/eraser_tool.dart` - Hit-test based stroke removal
- `drawing/tools/tool_registry.dart` - Dynamic tool registration singleton
- `drawing/pages/providers/drawing_provider.dart` - Drawing mode + strokes + undo/redo state
- `drawing/pages/widgets/drawing_canvas.dart` - Pointer event capture and tool delegation
- `drawing/pages/widgets/drawing_overlay.dart` - Per-page overlay builder
- `drawing/pages/widgets/stroke_painter.dart` - CustomPainter rendering
- `drawing/pages/widgets/drawing_toolbar.dart` - Panel-aware shared toolbar
- `drawing/utils/drawing_serializer.dart` - JSON persistence

**Architecture Highlights**:
- Drawing is a standalone feature shared between PDF panel and Scrapnote panel
- DrawingToolHandler plugin interface enables future tool extensions (Rectangle Select, Capture, Highlight tools in future SPECs)
- Per-page stroke storage: `Map<int, List<DrawingStroke>>` for efficient rendering
- Undo/redo support with max 50 stroke depth
- Panel-aware toolbar reads `focusedPanel` state to route actions to active panel provider

**perfect_freehand Library**:
- Applies smoothing algorithm to create natural strokes
- Handles pressure sensitivity (if available)
- Produces consistent output across devices

### 7. Scrapnote Persistence: Custom JSON Format

**File Format**: `.scrapnote` files (actually JSON with metadata)

**Structure**:
```dart
{
  id: UUID string,
  title: Scrapnote title,
  pageMode: "a4" | "infinite",
  linkedPdfPath: Path to associated PDF,
  pages: [
    {
      pageNumber: int,
      strokes: [
        {
          id: UUID,
          points: [[0.1, 0.2], [0.15, 0.25], ...],
          color: 0xFF000000,
          thickness: 2.0,
          tool: "pen"
        }
      ],
      cards: [
        {
          id: UUID,
          type: "capture" | "highlight",
          x: 0.1, y: 0.15,
          width: 0.8, height: 0.5,
          imagePath: "...",  // capture only
          selectedText: "...", // highlight only
          sourcePageNumber: 3,
          sourceRect: {left, top, right, bottom}
        }
      ],
      textBlocks: [...]
    }
  ],
  createdAt: ISO datetime,
  modifiedAt: ISO datetime
}
```

**Persistence**:
- Saved to filesystem in documents directory
- Serialized using `json_serializable` codegen
- Hive stores document metadata in registry

### 8. Sidebar Navigator: Item References

**Item Types**:
- C-n: Capture items with thumbnail preview
- H-n: Highlight items with text snippet
- P-n: Pen stroke groups

**Data Model**:
```dart
{
  id: UUID,
  type: "capture" | "highlight" | "pen",
  label: "C-1" or "H-1" or "P-1",
  sourcePageNumber: int,
  sourceRect: {left, top, right, bottom}?,
  linkedCardId: UUID? (ref to card in scrapnote)
}
```

**Navigation**:
- Click item → Jump to source page in PDF
- Show source location (highlighted or outlined)
- Sync with sidebar filter (All/Capture/Highlight/Pen)

## Development Environment Requirements

### Local Setup

**Required**:
- Dart SDK: ^3.10.8
- Flutter SDK: 3.24+ (stable channel)
- Git (version control)

**Optional**:
- Android SDK (for Android builds)
- Xcode (for iOS builds)
- Visual Studio Build Tools (for Windows)

### Code Generation Workflow

```bash
# After modifying @freezed models or @riverpod providers
cd frontend_v2
dart run build_runner build --delete-conflicting-outputs

# Watch mode for active development
dart run build_runner watch
```

### Validation Commands

```bash
# Linting
dart analyze --no-fatal-infos

# Formatting
dart format lib test

# Testing
flutter test

# Platform-specific builds
flutter build windows  # Windows executable
flutter build apk      # Android APK
flutter build ios      # iOS app
```

## Build Configuration

### Windows (Primary Platform)

**CMake-based build** with Flutter embedding:
- `windows/runner/CMakeLists.txt` → Configures native build
- `windows/runner/main.cpp` → Application entry point
- `windows/runner/flutter_window.cpp` → Window initialization

### Android

**Gradle build** with Material design:
- `android/app/build.gradle.kts` → App configuration
- `android/app/src/main/AndroidManifest.xml` → Permissions
- `android/app/src/main/kotlin/MainActivity.kt` → Activity entry point

### iOS

**Xcode project** with CocoaPods:
- `ios/Podfile` → Pod dependencies
- `ios/Runner.xcodeproj/` → Build configuration
- `ios/Runner/Info.plist` → App metadata

### macOS

**Native macOS support** via Xcode:
- `macos/Runner.xcodeproj/` → Build project
- `macos/Runner/Info.plist` → System preferences

### Linux

**GTK-based** with CMake:
- `linux/CMakeLists.txt` → Build configuration
- Integration with system libraries

## Design Patterns Summary

| Pattern | Usage | Example |
|---------|-------|---------|
| **Provider** | State management | workspaceProvider, scrapnoteProvider |
| **Freezed** | Immutable models | ScrapnoteModel, CaptureCard, Stroke |
| **Normalized Coordinates** | Resolution independence | Drawing strokes in 0-1 range |
| **CustomPaint** | Canvas rendering | A4 page background, stroke painter |
| **Family Modifiers** | Parameterized state | PDF document by file path |

## Performance Optimization

### Token Budget (State Size)
- Minimize Riverpod provider dependencies
- Use `.select()` to watch specific fields only
- Implement `.keepAlive: true` for global providers

### Memory Management
- Dispose drawing provider after workspace changes
- Clear scrapnote cache periodically
- Limit PDF page cache (pdfrx configuration)

### UI Rendering
- Use `const` constructors throughout
- Implement `RepaintBoundary` for complex CustomPaint
- Lazy-load card widgets with visibility detection

## Security Considerations

**Local-Only Storage**:
- No credential transmission (all operations local)
- Hive boxes stored in platform-specific app directories
- No analytics or telemetry

**Input Validation**:
- File paths validated to prevent directory traversal
- JSON deserialization validates structure
- Stroke data validates coordinate ranges (0-1)

## Testing Strategy

**Coverage Target**: 85%

**Test Organization**:
- **Unit Tests**: Model serialization, utilities, parsers
- **Integration Tests**: Feature workflows (capture, highlight, drawing)
- **E2E Tests**: Full PDF→Scrapnote→PDF roundtrip

**Key Test Files**:
- `test/features/pdf_viewer/drawing_model_test.dart`
- `test/features/scrapnote/card_model_test.dart`
- `test/features/scrapnote/stroke_serializer_test.dart`
- `test/e2e/capture_workflow_test.dart`
- `test/e2e/highlight_workflow_test.dart`

## Version Management

**Dart/Flutter Versions**:
- Dart: ^3.10.8 (enforced in `pubspec.yaml`)
- Flutter: 3.24+ (implicit through SDK constraints)
- Updates via `flutter upgrade` command

**Dependency Management**:
- `pubspec.lock` ensures reproducible builds
- Run `flutter pub upgrade` carefully
- Run `flutter pub get` after lock file changes
