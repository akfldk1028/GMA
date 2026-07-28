# SOK Note — Note 편집 화면 GUI 프로토타입

Flutter 개발자 핸드오프용 HTML/CSS 프로토타입입니다.

## 시작하기

`index.html`을 브라우저에서 바로 열면 됩니다. 별도 서버 불필요.

이 폴더는 `GUI/shared/`의 디자인 토큰·공용 컴포넌트를 그대로 참조합니다.
이 폴더만 따로 옮기면 `../../shared/...` 상대경로가 깨지니, 공유할 때는
반드시 `GUI` 폴더 전체를 함께 전달하세요. (자세한 내용은 [GUI/CLAUDE.md](../../CLAUDE.md) 참고)

## 폴더 구조

```
GUI/
├── CLAUDE.md                       # 디자인 시스템 규칙 (모든 화면 폴더 공통)
├── shared/
│   ├── css/
│   │   ├── reset.css
│   │   ├── tokens.css
│   │   ├── layout.css              # device-frame, app-shell 등 공용 셸
│   │   ├── components.css          # icon-btn, chip, overflow-menu 등 공용 컴포넌트
│   │   └── note-editor.css         # 이 화면(Note) 전용 레이아웃/컴포넌트
│   └── assets/
└── Note/soknote-note-prototype/    # 이 화면(노트 편집) 폴더
    ├── index.html                  # 진입점 — shared/ 참조
    ├── js/
    │   └── main.js                 # 더보기 메뉴 / AI Agent 패널 / 도구 선택 상태 전환
    ├── screens/
    │   └── note.html               # 화면 컴포넌트 조합 참고
    └── components/                 # 컴포넌트별 HTML 조각
        ├── rail.html
        ├── topbar.html
        ├── toolbar.html
        ├── note-page.html
        ├── scraps-panel.html
        └── ai-agent-panel.html
```

## 상태 전환 (JS)

| 트리거 | 상태 |
|--------|------|
| 툴바 `⋮` (더 보기) 클릭 | 드롭다운 메뉴 열림/닫힘 (`overflow-menu--open`) |
| 툴바 `✨` (AI Agent) 클릭 | 우측 노트 영역 위에 AI Agent 플로팅 패널 열림 (`ai-agent--active`, Scraps 뷰는 뒤에 유지) |
| AI Agent 패널의 `×` 클릭 | 플로팅 패널 닫힘 |
| 좌측 레일 탭 클릭 | 선택된 탭 활성화 표시 |
| 색상 스와치 / 굵기 도트 클릭 | 선택 상태 표시 |

## 디자인 토큰 수정

`../../shared/css/tokens.css`의 `:root` 변수만 바꾸면 GUI 폴더 안의 모든 화면에
색상·간격이 일괄 적용됩니다. (다른 화면 폴더에도 영향을 주니 수정 시 유의)

## 컴포넌트 교체 방법

1. `components/` 안의 해당 `.html` 파일을 수정
2. `index.html`의 같은 마크업 블록을 붙여넣기
3. 공용 컴포넌트(`icon-btn`, `chip`, `overflow-menu`, `color-swatch`, `size-dot`)는
   `../../shared/css/components.css`에서, 이 화면 전용 레이아웃은
   `../../shared/css/note-editor.css`에서 스타일 수정

## CSS 클래스 규칙 (BEM 기반)

- 블록: `note-shell`, `note-content`, `note-rail`, `note-topbar`, `note-tab`, `note-toolbar__group`, `note-page`, `note-panel`, `ai-agent`
- 요소: `note-toolbar__group`, `note-panel__header`, `ai-agent__footer`
- 상태: `note-rail__tab--active`, `overflow-menu--open`, `ai-agent--active`
