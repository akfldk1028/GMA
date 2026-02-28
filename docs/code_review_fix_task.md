GMA Code Review Fix - Critical Issues (총 4개 자식 태스크로 분해)

전체 코드 리뷰 결과 발견된 버그/이슈를 수정한다. 아래 4개 영역으로 나누어 구현하라.
반드시 C:\DK\GMA\docs\PROJECT_DESIGN.md 와 C:\DK\GMA\frontend\CLAUDE.md 를 참고하라.

=== 자식 태스크 1: Critical - 컴파일 에러 + Dead Code 정리 ===
의존성: 없음 (가장 먼저 실행)

1. scrapnote_block.dart (line 6): `../stubs/element_stubs.dart` import가 존재하지 않음 → 실제 scrapnote 모델(element_model.dart, element_ref_parser.dart)을 import하도록 수정. elementStoreProvider 대신 실제 provider 사용. parseElementRef 대신 ElementRefParser.parse 사용.
2. element_card.dart (lines 13-44): private stub 타입들(_ElementType, _ScrapElement, _PdfRegistry)을 삭제하고 실제 모델(ScrapElement, ElementType, PdfRegistry)을 import하여 사용.
3. workspace_state_model.dart: 전체 파일 삭제 (dead code). workspace_state_model.freezed.dart, workspace_state_model.g.dart도 함께 삭제.
4. app_colors.dart: 전체 파일 삭제 (어디서도 import되지 않는 dead code).
5. container_block.dart (gma_md/models/): 전체 파일 삭제 (미사용 dead code).
6. container_block_parser.dart line 48-58: parseMetadata 메서드 삭제 (미사용).
7. 코드 생성 재실행: dart run build_runner build --delete-conflicting-outputs
8. flutter analyze --no-fatal-infos --no-fatal-warnings 통과 확인.

=== 자식 태스크 2: High - PdfMarker 모델 통합 + 마커 시스템 수정 ===
의존성: 태스크 1

1. PdfMarker 이중 모델 통합:
   - pdf_viewer/models/pdf_marker_model.dart의 PdfRect(x, y, width, height)와 workspace/models/pdf_marker_model.dart의 PdfRect(left, top, right, bottom) 불일치.
   - workspace 모델의 PdfRectConverter(pdfrx 네이티브 PdfRect 사용)를 표준으로 채택.
   - pdf_viewer/models/pdf_marker_model.dart를 삭제하고, 모든 import를 workspace 모델로 통일.
   - pdf_page_overlay.dart의 좌표 변환 로직 수정 (tr.x/tr.y/tr.width/tr.height → PdfRect 직접 사용).
   - marker_overlay_widget.dart, pdf_marker_provider.dart 등 모든 참조 파일 import 경로 수정.
2. workspace/pdf_marker_model.dart PdfRectConverter.fromJson (lines 16-19): `as double` → `(json['left'] as num).toDouble()` 로 수정. 4개 필드 모두.
3. marker_parser.dart (line 48): regex를 sub-number 지원하도록 수정: `r'^-\s+(🔴|🟡|🟢|🔵|🟣|🖊️)\s+P(\d+)(?:-(\d+))?(?:\s{2}(.+))?$'` (pen emoji 추가, sub-number 그룹 추가).
4. MarkerLineParseResult에 subNumber 필드 추가.
5. note_provider.dart line 103: 마커 ID를 매번 새로 생성하지 말고, 기존 마커와 매칭하여 ID 유지하는 로직 추가. pageNumber+text 조합으로 기존 마커 매칭.
6. marker_edit_modal.dart lines 236-248: editingMarkerId가 있을 때 createMarker 대신 updateMarker를 호출하도록 수정. WorkspaceProvider에 updateMarker 메서드가 없으면 추가.
7. pdf_marker_provider.dart: Hive index 기반 putAt/deleteAt를 marker.id 기반 put/delete로 변경.
8. 코드 생성 + flutter analyze 통과 확인.

=== 자식 태스크 3: High - 런타임 안정성 수정 ===
의존성: 태스크 1

1. workspace_screen.dart: dispose() 추가하여 _pdfController.dispose() 호출.
2. note_provider.dart lines 88-94: 에러 삼키기 대신 로깅 추가 + 빈 노트로 덮어쓰기 방지. catch에서 debugPrint로 에러 로깅. 파일이 존재하지만 읽기 실패한 경우 빈 content 반환하지 말고 에러 상태 유지.
3. note_storage_service.dart lines 56-64: Timer 콜백 안의 rethrow 제거. try-catch에서 debugPrint로 에러 로깅만 하고 rethrow하지 않기.
4. note_provider.dart line 115: ref.watch() → ref.read()로 변경.
5. latex_renderer.dart line 38: block LaTeX regex의 `[\s\S]+`를 `[\s\S]+?` (non-greedy)로 수정.
6. markdown_config.dart lines 93-97: 상대 경로 이미지(./captures/ 등) 처리 로직 추가. notesDir 기준으로 절대 경로 변환 후 Image.file() 사용.
7. wiki_link_renderer.dart line 100: TapGestureRecognizer를 stateful하게 관리하거나, dispose 가능하도록 수정.
8. file_browser_drawer.dart, marker_edit_modal.dart, note_editor_modal.dart: _close() 메서드에서 animation reverse 후 mounted 체크 추가.
9. theme_provider.dart line 27: Hive.box() 호출을 try-catch로 감싸기.
10. pdf_viewer_screen.dart line 172: await 후 mounted 체크 추가.
11. app_router.dart: @Riverpod(keepAlive: true) 추가하여 GoRouter dispose 방지.
12. note_list_provider.dart line 72: 원본 리스트 sort 대신 [...notes].sort() 사용.
13. timeline_block.dart line 79: dynamic → TimelineEvent 타입으로 변경.
14. flutter analyze 통과 확인.

=== 자식 태스크 4: Medium - 성능 + 코드 품질 ===
의존성: 태스크 2, 태스크 3

1. flow_canvas_painter.dart, graph_canvas_painter.dart, mindmap_canvas_painter.dart: shouldRepaint가 항상 true 반환 → 이전 데이터와 비교하여 변경 시에만 true 반환.
2. stroke_painter.dart line 23: saveLayer를 eraser stroke가 존재할 때만 사용하도록 조건 추가.
3. drawing_provider.dart: _autoSave에 500ms 디바운싱 추가 (Timer 사용).
4. capture_service.dart lines 53,58: pdfImage.dispose()와 uiImage.dispose()를 try-finally 블록으로 이동.
5. drawing_serializer.dart line 53: 파일 경로에 path.join 사용.
6. pdf_document_provider.dart: currentPdfPage provider가 controller 페이지 변경을 감지하도록 수정.
7. note_editor_provider.dart lines 208-228: _computeSubNumber regex에 마커 라인 앵커(이모지 프리픽스) 추가.
8. scrapnote_provider.dart: stub 메서드들에 TODO 주석 추가 (향후 구현 예정 명시).
9. settings_screen.dart lines 131-133: auto-save toggle를 실제 Hive 설정과 연결하거나, 미구현 표시.
10. app_theme.dart: textTheme 중복 제거 (static final로 공유). getter를 static final로 변경.
11. flutter analyze 통과 확인.
