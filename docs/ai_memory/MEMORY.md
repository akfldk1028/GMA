# GMA Project Memory Index

## project/ - 프로젝트 정보
- [overview.md](project/overview.md) — LinkNote 앱 개요, 기술 스택, 완료 기능, 빌드 상태
- [architecture.md](project/architecture.md) — 노드형 모듈화 아키텍처 (n8n 패턴)
- [scrapnote_architecture.md](project/scrapnote_architecture.md) — ScrapNote 아키텍처: 마크다운 source of truth + 4가지 ElementType + 상호배제

## specs/ - UI/기능 기획안
- [home_ui.md](specs/home_ui.md) — Home UI 리워크 (3탭 아이콘 레일, 폴더, 휴지통)
- [scrapnote.md](specs/scrapnote.md) — ScrapNote 시스템 (Task 022~037 + 리디자인 4 Phase 완료)
- [note_ui_260316.md](specs/note_ui_260316.md) — 노트 UI 긴급용 (260316) Workspace 레이아웃+스크랩 플로우 20장
- [note_ui_progress.md](specs/note_ui_progress.md) — 구현 진행 상황 (Phase 1~4 완료, 버그 4건 수정)

## performance/ - 성능 최적화
- [pdf_region_rendering.md](performance/pdf_region_rendering.md) — PDF 영역 렌더링 viewport culling, 캐시 전략, 미적용 알고리즘

## user/ - 유저 정보
- [preferences.md](user/preferences.md) — 한국어, n8n 패턴, UI 기획안 준수, IDE 설정

## feedback/ - GMA 전용 피드백
- [white_theme.md](feedback/white_theme.md) — 배경 항상 흰색(라이트 테마), 다크 테마 금지
- [stability_first.md](feedback/stability_first.md) — 기본 기능 안정화 우선, 새 기능 전에 기존 기능 확인 필수
- [pdf_facing_layout.md](feedback/pdf_facing_layout.md) — PDF는 facing pages 레이아웃 필수 (1단독, 2-3쌍, 4-5쌍)
- [no_slow_agents.md](feedback/no_slow_agents.md) — 느린 Agent 서브프로세스 금지 (글로벌 CLAUDE.md에도 등록)
- [scrap_panel_direction.md](feedback/scrap_panel_direction.md) — 패널은 캡처/올가미만, 하이라이트/드로잉 제외, 패널 위 필기 가능, 임포트 가능
- [capture_wysiwyg.md](feedback/capture_wysiwyg.md) — 캡처 시 PDF + 필기 합성 필수 (WYSIWYG)
- [scrap_panel_no_pdf_rerender.md](feedback/scrap_panel_no_pdf_rerender.md) — 스크랩 패널에서 PDF 재렌더링 금지, 캡처 PNG만 표시
- [canvas_improvements.md](feedback/canvas_improvements.md) — 캔버스 100% 채우기, 카드 리사이즈, 올가미 투명, 사이드바 연동, contain 필수
- [canvas_sidebar_sync.md](feedback/canvas_sidebar_sync.md) — 캔버스↔사이드바 순서 동기화: 콜백 방식 (마크다운 경로 async 지연 문제)

## setup/ - 셋업 및 빌드
- [build_guide.md](setup/build_guide.md) — 클론→의존성→코드생성→빌드→실행 전체 가이드 (다른 컴퓨터용)
- [current_state.md](setup/current_state.md) — 현재 구현 완료 기능 + 활성 작업 상태 (2026-03-19)

## reference/ - 외부 참조
- [docs.md](reference/docs.md) — 핵심 문서 위치 (설계서, GMA-MD 스펙, UI 기획안 경로)
- [scrapnote_files.md](reference/scrapnote_files.md) — ScrapNote 핵심 파일 경로 (올가미, 어노테이션, 임포트 포함)
