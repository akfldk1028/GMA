# GMA — PDF 좌표 연동 Markdown 메모 앱

PDF 텍스트 선택 → 마커 → Markdown 노트 삽입, 마커 클릭 → PDF 페이지 점프.
단순 뷰어/에디터가 아닌 **양방향 연동**이 핵심 가치.

## 구조

- `frontend/` — Flutter 앱 (Windows Desktop)
- `frontend/vendor/opendataloader-pdf/` — PDF 텍스트/구조 추출 서브모듈
- 상세 설계: @docs/PROJECT_DESIGN.md

## 소통

- 사용자 응답: **한국어**, 간결하게 (반말 OK)
- 코드/커밋: 영어

## IMPORTANT: 코드 수정 규칙

1. 수정 전 **관련 코드 경로 전부** grep으로 찾고, 실행 순서를 trace
2. Riverpod state 변경 / `invalidate`는 **반드시 provider 안에** 유지
3. 리팩토링은 한 단계씩 + 즉시 동작 확인. 통째로 추출 금지
4. 수정 → `flutter analyze` → `flutter run -d windows` → 실제 동작 확인 → 다음 수정

## 벤더 우선순위

PDF 텍스트/구조 추출 시 **vendor/opendataloader-pdf 우선**. pdfrx는 뷰어 렌더링만.
Java 미설치 시 에러 표시 (pdfrx fallback 안 함 — 품질 차이 큼).

## Hive 저장소

- `Hive.init(getApplicationSupportDirectory())` 사용 (AppData/Local)
- `Hive.initFlutter()` **금지** → OneDrive .lock 충돌

<!-- 
유지보수 메모 (context에 포함 안 됨):
- 이 파일은 30줄 이하 유지. 상세 규칙은 frontend/CLAUDE.md와 .claude/rules/ 참조
- 공식 문서: https://code.claude.com/docs/en/memory
-->
