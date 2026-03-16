# 07. 드로잉 시스템 — 펜/형광펜/지우개

## 파일 구조
```
lib/features/pdf_viewer/drawing/
├── models/
│   └── drawing_model.dart         — DrawingStroke, DrawingState (Freezed)
├── pages/
│   ├── providers/
│   │   └── drawing_provider.dart  — 드로잉 상태 관리 (모드, 활성도구)
│   └── widgets/
│       ├── drawing_toolbar.dart   — 도구 선택 UI (펜/형광펜/지우개/완료)
│       ├── drawing_overlay.dart   — PdfViewer 페이지 위 투명 캔버스
│       ├── drawing_canvas.dart    — 터치 입력 → 스트로크 변환
│       └── stroke_painter.dart    — CustomPainter (스트로크 렌더링)
├── tools/
│   ├── drawing_tool_handler.dart  — 인터페이스 (플러그인 패턴)
│   ├── tool_registry.dart         — 도구 레지스트리 (1줄 추가로 새 도구)
│   ├── pen_tool.dart              — 펜 도구 구현
│   ├── highlighter_tool.dart      — 형광펜 도구 구현
│   └── eraser_tool.dart           — 지우개 도구 구현
└── utils/
    └── drawing_serializer.dart    — 스트로크 직렬화/역직렬화
```

## 플러그인 패턴 (n8n 스타일)
새 드로잉 도구 추가 = 1파일 생성 + tool_registry.dart에 1줄 추가.
```dart
// tool_registry.dart
final toolHandlers = <DrawingToolHandler>[
  PenTool(),
  HighlighterTool(),
  EraserTool(),
  // NewTool(),  ← 여기에 1줄 추가
];
```

## DrawingToolbar 위치
- `externalToolbar=false` (단독 PdfViewer): PDF 뷰어 내부 상단 중앙
- `externalToolbar=true` (workspace): Header 아래 독립 행 (workspace_screen.dart)

## 드로잉 → 마커 연동
스트로크 완료 → `_handleDrawingStrokeAdded()` → PDF 텍스트 추출 → `createDrawingMarker()`

## 수정 시 주의사항
- 드로잉 모드 ON → 캡처 모드 자동 OFF (상호 배타)
- 드로잉/캡처 활성 시 텍스트 선택 비활성화
- 스트로크는 noteId + pageNumber별로 저장됨
